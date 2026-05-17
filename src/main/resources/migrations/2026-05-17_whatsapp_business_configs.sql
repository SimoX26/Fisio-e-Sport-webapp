-- Migrazione: configurazione WhatsApp Business Cloud API per terapista
-- Eseguire con: source /percorso/2026-05-17_whatsapp_business_configs.sql

USE fisio_e_sport;

START TRANSACTION;

CREATE TABLE IF NOT EXISTS whatsapp_business_configs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  therapist_id BIGINT NOT NULL UNIQUE,
  access_token VARCHAR(512) NOT NULL,
  phone_number_id VARCHAR(64) NOT NULL,
  business_account_id VARCHAR(64) NOT NULL,
  daily_template_name VARCHAR(120) NOT NULL,
  weekly_template_name VARCHAR(120) NOT NULL,
  template_language VARCHAR(20) NOT NULL DEFAULT 'it',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_whatsapp_config_therapist
    FOREIGN KEY (therapist_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

COMMIT;

SELECT COUNT(*) AS whatsapp_configs FROM whatsapp_business_configs;
