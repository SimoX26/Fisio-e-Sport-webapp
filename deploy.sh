#!/usr/bin/env bash
set -euo pipefail

# Default locali/remoti
LOCAL_WEBAPPS_DEFAULT="/home/simone/apache-tomcat-9.0.112/webapps"
REMOTE_USER_DEFAULT="ubuntu"
REMOTE_HOST_DEFAULT="ec2-51-21-247-183.eu-north-1.compute.amazonaws.com"
REMOTE_WEBAPPS_DEFAULT="~"
REMOTE_SQL_PATH_DEFAULT="~/sql-scripts"

usage() {
  cat <<'HELP'
Uso:
  ./deploy.sh (--locale | --remoto) [opzioni]

Esempi:
  ./deploy.sh --locale
  ./deploy.sh --remoto
  ./deploy.sh --remoto --skip-build

Opzioni:
  --locale           Copia il WAR in locale su /home/simone/apache-tomcat-9.0.112/webapps
  --remoto           Copia il WAR su host remoto preconfigurato via scp
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
  echo "Errore: devi specificare --locale oppure --remoto." >&2
  usage
  exit 1
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
