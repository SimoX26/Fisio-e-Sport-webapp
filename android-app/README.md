# Fisio e Sports Android

Wrapper Android WebView della webapp Fisio e Sports.

## Requisiti

- JDK 17;
- Android SDK con API 35;
- dispositivo Android 7.0 (API 24) o successivo, oppure un emulatore;
- backend Fisio e Sports raggiungibile dal dispositivo.

Per usare il progetto con Android Studio è sufficiente aprire la cartella `android-app`.

## Configurazione SDK

Se non viene generato automaticamente da Android Studio, crea `local.properties` a partire dall'esempio:

```bash
cp local.properties.example local.properties
```

Imposta in `sdk.dir` il percorso locale dell'Android SDK. `local.properties` è escluso da Git.

## URL del backend

La build legge la proprietà Gradle `FISIO_SPORT_BASE_URL`. In assenza della proprietà usa il backend remoto configurato in `app/build.gradle.kts`.

Da un dispositivo fisico non usare `localhost`: indica un host raggiungibile dal telefono, mantenendo il contesto web `Fisio-e-Sport-webapp`.

Esempio per un backend nella rete locale:

```bash
./gradlew assembleDebug -PFISIO_SPORT_BASE_URL=http://192.168.1.50:8080/Fisio-e-Sport-webapp
```

## Build

Dalla cartella `android-app`:

```bash
./gradlew assembleDebug
```

L'APK debug viene generato in:

```text
app/build/outputs/apk/debug/FisioESport.apk
```

Per installarlo con ADB:

```bash
adb install -r app/build/outputs/apk/debug/FisioESport.apk
```

La build release è disponibile con `./gradlew assembleRelease`, ma il progetto non definisce credenziali di firma: la firma per la distribuzione deve essere configurata separatamente.

## Script dalla radice del repository

`deploy-apk.sh` crea un APK debug e lo copia nella directory di output indicata:

```bash
./deploy-apk.sh --apk-output-dir /percorso/output
```

Per una build di test LAN con applicazione separata e overlay rosso:

```bash
./deploy-apk.sh --apk-test --apk-output-dir /percorso/output
```

Consulta tutte le opzioni con `./deploy-apk.sh --help`.

## Funzioni del wrapper

- JavaScript, DOM storage e cookie di sessione;
- pull-to-refresh e navigazione indietro;
- selezione multipla di immagini e video;
- acquisizione di più foto tramite fotocamera;
- apertura esterna dei link `tel:` e `mailto:`;
- supporto HTTP per backend LAN tramite `network_security_config`.
