#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./deploy.sh [options]

Options:
  --war <path>            Local path del file .war da trasferire (default: ultimo .war in target/)
  --key <path.pem>        Chiave privata SSH (opzionale, equivalente a -i)
  --port <port>           Porta SSH (default: 22)
  --method <scp|rsync>    Metodo trasferimento (default: scp)
  --skip-tests            Esegue Maven con -DskipTests
  --promote               Tenta la copia da ~ a /opt/tomcat (richiede permessi)
  --no-sql                Non trasferisce gli script SQL da src/main/resources
  -h, --help              Mostra questo help

Example:
  ./deploy.sh \
    --key ~/Documenti/Fisio-e-Sport-keys.pem \
    --skip-tests \
    --method scp
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Errore: comando richiesto non trovato: $1" >&2
    exit 1
  fi
}

WAR_PATH=""
SSH_PORT="22"
TRANSFER_METHOD="scp"
SKIP_TESTS="false"
SSH_KEY_PATH=""
PROMOTE_TO_TOMCAT="false"
TRANSFER_SQL="true"

# Configurazione hardcoded richiesta
REMOTE_USER="ubuntu"
REMOTE_HOST="ec2-13-48-104-157.eu-north-1.compute.amazonaws.com"
REMOTE_TOMCAT_DIR="/opt/tomcat"
REMOTE_STAGING_DIR="/home/ubuntu"
LOCAL_SQL_DIR="src/main/resources"
REMOTE_SQL_DIR="/home/ubuntu/sql-scripts"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --war)
      WAR_PATH="${2:-}"; shift 2 ;;
    --port)
      SSH_PORT="${2:-}"; shift 2 ;;
    --key)
      SSH_KEY_PATH="${2:-}"; shift 2 ;;
    --method)
      TRANSFER_METHOD="${2:-}"; shift 2 ;;
    --skip-tests)
      SKIP_TESTS="true"; shift ;;
    --promote)
      PROMOTE_TO_TOMCAT="true"; shift ;;
    --no-sql)
      TRANSFER_SQL="false"; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Argomento non riconosciuto: $1" >&2
      usage
      exit 1 ;;
  esac
done

if [[ "$TRANSFER_METHOD" != "scp" && "$TRANSFER_METHOD" != "rsync" ]]; then
  echo "Errore: --method deve essere 'scp' oppure 'rsync'." >&2
  exit 1
fi

if [[ -n "$SSH_KEY_PATH" && ! -f "$SSH_KEY_PATH" ]]; then
  echo "Errore: chiave SSH non trovata: $SSH_KEY_PATH" >&2
  exit 1
fi

require_cmd mvn
require_cmd ssh
if [[ "$TRANSFER_METHOD" == "scp" ]]; then
  require_cmd scp
else
  require_cmd rsync
fi

echo "[STEP] Maven clean..."
mvn clean

echo "[STEP] Maven package..."
if [[ "$SKIP_TESTS" == "true" ]]; then
  mvn package -DskipTests
else
  mvn package
fi

if [[ -z "$WAR_PATH" ]]; then
  WAR_PATH="$(ls -1t target/*.war 2>/dev/null | head -n 1 || true)"
fi

if [[ ! -f "$WAR_PATH" ]]; then
  echo "Errore: file .war non trovato. Specifica --war oppure verifica target/." >&2
  exit 1
fi

WAR_NAME="$(basename "$WAR_PATH")"
REMOTE_STAGE_WAR_PATH="${REMOTE_STAGING_DIR}/${WAR_NAME}"
SSH_OPTS=(-p "$SSH_PORT")
if [[ -n "$SSH_KEY_PATH" ]]; then
  SSH_OPTS+=(-i "$SSH_KEY_PATH")
fi

echo "[STEP] Verifica directory remota..."
ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p '$REMOTE_STAGING_DIR'"

echo "[STEP] Trasferimento WAR con $TRANSFER_METHOD..."
if [[ "$TRANSFER_METHOD" == "scp" ]]; then
  SCP_OPTS=(-P "$SSH_PORT")
  if [[ -n "$SSH_KEY_PATH" ]]; then
    SCP_OPTS+=(-i "$SSH_KEY_PATH")
  fi
  scp "${SCP_OPTS[@]}" "$WAR_PATH" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_STAGE_WAR_PATH}"
else
  RSYNC_RSH="ssh -p $SSH_PORT"
  if [[ -n "$SSH_KEY_PATH" ]]; then
    RSYNC_RSH+=" -i $SSH_KEY_PATH"
  fi
  rsync -avz --progress -e "$RSYNC_RSH" "$WAR_PATH" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_STAGE_WAR_PATH}"
fi

if [[ "$TRANSFER_SQL" == "true" ]]; then
  shopt -s nullglob
  SQL_FILES=("${LOCAL_SQL_DIR}"/*.sql)
  shopt -u nullglob

  if [[ ${#SQL_FILES[@]} -gt 0 ]]; then
    echo "[STEP] Trasferimento script SQL..."
    ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p '$REMOTE_SQL_DIR'"
    if [[ "$TRANSFER_METHOD" == "scp" ]]; then
      SCP_OPTS=(-P "$SSH_PORT")
      if [[ -n "$SSH_KEY_PATH" ]]; then
        SCP_OPTS+=(-i "$SSH_KEY_PATH")
      fi
      scp "${SCP_OPTS[@]}" "${SQL_FILES[@]}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SQL_DIR}/"
    else
      RSYNC_RSH="ssh -p $SSH_PORT"
      if [[ -n "$SSH_KEY_PATH" ]]; then
        RSYNC_RSH+=" -i $SSH_KEY_PATH"
      fi
      rsync -avz --progress -e "$RSYNC_RSH" "${LOCAL_SQL_DIR}/"*.sql "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SQL_DIR}/"
    fi
  else
    echo "Nessun file .sql trovato in ${LOCAL_SQL_DIR}, salto trasferimento SQL."
  fi
fi

if [[ "$PROMOTE_TO_TOMCAT" == "true" ]]; then
  echo "[STEP] Tentativo copia in ${REMOTE_TOMCAT_DIR}..."
  set +e
  ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" "\
if [ -w '${REMOTE_TOMCAT_DIR}' ]; then
  cp '${REMOTE_STAGE_WAR_PATH}' '${REMOTE_TOMCAT_DIR}/';
elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
  sudo cp '${REMOTE_STAGE_WAR_PATH}' '${REMOTE_TOMCAT_DIR}/';
else
  exit 42;
fi"
  PROMOTE_EXIT_CODE=$?
  set -e

  if [[ $PROMOTE_EXIT_CODE -eq 0 ]]; then
    echo "Completato: ${WAR_NAME} caricato e copiato in ${REMOTE_TOMCAT_DIR}/"
    exit 0
  fi

  echo "Avviso: WAR caricato in staging ma non copiato in ${REMOTE_TOMCAT_DIR}/ (permessi insufficienti)."
  echo "File disponibile su: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_STAGE_WAR_PATH}"
  echo "Esegui sul server con un utente autorizzato:"
  echo "  sudo cp '${REMOTE_STAGE_WAR_PATH}' '${REMOTE_TOMCAT_DIR}/'"
  exit 0
fi

echo "Completato: ${WAR_NAME} trasferito in ${REMOTE_USER}@${REMOTE_HOST}:~/"
