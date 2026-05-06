#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'HELP'
Uso:
  ./deploy.sh --remoto [opzioni]

Descrizione:
  Builda il progetto Maven, carica il WAR su server remoto via sshpass/scp
  e lo copia in /opt/tomcat/webapps/ (default).

Opzioni:
  --remoto                Esegue deploy remoto (obbligatorio)
  --host <host>            Host remoto (default: 31.70.74.92)
  --user <user>            Utente SSH (default: root)
  --password <password>    Password SSH (default: preconfigurata nello script)
  --port <port>            Porta SSH (default: 22)
  --remote-path <path>     Cartella deploy remota (default: /opt/tomcat/webapps)
  --war <path>             WAR locale da deployare (default: ultimo in target/)
  --skip-build             Salta mvn clean package
  --restart-service <name> Riavvia servizio remoto con systemctl (opzionale)
  --help                   Mostra questo aiuto

Esempi:
  ./deploy.sh --remoto
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
REMOTE_PATH="/opt/tomcat/webapps"
WAR_PATH=""
SKIP_BUILD="false"
RESTART_SERVICE=""
MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remoto)
      MODE="remoto"
      shift
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

if [[ "$MODE" != "remoto" ]]; then
  echo "Errore: devi specificare --remoto." >&2
  usage
  exit 1
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
sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$TARGET" "mkdir -p '$REMOTE_PATH'"

echo ">> Upload WAR verso ${TARGET}:${REMOTE_PATH}/"
sshpass -p "$PASSWORD" scp "${SCP_OPTS[@]}" "$WAR_PATH" "$TARGET:${REMOTE_PATH%/}/$WAR_NAME"

echo ">> Rimuovo eventuale cartella esplosa precedente: ${REMOTE_PATH%/}/${APP_CONTEXT}"
sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$TARGET" "rm -rf '${REMOTE_PATH%/}/${APP_CONTEXT}'"

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
