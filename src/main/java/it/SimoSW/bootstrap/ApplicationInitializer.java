package it.SimoSW.bootstrap;

import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.controller.application.TreatmentHistoryController;
import it.SimoSW.dao.AppointmentDAO;
import it.SimoSW.dao.PatientDAO;
import it.SimoSW.dao.TherapistDAO;
import it.SimoSW.dao.TreatmentSessionDAO;
import it.SimoSW.dao.filesystem.FileSystemAppointmentDAO;
import it.SimoSW.dao.filesystem.FileSystemPatientDAO;
import it.SimoSW.dao.filesystem.FileSystemTherapistDAO;
import it.SimoSW.dao.filesystem.FileSystemTreatmentSessionDAO;

import java.nio.file.Path;
import java.nio.file.Paths;

public class ApplicationInitializer {

    private AddressBookController addressBookController;
    private CalendarController calendarController;
    private TreatmentHistoryController treatmentHistoryController;


    public void init() {

        /* =====================================================
           Root directory per la persistenza File System
           Responsabilità del bootstrap, NON dei DAO
           ===================================================== */
        Path dataRoot = Paths.get("data");

        System.out.println(">>> DATA ROOT = " + dataRoot.toAbsolutePath());

        Path patientsDir = dataRoot.resolve("patients");
        Path therapistsDir = dataRoot.resolve("therapists");
        Path appointmentsDir = dataRoot.resolve("appointments");
        Path treatmentSessionsDir = dataRoot.resolve("treatment_sessions");

        /* =====================================================
           Inizializzazione DAO (File System strategy)
           ===================================================== */
        PatientDAO patientDAO = new FileSystemPatientDAO(patientsDir);
        TherapistDAO therapistDAO = new FileSystemTherapistDAO(therapistsDir);
        AppointmentDAO appointmentDAO = new FileSystemAppointmentDAO(appointmentsDir);
        TreatmentSessionDAO treatmentSessionDAO = new FileSystemTreatmentSessionDAO(treatmentSessionsDir);

        /* =====================================================
           Creazione controller applicativi
           ===================================================== */
        addressBookController = new AddressBookController(patientDAO);
        calendarController = new CalendarController(appointmentDAO, patientDAO, therapistDAO);
        treatmentHistoryController = new TreatmentHistoryController(treatmentSessionDAO, appointmentDAO, patientDAO);
    }

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
