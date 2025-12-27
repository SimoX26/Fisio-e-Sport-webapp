package it.SimoSW.util.bootstrap;

import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.controller.application.TreatmentHistoryController;
import it.SimoSW.dao.*;
import it.SimoSW.dao.filesystem.*;
import it.SimoSW.dao.database.*;

import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

public class ApplicationInitializer {

    private static final String CONFIG_FILE = "config.properties";

    private AddressBookController addressBookController;
    private CalendarController calendarController;
    private TreatmentHistoryController treatmentHistoryController;

    public void init() {

        Properties config = loadConfiguration();

        String persistenceType = config.getProperty("persistence.type");

        if (persistenceType == null) {
            throw new RuntimeException("persistence.type non specificato in config.properties");
        }

        switch (persistenceType.toLowerCase()) {
            case "filesystem":
                initFileSystemPersistence(config);
                break;

            case "mysql":
                // initDatabasePersistence();
                break;

            default:
                throw new RuntimeException("Tipo di persistenza non supportato: " + persistenceType);
        }
    }

    /* =====================================================
       Inizializzazione FILE SYSTEM
       ===================================================== */
    private void initFileSystemPersistence(Properties config) {

        String basePath = config.getProperty("fs.base.path", "data");
        Path dataRoot = Paths.get(basePath);

        System.out.println(">>> DATA ROOT = " + dataRoot.toAbsolutePath());

        Path patientsDir = dataRoot.resolve("patients");
        Path therapistsDir = dataRoot.resolve("therapists");
        Path appointmentsDir = dataRoot.resolve("appointments");
        Path treatmentSessionsDir = dataRoot.resolve("treatment_sessions");

        PatientDAO patientDAO = new FileSystemPatientDAO(patientsDir);
        TherapistDAO therapistDAO = new FileSystemTherapistDAO(therapistsDir);
        AppointmentDAO appointmentDAO = new FileSystemAppointmentDAO(appointmentsDir);
        TreatmentSessionDAO treatmentSessionDAO = new FileSystemTreatmentSessionDAO(treatmentSessionsDir);

        wireControllers(patientDAO, therapistDAO, appointmentDAO, treatmentSessionDAO);
    }


    /* =====================================================
       Inizializzazione DATABASE (MySQL)
       ===================================================== */
  /*  private void initDatabasePersistence() {

        PatientDAO patientDAO = new DatabasePatientDAO();
        TherapistDAO therapistDAO = new DatabaseTherapistDAO();
        AppointmentDAO appointmentDAO = new DatabaseAppointmentDAO();
        TreatmentSessionDAO treatmentSessionDAO = new DatabaseTreatmentSessionDAO();

        wireControllers(patientDAO, therapistDAO, appointmentDAO, treatmentSessionDAO);
    }

   */


    /* =====================================================
       Wiring controller applicativi
       ===================================================== */
    private void wireControllers(
            PatientDAO patientDAO,
            TherapistDAO therapistDAO,
            AppointmentDAO appointmentDAO,
            TreatmentSessionDAO treatmentSessionDAO
    ) {
        addressBookController = new AddressBookController(patientDAO);
        calendarController = new CalendarController(appointmentDAO, patientDAO, therapistDAO);
        treatmentHistoryController = new TreatmentHistoryController(
                treatmentSessionDAO,
                appointmentDAO,
                patientDAO
        );
    }

    /* =====================================================
       Caricamento configurazione
       ===================================================== */
    private Properties loadConfiguration() {
        try {
            Properties props = new Properties();
            InputStream is = getClass()
                    .getClassLoader()
                    .getResourceAsStream(CONFIG_FILE);

            if (is == null) {
                throw new RuntimeException("Impossibile trovare " + CONFIG_FILE);
            }

            props.load(is);
            return props;

        } catch (Exception e) {
            throw new RuntimeException("Errore nel caricamento della configurazione", e);
        }
    }

    /* =====================================================
       Getter per Servlet
       ===================================================== */
    public AddressBookController getAddressBookController() {
        return addressBookController;
    }

    public CalendarController getCalendarController() {
        return calendarController;
    }

    public TreatmentHistoryController getTreatmentHistoryController() {
        return treatmentHistoryController;
    }
}
