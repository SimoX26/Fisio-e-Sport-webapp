package it.SimoSW.util;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public final class AppProperties {

    private static final String CONFIG_FILE = "config.properties";
    private static final Properties PROPERTIES = loadProperties();

    private AppProperties() {
    }

    public static String get(String key) {
        return PROPERTIES.getProperty(key);
    }

    private static Properties loadProperties() {
        try {
            Properties props = new Properties();
            InputStream input = AppProperties.class.getClassLoader().getResourceAsStream(CONFIG_FILE);
            if (input == null) {
                throw new RuntimeException("Impossibile trovare " + CONFIG_FILE);
            }
            props.load(new InputStreamReader(input, StandardCharsets.UTF_8));
            return props;
        } catch (Exception e) {
            throw new RuntimeException("Errore lettura configurazione applicativa", e);
        }
    }
}
