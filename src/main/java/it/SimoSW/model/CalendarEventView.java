package it.SimoSW.model;

import java.time.LocalDateTime;

public class CalendarEventView {
    private final long appointmentId;
    private final Long patientId;
    private final long therapistId;
    private final LocalDateTime start;
    private final LocalDateTime end;
    private final boolean allDay;
    private final String notes;
    private final AppointmentState state;
    private final String patientFullName;

    public CalendarEventView(long appointmentId,
                             Long patientId,
                             long therapistId,
                             LocalDateTime start,
                             LocalDateTime end,
                             boolean allDay,
                             String notes,
                             AppointmentState state,
                             String patientFullName) {
        this.appointmentId = appointmentId;
        this.patientId = patientId;
        this.therapistId = therapistId;
        this.start = start;
        this.end = end;
        this.allDay = allDay;
        this.notes = notes;
        this.state = state;
        this.patientFullName = patientFullName;
    }

    public long getAppointmentId() {
        return appointmentId;
    }

    public Long getPatientId() {
        return patientId;
    }

    public long getTherapistId() {
        return therapistId;
    }

    public LocalDateTime getStart() {
        return start;
    }

    public LocalDateTime getEnd() {
        return end;
    }

    public boolean isAllDay() {
        return allDay;
    }

    public String getNotes() {
        return notes;
    }

    public AppointmentState getState() {
        return state;
    }

    public String getPatientFullName() {
        return patientFullName;
    }
}
