# Fisio e Sports WebApp

Applicazione web Java per la gestione di un centro di fisioterapia e riabilitazione: autenticazione, calendario appuntamenti, rubrica pazienti e storico trattamenti.

## Stack Tecnologico

- Java 15
- Maven
- Servlet/JSP (javax.servlet 4)
- MySQL
- Bootstrap 5 + FullCalendar
- Jackson (JSON)

## Prerequisiti

- JDK 15
- Maven 3.8+
- MySQL 8+
- Servlet container compatibile Servlet 4 (consigliato Apache Tomcat 9)

## Setup Locale

1. Clona il repository.
2. Configura il DB:
   - File schema: `src/main/resources/db.sql`
   - Config app: `src/main/resources/config.properties`
3. Esegui script SQL:

```bash
mysql -u root -p < src/main/resources/db.sql
mysql -u root -p < src/main/resources/users.sql
```

## Avvio Progetto

Compila il progetto:

```bash
mvn clean package
```

WAR generato:

- `target/Fisio-e-Sport-webapp.war`

Deploya il WAR su Tomcat (o altro container Servlet 4) e apri:

- `http://localhost:8080/Fisio-e-Sport-webapp/`

## Utenti Test

Password per tutti: `1234`

- `marco` (THERAPIST, attivo)
- `andrea` (ADMIN, attivo)
- `jessica` (THERAPIST, disattivato)

## Note Funzionali

- Il terapista e gestito tramite tabella `users` con ruolo `THERAPIST` (non esiste tabella `therapists`).
- In creazione appuntamento:
  - il paziente si inserisce con testo;
  - se non esiste viene creato automaticamente;
  - il terapista viene risolto dall'utente loggato.

## Struttura Progetto

- `src/main/java/it/SimoSW/controller/graphic`: Servlet HTTP/UI
- `src/main/java/it/SimoSW/controller/application`: logica applicativa
- `src/main/java/it/SimoSW/model`: dominio
- `src/main/java/it/SimoSW/model/dao`: interfacce DAO
- `src/main/java/it/SimoSW/model/dao/database`: persistenza MySQL
- `src/main/webapp`: JSP, asset CSS/JS
- `src/main/resources`: configurazioni e script SQL

## Documentazione Architetturale

Per stato e decisioni architetturali aggiornate:

- `STATO_ARCHITETTURALE.md`

## Documentazione Statistiche

Per dettagli su KPI, formule e interpretazione dei grafici:

- `KPI_STATISTICHE_GUIDA.md`


## Versione Android (WebView)

Nel repository e disponibile anche il wrapper Android Kotlin:

- `android-app/`

Documentazione build/install:

- `android-app/README.md`
