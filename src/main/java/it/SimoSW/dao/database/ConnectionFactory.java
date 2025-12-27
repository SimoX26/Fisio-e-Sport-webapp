package it.SimoSW.dao.database;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class ConnectionFactory {

    private static final String CONFIG_FILE = "config.properties";

    private static final String url;
    private static final String username;
    private static final String password;

    static {
        try {
            Properties props = new Properties();

            InputStream input = ConnectionFactory.class
                    .getClassLoader()
                    .getResourceAsStream(CONFIG_FILE);

            if (input == null) {
                throw new RuntimeException("Impossibile trovare " + CONFIG_FILE);
            }

            props.load(input);

            String driver = props.getProperty("db.driver");
            url = props.getProperty("db.url");
            username = props.getProperty("db.username");
            password = props.getProperty("db.password");

            if (driver == null || url == null || username == null || password == null) {
                throw new RuntimeException("Configurazione database incompleta");
            }

            Class.forName(driver);

        } catch (Exception e) {
            throw new RuntimeException("Errore inizializzazione ConnectionFactory", e);
        }
    }

    private ConnectionFactory() {
        // Costruttore vuoto che impedisce l'istanziazione
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}
