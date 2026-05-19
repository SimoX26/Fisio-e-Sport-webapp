#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'HELP'
Uso:
  ./deploy-remoto.sh [opzioni]

Descrizione:
  Builda il progetto Maven, carica il WAR su server remoto via sshpass/scp
  e lo deploya in Tomcat con staging remoto.

Opzioni:
  --host <host>            Host remoto (default: 31.70.74.92)
  --user <user>            Utente SSH (default: root)
  --password <password>    Password SSH (default: da variabile DEPLOY_SSH_PASSWORD)
  --port <port>            Porta SSH (default: 22)
  --remote-path <path>     Cartella deploy remota (default: ~/)
  --tomcat-webapps <path>  Cartella webapps Tomcat (default: /opt/tomcat/webapps)
  --with-sql               Carica la cartella migration su server remoto (destinazione: ~/)
  --war <path>             WAR locale da deployare (default: ultimo in target/)
  --skip-build             Salta mvn clean package
  --help                   Mostra questo aiuto

Esempi:
  ./deploy-remoto.sh
  ./deploy-remoto.sh --with-sql
  ./deploy-remoto.sh --password '***'
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
PASSWORD="${DEPLOY_SSH_PASSWORD:-}"
PORT="22"
REMOTE_PATH="~/"
TOMCAT_WEBAPPS_PATH="/opt/tomcat/webapps"
WAR_PATH=""
SKIP_BUILD="false"
WITH_SQL="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
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
  MIGRATION_DIR="src/main/resources/migrations"

  if [[ ! -d "$MIGRATION_DIR" ]]; then
    echo ">> Cartella migration non trovata: $MIGRATION_DIR"
  else
    echo ">> Upload cartella migration verso ${TARGET}:~/"
    sshpass -p "$PASSWORD" scp -r "${SCP_OPTS[@]}" "$MIGRATION_DIR" "$TARGET:~/"
    echo ">> Cartella migration caricata: ~/migrations"
  fi
fi

echo ">> Cartella esplosa ${TOMCAT_WEBAPPS_PATH%/}/${APP_CONTEXT} non rimossa manualmente (gestita da Tomcat)."

APP_URL="http://${HOST}:8080/${APP_CONTEXT}/"
if [[ "$APP_CONTEXT" == "ROOT" ]]; then
  APP_URL="http://${HOST}:8080/"
fi

echo ">> Deploy remoto completato."
echo ">> URL applicativo: $APP_URL"
