DROP DATABASE IF EXISTS fisio_e_sport;

CREATE DATABASE fisio_e_sport
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'fisio_e_sport'@'localhost'
IDENTIFIED BY 'password_123';

GRANT ALL PRIVILEGES ON fisio_e_sport.* TO 'fisio_e_sport'@'localhost';

FLUSH PRIVILEGES;

USE fisio_e_sport;



CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  role ENUM('PHYSIOTHERAPIST', 'ADMIN') NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE patient (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome_completo VARCHAR(200) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  email VARCHAR(150),
  data_nascita DATE,
  cautele TEXT,

  -- Campi clinici dettagliati
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
  intensita TINYINT,
  farmaci TEXT,
  esami TEXT,
  visite TEXT,
  farmaci_regolari TEXT,
  interventi TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE appointment (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_paziente INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  start DATETIME NOT NULL,
  end DATETIME NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (id_paziente) REFERENCES pazienti(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);



CREATE TABLE treatment_session (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_evento INT NOT NULL,
  valutazione_pre_trattamento TEXT NOT NULL,
  note_post_trattamento TEXT,
  durata_minuti INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (id_evento) REFERENCES eventi(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);



CREATE OR REPLACE VIEW vista_eventi_sedute AS
SELECT
  e.id AS id_evento,
  p.id AS id_paziente,
  p.nome_completo,
  e.start,
  e.end,
  e.title,
  e.note AS note_evento,
  s.id AS id_seduta,
  s.valutazione_pre_trattamento,
  s.note_post_trattamento,
  s.durata_minuti
FROM eventi e
LEFT JOIN pazienti p ON e.id_paziente = p.id
LEFT JOIN sedute s ON s.id_evento = e.id;
