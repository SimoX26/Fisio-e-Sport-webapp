package it.SimoSW.model.dao.database;

import it.SimoSW.model.Patient;
import it.SimoSW.model.PatientState;
import it.SimoSW.model.dao.PatientDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class DatabasePatientDAO implements PatientDAO {

    private static final String INSERT_PATIENT = """
            INSERT INTO patients (first_name, last_name, email, phone, state)
            VALUES (?, ?, ?, ?, ?)
            """;

    private static final String UPDATE_PATIENT = """
            UPDATE patients
            SET first_name = ?,
                last_name = ?,
                email = ?,
                phone = ?,
                state = ?
            WHERE id = ?
            """;

    private static final String FIND_BY_ID = """
            SELECT p.id, p.first_name, p.last_name, p.email, p.phone, p.state, p.created_at,
                   (SELECT COUNT(*) FROM appointments a WHERE a.patient_id = p.id) AS linked_appointments_count
            FROM patients p
            WHERE id = ?
            """;

    private static final String SEARCH_ALL = """
            SELECT p.id, p.first_name, p.last_name, p.email, p.phone, p.state, p.created_at,
                   (SELECT COUNT(*) FROM appointments a WHERE a.patient_id = p.id) AS linked_appointments_count
            FROM patients p
            ORDER BY p.last_name, p.first_name
            """;

    private static final String SEARCH_BY_QUERY = """
            SELECT p.id, p.first_name, p.last_name, p.email, p.phone, p.state, p.created_at,
                   (SELECT COUNT(*) FROM appointments a WHERE a.patient_id = p.id) AS linked_appointments_count
            FROM patients p
            WHERE LOWER(p.first_name) LIKE ?
               OR LOWER(p.last_name) LIKE ?
               OR LOWER(CONCAT(p.first_name, ' ', p.last_name)) LIKE ?
               OR LOWER(COALESCE(p.email, '')) LIKE ?
               OR LOWER(COALESCE(p.phone, '')) LIKE ?
            ORDER BY p.last_name, p.first_name
            """;

    private static final String DELETE_BY_ID = """
            DELETE FROM patients
            WHERE id = ?
            """;

    private static final String MERGE_APPOINTMENTS = """
            UPDATE appointments
            SET patient_id = ?,
                title = CASE
                    WHEN title IS NULL OR TRIM(title) = '' THEN NULL
                    ELSE title
                END
            WHERE patient_id = ?
            """;

    private static final String MERGE_ANAMNESES = """
            UPDATE patient_anamneses
            SET patient_id = ?
            WHERE patient_id = ?
            """;

    private static final String MERGE_TREATMENT_PLANS = """
            UPDATE treatment_plans
            SET patient_id = ?
            WHERE patient_id = ?
            """;

    private static final String MERGE_TREATMENT_SESSIONS = """
            UPDATE treatment_sessions
            SET patient_id = ?
            WHERE patient_id = ?
            """;

    @Override
    public Patient save(Patient patient) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_PATIENT, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, patient.getFirstName());
            stmt.setString(2, patient.getLastName());
            stmt.setString(3, patient.getEmail());
            stmt.setString(4, patient.getPhone());
            stmt.setString(5, patient.getState().name());

            stmt.executeUpdate();

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    patient.setId(keys.getLong(1));
                }
            }

            return patient;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il salvataggio del paziente", e);
        }
    }

    @Override
    public Patient update(Patient patient) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_PATIENT)) {

            stmt.setString(1, patient.getFirstName());
            stmt.setString(2, patient.getLastName());
            stmt.setString(3, patient.getEmail());
            stmt.setString(4, patient.getPhone());
            stmt.setString(5, patient.getState().name());
            stmt.setLong(6, patient.getId());

            int updatedRows = stmt.executeUpdate();
            if (updatedRows == 0) {
                throw new RuntimeException("Nessun paziente aggiornato, id non trovato: " + patient.getId());
            }

            return patient;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante l'aggiornamento del paziente", e);
        }
    }

    @Override
    public Optional<Patient> findById(long id) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(FIND_BY_ID)) {

            stmt.setLong(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return Optional.empty();
                }
                return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il recupero del paziente", e);
        }
    }

    @Override
    public List<Patient> search(String query) {
        String normalized = query == null ? "" : query.trim().toLowerCase();

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     normalized.isEmpty() ? SEARCH_ALL : SEARCH_BY_QUERY
             )) {

            if (!normalized.isEmpty()) {
                String like = "%" + normalized + "%";
                stmt.setString(1, like);
                stmt.setString(2, like);
                stmt.setString(3, like);
                stmt.setString(4, like);
                stmt.setString(5, like);
            }

            List<Patient> result = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.add(mapRow(rs));
                }
            }
            return result;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante la ricerca dei pazienti", e);
        }
    }

    @Override
    public void deleteById(long id) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(DELETE_BY_ID)) {

            stmt.setLong(1, id);
            int deletedRows = stmt.executeUpdate();
            if (deletedRows == 0) {
                throw new RuntimeException("Nessun paziente eliminato, id non trovato: " + id);
            }

        } catch (SQLIntegrityConstraintViolationException e) {
            throw new RuntimeException("Impossibile eliminare il paziente: esistono dati clinici o trattamenti ancora collegati", e);
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante l'eliminazione del paziente", e);
        }
    }

    @Override
    public void mergeInto(long sourcePatientId, long targetPatientId) {
        if (sourcePatientId <= 0 || targetPatientId <= 0 || sourcePatientId == targetPatientId) {
            throw new IllegalArgumentException("Parametri merge non validi");
        }

        try (Connection conn = ConnectionFactory.getConnection()) {
            boolean originalAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            try {
                if (!existsById(conn, sourcePatientId) || !existsById(conn, targetPatientId)) {
                    throw new RuntimeException("Paziente origine o destinazione non trovato");
                }

                executeUpdate(conn, MERGE_APPOINTMENTS, targetPatientId, sourcePatientId);
                executeUpdate(conn, MERGE_ANAMNESES, targetPatientId, sourcePatientId);
                executeUpdate(conn, MERGE_TREATMENT_PLANS, targetPatientId, sourcePatientId);
                executeUpdate(conn, MERGE_TREATMENT_SESSIONS, targetPatientId, sourcePatientId);

                try (PreparedStatement deleteStmt = conn.prepareStatement(DELETE_BY_ID)) {
                    deleteStmt.setLong(1, sourcePatientId);
                    int deletedRows = deleteStmt.executeUpdate();
                    if (deletedRows == 0) {
                        throw new RuntimeException("Nessun paziente eliminato durante il merge");
                    }
                }

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(originalAutoCommit);
            }
        } catch (SQLIntegrityConstraintViolationException e) {
            throw new RuntimeException("Merge non riuscito per vincoli di integrita referenziale", e);
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il merge pazienti", e);
        }
    }

    private void executeUpdate(Connection conn, String sql, long targetId, long sourceId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, targetId);
            stmt.setLong(2, sourceId);
            stmt.executeUpdate();
        }
    }

    private boolean existsById(Connection conn, long patientId) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement("SELECT 1 FROM patients WHERE id = ?")) {
            stmt.setLong(1, patientId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Patient mapRow(ResultSet rs) throws SQLException {
        Patient patient = new Patient();
        patient.setId(rs.getLong("id"));
        patient.setFirstName(rs.getString("first_name"));
        patient.setLastName(rs.getString("last_name"));
        patient.setEmail(rs.getString("email"));
        patient.setPhone(rs.getString("phone"));
        patient.setState(PatientState.valueOf(rs.getString("state")));
        java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            patient.setCreatedAt(createdAt.toLocalDateTime());
        }
        patient.setLinkedAppointmentsCount(rs.getInt("linked_appointments_count"));
        return patient;
    }
}
