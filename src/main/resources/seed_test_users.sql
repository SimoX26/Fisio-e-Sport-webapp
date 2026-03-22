/* Seed utenti test per login applicativo
   Database target: fisio_e_sport
   Tabella target: users

   Password in chiaro:
   marco   -> 1234
   andrea  -> 1234
   jessica -> 1234 (utente disattivato per test) */

USE fisio_e_sport;

INSERT INTO users (username, password_hash, role, active)
VALUES
    ('marco', SHA2('1234', 256), 'THERAPIST', TRUE),
    ('andrea', SHA2('1234', 256), 'ADMIN', TRUE),
    ('jessica', SHA2('1234', 256), 'THERAPIST', FALSE)
ON DUPLICATE KEY UPDATE
    password_hash = VALUES(password_hash),
    role = VALUES(role),
    active = VALUES(active);

/* Verifica rapida post-seed (password_ok deve essere 1 per tutti) */
SELECT username, role, active, (password_hash = SHA2('1234', 256)) AS password_ok
FROM users
WHERE username IN ('marco', 'andrea', 'jessica')
ORDER BY username;
