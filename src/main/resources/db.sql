-- 🔥 Elimina il database se esiste
DROP DATABASE IF EXISTS fisio_e_sport;

-- 🏗️ Crea il database
CREATE DATABASE fisio_e_sport
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 👤 Crea l'utente DB
CREATE USER IF NOT EXISTS 'fisio_e_sport'@'localhost'
IDENTIFIED BY 'password_123';

-- 🛡️ Permessi (semplificati per progetto universitario)
GRANT ALL PRIVILEGES ON fisio_e_sport.* TO 'fisio_e_sport'@'localhost';

FLUSH PRIVILEGES;

-- 📂 Usa il database
USE fisio_e_sport;

-- =========================
-- 👤 USERS (AUTENTICAZIONE)
-- =========================
CREATE TABLE user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  role ENUM('PHYSIOTHERAPIST', 'ADMIN') NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 🩺 PATIENT
-- =========================
CREATE TABLE patient (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome_completo VARCHAR(200) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  email VARCHAR(150),
  data_nascita DATE,
  cautele TEXT,

  -- Campi clinici
  motivo_consulto TEXT,
  localizzazione TEXT,
  tipologia_dolore TEXT,
  insorgenza TEXT,
  causa_presunta TEXT,
  invalidante TEXT,
  frequenza TEXT,
  progressione TEXT,
  dolore_movimento TEXT,
  dolore_riposo TEXT,
  dolore_notturno TEXT,
  intensita TINYINT CHECK (intensita BETWEEN 0 AND 10),
  farmaci TEXT,
  esami TEXT,
  visite TEXT,
  farmaci_regolari TEXT,
  interventi TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 📅 APPOINTMENT (CALENDARIO)
-- =========================
CREATE TABLE appointment (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  start DATETIME NOT NULL,
  end DATETIME NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_appointment_patient
    FOREIGN KEY (patient_id) REFERENCES patient(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- =========================
-- 💆 TREATMENT SESSION
-- =========================
CREATE TABLE treatment_session (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  valutazione_pre_trattamento TEXT NOT NULL,
  note_post_trattamento TEXT,
  durata_minuti INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_treatment_session_appointment
    FOREIGN KEY (appointment_id) REFERENCES appointment(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- =========================
-- 👁️ VIEW: APPOINTMENT + PATIENT + TREATMENT
-- =========================
CREATE OR REPLACE VIEW appointment_overview AS
SELECT
  a.id AS appointment_id,
  p.id AS patient_id,
  p.nome_completo,
  a.start,
  a.end,
  a.title,
  a.note AS appointment_note,
  ts.id AS treatment_session_id,
  ts.valutazione_pre_trattamento,
  ts.note_post_trattamento,
  ts.durata_minuti
FROM appointment a
JOIN patient p ON a.patient_id = p.id
LEFT JOIN treatment_session ts ON ts.appointment_id = a.id;
