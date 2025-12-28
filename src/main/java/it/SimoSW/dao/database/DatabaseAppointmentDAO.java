package it.SimoSW.dao.database;

import it.SimoSW.dao.AppointmentDAO;
import it.SimoSW.model.Appointment;
import it.SimoSW.model.AppointmentState;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class DatabaseAppointmentDAO implements AppointmentDAO {

    @Override
    public Appointment save(Appointment appointment) {

        String sql = """
            INSERT INTO appointments
            (patient_id, therapist_id, start_time, end_time, state)
            VALUES (?, ?, ?, ?, ?)
        """;

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, appointment.getPatientId());
            ps.setLong(2, appointment.getTherapistId());
            ps.setTimestamp(3, Timestamp.valueOf(appointment.getStart()));
            ps.setTimestamp(4, Timestamp.valueOf(appointment.getEnd()));
            ps.setString(5, appointment.getState().name());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    appointment.setId(keys.getLong(1));
                }
            }

            return appointment;

        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il salvataggio dell'appuntamento", e);
        }
    }


    @Override
    public Appointment update(Appointment appointment) {

        String sql = """
            UPDATE appointments
            SET patient_id = ?,
                therapist_id = ?,
                start_time = ?,
                end_time = ?,
                state = ?
            WHERE id = ?
        """;

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, appointment.getPatientId());
            ps.setLong(2, appointment.getTherapistId());
            ps.setTimestamp(3, Timestamp.valueOf(appointment.getStart()));
            ps.setTimestamp(4, Timestamp.valueOf(appointment.getEnd()));
            ps.setString(5, appointment.getState().name());
            ps.setLong(6, appointment.getId());

            int updatedRows = ps.executeUpdate();

            if (updatedRows == 0) {
                throw new RuntimeException(
                        "Nessun appuntamento aggiornato, id non trovato: " + appointment.getId()
                );
            }

            return appointment;

        } catch (SQLException e) {
            throw new RuntimeException("Errore durante l'update dell'appuntamento", e);
        }
    }


    @Override
    public Optional<Appointment> findById(long id) {

        String sql = "SELECT * FROM appointments WHERE id = ?";

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
                return Optional.empty();
            }

        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il recupero dell'appuntamento", e);
        }
    }


    @Override
    public List<Appointment> findInPeriod(LocalDateTime start, LocalDateTime end) {

        String sql = """
            SELECT * FROM appointments
            WHERE start_time >= ? AND end_time <= ?
            ORDER BY start_time
        """;

        List<Appointment> result = new ArrayList<>();

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(start));
            ps.setTimestamp(2, Timestamp.valueOf(end));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(mapRow(rs));
                }
            }

            return result;

        } catch (SQLException e) {
            throw new RuntimeException("Errore caricamento appuntamenti nel periodo", e);
        }
    }


    @Override
    public List<Appointment> findByTherapistInPeriod(long therapistId, LocalDateTime start, LocalDateTime end) {
        String sql = """
            SELECT * FROM appointments
            WHERE therapist_id = ?
              AND start_time >= ?
              AND end_time <= ?
            ORDER BY start_time
        """;

        List<Appointment> result = new ArrayList<>();

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, therapistId);
            ps.setTimestamp(2, Timestamp.valueOf(start));
            ps.setTimestamp(3, Timestamp.valueOf(end));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(mapRow(rs));
                }
            }

            return result;

        } catch (SQLException e) {
            throw new RuntimeException("Errore caricamento appuntamenti terapista", e);
        }
    }

    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getLong("id"));
        a.setPatientId(rs.getLong("patient_id"));
        a.setTherapistId(rs.getLong("therapist_id"));
        a.setStart(rs.getTimestamp("start_time").toLocalDateTime());
        a.setEnd(rs.getTimestamp("end_time").toLocalDateTime());
        a.setState(AppointmentState.valueOf(rs.getString("state")));
        return a;
    }
}
