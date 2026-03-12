package it.SimoSW.model.dao.database;

import it.SimoSW.model.Patient;
import it.SimoSW.model.PatientState;
import it.SimoSW.model.dao.PatientDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
            SELECT id, first_name, last_name, email, phone, state
            FROM patients
            WHERE id = ?
            """;

    private static final String SEARCH_ALL = """
            SELECT id, first_name, last_name, email, phone, state
            FROM patients
            ORDER BY last_name, first_name
            """;

    private static final String SEARCH_BY_QUERY = """
            SELECT id, first_name, last_name, email, phone, state
            FROM patients
            WHERE LOWER(first_name) LIKE ?
               OR LOWER(last_name) LIKE ?
               OR LOWER(CONCAT(first_name, ' ', last_name)) LIKE ?
               OR LOWER(COALESCE(email, '')) LIKE ?
               OR LOWER(COALESCE(phone, '')) LIKE ?
            ORDER BY last_name, first_name
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

    private Patient mapRow(ResultSet rs) throws SQLException {
        Patient patient = new Patient();
        patient.setId(rs.getLong("id"));
        patient.setFirstName(rs.getString("first_name"));
        patient.setLastName(rs.getString("last_name"));
        patient.setEmail(rs.getString("email"));
        patient.setPhone(rs.getString("phone"));
        patient.setState(PatientState.valueOf(rs.getString("state")));
        return patient;
    }
}
