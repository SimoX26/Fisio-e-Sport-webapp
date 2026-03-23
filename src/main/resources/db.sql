/* Drop and recreate database */
DROP DATABASE IF EXISTS fisio_e_sport;

CREATE DATABASE fisio_e_sport
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

/* Optional local DB user bootstrap */
CREATE USER IF NOT EXISTS 'fisio_e_sport'@'localhost'
IDENTIFIED BY 'password_123';

GRANT ALL PRIVILEGES ON fisio_e_sport.* TO 'fisio_e_sport'@'localhost';
FLUSH PRIVILEGES;

USE fisio_e_sport;

/* =========================
   USERS
   ========================= */
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  role ENUM('THERAPIST', 'ADMIN') NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

/* =========================
   REMEMBER ME TOKENS
   ========================= */
CREATE TABLE remember_me_tokens (
  user_id BIGINT PRIMARY KEY,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_remember_me_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* =========================
   PATIENTS
   ========================= */
CREATE TABLE patients (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150),
  phone VARCHAR(20),
  state ENUM('ACTIVE', 'INACTIVE', 'ARCHIVED') NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

/* =========================
   PATIENT ANAMNESES
   ========================= */
CREATE TABLE patient_anamneses (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  therapist_id BIGINT NOT NULL,
  assessment_date DATE NOT NULL,

  chief_complaint VARCHAR(255),
  pain_location VARCHAR(255),
  pain_quality VARCHAR(255),
  associated_symptoms VARCHAR(255),

  onset_type ENUM('ACUTE', 'SUBACUTE', 'CHRONIC'),
  onset_context VARCHAR(255),
  is_disabling BOOLEAN,
  pain_frequency ENUM('LOW', 'MEDIUM', 'HIGH'),
  pain_progression ENUM('CONSTANT', 'WORSE', 'BETTER'),
  pain_with_movement ENUM('WORSE', 'BETTER', 'UNCHANGED'),
  pain_with_rest ENUM('WORSE', 'BETTER', 'UNCHANGED'),
  night_pain BOOLEAN,
  morning_pain BOOLEAN,
  pain_intensity TINYINT UNSIGNED,
  uses_pain_meds BOOLEAN,
  pain_meds_effect ENUM('YES', 'NO', 'PARTIAL'),

  clinical_tests TEXT,
  specialist_visits TEXT,
  previous_treatments TEXT,
  pathology_history TEXT,
  current_regular_drugs TEXT,
  surgery_history TEXT,
  trauma_history TEXT,
  devices_history TEXT,
  chewing_disorders BOOLEAN,
  major_infections_history TEXT,
  family_history TEXT,

  height_cm DECIMAL(5,2),
  weight_kg DECIMAL(5,2),
  lifestyle ENUM('SPORTY', 'SEDENTARY', 'MIXED'),
  sport_practice VARCHAR(120),
  substance_use VARCHAR(255),
  sleep_quality TINYINT UNSIGNED,
  stress_level TINYINT UNSIGNED,
  diet_quality ENUM('HEALTHY', 'IMBALANCED', 'MIXED'),
  female_cycle_notes VARCHAR(255),

  free_notes_json JSON,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_patient_anamneses_patient_date (patient_id, assessment_date),

  CONSTRAINT fk_anamneses_patient
    FOREIGN KEY (patient_id) REFERENCES patients(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_anamneses_therapist
    FOREIGN KEY (therapist_id) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

/* =========================
   PATIENT CONDITIONS
   ========================= */
CREATE TABLE patient_conditions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  anamnesis_id BIGINT NOT NULL,
  category ENUM('PATHOLOGY', 'SYMPTOM', 'FAMILY_HISTORY', 'ALLERGY', 'DRUG', 'SYSTEM_REVIEW', 'OTHER') NOT NULL,
  code VARCHAR(80),
  label VARCHAR(120) NOT NULL,
  status ENUM('PRESENT', 'ABSENT', 'UNKNOWN') NOT NULL DEFAULT 'PRESENT',
  notes VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_patient_conditions_anamnesis_category (anamnesis_id, category),

  CONSTRAINT fk_conditions_anamnesis
    FOREIGN KEY (anamnesis_id) REFERENCES patient_anamneses(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

/* =========================
   APPOINTMENTS
   ========================= */
CREATE TABLE appointments (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  therapist_id BIGINT NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  notes TEXT,
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

/* =========================
   TREATMENT SESSIONS
   ========================= */
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
