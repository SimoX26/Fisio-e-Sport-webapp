package it.SimoSW.service.whatsapp;

import it.SimoSW.model.WhatsAppBusinessConfig;
import it.SimoSW.model.dao.WhatsAppBusinessConfigDAO;
import it.SimoSW.util.AppProperties;

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
        Optional<WhatsAppBusinessConfig> configuredFromProperties = loadConfigurationFromProperties(therapistId);
        if (configuredFromProperties.isPresent()) {
            return configuredFromProperties;
        }
        return configDAO.findByTherapistId(therapistId).filter(this::isComplete);
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

    private Optional<WhatsAppBusinessConfig> loadConfigurationFromProperties(long therapistId) {
        Long configuredTherapistId = parseOptionalLong(AppProperties.get("whatsapp.marco.therapistId"));
        if (configuredTherapistId == null || configuredTherapistId != therapistId) {
            return Optional.empty();
        }
        String propertyKeyPrefix = "whatsapp.marco.";
        WhatsAppBusinessConfig config = new WhatsAppBusinessConfig();
        config.setTherapistId(therapistId);
        config.setAccessToken(normalize(AppProperties.get(propertyKeyPrefix + "accessToken")));
        config.setPhoneNumberId(normalize(AppProperties.get(propertyKeyPrefix + "phoneNumberId")));
        config.setBusinessAccountId(normalize(AppProperties.get(propertyKeyPrefix + "businessAccountId")));
        config.setDailyTemplateName(normalize(AppProperties.get(propertyKeyPrefix + "dailyTemplateName")));
        config.setWeeklyTemplateName(normalize(AppProperties.get(propertyKeyPrefix + "weeklyTemplateName")));
        config.setTemplateLanguage(normalize(AppProperties.get(propertyKeyPrefix + "templateLanguage")));
        return isComplete(config) ? Optional.of(config) : Optional.empty();
    }

    private Long parseOptionalLong(String raw) {
        String normalized = normalize(raw);
        if (normalized == null) {
            return null;
        }
        try {
            return Long.parseLong(normalized);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
