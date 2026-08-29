# Fisio e Sports

Gestionale per centri di fisioterapia e riabilitazione. Il repository contiene la webapp Java, un servizio locale per l'integrazione WhatsApp e un wrapper Android WebView.

## Funzionalità

- autenticazione con sessione, "ricordami" e ruoli `ADMIN`/`THERAPIST`;
- calendario, cestino appuntamenti e lista d'attesa;
- rubrica pazienti, anamnesi e condizioni cliniche;
- piani e storico dei trattamenti;
- dashboard e statistiche KPI mensili;
- ricerca globale, promemoria e modelli messaggio per terapista;
- registrazione tramite richiesta di accesso e revisione amministrativa;
- configurazione del gateway WhatsApp dalla webapp.

## Componenti

- `src/main/java/it/SimoSW/controller/graphic`: servlet, filtri e routing HTTP;
- `src/main/java/it/SimoSW/controller/application`: logica applicativa;
- `src/main/java/it/SimoSW/model`: dominio, DTO e contratti DAO;
- `src/main/java/it/SimoSW/model/dao/database`: persistenza MySQL con pool HikariCP;
- `src/main/webapp`: JSP e asset frontend;
- `src/main/resources`: configurazione, schema e migrazioni SQL;
- `baileys-service`: gateway Node.js locale per WhatsApp;
- `android-app`: wrapper Android Kotlin della webapp.

Il wiring delle dipendenze avviene in `ApplicationInitializer`; `ApplicationContextListener` inizializza l'applicazione e lo scheduler KPI. L'accesso alle route è protetto da `AuthenticationFilter`.

## Stack e requisiti

Webapp:

- JDK 15;
- Maven 3.8 o successivo;
- MySQL 8;
- container Servlet 4, ad esempio Apache Tomcat 9.

Componenti opzionali:

- Node.js 20 o successivo per `baileys-service`;
- JDK 17 e Android SDK per `android-app`.

## Configurazione locale

1. Clona il repository:

```bash
git clone https://github.com/SimoX26/Fisio-e-Sports.git
cd Fisio-e-Sports
```

2. Crea la configurazione runtime:

```bash
cp src/main/resources/config.properties.example src/main/resources/config.properties
```

Imposta almeno `db.url`, `db.username` e `db.password`. Il file reale è ignorato da Git e non deve essere versionato.

3. Inizializza un database di sviluppo:

```bash
mysql -u root -p < src/main/resources/db.sql
```

Attenzione: `db.sql` elimina e ricrea il database `fisio_e_sport`; non usarlo su un database che contiene dati da conservare.

Il seed opzionale per gli utenti di sviluppo è in `src/main/resources/users.sql`:

```bash
mysql -u root -p < src/main/resources/users.sql
```

Su database esistenti applica invece, in ordine cronologico e solo se necessarie, le migrazioni presenti in `src/main/resources/migrations`.

## Build e avvio webapp

Compila e verifica il progetto:

```bash
mvn clean package
```

Il WAR viene generato in `target/Fisio-e-Sport-webapp.war`; il nome del contesto applicativo resta `Fisio-e-Sport-webapp` anche se il repository si chiama `Fisio-e-Sports`.

Puoi copiare manualmente il WAR nella directory `webapps` di Tomcat oppure usare lo script locale, specificando il percorso della tua installazione:

```bash
./deploy-locale.sh --tomcat-webapps /percorso/tomcat/webapps
```

L'applicazione sarà disponibile, salvo configurazioni diverse di Tomcat, su:

```text
http://localhost:8080/Fisio-e-Sport-webapp/
```

Per tutte le opzioni degli script di deploy:

```bash
./deploy-locale.sh --help
./deploy-remoto.sh --help
```

Il deploy remoto richiede `ssh`, `scp`, `sshpass` e la variabile d'ambiente `DEPLOY_SSH_PASSWORD`; può caricare anche le migrazioni e il servizio Baileys.

## Servizio WhatsApp

Abilita il gateway in `src/main/resources/config.properties`:

```properties
whatsapp.baileys.enabled=true
whatsapp.baileys.gatewayBaseUrl=http://127.0.0.1:3001
```

Avvia il servizio dalla radice del repository:

```bash
./baileys-service/start-baileys.sh
```

Lo script installa le dipendenze di produzione se non sono presenti. Associa la sessione dalla pagina `Impostazioni` della webapp o tramite `http://localhost:3001/api/qr`.

Per arrestare il servizio:

```bash
./baileys-service/stop-baileys.sh
```

Per azzerare e riassociare la sessione locale:

```bash
BAILEYS_RESET_SESSION=1 ./baileys-service/start-baileys.sh
```

La sessione è salvata in `baileys-service/auth-session` ed è esclusa da Git.

## Android

Il wrapper Android usa la webapp come backend. Per configurazione, build e installazione consulta [`android-app/README.md`](android-app/README.md).

Dalla radice del repository è disponibile anche:

```bash
./deploy-apk.sh --help
```

## Statistiche KPI

La pagina `/dashboard/insights` legge gli snapshot mensili esposti da `/dashboard/kpi`. Definizioni, formule e aggiornamento dei dati sono descritti in [`KPI_STATISTICHE_GUIDA.md`](KPI_STATISTICHE_GUIDA.md).
