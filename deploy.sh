#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'HELP'
Uso:
  ./deploy.sh (--remoto | --apk) [opzioni]

Descrizione:
  Builda il progetto Maven, carica il WAR su server remoto via sshpass/scp
  e lo copia in /opt/tomcat/webapps/ (default).

Opzioni:
  --remoto                Esegue deploy remoto
  --apk                   Genera APK Android debug (senza installazione)
  --android-url <url>     URL backend per build APK (FISIO_SPORT_BASE_URL)
  --host <host>            Host remoto (default: 31.70.74.92)
  --user <user>            Utente SSH (default: root)
  --password <password>    Password SSH (default: preconfigurata nello script)
  --port <port>            Porta SSH (default: 22)
  --remote-path <path>     Cartella deploy remota (default: ~/)
  --with-sql              Carica anche gli script SQL su server remoto
  --remote-sql-path <p>   Cartella remota per script SQL (default: /root/sql-scripts)
  --war <path>             WAR locale da deployare (default: ultimo in target/)
  --skip-build             Salta mvn clean package
  --restart-service <name> Riavvia servizio remoto con systemctl (opzionale)
  --help                   Mostra questo aiuto

Esempi:
  ./deploy.sh --remoto
  ./deploy.sh --remoto --with-sql
  ./deploy.sh --remoto --with-sql --remote-sql-path /root/sql-scripts
  ./deploy.sh --apk
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
REMOTE_SQL_PATH="/root/sql-scripts"
WAR_PATH=""
SKIP_BUILD="false"
RESTART_SERVICE=""
WITH_SQL="false"
MODE=""
ANDROID_URL=""
ANDROID_URL_EXPLICIT="false"

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
    --android-url)
      ANDROID_URL="${2:-}"
      ANDROID_URL_EXPLICIT="true"
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
    --restart-service)
      RESTART_SERVICE="${2:-}"
      shift 2
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

if [[ "$MODE" != "remoto" && "$MODE" != "apk" ]]; then
  echo "Errore: devi specificare --remoto o --apk." >&2
  usage
  exit 1
fi

if [[ "$MODE" == "apk" ]]; then
  ANDROID_DIR="android-app"
  APK_DIR="${ANDROID_DIR}/app/build/outputs/apk/debug"

  if [[ ! -d "$ANDROID_DIR" ]]; then
    echo "Errore: cartella Android non trovata: $ANDROID_DIR" >&2
    exit 1
  fi

  if [[ "$ANDROID_URL_EXPLICIT" == "true" ]]; then
    echo ">> Build APK con backend URL: $ANDROID_URL"
    (
      cd "$ANDROID_DIR"
      ./gradlew assembleDebug "-PFISIO_SPORT_BASE_URL=${ANDROID_URL}"
    )
  else
    echo ">> Build APK con configurazione di default"
    (
      cd "$ANDROID_DIR"
      ./gradlew assembleDebug
    )
  fi

  APK_FILE="$(ls -t "${APK_DIR}"/*.apk 2>/dev/null | head -n 1 || true)"
  if [[ -z "$APK_FILE" || ! -f "$APK_FILE" ]]; then
    echo "Errore: APK non trovato dopo la build in: $APK_DIR" >&2
    exit 1
  fi

  APK_ABS_PATH="$(cd "$(dirname "$APK_FILE")" && pwd)/$(basename "$APK_FILE")"
  echo ">> APK generato: $APK_FILE"
  echo ">> Percorso filesystem: $APK_ABS_PATH"
  exit 0
fi

require_cmd sshpass
require_cmd ssh
require_cmd scp
require_cmd mvn

if [[ -z "$PASSWORD" ]]; then
  echo "Errore: password SSH mancante. Usa --password o DEPLOY_SSH_PASSWORD." >&2
  exit 1
fi

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
TARGET="${USER}@${HOST}"
SSH_OPTS=(-o StrictHostKeyChecking=accept-new -p "$PORT")
SCP_OPTS=(-o StrictHostKeyChecking=accept-new -P "$PORT")

echo ">> WAR selezionato: $WAR_PATH"
echo ">> Verifico cartella remota: $REMOTE_PATH"
sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$TARGET" "mkdir -p ${REMOTE_PATH}"

echo ">> Upload WAR verso ${TARGET}:${REMOTE_PATH}/"
sshpass -p "$PASSWORD" scp "${SCP_OPTS[@]}" "$WAR_PATH" "$TARGET:${REMOTE_PATH%/}/$WAR_NAME"

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

echo ">> Cartella esplosa ${REMOTE_PATH%/}/${APP_CONTEXT} non rimossa manualmente (gestita da Tomcat)."

if [[ -n "$RESTART_SERVICE" ]]; then
  echo ">> Riavvio servizio remoto: $RESTART_SERVICE"
  sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$TARGET" "systemctl restart '$RESTART_SERVICE' && systemctl is-active '$RESTART_SERVICE'"
fi

APP_URL="http://${HOST}:8080/${APP_CONTEXT}/"
if [[ "$APP_CONTEXT" == "ROOT" ]]; then
  APP_URL="http://${HOST}:8080/"
fi

echo ">> Deploy remoto completato."
echo ">> URL applicativo: $APP_URL"
