package it.SimoSW.service.whatsapp;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.SimoSW.model.WhatsAppBusinessConfig;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WhatsAppCloudApiService {

    private static final String GRAPH_API_VERSION = "v22.0";

    private final ObjectMapper objectMapper;

    public WhatsAppCloudApiService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public void sendDailyReminderTemplate(WhatsAppBusinessConfig config,
                                          String destinationPhone,
                                          String patientName,
                                          String dayLabel,
                                          String timeRange) {
        if (destinationPhone == null || destinationPhone.isBlank()) {
            throw new IllegalArgumentException("Numero destinatario mancante");
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("messaging_product", "whatsapp");
        payload.put("to", sanitizePhone(destinationPhone));
        payload.put("type", "template");

        Map<String, Object> language = new HashMap<>();
        language.put("code", config.getTemplateLanguage());

        Map<String, Object> template = new HashMap<>();
        template.put("name", config.getDailyTemplateName());
        template.put("language", language);
        template.put("components", List.of(
                Map.of(
                        "type", "body",
                        "parameters", List.of(
                                Map.of("type", "text", "text", valueOrFallback(patientName, "Paziente")),
                                Map.of("type", "text", "text", valueOrFallback(dayLabel, "-")),
                                Map.of("type", "text", "text", valueOrFallback(timeRange, "-"))
                        )
                )
        ));
        payload.put("template", template);

        postTemplate(config, payload);
    }

    private void postTemplate(WhatsAppBusinessConfig config, Map<String, Object> payload) {
        HttpURLConnection connection = null;
        try {
            URL endpoint = new URL("https://graph.facebook.com/" + GRAPH_API_VERSION + "/" + config.getPhoneNumberId() + "/messages");
            connection = (HttpURLConnection) endpoint.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Authorization", "Bearer " + config.getAccessToken());
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setDoOutput(true);

            String json = objectMapper.writeValueAsString(payload);
            try (OutputStream outputStream = connection.getOutputStream()) {
                outputStream.write(json.getBytes(StandardCharsets.UTF_8));
            }

            int status = connection.getResponseCode();
            if (status < 200 || status >= 300) {
                String responseBody = readBody(connection);
                throw new RuntimeException("WhatsApp API error HTTP " + status + ": " + responseBody);
            }
        } catch (IOException ex) {
            throw new RuntimeException("Errore invio messaggio WhatsApp", ex);
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private String sanitizePhone(String rawPhone) {
        String digitsOnly = rawPhone == null ? "" : rawPhone.replaceAll("[^0-9]", "");
        if (digitsOnly.startsWith("00")) {
            digitsOnly = digitsOnly.substring(2);
        }
        if (digitsOnly.length() < 8 || digitsOnly.length() > 15) {
            throw new IllegalArgumentException("Numero WhatsApp non valido. Usa il formato internazionale, ad esempio 393331234567.");
        }
        return digitsOnly;
    }

    private String valueOrFallback(String value, String fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        return value;
    }

    private String readBody(HttpURLConnection connection) {
        try (InputStream input = connection.getErrorStream() != null
                ? connection.getErrorStream()
                : connection.getInputStream()) {
            if (input == null) {
                return "";
            }
            return new String(input.readAllBytes(), StandardCharsets.UTF_8);
        } catch (IOException ex) {
            return "";
        }
    }
}
