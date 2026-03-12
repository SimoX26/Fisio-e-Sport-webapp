package it.SimoSW.model.dao.database;

import it.SimoSW.model.TreatmentSession;
import it.SimoSW.model.TreatmentSessionState;
import it.SimoSW.model.dao.TreatmentSessionDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class DatabaseTreatmentSessionDAO implements TreatmentSessionDAO {

    private static final String INSERT_SESSION = """
            INSERT INTO treatment_sessions
            (appointment_id, patient_id, therapist_id, start_time, end_time, notes, state)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;

    private static final String UPDATE_SESSION = """
            UPDATE treatment_sessions
            SET appointment_id = ?,
                patient_id = ?,
                therapist_id = ?,
                start_time = ?,
                end_time = ?,
                notes = ?,
                state = ?
            WHERE id = ?
            """;

    private static final String FIND_BY_ID = """
            SELECT id, appointment_id, patient_id, therapist_id, start_time, end_time, notes, state
            FROM treatment_sessions
            WHERE id = ?
            """;

    private static final String FIND_BY_APPOINTMENT_ID = """
            SELECT id, appointment_id, patient_id, therapist_id, start_time, end_time, notes, state
            FROM treatment_sessions
            WHERE appointment_id = ?
            """;

    private static final String FIND_BY_PATIENT_ID = """
            SELECT id, appointment_id, patient_id, therapist_id, start_time, end_time, notes, state
            FROM treatment_sessions
            WHERE patient_id = ?
            ORDER BY start_time DESC
            """;

    @Override
    public TreatmentSession save(TreatmentSession session) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_SESSION, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, session.getAppointmentId());
            stmt.setLong(2, session.getPatientId());
            stmt.setLong(3, session.getTherapistId());
            stmt.setTimestamp(4, Timestamp.valueOf(session.getStart()));
            stmt.setTimestamp(5, Timestamp.valueOf(session.getEnd()));
            stmt.setString(6, session.getNotes());
            stmt.setString(7, session.getState().name());

            stmt.executeUpdate();

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    session.setId(keys.getLong(1));
                }
            }

            return session;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il salvataggio della sessione", e);
        }
    }

    @Override
    public TreatmentSession update(TreatmentSession session) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_SESSION)) {

            stmt.setLong(1, session.getAppointmentId());
            stmt.setLong(2, session.getPatientId());
            stmt.setLong(3, session.getTherapistId());
            stmt.setTimestamp(4, Timestamp.valueOf(session.getStart()));
            stmt.setTimestamp(5, Timestamp.valueOf(session.getEnd()));
            stmt.setString(6, session.getNotes());
            stmt.setString(7, session.getState().name());
            stmt.setLong(8, session.getId());

            int updatedRows = stmt.executeUpdate();
            if (updatedRows == 0) {
                throw new RuntimeException("Nessuna sessione aggiornata, id non trovato: " + session.getId());
            }

            return session;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante l'aggiornamento della sessione", e);
        }
    }

    @Override
    public Optional<TreatmentSession> findById(long id) {
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
            throw new RuntimeException("Errore durante il recupero della sessione", e);
        }
    }

    @Override
    public Optional<TreatmentSession> findByAppointmentId(long appointmentId) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(FIND_BY_APPOINTMENT_ID)) {

            stmt.setLong(1, appointmentId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return Optional.empty();
                }
                return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il recupero della sessione per appointment", e);
        }
    }

    @Override
    public List<TreatmentSession> findByPatientId(long patientId) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(FIND_BY_PATIENT_ID)) {

            stmt.setLong(1, patientId);

            List<TreatmentSession> result = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.add(mapRow(rs));
                }
            }
            return result;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il recupero delle sessioni paziente", e);
        }
    }

    private TreatmentSession mapRow(ResultSet rs) throws SQLException {
        TreatmentSession session = new TreatmentSession();
        session.setId(rs.getLong("id"));
        session.setAppointmentId(rs.getLong("appointment_id"));
        session.setPatientId(rs.getLong("patient_id"));
        session.setTherapistId(rs.getLong("therapist_id"));
        session.setStart(rs.getTimestamp("start_time").toLocalDateTime());
        session.setEnd(rs.getTimestamp("end_time").toLocalDateTime());
        session.setNotes(rs.getString("notes"));
        session.setState(TreatmentSessionState.valueOf(rs.getString("state")));
        return session;
    }
}
