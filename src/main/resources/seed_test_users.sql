-- Seed utenti test per login applicativo
-- Database target: fisio_e_sport
-- Tabella target: users
--
-- Password in chiaro:
-- therapist.test -> therapist123
-- admin.test     -> admin123
-- disabled.test  -> test1234 (utente disattivato per test)

USE fisio_e_sport;

INSERT INTO users (username, password_hash, role, active)
VALUES
    ('therapist.test', 'c108533d4511b3e7263207ace80f6b4be9dd983898514f1dbc075c9b6a83bae1', 'THERAPIST', TRUE),
    ('admin.test',     '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'ADMIN', TRUE),
    ('disabled.test',  '937e8d5fbb48bd4949536cd65b8d35c426b80d2f830c5c308e2cdec422ae2244', 'THERAPIST', FALSE)
ON DUPLICATE KEY UPDATE
    password_hash = VALUES(password_hash),
    role = VALUES(role),
    active = VALUES(active);

-- Verifica rapida
SELECT id, username, role, active
FROM users
WHERE username IN ('therapist.test', 'admin.test', 'disabled.test')
ORDER BY username;
