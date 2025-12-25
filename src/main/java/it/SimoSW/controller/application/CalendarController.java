package it.SimoSW.controller.application;

import it.SimoSW.model.Appointment;
import it.SimoSW.util.dao.AppointmentDAO;
import it.SimoSW.util.dao.PatientDAO;
import it.SimoSW.util.dao.TherapistDAO;

import java.time.LocalDateTime;
import java.util.List;

public class CalendarController {

    private final AppointmentDAO appointmentDAO;
    private final PatientDAO patientDAO;
    private final TherapistDAO therapistDAO;

    public CalendarController(AppointmentDAO appointmentDAO, PatientDAO patientDAO, TherapistDAO therapistDAO) {
        this.appointmentDAO = appointmentDAO;
        this.patientDAO = patientDAO;
        this.therapistDAO = therapistDAO;
    }

    public List<Appointment> getAppointmentsInPeriod(LocalDateTime start,
                                                     LocalDateTime end) {
        return null;
    }

    public Appointment scheduleAppointment(Appointment appointment) {
        return null;
    }

    public Appointment rescheduleAppointment(long appointmentId,
                                             LocalDateTime newStart,
                                             LocalDateTime newEnd) {
        return null;
    }

    public void cancelAppointment(long appointmentId) {
    }


    private void validateTimeRange(LocalDateTime start, LocalDateTime end) {
    }

    private void checkPatientExists(long patientId) {
    }

    private void checkTherapistExists(long therapistId) {
    }

    private void checkForConflicts(Appointment appointment) {
    }

}
