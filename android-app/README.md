# Fisio e Sport Android

Wrapper Android installabile per la webapp **Fisio e Sport**.

## Requisiti

- Android Studio (consigliato) oppure JDK 17 + Android SDK
- Dispositivo Android o emulatore
- Backend Fisio e Sport raggiungibile via rete

## Configurazione URL backend

L'app legge l'URL da proprietà Gradle `FISIO_SPORT_BASE_URL`.

Default di progetto (server remoto deployato):

- `http://ec2-51-21-247-183.eu-north-1.compute.amazonaws.com:8080/Fisio-e-Sport-webapp`

Esempio build debug con backend in LAN:

```bash
./gradlew assembleDebug -PFISIO_SPORT_BASE_URL=http://192.168.1.50:8080/Fisio-e-Sport-webapp
```

Note importanti:

- Su dispositivo fisico non usare `localhost`, ma l'IP della macchina che ospita Tomcat.
- Assicurati che telefono e server siano sulla stessa rete o raggiungibili via internet/VPN.

## Build APK

Debug APK:

```bash
./gradlew assembleDebug
```

Release APK:

```bash
./gradlew assembleRelease
```

APK rinominato automaticamente in:

- `FisioESport.apk`

## Installazione su dispositivo

Con ADB:

```bash
adb install -r app/build/outputs/apk/debug/FisioESport.apk
```

## Cosa include il wrapper

- WebView con JavaScript e storage abilitati
- Pull-to-refresh
- Navigazione indietro gestita come app nativa
- Upload file e foto da camera (FileProvider)
- Supporto backend HTTP in LAN tramite `network_security_config`
