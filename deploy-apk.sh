#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'HELP'
Uso:
  ./deploy-apk.sh [opzioni]

Descrizione:
  Genera APK Android debug (senza installazione).

Opzioni:
  --android-url <url>     URL backend per build APK (FISIO_SPORT_BASE_URL)
  --apk-prefix <prefix>   Prefisso nome APK generato (es: test)
  --apk-test              Profilo test LAN (prefix: test, server: 192.168.1.16, overlay rosso)
  --apk-output-dir <dir>  Cartella output APK locale (default: /home/simone/Scaricati)
  --help                  Mostra questo aiuto

Esempi:
  ./deploy-apk.sh
  ./deploy-apk.sh --apk-test
  ./deploy-apk.sh --apk-prefix test --android-url http://192.168.1.16:8080/Fisio-e-Sport-webapp
HELP
}

ANDROID_DIR="android-app"
APK_DIR="${ANDROID_DIR}/app/build/outputs/apk/debug"
BASE_APK_NAME="FisioESport.apk"
LAN_TEST_URL="http://192.168.1.16:8080/Fisio-e-Sport-webapp"

ANDROID_URL=""
ANDROID_URL_EXPLICIT="false"
APK_PREFIX=""
APK_TEST_MODE="false"
APK_OUTPUT_DIR="/home/simone/Scaricati"

while [[ $# -gt 0 ]]; do
  case "$1" in
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
    --apk-output-dir)
      APK_OUTPUT_DIR="${2:-}"
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
