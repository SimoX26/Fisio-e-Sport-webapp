# Performance Roadmap - Fisio e Sports

## Obiettivo
Portare il gestionale a un livello di performance e stabilita elevato anche in condizioni reali (utenti concorrenti, dataset crescente, server con risorse limitate), con un piano progressivo e misurabile.

## Baseline Attuale (sintesi)
- Stack: Java Servlet + JSP + Tomcat 9 + MySQL.
- Vista critica: calendario (FullCalendar + fetch eventi).
- Server attuale: 1 vCPU / 1 GB RAM (collo di bottiglia strutturale).
- Migliorie gia introdotte:
  - filtro eventi per terapista + range vista calendario;
  - riduzione N+1 su eventi calendario con query join dedicata;
  - overlay loading piu robusto.

---

## Fase 0 - Baseline e Misurazione (prima di ogni altra ottimizzazione)
1. Definire 4 metriche target:
   - TTFB endpoint `/calendar?events=true`: target `< 300ms` in condizioni normali.
   - Tempo render vista calendario (week): target `< 1.5s` lato utente.
   - Error rate HTTP 5xx: target `< 0.5%`.
   - Saturazione CPU media: target `< 70%`.
2. Abilitare logging tempi su endpoint critici:
   - `/calendar` GET eventi
   - `/address-book`
   - `/treatment-history`
3. Creare uno script di smoke test prestazionale leggero:
   - 20 richieste sequenziali su endpoint principali
   - report min/avg/p95.
4. Salvare il baseline in un file `docs/performance-baseline.md`.

Deliverable:
- Baseline numerica e ripetibile prima/dopo ogni modifica.

---

## Fase 1 - Quick Wins ad Alto Impatto (1-3 giorni)
1. Connection Pool DB (priorita massima)
   - Sostituire `DriverManager.getConnection()` con DataSource pool (HikariCP o Tomcat JDBC Pool).
   - Parametri iniziali consigliati su server piccolo:
     - `maximumPoolSize=5`
     - `minimumIdle=1`
     - `connectionTimeout=3000`
     - `idleTimeout=60000`
2. Indici SQL per query calendario
   - Aggiungere/validare:
     - `appointments(therapist_id, start_time, end_time, state)`
     - `appointments(patient_id)`
   - Verificare con `EXPLAIN`.
3. Ridurre payload JSON eventi
   - Inviare solo campi realmente usati dal frontend.
   - Evitare campi duplicati o superflui.
4. Compressione HTTP
   - Attivare gzip/deflate su Tomcat per JSON/CSS/JS.
5. Cache browser su statici
   - Header cache lunga per `assets/*` con versioning querystring.

Deliverable:
- -30%/-60% tempo medio endpoint calendario in ambienti piccoli.

---

## Fase 2 - Ottimizzazioni Backend Applicative (3-7 giorni)
1. Estendere rimozione N+1 ad altri flussi
   - Reminder preview (evitare query ripetute per paziente/email).
   - Search/list dove ci sono lookup ripetuti in loop.
2. DTO dedicati per le viste
   - Evitare mapping di entity complete quando servono pochi campi.
3. Limiti e paginazione server-side
   - Rubrica, storico trattamenti, risultati ricerca.
4. Debounce e limiti endpoint suggerimenti
   - Endpoint pazienti: gia debounce lato client; aggiungere rate guard lato server.
5. Timeout e fallback robusti
   - Timeout per chiamate DB.
   - Messaggi utente chiari su degradazione temporanea.

Deliverable:
- Endpoint principali piu prevedibili con dataset crescente.

---

## Fase 3 - Frontend Calendario e UX Prestazionale (2-5 giorni)
1. Caricamento lazy dei blocchi non critici
   - Modali avanzate (reminder/completamento) inizializzate on-demand.
2. Minore lavoro al bootstrap pagina calendario
   - Spostare setup non essenziale dopo primo render.
3. Evitare reflow pesanti
   - Ridurre operazioni DOM in loop durante `datesSet`.
4. Soglia anti-flicker per overlay loading
   - Mostrare spinner solo se loading > 120ms.
5. Ottimizzare script delivery
   - `defer` consistente
   - bundling/minify (se introdotto pipeline build frontend).

Deliverable:
- Tempo percepito migliore su navigazione day/week/month.

---

## Fase 4 - Database Hardening (2-4 giorni)
1. Piano indici completo
   - Ricerca testuale frequente: valutare indici funzionali o fulltext dove sensato.
2. Query plan review periodica
   - `EXPLAIN ANALYZE` sulle top query.
3. Manutenzione DB
   - ANALYZE/OPTIMIZE programmati.
4. Crescita dati
   - Politica archiviazione soft per dati storici molto vecchi (se necessario).

Deliverable:
- Stabilita query nel lungo periodo.

---

## Fase 5 - Tomcat/JVM Tuning (1-2 giorni)
1. JVM sizing per server piccolo
   - Esempio iniziale:
     - `-Xms256m -Xmx512m`
     - `-XX:MaxMetaspaceSize=128m`
2. Connector tuning
   - Ridurre `maxThreads` su macchina 1 core (es. 30-50).
   - Configurare `acceptCount` coerente.
3. Keep-alive/timeout
   - evitare connessioni appese troppo lunghe.
4. Log rotation e livello log
   - evitare overhead I/O da logging eccessivo.

Deliverable:
- Riduzione OOM/rallentamenti da saturazione runtime.

---

## Fase 6 - Infrastruttura (priorita strategica)
1. Upgrade minimo consigliato
   - Da 1 vCPU / 1GB a 2 vCPU / 4GB.
2. Separazione servizi
   - App e DB su host separati (quando possibile).
3. Storage e swap
   - SSD obbligatorio.
   - swap moderata come safety net, non come soluzione.
4. Reverse proxy
   - Nginx davanti a Tomcat per compressione, cache statici, buffering.

Deliverable:
- Miglioramento strutturale della capacita e resilienza.

---

## Fase 7 - Osservabilita e Guardrail Continuo
1. Dashboard minima
   - CPU, RAM, load average, response time p95, error rate.
2. Alerting
   - alert su CPU > 85%, RAM > 90%, 5xx > soglia.
3. Performance regression check
   - mini test ad ogni release prima del deploy.

Deliverable:
- Prevenzione regressioni, non solo fix reattivi.

---

## Priorita Consigliata (ordine pratico)
1. Fase 1.1 Connection Pool.
2. Fase 1.2 Indici calendario + EXPLAIN.
3. Fase 5 JVM/Tomcat tuning.
4. Fase 2 (N+1 residui + DTO + paginazione).
5. Fase 6 upgrade infrastruttura.
6. Fase 3 UX avanzata.
7. Fase 7 osservabilita continua.

---

## Criteri di Successo
- Calendario week apre stabilmente senza timeout percepibili.
- Navigazione day/week/month fluida sotto carico reale.
- Nessun blocco applicativo su server target.
- Metriche p95 e error rate stabili per almeno 2 settimane.

---

## Note Operative
- Applicare una modifica alla volta con misurazione prima/dopo.
- Evitare deploy cumulativi grandi senza benchmark intermedio.
- Se il budget lo consente, l'upgrade hardware anticipato riduce drasticamente i tempi di tuning.
