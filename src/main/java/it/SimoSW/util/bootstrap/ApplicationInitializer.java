package it.SimoSW.util.bootstrap;

import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.controller.application.TreatmentHistoryController;
import it.SimoSW.util.dao.AppointmentDAO;
import it.SimoSW.util.dao.database.DatabaseAppointmentDAO;
import it.SimoSW.util.dao.database.DatabasePatientDAO;
import it.SimoSW.util.dao.PatientDAO;
import it.SimoSW.util.dao.TherapistDAO;
import it.SimoSW.util.dao.TreatmentSessionDAO;
import it.SimoSW.util.dao.database.DatabaseTherapistDAO;
import it.SimoSW.util.dao.database.DatabaseTreatmentSessionDAO;

public class ApplicationInitializer {

    private AddressBookController addressBookController;
    private CalendarController calendarController;
    private TreatmentHistoryController treatmentHistoryController;

    public void init() {

        // Inizializzazione persistenza (DB in questo caso)
        PatientDAO patientDAO = new DatabasePatientDAO();
        TherapistDAO therapistDAO = new DatabaseTherapistDAO();
        AppointmentDAO appointmentDAO = new DatabaseAppointmentDAO();
        TreatmentSessionDAO treatmentSessionDAO = new DatabaseTreatmentSessionDAO();

        // Creazione controller applicativi
        addressBookController = new AddressBookController(patientDAO);
        calendarController = new CalendarController(appointmentDAO, patientDAO, therapistDAO);
        treatmentHistoryController = new TreatmentHistoryController(
                treatmentSessionDAO,
                appointmentDAO,
                patientDAO
        );
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
