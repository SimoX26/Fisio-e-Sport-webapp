-- Migrazione non distruttiva: passaggio invio WhatsApp a gateway locale Baileys.
-- Non sono richieste modifiche schema per Baileys:
-- - la configurazione del gateway vive in src/main/resources/config.properties;
-- - la sessione WhatsApp vive in baileys-service/auth-session/;
-- - i dati applicativi esistenti restano invariati.
--
-- Nota: se in un database esistente e ancora presente la vecchia tabella
-- whatsapp_business_configs, questa migrazione la lascia intatta per evitare
-- qualunque perdita di dati storici/configurativi.

USE fisio_e_sport;

START TRANSACTION;

SELECT 'WhatsApp Baileys: nessuna modifica schema necessaria, dati esistenti non toccati.' AS migration_note;

COMMIT;
