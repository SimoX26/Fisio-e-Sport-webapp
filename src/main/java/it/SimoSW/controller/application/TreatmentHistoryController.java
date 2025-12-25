package it.SimoSW.controller.application;

import it.SimoSW.model.TreatmentSession;
import it.SimoSW.util.dao.AppointmentDAO;
import it.SimoSW.util.dao.PatientDAO;
import it.SimoSW.util.dao.TreatmentSessionDAO;

import java.util.List;

public class TreatmentHistoryController {

    private final TreatmentSessionDAO treatmentSessionDAO;
    private final AppointmentDAO appointmentDAO;
    private final PatientDAO patientDAO;

    public TreatmentHistoryController(TreatmentSessionDAO treatmentSessionDAO, AppointmentDAO appointmentDAO, PatientDAO patientDAO) {
        this.treatmentSessionDAO = treatmentSessionDAO;
        this.appointmentDAO = appointmentDAO;
        this.patientDAO = patientDAO;
    }

    public TreatmentSession recordTreatmentSession(TreatmentSession session) {
        return null;
    }

    public TreatmentSession finalizeTreatment(long sessionId) {
        return null;
    }

    public List<TreatmentSession> getTreatmentHistoryForPatient(long patientId) {
        return null;
    }

    public TreatmentSession getTreatmentByAppointment(long appointmentId) {
        return null;
    }

    private void checkAppointmentExists(long appointmentId) {
    }

    private void checkNoExistingTreatment(long appointmentId) {
    }

    private void checkPatientExists(long patientId) {
    }

    private void checkSessionEditable(TreatmentSession session) {
    }

}
