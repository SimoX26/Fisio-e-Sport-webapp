-- Drop and recreate database
DROP DATABASE IF EXISTS fisio_e_sport;

CREATE DATABASE fisio_e_sport
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Optional local DB user bootstrap
CREATE USER IF NOT EXISTS 'fisio_e_sport'@'localhost'
IDENTIFIED BY 'password_123';

GRANT ALL PRIVILEGES ON fisio_e_sport.* TO 'fisio_e_sport'@'localhost';
FLUSH PRIVILEGES;

USE fisio_e_sport;

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  role ENUM('THERAPIST', 'ADMIN') NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- PATIENTS
-- =========================
CREATE TABLE patients (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150),
  phone VARCHAR(20),
  state ENUM('ACTIVE', 'INACTIVE', 'ARCHIVED') NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- APPOINTMENTS
-- =========================
CREATE TABLE appointments (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  therapist_id BIGINT NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  state ENUM('SCHEDULED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'SCHEDULED',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_appointments_patient
    FOREIGN KEY (patient_id) REFERENCES patients(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  CONSTRAINT fk_appointments_therapist
    FOREIGN KEY (therapist_id) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- =========================
-- TREATMENT SESSIONS
-- =========================
CREATE TABLE treatment_sessions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  appointment_id BIGINT NOT NULL,
  patient_id BIGINT NOT NULL,
  therapist_id BIGINT NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  notes TEXT,
  state ENUM('IN_PROGRESS', 'COMPLETED') NOT NULL DEFAULT 'IN_PROGRESS',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_treatment_sessions_appointment UNIQUE (appointment_id),

  CONSTRAINT fk_treatment_sessions_appointment
    FOREIGN KEY (appointment_id) REFERENCES appointments(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_treatment_sessions_patient
    FOREIGN KEY (patient_id) REFERENCES patients(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  CONSTRAINT fk_treatment_sessions_therapist
    FOREIGN KEY (therapist_id) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
