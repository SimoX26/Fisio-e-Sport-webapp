package it.SimoSW.service.whatsapp;

import it.SimoSW.model.WhatsAppBusinessConfig;
import it.SimoSW.model.dao.WhatsAppBusinessConfigDAO;

import java.util.Optional;

public class WhatsAppConfigurationService {

    private final WhatsAppBusinessConfigDAO configDAO;

    public WhatsAppConfigurationService(WhatsAppBusinessConfigDAO configDAO) {
        this.configDAO = configDAO;
    }

    public boolean hasConfiguration(long therapistId) {
        return getConfiguration(therapistId).isPresent();
    }

    public Optional<WhatsAppBusinessConfig> getConfiguration(long therapistId) {
        return configDAO.findByTherapistId(therapistId)
                .filter(this::isComplete);
    }

    public WhatsAppBusinessConfig saveConfiguration(long therapistId,
                                                    String accessToken,
                                                    String phoneNumberId,
                                                    String businessAccountId,
                                                    String dailyTemplateName,
                                                    String weeklyTemplateName,
                                                    String templateLanguage) {
        WhatsAppBusinessConfig config = new WhatsAppBusinessConfig();
        config.setTherapistId(therapistId);
        config.setAccessToken(requireValue(accessToken, "Access token obbligatorio"));
        config.setPhoneNumberId(requireValue(phoneNumberId, "Phone Number ID obbligatorio"));
        config.setBusinessAccountId(requireValue(businessAccountId, "WhatsApp Business Account ID obbligatorio"));
        config.setDailyTemplateName(requireValue(dailyTemplateName, "Template giornaliero obbligatorio"));
        config.setWeeklyTemplateName(requireValue(weeklyTemplateName, "Template settimanale obbligatorio"));
        config.setTemplateLanguage(requireValue(templateLanguage, "Lingua template obbligatoria"));
        return configDAO.saveOrUpdate(config);
    }

    public String maskAccessToken(String token) {
        String normalized = normalize(token);
        if (normalized == null) {
            return "";
        }
        if (normalized.length() <= 6) {
            return "******";
        }
        return normalized.substring(0, 3) + "..." + normalized.substring(normalized.length() - 3);
    }

    private boolean isComplete(WhatsAppBusinessConfig config) {
        return normalize(config.getAccessToken()) != null
                && normalize(config.getPhoneNumberId()) != null
                && normalize(config.getBusinessAccountId()) != null
                && normalize(config.getDailyTemplateName()) != null
                && normalize(config.getWeeklyTemplateName()) != null
                && normalize(config.getTemplateLanguage()) != null;
    }

    private String requireValue(String raw, String errorMessage) {
        String normalized = normalize(raw);
        if (normalized == null) {
            throw new IllegalArgumentException(errorMessage);
        }
        return normalized;
    }

    private String normalize(String raw) {
        if (raw == null) {
            return null;
        }
        String normalized = raw.trim();
        return normalized.isEmpty() ? null : normalized;
    }
}
