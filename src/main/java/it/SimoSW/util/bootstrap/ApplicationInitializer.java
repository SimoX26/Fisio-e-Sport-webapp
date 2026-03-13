package it.SimoSW.util.bootstrap;

import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.controller.application.AuthenticationController;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.controller.application.TreatmentHistoryController;
import it.SimoSW.controller.application.UserController;
import it.SimoSW.model.dao.AppointmentDAO;
import it.SimoSW.model.dao.PatientDAO;
import it.SimoSW.model.dao.TherapistDAO;
import it.SimoSW.model.dao.TreatmentSessionDAO;
import it.SimoSW.model.dao.UserDAO;
import it.SimoSW.model.dao.database.DatabaseAppointmentDAO;
import it.SimoSW.model.dao.database.DatabasePatientDAO;
import it.SimoSW.model.dao.database.DatabaseTherapistDAO;
import it.SimoSW.model.dao.database.DatabaseTreatmentSessionDAO;
import it.SimoSW.model.dao.database.DatabaseUserDAO;

public class ApplicationInitializer {

    private AddressBookController addressBookController;
    private CalendarController calendarController;
    private TreatmentHistoryController treatmentHistoryController;
    private AuthenticationController authenticationController;
    private UserController userController;

    public void init() {
        initDatabasePersistence();
    }

    private void initDatabasePersistence() {
        PatientDAO patientDAO = new DatabasePatientDAO();
        TherapistDAO therapistDAO = new DatabaseTherapistDAO();
        AppointmentDAO appointmentDAO = new DatabaseAppointmentDAO();
        TreatmentSessionDAO treatmentSessionDAO = new DatabaseTreatmentSessionDAO();
        UserDAO userDAO = new DatabaseUserDAO();

        wireControllers(patientDAO, therapistDAO, appointmentDAO, treatmentSessionDAO, userDAO);
    }

    private void wireControllers(
            PatientDAO patientDAO,
            TherapistDAO therapistDAO,
            AppointmentDAO appointmentDAO,
            TreatmentSessionDAO treatmentSessionDAO,
            UserDAO userDAO
    ) {
        addressBookController = new AddressBookController(patientDAO);
        calendarController = new CalendarController(appointmentDAO, patientDAO, therapistDAO);
        treatmentHistoryController = new TreatmentHistoryController(
                treatmentSessionDAO,
                appointmentDAO,
                patientDAO
        );
        authenticationController = new AuthenticationController(userDAO);
        userController = new UserController(userDAO);
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

    public UserController getUserController() {
        return userController;
    }

    public AuthenticationController getAuthenticationController() {
        return authenticationController;
    }
}
