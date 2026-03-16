package it.SimoSW.controller.application;

import it.SimoSW.exception.AppointmentNotFoundException;
import it.SimoSW.exception.InvalidAppointmentStateException;
import it.SimoSW.exception.TimeSlotNotAvailableException;
import it.SimoSW.model.Appointment;
import it.SimoSW.model.AppointmentState;
import it.SimoSW.model.Patient;
import it.SimoSW.model.PatientState;
import it.SimoSW.model.UserRole;
import it.SimoSW.model.dao.AppointmentDAO;
import it.SimoSW.model.dao.PatientDAO;
import it.SimoSW.model.dao.UserDAO;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;

public class CalendarController {
    private static final int APPOINTMENT_DURATION_HOURS = 1;

    private final AppointmentDAO appointmentDAO;
    private final PatientDAO patientDAO;
    private final UserDAO userDAO;

    public CalendarController(AppointmentDAO appointmentDAO, PatientDAO patientDAO, UserDAO userDAO) {
        this.appointmentDAO = appointmentDAO;
        this.patientDAO = patientDAO;
        this.userDAO = userDAO;
    }

    public List<Appointment> getAppointmentsInPeriod(LocalDateTime start, LocalDateTime end) {
        validateTimeRange(start, end);
        return appointmentDAO.findInPeriod(start, end);
    }

    public Appointment scheduleAppointment(Appointment appointment) {
        if (appointment == null) {
            throw new IllegalArgumentException("Appointment cannot be null");
        }

        validateTimeRange(appointment.getStart(), appointment.getEnd());
        checkPatientExists(appointment.getPatientId());
        checkTherapistUserExists(appointment.getTherapistId());
        checkForConflicts(appointment);

        appointment.setState(AppointmentState.SCHEDULED);
        return appointmentDAO.save(appointment);
    }

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

    public long resolveOrCreatePatientId(String patientName) {
        String normalizedInput = normalize(patientName);
        if (normalizedInput.isBlank()) {
            throw new IllegalArgumentException("Il nome del paziente e obbligatorio");
        }

        List<Patient> matches = patientDAO.search(patientName);
        for (Patient existing : matches) {
            if (normalize(existing.getFullName()).equals(normalizedInput)) {
                return existing.getId();
            }
        }

        Patient newPatient = new Patient();
        String[] parts = patientName.trim().split("\\s+", 2);
        newPatient.setFirstName(parts[0]);
        newPatient.setLastName(parts.length > 1 ? parts[1] : "Paziente");
        newPatient.setEmail(null);
        newPatient.setPhone(null);
        newPatient.setState(PatientState.ACTIVE);

        return patientDAO.save(newPatient).getId();
    }

    public long resolveTherapistUserIdFromUsername(String username) {
        String normalizedUsername = normalize(username);
        if (normalizedUsername.isBlank()) {
            throw new IllegalArgumentException("Utente loggato non valido");
        }

        return userDAO.findIdByUsernameAndRole(username, UserRole.THERAPIST)
                .orElseThrow(() -> new IllegalArgumentException("L'utente loggato non e un terapista attivo"));
    }

    private void validateTimeRange(LocalDateTime start, LocalDateTime end) {
        if (start == null || end == null || !start.isBefore(end)) {
            throw new IllegalArgumentException("Invalid time range");
        }

        if (!isOnHourBoundary(start) || !isOnHourBoundary(end)) {
            throw new IllegalArgumentException("Gli appuntamenti devono iniziare e finire all'ora piena");
        }

        long durationHours = ChronoUnit.HOURS.between(start, end);
        if (durationHours != APPOINTMENT_DURATION_HOURS) {
            throw new IllegalArgumentException("La durata dell'appuntamento deve essere di 1 ora");
        }
    }

    private boolean isOnHourBoundary(LocalDateTime value) {
        return value.getMinute() == 0
                && value.getSecond() == 0
                && value.getNano() == 0;
    }

    private void checkPatientExists(long patientId) {
        patientDAO.findById(patientId)
                .orElseThrow(() -> new IllegalArgumentException("Patient not found: " + patientId));
    }

    private void checkTherapistUserExists(long therapistUserId) {
        if (therapistUserId <= 0) {
            throw new IllegalArgumentException("Invalid therapist user id");
        }
        if (!userDAO.existsByIdAndRole(therapistUserId, UserRole.THERAPIST)) {
            throw new IllegalArgumentException("Therapist user not found: " + therapistUserId);
        }
    }

    private void checkForConflicts(Appointment appointment) {
        List<Appointment> overlapping = appointmentDAO.findByTherapistInPeriod(
                appointment.getTherapistId(),
                appointment.getStart(),
                appointment.getEnd()
        );

        boolean hasConflict = overlapping.stream()
                .anyMatch(existing -> existing.getId() != appointment.getId());

        if (hasConflict) {
            throw new TimeSlotNotAvailableException();
        }
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value
                .trim()
                .toLowerCase(Locale.ROOT)
                .replaceAll("\\s+", " ");
    }
}
