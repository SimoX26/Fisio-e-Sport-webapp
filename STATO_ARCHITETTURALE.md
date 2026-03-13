# Documento di Stato Architetturale

Ultimo aggiornamento: 2026-03-13
Versione applicazione: 1.0 (da `pom.xml`)

## Scopo del documento
Questo file descrive lo stato reale del software dal punto di vista architetturale:
- come e composto il sistema;
- cosa e gia funzionante;
- quali parti sono parziali o mancanti;
- quali decisioni tecniche guidano i prossimi sviluppi.

Non e una to-do list operativa, ma un riferimento tecnico per mantenere coerenza durante l'avanzamento.

## Panorama del sistema
Applicazione web Java (Servlet/JSP), packaging `war`, con persistenza principale su MySQL.

Stack principale:
- Java 15
- Maven
- Jakarta/Javax Servlet 4
- JSP + JSTL
- Jackson (JSON)
- MySQL Connector/J
- Frontend con Bootstrap + JS (FullCalendar lato client)

## Architettura logica attuale
Struttura a layer:

1. Presentation layer (UI)
- JSP sotto `src/main/webapp/WEB-INF/jsp`
- Asset statici in `src/main/webapp/assets`
- Servlet grafiche in `it.SimoSW.controller.graphic` per routing HTTP e rendering pagine

2. Application layer
- Controller applicativi in `it.SimoSW.controller.application`
- Orchestrano regole di dominio e accesso ai DAO
- Nessuna dipendenza da JSP

3. Domain layer
- Modelli in `it.SimoSW.model` (User, Patient, Appointment, TreatmentSession, ecc.)
- Enum di stato/ruolo per vincoli di business
- Eccezioni dedicate per casi applicativi

4. Persistence layer
- Interfacce DAO in `it.SimoSW.model.dao`
- Implementazioni database in `it.SimoSW.model.dao.database`
- Nessuna implementazione alternativa su file system (rimossa dal progetto)

## Bootstrap e dependency wiring
- `ApplicationContextListener` crea un `ApplicationInitializer` all'avvio del contesto servlet.
- `ApplicationInitializer` esegue attualmente solo `initDatabasePersistence()`.
- I controller applicativi sono costruiti e pubblicati nel `ServletContext` (attributo `appInitializer`).
- Ogni servlet recupera i controller necessari in `init()`.

Implicazione architetturale: wiring centralizzato e semplice, ma senza DI container (es. Spring), quindi lifecycle e testability dipendono da codice manuale.

## Stato per capability funzionale

1. Autenticazione utente: **Operativa**
- Endpoint `/login` e `/logout`
- Verifica credenziali tramite `AuthenticationController`
- Sessione HTTP con `loggedUser` e `userRole`
- Distinzione ruolo `ADMIN` vs `THERAPIST`

2. Gestione calendario/appuntamenti: **Operativa (core)**
- Endpoint `/calendar`
- GET eventi in JSON per FullCalendar
- POST con azioni `create`, `reschedule`, `cancel`
- Associazione terapista derivata dall'utente loggato (`users` con ruolo `THERAPIST`)
- Regole business gestite da `CalendarController`
- Contratto eventi frontend standardizzato su `title/start/end/extendedProps` per visibilita immediata in FullCalendar
- Parsing date-time lato backend compatibile con formati ISO locali e con offset timezone

3. Rubrica pazienti (address book): **Operativa**
- Endpoint `/address-book` e pagina creazione
- Controller dedicato con DAO pazienti

4. Storico trattamenti: **Operativa/Parziale**
- Endpoint `/treatment-history` presente
- Modello e DAO disponibili
- Da consolidare copertura dei casi limite e validazioni trasversali

5. Area amministrativa utenti: **Operativa (base)**
- Dashboard admin e creazione nuovo utente
- Controller dedicato (`UserController`)
- Da raffinare UX e policy di gestione errori

6. Registrazione pubblica: **UI pronta, integrazione backend da verificare**
- Pagina `/register` presente
- Necessaria verifica end-to-end sul flusso di persistenza e validazioni

## Persistenza e dati
- Modalita attiva: MySQL
- Script schema disponibile: `src/main/resources/db.sql`
- Seed utenti test disponibile: `src/main/resources/seed_test_users.sql`
- Entita terapista gestita tramite tabella `users` (role-based), senza tabella `therapists`

## Sicurezza e sessione
- Hash password previsto con SHA-256 (config + utilita `PasswordHasher`)
- Timeout sessione configurato in properties (`security.session.timeout=1800`), da allineare con configurazione effettiva servlet/session management
- Mancano ancora evidenze di autorizzazioni centralizzate per proteggere tutte le route riservate

## Allineamento codice-configurazione
Punti coerenti:
- Modello dominio allineato allo schema SQL (users, patients, appointments, treatment_sessions)
- Frontend calendario allineato a endpoint JSON `/calendar`

Punti da consolidare:
- Uso reale delle properties in bootstrap (persistenza, timeout, slot calendario)
- Hardening della gestione errori HTTP lato servlet
- Verifica copertura test automatizzati (unit/integration)

## Rischi tecnici correnti
1. Wiring manuale senza container DI: crescita complessita di inizializzazione e test.
2. Configurazione non pienamente applicata a runtime: possibile drift tra file config e comportamento reale.
3. Sicurezza applicativa distribuita nelle servlet: rischio inconsistenze autorizzative.
4. Assenza di baseline test esplicita: rischio regressioni su flussi core.

## Guida pratica per aggiornare questo documento
Aggiornare il file quando cambia almeno uno di questi elementi:
- struttura dei layer o package;
- contract HTTP (endpoint, payload, codici risposta);
- modello dominio o schema DB;
- decisioni su persistenza, sicurezza o bootstrap;
- stato capability (Operativa, Operativa/Parziale, UI pronta, Non avviata).

Formato raccomandato:
- descrivere prima il comportamento reale in produzione/sviluppo;
- poi indicare gap o rischi architetturali;
- evitare checklist di task minute.
