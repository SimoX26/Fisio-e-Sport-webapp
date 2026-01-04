package it.SimoSW.controller.application;

import it.SimoSW.exception.InvalidTreatmentSessionStateException;
import it.SimoSW.exception.TreatmentAlreadyExistsException;
import it.SimoSW.exception.TreatmentSessionNotFoundException;
import it.SimoSW.model.TreatmentSession;
import it.SimoSW.model.TreatmentSessionState;
import it.SimoSW.model.dao.AppointmentDAO;
import it.SimoSW.model.dao.PatientDAO;
import it.SimoSW.model.dao.TreatmentSessionDAO;

import java.util.List;

/**
 * Application controller responsible for managing the treatment history
 * of patients.
 *
 * <p>This controller handles the lifecycle of treatment sessions,
 * including creation, completion and retrieval, enforcing domain rules
 * such as one-to-one correspondence between appointments and treatments
 * and valid state transitions.</p>
 *
 * <p>It acts as an application-layer boundary, coordinating multiple
 * DAOs while keeping business logic separate from persistence concerns.</p>
 */
public class TreatmentHistoryController {

    /**
     * DAO responsible for treatment session persistence.
     */
    private final TreatmentSessionDAO treatmentSessionDAO;

    /**
     * DAO used to validate appointment existence.
     */
    private final AppointmentDAO appointmentDAO;

    /**
     * DAO used to validate patient existence.
     */
    private final PatientDAO patientDAO;

    /**
     * Constructs a TreatmentHistoryController with the required DAOs.
     *
     * @param treatmentSessionDAO DAO for treatment session persistence
     * @param appointmentDAO DAO for appointment lookup
     * @param patientDAO DAO for patient lookup
     */
    public TreatmentHistoryController(TreatmentSessionDAO treatmentSessionDAO,
                                      AppointmentDAO appointmentDAO,
                                      PatientDAO patientDAO) {
        this.treatmentSessionDAO = treatmentSessionDAO;
        this.appointmentDAO = appointmentDAO;
        this.patientDAO = patientDAO;
    }

    /**
     * Records a new treatment session.
     *
     * <p>This method ensures that:
     * <ul>
     *   <li>the referenced appointment exists</li>
     *   <li>the referenced patient exists</li>
     *   <li>no other treatment session is already associated with the appointment</li>
     * </ul>
     * </p>
     *
     * <p>If all checks pass, the treatment session is persisted
     * with an initial {@code IN_PROGRESS} state.</p>
     *
     * @param session the treatment session to record
     * @return the persisted treatment session
     * @throws IllegalArgumentException if the session is null or references invalid entities
     * @throws TreatmentAlreadyExistsException if a session already exists for the appointment
     */
    public TreatmentSession recordTreatmentSession(TreatmentSession session) {
        if (session == null) {
            throw new IllegalArgumentException("Treatment session cannot be null");
        }

        // Ensure the appointment exists
        appointmentDAO.findById(session.getAppointmentId())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Appointment not found: " + session.getAppointmentId())
                );

        // Ensure the patient exists
        patientDAO.findById(session.getPatientId())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Patient not found: " + session.getPatientId())
                );

        // Domain invariant: exactly one treatment session per appointment
        treatmentSessionDAO.findByAppointmentId(session.getAppointmentId())
                .ifPresent(existing -> {
                    throw new TreatmentAlreadyExistsException(session.getAppointmentId());
                });

        // Domain invariant: a newly recorded treatment session starts IN_PROGRESS
        session.setState(TreatmentSessionState.IN_PROGRESS);

        return treatmentSessionDAO.save(session);
    }

    /**
     * Finalizes a treatment session.
     *
     * <p>Once completed, a treatment session becomes immutable and
     * cannot transition to any other state.</p>
     *
     * @param sessionId the treatment session identifier
     * @return the updated treatment session
     * @throws TreatmentSessionNotFoundException if the session does not exist
     * @throws InvalidTreatmentSessionStateException if the session is already completed
     */
    public TreatmentSession finalizeTreatment(long sessionId) {
        TreatmentSession session = treatmentSessionDAO.findById(sessionId)
                .orElseThrow(() -> new TreatmentSessionNotFoundException(sessionId));

        if (session.getState() == TreatmentSessionState.COMPLETED) {
            throw new InvalidTreatmentSessionStateException(
                    "Treatment session already completed"
            );
        }

        session.setState(TreatmentSessionState.COMPLETED);
        return treatmentSessionDAO.update(session);
    }

    /**
     * Retrieves the full treatment history for a given patient.
     *
     * @param patientId the patient identifier
     * @return a list of treatment sessions associated with the patient
     * @throws IllegalArgumentException if the patient does not exist
     */
    public List<TreatmentSession> getTreatmentHistoryForPatient(long patientId) {
        patientDAO.findById(patientId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Patient not found: " + patientId));

        return treatmentSessionDAO.findByPatientId(patientId);
    }

    /**
     * Retrieves the treatment session associated with a specific appointment.
     *
     * <p>By design, each appointment can be linked to at most one
     * treatment session.</p>
     *
     * @param appointmentId the appointment identifier
     * @return the corresponding treatment session
     * @throws TreatmentSessionNotFoundException if no session is found
     */
    public TreatmentSession getTreatmentByAppointment(long appointmentId) {
        return treatmentSessionDAO.findByAppointmentId(appointmentId)
                .orElseThrow(() ->
                        new TreatmentSessionNotFoundException(appointmentId)
                );
    }
}
