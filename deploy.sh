#!/usr/bin/env bash
set -euo pipefail

# Default locali/remoti
LOCAL_WEBAPPS_DEFAULT="/home/simone/apache-tomcat-9.0.112/webapps"
REMOTE_USER_DEFAULT="ubuntu"
REMOTE_HOST_DEFAULT="ec2-51-21-247-183.eu-north-1.compute.amazonaws.com"
REMOTE_WEBAPPS_DEFAULT="~"
REMOTE_SQL_PATH_DEFAULT="~/sql-scripts"
ANDROID_BACKEND_URL_DEFAULT="http://ec2-51-21-247-183.eu-north-1.compute.amazonaws.com:8080/Fisio-e-Sport-webapp"

usage() {
  cat <<'HELP'
Uso:
  ./deploy.sh (--locale | --remoto | --android | --apk) [opzioni]

Esempi:
  ./deploy.sh --locale
  ./deploy.sh --remoto
  ./deploy.sh --remoto --skip-build
  ./deploy.sh --android
  ./deploy.sh --apk
  ./deploy.sh --android --android-url http://192.168.1.50:8080/Fisio-e-Sport-webapp

Opzioni:
  --locale           Copia il WAR in locale su /home/simone/apache-tomcat-9.0.112/webapps
  --remoto           Copia il WAR su host remoto preconfigurato via scp
  --android          Build APK Android (android-app) e installa via adb se disponibile
  --apk              Build APK Android (android-app) senza installazione adb
  --android-url <u>  URL backend da iniettare nella build Android (FISIO_SPORT_BASE_URL)
  --android-no-install Salta installazione adb automatica (build-only)
  --war <path>       Percorso WAR locale (default: WAR piu recente in target/)
  --key <path.pem>   Chiave SSH (default: auto-rilevata)
  --port <port>      Porta SSH (default: 22)
  --remote-user <u>  Utente SSH remoto (default: ubuntu)
  --remote-host <h>  Host SSH remoto (default: ec2-51-21-247-183.eu-north-1.compute.amazonaws.com)
  --remote-path <p>  Cartella remota per il WAR (default: ~)
  --remote-sql-path <p> Cartella remota script SQL (default: ~/sql-scripts)
  --skip-build       Salta 'mvn clean package' e usa WAR gia presente in target/
  --no-sql           Non trasferisce i file .sql in remoto
  --help             Mostra questo aiuto

Note:
  - Se --key non e specificato, prova in ordine:
    1) DEPLOY_SSH_KEY
    2) ~/Documenti/Fisio-e-Sport-keys.pem
    3) ~/.ssh/id_ed25519
    4) ~/.ssh/id_rsa
HELP
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Errore: comando richiesto non trovato: $1" >&2
    exit 1
  fi
}

expand_tilde_path() {
  local path="$1"
  case "$path" in
    "~")
      echo "$HOME"
      ;;
    "~/"*)
      echo "$HOME/${path#~/}"
      ;;
    *)
      echo "$path"
      ;;
  esac
}

detect_ssh_key_path() {
  if [[ -n "${DEPLOY_SSH_KEY:-}" ]]; then
    local env_path
    env_path="$(expand_tilde_path "$DEPLOY_SSH_KEY")"
    if [[ -f "$env_path" ]]; then
      echo "$env_path"
      return 0
    fi
  fi

  local candidates=(
    "$HOME/Documenti/Fisio-e-Sport-keys.pem"
    "$HOME/.ssh/id_ed25519"
    "$HOME/.ssh/id_rsa"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

resolve_ipv4() {
  local host="$1"
  local ip=""

  if [[ "$host" == "localhost" || "$host" == "127.0.0.1" ]]; then
    ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
    if [[ -z "$ip" ]]; then
      ip="127.0.0.1"
    fi
    echo "$ip"
    return 0
  fi

  ip="$(getent ahostsv4 "$host" 2>/dev/null | awk '{print $1; exit}' || true)"
  if [[ -z "$ip" ]]; then
    ip="$host"
  fi
  echo "$ip"
}

detect_android_sdk_path() {
  local raw=""
  local candidate=""
  local candidates=(
    "${ANDROID_HOME:-}"
    "${ANDROID_SDK_ROOT:-}"
    "$HOME/Android/Sdk"
    "$HOME/Library/Android/sdk"
    "/opt/android-sdk"
    "/usr/local/share/android-sdk"
  )

  for raw in "${candidates[@]}"; do
    [[ -n "$raw" ]] || continue
    candidate="$(expand_tilde_path "$raw")"
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

configure_android_sdk() {
  local android_dir="$1"
  local sdk_path=""
  local local_properties_path=""
  local sdk_escaped=""

  sdk_path="$(detect_android_sdk_path || true)"
  if [[ -z "$sdk_path" ]]; then
    echo "Errore: Android SDK non trovato." >&2
    echo "Imposta ANDROID_HOME/ANDROID_SDK_ROOT oppure crea ${android_dir}/local.properties con sdk.dir=/percorso/android-sdk" >&2
    exit 1
  fi

  export ANDROID_HOME="$sdk_path"
  export ANDROID_SDK_ROOT="$sdk_path"
  echo ">> Android SDK rilevato: ${sdk_path}"

  local_properties_path="${android_dir}/local.properties"
  sdk_escaped="${sdk_path//\\/\\\\}"
  sdk_escaped="${sdk_escaped//:/\\:}"
  printf "sdk.dir=%s\n" "$sdk_escaped" > "$local_properties_path"
  echo ">> local.properties aggiornato: ${local_properties_path}"
}

MODE=""
WAR_PATH=""
SSH_PORT="22"
SSH_KEY_PATH=""
REMOTE_USER="$REMOTE_USER_DEFAULT"
REMOTE_HOST="$REMOTE_HOST_DEFAULT"
REMOTE_PATH="$REMOTE_WEBAPPS_DEFAULT"
REMOTE_SQL_PATH="$REMOTE_SQL_PATH_DEFAULT"
SKIP_BUILD="false"
TRANSFER_SQL="true"
LOCAL_PATH="$LOCAL_WEBAPPS_DEFAULT"
ANDROID_URL=""
ANDROID_URL_EXPLICIT="false"
ANDROID_INSTALL="true"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --locale)
      MODE="locale"
      shift
      ;;
    --remoto)
      MODE="remoto"
      shift
      ;;
    --android)
      MODE="android"
      shift
      ;;
    --apk)
      MODE="apk"
      ANDROID_INSTALL="false"
      shift
      ;;
    --android-url)
      ANDROID_URL="${2:-}"
      ANDROID_URL_EXPLICIT="true"
      shift 2
      ;;
    --android-no-install)
      ANDROID_INSTALL="false"
      shift
      ;;
    --war)
      WAR_PATH="${2:-}"
      shift 2
      ;;
    --key)
      SSH_KEY_PATH="${2:-}"
      shift 2
      ;;
    --port)
      SSH_PORT="${2:-}"
      shift 2
      ;;
    --remote-user)
      REMOTE_USER="${2:-}"
      shift 2
      ;;
    --remote-host)
      REMOTE_HOST="${2:-}"
      shift 2
      ;;
    --remote-path)
      REMOTE_PATH="${2:-}"
      shift 2
      ;;
    --remote-sql-path)
      REMOTE_SQL_PATH="${2:-}"
      shift 2
      ;;
    --skip-build)
      SKIP_BUILD="true"
      shift
      ;;
    --no-sql)
      TRANSFER_SQL="false"
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

if [[ -z "$MODE" ]]; then
  echo "Errore: devi specificare --locale, --remoto, --android o --apk." >&2
  usage
  exit 1
fi

if [[ "$ANDROID_URL_EXPLICIT" != "true" ]]; then
  ANDROID_URL="$ANDROID_BACKEND_URL_DEFAULT"
fi

if [[ "$MODE" == "android" || "$MODE" == "apk" ]]; then
  ANDROID_DIR="android-app"
  APK_DIR="${ANDROID_DIR}/app/build/outputs/apk/debug"
  PACKAGE_NAME="it.simosw.fisioesport"

  if [[ ! -d "$ANDROID_DIR" ]]; then
    echo "Errore: cartella Android non trovata: $ANDROID_DIR" >&2
    exit 1
  fi

  configure_android_sdk "$ANDROID_DIR"

  GRADLE_CMD=("./gradlew" "assembleDebug")
  if [[ -n "$ANDROID_URL" ]]; then
    GRADLE_CMD+=("-PFISIO_SPORT_BASE_URL=${ANDROID_URL}")
  fi

  echo ">> Android backend URL: ${ANDROID_URL}"
  echo ">> Build Android in ${ANDROID_DIR}: ${GRADLE_CMD[*]}"
  (
    cd "$ANDROID_DIR"
    "${GRADLE_CMD[@]}"
  )

  APK_FILE="$(ls -t "${APK_DIR}"/*.apk 2>/dev/null | head -n 1 || true)"
  if [[ -z "$APK_FILE" || ! -f "$APK_FILE" ]]; then
    echo "Errore: APK non trovato dopo la build in: $APK_DIR" >&2
    exit 1
  fi

  APK_ABS_PATH="$(cd "$(dirname "$APK_FILE")" && pwd)/$(basename "$APK_FILE")"

  if [[ "$ANDROID_INSTALL" == "false" ]]; then
    echo ">> APK generato: $APK_FILE"
    echo ">> Percorso filesystem: $APK_ABS_PATH"
    exit 0
  fi

  if ! command -v adb >/dev/null 2>&1; then
    echo ">> adb non trovato: installazione automatica saltata."
    echo ">> Installa manualmente con: adb install -r \"$APK_FILE\""
    exit 0
  fi

  ADB_DEVICE_COUNT="$(adb devices | awk 'NR>1 && $2=="device" {count++} END {print count+0}')"
  if [[ "$ADB_DEVICE_COUNT" -eq 0 ]]; then
    echo ">> Nessun dispositivo adb collegato: installazione automatica saltata."
    echo ">> Installa manualmente con: adb install -r \"$APK_FILE\""
    exit 0
  fi

  echo ">> Installazione APK su dispositivo (adb install -r)"
  adb install -r "$APK_FILE"
  echo ">> Deploy Android completato."
  echo ">> Pacchetto installato: ${PACKAGE_NAME}"
  exit 0
fi

require_cmd mvn

if [[ "$SKIP_BUILD" != "true" ]]; then
  echo ">> Eseguo build Maven: mvn clean package"
  mvn clean package
fi

if [[ -z "$WAR_PATH" ]]; then
  WAR_PATH="$(ls -t target/*.war 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "$WAR_PATH" || ! -f "$WAR_PATH" ]]; then
  echo "Errore: nessun file WAR trovato. Specifica --war o esegui la build." >&2
  exit 1
fi

WAR_NAME="$(basename "$WAR_PATH")"
APP_CONTEXT="${WAR_NAME%.war}"
echo ">> WAR selezionato: $WAR_PATH"

if [[ "$MODE" == "locale" ]]; then
  if [[ ! -d "$LOCAL_PATH" ]]; then
    echo "Errore: cartella locale non trovata: $LOCAL_PATH" >&2
    exit 1
  fi

  echo ">> Deploy locale in: $LOCAL_PATH"
  cp -f "$WAR_PATH" "$LOCAL_PATH/"
  echo ">> Deploy locale completato."

  LOCAL_IP="$(resolve_ipv4 "localhost")"
  if [[ "$APP_CONTEXT" == "ROOT" ]]; then
    APP_URL="http://${LOCAL_IP}:8080/"
  else
    APP_URL="http://${LOCAL_IP}:8080/${APP_CONTEXT}/"
  fi
  echo ">> Avvio applicativo: $APP_URL"
  exit 0
fi

require_cmd scp

if [[ -n "$SSH_KEY_PATH" ]]; then
  SSH_KEY_PATH="$(expand_tilde_path "$SSH_KEY_PATH")"
else
  SSH_KEY_PATH="$(detect_ssh_key_path || true)"
  if [[ -n "$SSH_KEY_PATH" ]]; then
    echo ">> Chiave SSH auto-rilevata: $SSH_KEY_PATH"
  else
    echo ">> Nessuna chiave auto-rilevata: provo autenticazione SSH di default."
  fi
fi

if [[ -n "$SSH_KEY_PATH" && ! -f "$SSH_KEY_PATH" ]]; then
  echo "Errore: chiave SSH non trovata: $SSH_KEY_PATH" >&2
  exit 1
fi

TARGET="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH%/}/"

SCP_CMD=(scp -P "$SSH_PORT")
if [[ -n "$SSH_KEY_PATH" ]]; then
  SCP_CMD+=(-i "$SSH_KEY_PATH")
fi
SCP_CMD+=("$WAR_PATH" "$TARGET")

echo ">> Upload WAR verso: $TARGET"
"${SCP_CMD[@]}"

if [[ "$TRANSFER_SQL" == "true" ]]; then
  shopt -s nullglob
  SQL_FILES=(src/main/resources/*.sql)
  shopt -u nullglob

  if [[ ${#SQL_FILES[@]} -gt 0 ]]; then
    SQL_TARGET="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SQL_PATH%/}/"
    echo ">> Upload script SQL verso: $SQL_TARGET"
    for sql_file in "${SQL_FILES[@]}"; do
      if [[ -n "$SSH_KEY_PATH" ]]; then
        scp -P "$SSH_PORT" -i "$SSH_KEY_PATH" "$sql_file" "$SQL_TARGET"
      else
        scp -P "$SSH_PORT" "$sql_file" "$SQL_TARGET"
      fi
    done
  else
    echo ">> Nessuno script SQL trovato in src/main/resources."
  fi
fi

echo ">> Deploy remoto completato con successo."
REMOTE_IP="$(resolve_ipv4 "$REMOTE_HOST")"
if [[ "$APP_CONTEXT" == "ROOT" ]]; then
  APP_URL="http://${REMOTE_IP}:8080/"
else
  APP_URL="http://${REMOTE_IP}:8080/${APP_CONTEXT}/"
fi
echo ">> Avvio applicativo: $APP_URL"
