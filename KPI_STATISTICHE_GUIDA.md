# Guida Lettura Statistiche KPI

Questa guida spiega come interpretare la pagina **Statistiche** (`/dashboard/insights`) e l'endpoint dati (`/dashboard/kpi`).

## Origine dei dati

Le statistiche sono basate su snapshot mensili salvati in `kpi_monthly_snapshot`.
Il sistema aggiorna gli snapshot automaticamente (job notturno) per:

- mese corrente
- mese precedente

Questo approccio migliora le performance su server con risorse limitate.

## Ambiti (`scope`)

- `me`: mostra solo i KPI del terapista loggato.
- `global`: mostra i KPI aggregati globali.

## Finestra temporale

La pagina permette la selezione della finestra:

- ultimi 6 mesi
- ultimi 12 mesi
- ultimi 24 mesi

## KPI mostrati

### Completati (mese)
Numero di appuntamenti in stato `COMPLETED` nel mese selezionato.

### Nuovi pazienti (mese)
Numero di pazienti creati nel mese.
In `scope=me`, vengono conteggiati i pazienti creati nel mese che hanno almeno un appuntamento associato a quel terapista.

### Ore prenotate (mese)
Somma delle durate degli appuntamenti non cancellati nel mese, espressa in ore.

Formula:

`ore_prenotate = total_booked_minutes / 60`

### Tasso cancellazione
Percentuale di cancellazioni rispetto agli appuntamenti creati nel mese.

Formula:

`tasso_cancellazione = appointments_cancelled / appointments_created * 100`

## Grafico trend

Il grafico lineare mostra l'andamento mensile di:

- appuntamenti completati
- appuntamenti cancellati
- nuovi pazienti

## Tabella dettaglio

La tabella sotto al grafico mostra, per ogni mese della finestra selezionata:

- creati
- completati
- cancellati
- nuovi pazienti
- ore prenotate

## Note operative

- Se vedi valori a `0`, verifica che gli snapshot siano stati creati correttamente.
- Dopo deploy o modifiche importanti, è consigliato verificare che il job scheduler KPI sia attivo.
- I mesi antecedenti all'introduzione del sistema snapshot possono risultare vuoti (comportamento atteso).
