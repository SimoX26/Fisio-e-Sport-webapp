package it.SimoSW.model;

import java.time.LocalDateTime;

public class TreatmentSession {

    private long id;
    private long appointmentId;
    private long patientId;
    private long therapistId;
    private LocalDateTime start;
    private LocalDateTime end;
    private String notes;
    private TreatmentSessionState state;

    public TreatmentSession() {
    }

    public TreatmentSession(long id, long appointmentId,
                            long patientId, long therapistId) {
        this.id = id;
        this.appointmentId = appointmentId;
        this.patientId = patientId;
        this.therapistId = therapistId;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(long appointmentId) {
        this.appointmentId = appointmentId;
    }

    public long getPatientId() {
        return patientId;
    }

    public void setPatientId(long patientId) {
        this.patientId = patientId;
    }

    public long getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(long therapistId) {
        this.therapistId = therapistId;
    }

    public LocalDateTime getStart() {
        return start;
    }

    public void setStart(LocalDateTime start) {
        this.start = start;
    }

    public LocalDateTime getEnd() {
        return end;
    }

    public void setEnd(LocalDateTime end) {
        this.end = end;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public TreatmentSessionState getState() {
        return state;
    }

    public void setState(TreatmentSessionState state) {
        this.state = state;
    }
}
