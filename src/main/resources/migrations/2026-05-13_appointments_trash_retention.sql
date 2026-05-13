-- Migrazione safe: supporto cestino appuntamenti con retention automatica 30 giorni
-- Eseguire con: source /percorso/2026-05-13_appointments_trash_retention.sql

USE fisio_e_sport;

START TRANSACTION;

ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS cancelled_at DATETIME NULL;

-- Backfill: per gli appuntamenti gia cancellati senza data, impostiamo ora corrente
-- cosi non vengono eliminati subito dalla retention automatica.
UPDATE appointments
SET cancelled_at = NOW()
WHERE state = 'CANCELLED'
  AND cancelled_at IS NULL;

COMMIT;

SELECT COUNT(*) AS cancelled_with_timestamp
FROM appointments
WHERE state = 'CANCELLED' AND cancelled_at IS NOT NULL;
