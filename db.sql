-- 🔥 Elimina il database se esiste
DROP DATABASE IF EXISTS crm_fisioterapia;

-- 🏗️ Crea il database
CREATE DATABASE crm_fisioterapia
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 👤 Crea l'utente (opzionale)
CREATE USER IF NOT EXISTS 'crm_user'@'localhost'
IDENTIFIED BY 'password_123';

-- 🛡️ Concedi i permessi
GRANT ALL PRIVILEGES ON crm_fisioterapia.* TO 'crm_user'@'localhost';

-- 💾 Rendi effettive le modifiche
FLUSH PRIVILEGES;

-- 📂 Seleziona il database
USE crm_fisioterapia;

-- 🩺 Tabella Pazienti
CREATE TABLE pazienti (
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

-- 📅 Tabella Eventi (ora id_paziente è FACOLTATIVO)
CREATE TABLE eventi (
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

-- 💆 Tabella Sedute (collegate agli Eventi)
CREATE TABLE sedute (
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

-- 👁️ View: unione Eventi + Sedute + Pazienti (anche se paziente è NULL)
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
