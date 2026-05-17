package it.SimoSW.model.dao.database;

import it.SimoSW.model.WhatsAppBusinessConfig;
import it.SimoSW.model.dao.WhatsAppBusinessConfigDAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Optional;

public class DatabaseWhatsAppBusinessConfigDAO implements WhatsAppBusinessConfigDAO {

    private static final String FIND_BY_THERAPIST_ID = """
            SELECT id, therapist_id, access_token, phone_number_id, business_account_id,
                   daily_template_name, weekly_template_name, template_language
            FROM whatsapp_business_configs
            WHERE therapist_id = ?
            """;

    private static final String INSERT = """
            INSERT INTO whatsapp_business_configs
            (therapist_id, access_token, phone_number_id, business_account_id,
             daily_template_name, weekly_template_name, template_language)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;

    private static final String UPDATE = """
            UPDATE whatsapp_business_configs
            SET access_token = ?,
                phone_number_id = ?,
                business_account_id = ?,
                daily_template_name = ?,
                weekly_template_name = ?,
                template_language = ?
            WHERE therapist_id = ?
            """;

    @Override
    public Optional<WhatsAppBusinessConfig> findByTherapistId(long therapistId) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(FIND_BY_THERAPIST_ID)) {

            stmt.setLong(1, therapistId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return Optional.empty();
                }
                return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il recupero configurazione WhatsApp", e);
        }
    }

    @Override
    public WhatsAppBusinessConfig saveOrUpdate(WhatsAppBusinessConfig config) {
        Optional<WhatsAppBusinessConfig> existing = findByTherapistId(config.getTherapistId());
        if (existing.isPresent()) {
            update(config);
            config.setId(existing.get().getId());
            return config;
        }
        return insert(config);
    }

    private WhatsAppBusinessConfig insert(WhatsAppBusinessConfig config) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, config.getTherapistId());
            stmt.setString(2, config.getAccessToken());
            stmt.setString(3, config.getPhoneNumberId());
            stmt.setString(4, config.getBusinessAccountId());
            stmt.setString(5, config.getDailyTemplateName());
            stmt.setString(6, config.getWeeklyTemplateName());
            stmt.setString(7, config.getTemplateLanguage());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    config.setId(rs.getLong(1));
                }
            }
            return config;
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante il salvataggio configurazione WhatsApp", e);
        }
    }

    private void update(WhatsAppBusinessConfig config) {
        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE)) {

            stmt.setString(1, config.getAccessToken());
            stmt.setString(2, config.getPhoneNumberId());
            stmt.setString(3, config.getBusinessAccountId());
            stmt.setString(4, config.getDailyTemplateName());
            stmt.setString(5, config.getWeeklyTemplateName());
            stmt.setString(6, config.getTemplateLanguage());
            stmt.setLong(7, config.getTherapistId());

            int updated = stmt.executeUpdate();
            if (updated == 0) {
                throw new RuntimeException("Nessuna configurazione WhatsApp aggiornata");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Errore durante aggiornamento configurazione WhatsApp", e);
        }
    }

    private WhatsAppBusinessConfig mapRow(ResultSet rs) throws SQLException {
        WhatsAppBusinessConfig config = new WhatsAppBusinessConfig();
        config.setId(rs.getLong("id"));
        config.setTherapistId(rs.getLong("therapist_id"));
        config.setAccessToken(rs.getString("access_token"));
        config.setPhoneNumberId(rs.getString("phone_number_id"));
        config.setBusinessAccountId(rs.getString("business_account_id"));
        config.setDailyTemplateName(rs.getString("daily_template_name"));
        config.setWeeklyTemplateName(rs.getString("weekly_template_name"));
        config.setTemplateLanguage(rs.getString("template_language"));
        return config;
    }
}
