#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'HELP'
Uso:
  ./deploy.sh (--remoto | --locale | --apk) [opzioni]

Descrizione:
  Builda il progetto Maven, carica il WAR su server remoto via sshpass/scp
  e lo deploya in Tomcat con staging remoto.

Opzioni:
  --remoto                Esegue deploy remoto
  --locale                Esegue deploy locale su Tomcat
  --apk                   Genera APK Android debug (senza installazione)
  --android-url <url>     URL backend per build APK (FISIO_SPORT_BASE_URL)
  --apk-prefix <prefix>   Prefisso nome APK generato (es: test)
  --apk-test              Profilo test LAN (prefix: test, server: 192.168.1.16, overlay rosso)
  --local-server <host>    Host locale per URL finale (default: localhost)
  --local-port <port>      Porta locale Tomcat per URL finale (default: 8080)
  --host <host>            Host remoto (default: 31.70.74.92)
  --user <user>            Utente SSH (default: root)
  --password <password>    Password SSH (default: preconfigurata nello script)
  --port <port>            Porta SSH (default: 22)
  --remote-path <path>     Cartella deploy remota (default: ~/)
  --tomcat-webapps <path>  Cartella webapps Tomcat (default: /opt/tomcat/webapps)
  --with-sql              Carica anche gli script SQL su server remoto
  --remote-sql-path <p>   Cartella remota per script SQL (default: /root/sql-scripts)
  --war <path>             WAR locale da deployare (default: ultimo in target/)
  --skip-build             Salta mvn clean package
  --help                   Mostra questo aiuto

Esempi:
  ./deploy.sh --remoto
  ./deploy.sh --locale
  ./deploy.sh --locale --tomcat-webapps /home/simone/apache-tomcat-9.0.112/webapps
  ./deploy.sh --remoto --with-sql
  ./deploy.sh --remoto --with-sql --remote-sql-path /root/sql-scripts
  ./deploy.sh --apk
  ./deploy.sh --apk --apk-test
  ./deploy.sh --apk --apk-prefix test --android-url http://192.168.1.16:8080/Fisio-e-Sport-webapp
  ./deploy.sh --apk --android-url http://31.70.74.92:8080/Fisio-e-Sport-webapp
  ./deploy.sh --password '***'
HELP
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Errore: comando richiesto non trovato: $1" >&2
    exit 1
  fi
}

HOST="31.70.74.92"
USER="root"
REMOTE_PASSWORD_DEFAULT="b6vTvLSce98iLra"
PASSWORD="${DEPLOY_SSH_PASSWORD:-$REMOTE_PASSWORD_DEFAULT}"
PORT="22"
REMOTE_PATH="~/"
TOMCAT_WEBAPPS_PATH="/opt/tomcat/webapps"
REMOTE_SQL_PATH="/root/sql-scripts"
LOCAL_WEBAPPS_DEFAULT="/home/simone/apache-tomcat-9.0.112/webapps"
LOCAL_SERVER="localhost"
LOCAL_PORT="8080"
APK_OUTPUT_DIR="/home/simone/Scaricati"
WAR_PATH=""
SKIP_BUILD="false"
WITH_SQL="false"
MODE=""
ANDROID_URL=""
ANDROID_URL_EXPLICIT="false"
APK_PREFIX=""
APK_TEST_MODE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remoto)
      MODE="remoto"
      shift
      ;;
    --apk)
      MODE="apk"
      shift
      ;;
    --locale)
      MODE="locale"
      shift
      ;;
    --android-url)
      ANDROID_URL="${2:-}"
      ANDROID_URL_EXPLICIT="true"
      shift 2
      ;;
    --apk-prefix)
      APK_PREFIX="${2:-}"
      shift 2
      ;;
    --apk-test)
      APK_TEST_MODE="true"
      shift
      ;;
    --local-server)
      LOCAL_SERVER="${2:-}"
      shift 2
      ;;
    --local-port)
      LOCAL_PORT="${2:-}"
      shift 2
      ;;
    --host)
      HOST="${2:-}"
      shift 2
      ;;
    --user)
      USER="${2:-}"
      shift 2
      ;;
    --password)
      PASSWORD="${2:-}"
      shift 2
      ;;
    --port)
      PORT="${2:-}"
      shift 2
      ;;
    --remote-path)
      REMOTE_PATH="${2:-}"
      shift 2
      ;;
    --tomcat-webapps)
      TOMCAT_WEBAPPS_PATH="${2:-}"
      shift 2
      ;;
    --with-sql)
      WITH_SQL="true"
      shift
      ;;
    --remote-sql-path)
      REMOTE_SQL_PATH="${2:-}"
      shift 2
      ;;
    --war)
      WAR_PATH="${2:-}"
      shift 2
      ;;
    --skip-build)
      SKIP_BUILD="true"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Argomento non riconosciuto: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$MODE" != "remoto" && "$MODE" != "locale" && "$MODE" != "apk" ]]; then
  echo "Errore: devi specificare --remoto, --locale o --apk." >&2
  usage
  exit 1
fi

if [[ "$MODE" == "apk" ]]; then
  ANDROID_DIR="android-app"
  APK_DIR="${ANDROID_DIR}/app/build/outputs/apk/debug"
  BASE_APK_NAME="FisioESport.apk"
  LAN_TEST_URL="http://192.168.1.16:8080/Fisio-e-Sport-webapp"

  if [[ ! -d "$ANDROID_DIR" ]]; then
    echo "Errore: cartella Android non trovata: $ANDROID_DIR" >&2
    exit 1
  fi

  if [[ "$APK_TEST_MODE" == "true" ]]; then
    if [[ "$ANDROID_URL_EXPLICIT" != "true" ]]; then
      ANDROID_URL="$LAN_TEST_URL"
      ANDROID_URL_EXPLICIT="true"
    fi
    if [[ -z "$APK_PREFIX" ]]; then
      APK_PREFIX="test"
    fi
  fi

  if [[ "$ANDROID_URL_EXPLICIT" == "true" ]]; then
    echo ">> Build APK con backend URL: $ANDROID_URL"
    (
      cd "$ANDROID_DIR"
      if [[ "$APK_TEST_MODE" == "true" ]]; then
        ./gradlew assembleDebug "-PFISIO_SPORT_BASE_URL=${ANDROID_URL}" -PFISIO_SPORT_TEST_OVERLAY=true -PFISIO_SPORT_TEST_APP=true
      else
        ./gradlew assembleDebug "-PFISIO_SPORT_BASE_URL=${ANDROID_URL}"
      fi
    )
  else
    echo ">> Build APK con configurazione di default"
    (
      cd "$ANDROID_DIR"
      if [[ "$APK_TEST_MODE" == "true" ]]; then
        ./gradlew assembleDebug -PFISIO_SPORT_TEST_OVERLAY=true -PFISIO_SPORT_TEST_APP=true
      else
        ./gradlew assembleDebug
      fi
    )
  fi

  APK_FILE="${APK_DIR}/${BASE_APK_NAME}"
  if [[ -z "$APK_FILE" || ! -f "$APK_FILE" ]]; then
    echo "Errore: APK non trovato dopo la build in: $APK_FILE" >&2
    exit 1
  fi

  mkdir -p "$APK_OUTPUT_DIR"

  DEST_APK="${APK_OUTPUT_DIR%/}/${BASE_APK_NAME}"
  cp -f "$APK_FILE" "$DEST_APK"
  APK_FILE="$DEST_APK"
  APK_ABS_PATH="$(cd "$(dirname "$APK_FILE")" && pwd)/$(basename "$APK_FILE")"

  if [[ -n "$APK_PREFIX" ]]; then
    APK_BASENAME="$(basename "$DEST_APK")"
    PREFIXED_APK="${APK_OUTPUT_DIR%/}/${APK_PREFIX}-${APK_BASENAME}"
    cp -f "$DEST_APK" "$PREFIXED_APK"
    APK_FILE="$PREFIXED_APK"
    APK_ABS_PATH="$(cd "$(dirname "$APK_FILE")" && pwd)/$(basename "$APK_FILE")"
  fi

  echo ">> APK generato: $APK_FILE"
  echo ">> Percorso filesystem: $APK_ABS_PATH"
  exit 0
fi

require_cmd mvn

if [[ "$SKIP_BUILD" != "true" ]]; then
  echo ">> Build Maven: mvn clean package"
  mvn clean package
fi

if [[ -z "$WAR_PATH" ]]; then
  WAR_PATH="$(ls -t target/*.war 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "$WAR_PATH" || ! -f "$WAR_PATH" ]]; then
  echo "Errore: nessun file WAR trovato. Specifica --war oppure esegui la build." >&2
  exit 1
fi

WAR_NAME="$(basename "$WAR_PATH")"
APP_CONTEXT="${WAR_NAME%.war}"

echo ">> WAR selezionato: $WAR_PATH"

if [[ "$MODE" == "locale" ]]; then
  if [[ "$TOMCAT_WEBAPPS_PATH" == "/opt/tomcat/webapps" ]]; then
    TOMCAT_WEBAPPS_PATH="$LOCAL_WEBAPPS_DEFAULT"
  fi

  echo ">> Deploy locale in Tomcat webapps: $TOMCAT_WEBAPPS_PATH"
  mkdir -p "$TOMCAT_WEBAPPS_PATH"
  cp -f "$WAR_PATH" "${TOMCAT_WEBAPPS_PATH%/}/$WAR_NAME"
  find "$TOMCAT_WEBAPPS_PATH" -maxdepth 1 -type f -name "${APP_CONTEXT}*.war" ! -name "$WAR_NAME" -delete

  echo ">> Cartella esplosa ${TOMCAT_WEBAPPS_PATH%/}/${APP_CONTEXT} non rimossa manualmente (gestita da Tomcat)."
  echo ">> Deploy locale completato."
  echo ">> URL applicativo: http://${LOCAL_SERVER}:${LOCAL_PORT}/${APP_CONTEXT}/"
  if [[ "$APP_CONTEXT" == "ROOT" ]]; then
    echo ">> URL applicativo: http://${LOCAL_SERVER}:${LOCAL_PORT}/"
  fi
  exit 0
fi

require_cmd sshpass
require_cmd ssh
require_cmd scp

if [[ -z "$PASSWORD" ]]; then
  echo "Errore: password SSH mancante. Usa --password o DEPLOY_SSH_PASSWORD." >&2
  exit 1
fi

TARGET="${USER}@${HOST}"
SSH_OPTS=(-o StrictHostKeyChecking=accept-new -p "$PORT")
SCP_OPTS=(-o StrictHostKeyChecking=accept-new -P "$PORT")
echo ">> Verifico cartella remota: $REMOTE_PATH"
sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$TARGET" "mkdir -p ${REMOTE_PATH}"

echo ">> Upload WAR verso ${TARGET}:${REMOTE_PATH}/"
sshpass -p "$PASSWORD" scp "${SCP_OPTS[@]}" "$WAR_PATH" "$TARGET:${REMOTE_PATH%/}/$WAR_NAME"

echo ">> Deploy WAR in Tomcat webapps: $TOMCAT_WEBAPPS_PATH"
sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$TARGET" "
  set -e
  mkdir -p '$TOMCAT_WEBAPPS_PATH'
  cp -f ${REMOTE_PATH%/}/$WAR_NAME '${TOMCAT_WEBAPPS_PATH%/}/$WAR_NAME'
  find '$TOMCAT_WEBAPPS_PATH' -maxdepth 1 -type f -name '${APP_CONTEXT}*.war' ! -name '$WAR_NAME' -delete
"

if [[ "$WITH_SQL" == "true" ]]; then
  shopt -s nullglob
  SQL_FILES=(src/main/resources/*.sql)
  shopt -u nullglob

  if [[ ${#SQL_FILES[@]} -eq 0 ]]; then
    echo ">> Nessuno script SQL trovato in src/main/resources."
  else
    echo ">> Verifico cartella SQL remota: $REMOTE_SQL_PATH"
    sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$TARGET" "mkdir -p '$REMOTE_SQL_PATH'"
    echo ">> Upload script SQL verso ${TARGET}:${REMOTE_SQL_PATH}/"
    for sql_file in "${SQL_FILES[@]}"; do
      sshpass -p "$PASSWORD" scp "${SCP_OPTS[@]}" "$sql_file" "$TARGET:${REMOTE_SQL_PATH%/}/"
    done
  fi
fi

echo ">> Cartella esplosa ${TOMCAT_WEBAPPS_PATH%/}/${APP_CONTEXT} non rimossa manualmente (gestita da Tomcat)."

APP_URL="http://${HOST}:8080/${APP_CONTEXT}/"
if [[ "$APP_CONTEXT" == "ROOT" ]]; then
  APP_URL="http://${HOST}:8080/"
fi

echo ">> Deploy remoto completato."
echo ">> URL applicativo: $APP_URL"
