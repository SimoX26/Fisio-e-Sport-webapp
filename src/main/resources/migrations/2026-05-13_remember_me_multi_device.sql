-- Migrazione safe: abilita token remember-me multipli per utente (multi-dispositivo)
-- Eseguire con: source /percorso/2026-05-13_remember_me_multi_device.sql

USE fisio_e_sport;

START TRANSACTION;

-- Pulizia eventuali residui da esecuzioni precedenti fallite
DROP TABLE IF EXISTS remember_me_tokens_new;
DROP TABLE IF EXISTS remember_me_tokens_backup_20260513;

CREATE TABLE IF NOT EXISTS remember_me_tokens_new (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_remember_me_user_id (user_id),
  CONSTRAINT fk_remember_me_user_new
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

INSERT INTO remember_me_tokens_new (user_id, token_hash, expires_at, created_at)
SELECT user_id, token_hash, expires_at, created_at
FROM remember_me_tokens;

RENAME TABLE remember_me_tokens TO remember_me_tokens_backup_20260513,
             remember_me_tokens_new TO remember_me_tokens;

COMMIT;

-- Verifica rapida
SELECT COUNT(*) AS tokens_totali FROM remember_me_tokens;
