package it.SimoSW.service.whatsapp;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import it.SimoSW.util.AppProperties;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Map;

public class WhatsAppBaileysService {

    private static final String DEFAULT_GATEWAY_BASE_URL = "http://127.0.0.1:3001";
    private static final int DEFAULT_TIMEOUT_MS = 4000;

    private final ObjectMapper objectMapper;
    private final String gatewayBaseUrl;
    private final int timeoutMs;

    public WhatsAppBaileysService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.gatewayBaseUrl = trimTrailingSlash(AppProperties.get("whatsapp.baileys.gatewayBaseUrl", DEFAULT_GATEWAY_BASE_URL));
        this.timeoutMs = AppProperties.getInt("whatsapp.baileys.gatewayTimeoutMs", DEFAULT_TIMEOUT_MS);
    }

    public void sendTextMessage(String destinationPhone, String message) {
        String recipient = sanitizePhone(destinationPhone);
        String normalizedMessage = requireMessage(message);
        HttpURLConnection connection = null;
        try {
            URL endpoint = new URL(gatewayBaseUrl + "/api/send");
            connection = (HttpURLConnection) endpoint.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            connection.setConnectTimeout(timeoutMs);
            connection.setReadTimeout(timeoutMs);
            connection.setDoOutput(true);

            String json = objectMapper.writeValueAsString(Map.of(
                    "recipient", recipient,
                    "message", normalizedMessage
            ));
            try (OutputStream outputStream = connection.getOutputStream()) {
                outputStream.write(json.getBytes(StandardCharsets.UTF_8));
            }

            int status = connection.getResponseCode();
            if (status < 200 || status >= 300) {
                Map<String, Object> response = readJsonBody(connection);
                Object gatewayError = response.get("error");
                String messageFromGateway = gatewayError == null ? "Baileys non ha accettato il messaggio." : String.valueOf(gatewayError);
                throw new RuntimeException(messageFromGateway);
            }
        } catch (IOException ex) {
            throw new RuntimeException("Servizio WhatsApp locale non raggiungibile. Avvia Baileys e scansiona il QR.", ex);
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

    private String requireMessage(String rawMessage) {
        if (rawMessage == null || rawMessage.isBlank()) {
            throw new IllegalArgumentException("Messaggio WhatsApp mancante.");
        }
        return rawMessage.trim();
    }

    private Map<String, Object> readJsonBody(HttpURLConnection connection) {
        try (InputStream input = connection.getErrorStream() != null
                ? connection.getErrorStream()
                : connection.getInputStream()) {
            if (input == null) {
                return Map.of();
            }
            return objectMapper.readValue(input, new TypeReference<>() {
            });
        } catch (IOException ex) {
            return Map.of();
        }
    }

    private String trimTrailingSlash(String value) {
        if (value == null || value.isBlank()) {
            return DEFAULT_GATEWAY_BASE_URL;
        }
        String normalized = value.trim();
        while (normalized.endsWith("/")) {
            normalized = normalized.substring(0, normalized.length() - 1);
        }
        return normalized;
    }
}
