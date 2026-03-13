-- Seed utenti test per login applicativo
-- Database target: fisio_e_sport
-- Tabella target: users
--
-- Password in chiaro:
-- marco   -> 1234
-- andrea  -> 1234
-- jessica -> 1234 (utente disattivato per test)

USE fisio_e_sport;

INSERT INTO users (username, password_hash, role, active)
VALUES
    ('marco', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'THERAPIST', TRUE),
    ('andrea', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'ADMIN', TRUE),
    ('jessica', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'THERAPIST', FALSE)
ON DUPLICATE KEY UPDATE
    password_hash = VALUES(password_hash),
    role = VALUES(role),
    active = VALUES(active);
