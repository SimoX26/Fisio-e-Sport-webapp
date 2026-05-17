package it.SimoSW.model;

public class WhatsAppBusinessConfig {

    private Long id;
    private long therapistId;
    private String accessToken;
    private String phoneNumberId;
    private String businessAccountId;
    private String dailyTemplateName;
    private String weeklyTemplateName;
    private String templateLanguage;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public long getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(long therapistId) {
        this.therapistId = therapistId;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getPhoneNumberId() {
        return phoneNumberId;
    }

    public void setPhoneNumberId(String phoneNumberId) {
        this.phoneNumberId = phoneNumberId;
    }

    public String getBusinessAccountId() {
        return businessAccountId;
    }

    public void setBusinessAccountId(String businessAccountId) {
        this.businessAccountId = businessAccountId;
    }

    public String getDailyTemplateName() {
        return dailyTemplateName;
    }

    public void setDailyTemplateName(String dailyTemplateName) {
        this.dailyTemplateName = dailyTemplateName;
    }

    public String getWeeklyTemplateName() {
        return weeklyTemplateName;
    }

    public void setWeeklyTemplateName(String weeklyTemplateName) {
        this.weeklyTemplateName = weeklyTemplateName;
    }

    public String getTemplateLanguage() {
        return templateLanguage;
    }

    public void setTemplateLanguage(String templateLanguage) {
        this.templateLanguage = templateLanguage;
    }
}
