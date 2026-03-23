package it.SimoSW.model.dao.database;

import it.SimoSW.model.PatientCondition;
import it.SimoSW.model.dao.PatientConditionDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public class DatabasePatientConditionDAO implements PatientConditionDAO {

    private static final String INSERT_CONDITION = """
            INSERT INTO patient_conditions (anamnesis_id, category, code, label, status, notes)
            VALUES (?, ?, ?, ?, ?, ?)
            """;

    @Override
    public void saveAll(long anamnesisId, List<PatientCondition> conditions) {
        if (conditions == null || conditions.isEmpty()) {
            return;
        }

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_CONDITION)) {

            for (PatientCondition condition : conditions) {
                stmt.setLong(1, anamnesisId);
                stmt.setString(2, condition.getCategory().name());
                stmt.setString(3, condition.getCode());
                stmt.setString(4, condition.getLabel());
                stmt.setString(5, condition.getStatus());
                stmt.setString(6, condition.getNotes());
                stmt.addBatch();
            }

            stmt.executeBatch();
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il salvataggio delle condizioni anamnestiche", e);
        }
    }
}
