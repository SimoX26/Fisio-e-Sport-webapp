package it.SimoSW.controller.application;

import it.SimoSW.exception.AppointmentNotFoundException;
import it.SimoSW.exception.InvalidAppointmentStateException;
import it.SimoSW.exception.TimeSlotNotAvailableException;
import it.SimoSW.model.Appointment;
import it.SimoSW.model.AppointmentState;
import it.SimoSW.dao.AppointmentDAO;
import it.SimoSW.dao.PatientDAO;
import it.SimoSW.dao.TherapistDAO;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Application controller responsible for appointment scheduling and
 * calendar management.
 *
 * <p>This controller orchestrates the business logic related to
 * appointment creation, rescheduling, cancellation and querying,
 * ensuring consistency of time ranges, valid state transitions
 * and the absence of scheduling conflicts.</p>
 *
 * <p>It acts as a boundary between the presentation layer and the
 * persistence layer, enforcing domain rules before delegating
 * data access to DAOs.</p>
 */
public class CalendarController {

    /**
     * DAO responsible for appointment persistence and retrieval.
     */
    private final AppointmentDAO appointmentDAO;

    /**
     * DAO used to validate the existence of patients.
     */
    private final PatientDAO patientDAO;

    /**
     * DAO used to validate the existence of therapists.
     */
    private final TherapistDAO therapistDAO;

    /**
     * Constructs a CalendarController with the required DAOs.
     *
     * @param appointmentDAO DAO for appointment persistence
     * @param patientDAO DAO for patient lookup
     * @param therapistDAO DAO for therapist lookup
     */
    public CalendarController(AppointmentDAO appointmentDAO, PatientDAO patientDAO, TherapistDAO therapistDAO) {
        this.appointmentDAO = appointmentDAO;
        this.patientDAO = patientDAO;
        this.therapistDAO = therapistDAO;
    }

    /**
     * Retrieves all appointments within a given time interval.
     *
     * @param start the beginning of the time range (inclusive)
     * @param end the end of the time range (exclusive)
     * @return a list of appointments in the specified period
     * @throws IllegalArgumentException if the time range is invalid
     */
    public List<Appointment> getAppointmentsInPeriod(LocalDateTime start, LocalDateTime end) {
        validateTimeRange(start, end);
        return appointmentDAO.findInPeriod(start, end);
    }

    /**
     * Schedules a new appointment.
     *
     * <p>This method validates:
     * <ul>
     *   <li>the correctness of the time range</li>
     *   <li>the existence of the patient</li>
     *   <li>the existence of the therapist</li>
     *   <li>the absence of overlapping appointments</li>
     * </ul>
     * </p>
     *
     * <p>If all checks pass, the appointment is persisted
     * with an initial {@code SCHEDULED} state.</p>
     *
     * @param appointment the appointment to schedule
     * @return the persisted appointment
     * @throws IllegalArgumentException if the appointment is null or invalid
     * @throws TimeSlotNotAvailableException if the time slot is already occupied
     */
    public Appointment scheduleAppointment(Appointment appointment) {
        if (appointment == null) {
            throw new IllegalArgumentException("Appointment cannot be null");
        }

        validateTimeRange(appointment.getStart(), appointment.getEnd());
        checkPatientExists(appointment.getPatientId());
        checkTherapistExists(appointment.getTherapistId());
        checkForConflicts(appointment);

        // Domain invariant: a newly created appointment is always SCHEDULED
        appointment.setState(AppointmentState.SCHEDULED);

        return appointmentDAO.save(appointment);
    }

    /**
     * Reschedules an existing appointment.
     *
     * <p>Only appointments in {@code SCHEDULED} state can be rescheduled.
     * Completed or cancelled appointments are immutable.</p>
     *
     * @param appointmentId the appointment identifier
     * @param newStart the new start date-time
     * @param newEnd the new end date-time
     * @return the updated appointment
     * @throws AppointmentNotFoundException if the appointment does not exist
     * @throws InvalidAppointmentStateException if the appointment state is invalid
     * @throws TimeSlotNotAvailableException if the new time slot is not available
     */
    public Appointment rescheduleAppointment(long appointmentId, LocalDateTime newStart, LocalDateTime newEnd) {
        Appointment existing = appointmentDAO.findById(appointmentId)
                .orElseThrow(() -> new AppointmentNotFoundException(appointmentId));

        if (existing.getState() != AppointmentState.SCHEDULED) {
            throw new InvalidAppointmentStateException("Only scheduled appointments can be rescheduled");
        }

        validateTimeRange(newStart, newEnd);

        existing.setStart(newStart);
        existing.setEnd(newEnd);

        checkForConflicts(existing);

        return appointmentDAO.update(existing);
    }

    /**
     * Cancels an appointment.
     *
     * <p>An appointment can be cancelled only if it has not already been
     * completed or cancelled.</p>
     *
     * @param appointmentId the appointment identifier
     * @throws AppointmentNotFoundException if the appointment does not exist
     * @throws InvalidAppointmentStateException if cancellation is not allowed
     */
    public void cancelAppointment(long appointmentId) {
        Appointment appointment = appointmentDAO.findById(appointmentId)
                .orElseThrow(() -> new AppointmentNotFoundException(appointmentId));

        if (appointment.getState() == AppointmentState.CANCELLED) {
            throw new InvalidAppointmentStateException("Appointment already cancelled");
        }

        if (appointment.getState() == AppointmentState.COMPLETED) {
            throw new InvalidAppointmentStateException("Completed appointment cannot be cancelled");
        }

        appointment.setState(AppointmentState.CANCELLED);
        appointmentDAO.update(appointment);
    }

    /**
     * Validates that a time range is well-formed.
     *
     * @param start the start date-time
     * @param end the end date-time
     * @throws IllegalArgumentException if the range is invalid
     */
    private void validateTimeRange(LocalDateTime start, LocalDateTime end) {
        if (start == null || end == null || !start.isBefore(end)) {
            throw new IllegalArgumentException("Invalid time range");
        }
    }

    /**
     * Ensures that the referenced patient exists.
     *
     * @param patientId the patient identifier
     * @throws IllegalArgumentException if the patient does not exist
     */
    private void checkPatientExists(long patientId) {
        patientDAO.findById(patientId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Patient not found: " + patientId));
    }

    /**
     * Ensures that the referenced therapist exists.
     *
     * @param therapistId the therapist identifier
     * @throws IllegalArgumentException if the therapist does not exist
     */
    private void checkTherapistExists(long therapistId) {
        therapistDAO.findById(therapistId)
                .orElseThrow(() -> new IllegalArgumentException("Therapist not found: " + therapistId));
    }

    /**
     * Checks whether the given appointment overlaps with
     * other appointments of the same therapist.
     *
     * @param appointment the appointment to validate
     * @throws TimeSlotNotAvailableException if a conflict is detected
     */
    private void checkForConflicts(Appointment appointment) {
        List<Appointment> overlapping = appointmentDAO.findByTherapistInPeriod(
                                                                            appointment.getTherapistId(),
                                                                            appointment.getStart(),
                                                                            appointment.getEnd()
                                                                    );

        if (!overlapping.isEmpty()) {
            throw new TimeSlotNotAvailableException();
        }
    }

}
