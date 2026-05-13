package it.SimoSW.util.bootstrap;

import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.controller.application.AccessRequestController;
import it.SimoSW.controller.application.AuthenticationController;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.controller.application.KpiSnapshotController;
import it.SimoSW.controller.application.TreatmentController;
import it.SimoSW.controller.application.UserController;
import it.SimoSW.model.dao.AppointmentDAO;
import it.SimoSW.model.dao.AccessRequestDAO;
import it.SimoSW.model.dao.PatientAnamnesisDAO;
import it.SimoSW.model.dao.PatientConditionDAO;
import it.SimoSW.model.dao.PatientDAO;
import it.SimoSW.model.dao.KpiMonthlySnapshotDAO;
import it.SimoSW.model.dao.RememberMeTokenDAO;
import it.SimoSW.model.dao.TreatmentPlanDAO;
import it.SimoSW.model.dao.TreatmentSessionDAO;
import it.SimoSW.model.dao.UserDAO;
import it.SimoSW.model.dao.database.DatabaseAppointmentDAO;
import it.SimoSW.model.dao.database.DatabaseAccessRequestDAO;
import it.SimoSW.model.dao.database.DatabasePatientAnamnesisDAO;
import it.SimoSW.model.dao.database.DatabasePatientConditionDAO;
import it.SimoSW.model.dao.database.DatabasePatientDAO;
import it.SimoSW.model.dao.database.DatabaseKpiMonthlySnapshotDAO;
import it.SimoSW.model.dao.database.DatabaseRememberMeTokenDAO;
import it.SimoSW.model.dao.database.DatabaseTreatmentPlanDAO;
import it.SimoSW.model.dao.database.DatabaseTreatmentSessionDAO;
import it.SimoSW.model.dao.database.DatabaseUserDAO;

public class ApplicationInitializer {

    private AddressBookController addressBookController;
    private CalendarController calendarController;
    private TreatmentController treatmentController;
    private AuthenticationController authenticationController;
    private UserController userController;
    private AccessRequestController accessRequestController;
    private KpiSnapshotController kpiSnapshotController;

    public void init() {
        initDatabasePersistence();
    }

    private void initDatabasePersistence() {
        PatientDAO patientDAO = new DatabasePatientDAO();
        PatientAnamnesisDAO patientAnamnesisDAO = new DatabasePatientAnamnesisDAO();
        PatientConditionDAO patientConditionDAO = new DatabasePatientConditionDAO();
        AppointmentDAO appointmentDAO = new DatabaseAppointmentDAO();
        TreatmentPlanDAO treatmentPlanDAO = new DatabaseTreatmentPlanDAO();
        TreatmentSessionDAO treatmentSessionDAO = new DatabaseTreatmentSessionDAO();
        UserDAO userDAO = new DatabaseUserDAO();
        KpiMonthlySnapshotDAO kpiMonthlySnapshotDAO = new DatabaseKpiMonthlySnapshotDAO();
        RememberMeTokenDAO rememberMeTokenDAO = new DatabaseRememberMeTokenDAO();
        AccessRequestDAO accessRequestDAO = new DatabaseAccessRequestDAO();

        wireControllers(
                patientDAO,
                patientAnamnesisDAO,
                patientConditionDAO,
                appointmentDAO,
                treatmentPlanDAO,
                treatmentSessionDAO,
                userDAO,
                kpiMonthlySnapshotDAO,
                rememberMeTokenDAO,
                accessRequestDAO
        );
    }

    private void wireControllers(
            PatientDAO patientDAO,
            PatientAnamnesisDAO patientAnamnesisDAO,
            PatientConditionDAO patientConditionDAO,
            AppointmentDAO appointmentDAO,
            TreatmentPlanDAO treatmentPlanDAO,
            TreatmentSessionDAO treatmentSessionDAO,
            UserDAO userDAO,
            KpiMonthlySnapshotDAO kpiMonthlySnapshotDAO,
            RememberMeTokenDAO rememberMeTokenDAO,
            AccessRequestDAO accessRequestDAO
    ) {
        addressBookController = new AddressBookController(
                patientDAO,
                patientAnamnesisDAO,
                patientConditionDAO,
                appointmentDAO,
                userDAO
        );
        calendarController = new CalendarController(appointmentDAO, patientDAO, userDAO);
        treatmentController = new TreatmentController(
                treatmentPlanDAO,
                treatmentSessionDAO,
                patientDAO,
                appointmentDAO
        );
        authenticationController = new AuthenticationController(userDAO, rememberMeTokenDAO);
        userController = new UserController(userDAO);
        accessRequestController = new AccessRequestController(accessRequestDAO, userDAO);
        kpiSnapshotController = new KpiSnapshotController(kpiMonthlySnapshotDAO);
    }

    public AddressBookController getAddressBookController() {
        return addressBookController;
    }

    public CalendarController getCalendarController() {
        return calendarController;
    }

    public TreatmentController getTreatmentController() {
        return treatmentController;
    }

    public UserController getUserController() {
        return userController;
    }

    public AuthenticationController getAuthenticationController() {
        return authenticationController;
    }

    public AccessRequestController getAccessRequestController() {
        return accessRequestController;
    }

    public KpiSnapshotController getKpiSnapshotController() {
        return kpiSnapshotController;
    }
}
