package it.SimoSW.model.dao.database;

import it.SimoSW.model.Therapist;
import it.SimoSW.model.dao.TherapistDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class DatabaseTherapistDAO implements TherapistDAO {

    private static final String INSERT_THERAPIST = """
            INSERT INTO therapists (first_name, last_name, specialization)
            VALUES (?, ?, ?)
            """;

    private static final String UPDATE_THERAPIST = """
            UPDATE therapists
            SET first_name = ?,
                last_name = ?,
                specialization = ?
            WHERE id = ?
            """;

    private static final String FIND_BY_ID = """
            SELECT id, first_name, last_name, specialization
            FROM therapists
            WHERE id = ?
            """;

    private static final String FIND_ALL = """
            SELECT id, first_name, last_name, specialization
            FROM therapists
            ORDER BY last_name, first_name
            """;

    @Override
    public Therapist save(Therapist therapist) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_THERAPIST, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, therapist.getFirstName());
            stmt.setString(2, therapist.getLastName());
            stmt.setString(3, therapist.getSpecialization());

            stmt.executeUpdate();

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    therapist.setId(keys.getLong(1));
                }
            }

            return therapist;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il salvataggio del terapista", e);
        }
    }

    @Override
    public Therapist update(Therapist therapist) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_THERAPIST)) {

            stmt.setString(1, therapist.getFirstName());
            stmt.setString(2, therapist.getLastName());
            stmt.setString(3, therapist.getSpecialization());
            stmt.setLong(4, therapist.getId());

            int updatedRows = stmt.executeUpdate();
            if (updatedRows == 0) {
                throw new RuntimeException("Nessun terapista aggiornato, id non trovato: " + therapist.getId());
            }

            return therapist;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante l'aggiornamento del terapista", e);
        }
    }

    @Override
    public Optional<Therapist> findById(long id) {
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
            throw new RuntimeException("Errore durante il recupero del terapista", e);
        }
    }

    @Override
    public List<Therapist> findAll() {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(FIND_ALL);
             ResultSet rs = stmt.executeQuery()) {

            List<Therapist> result = new ArrayList<>();
            while (rs.next()) {
                result.add(mapRow(rs));
            }
            return result;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il caricamento dei terapisti", e);
        }
    }

    private Therapist mapRow(ResultSet rs) throws SQLException {
        Therapist therapist = new Therapist();
        therapist.setId(rs.getLong("id"));
        therapist.setFirstName(rs.getString("first_name"));
        therapist.setLastName(rs.getString("last_name"));
        therapist.setSpecialization(rs.getString("specialization"));
        return therapist;
    }
}
