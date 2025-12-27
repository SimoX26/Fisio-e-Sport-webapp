package it.SimoSW.model;

import java.time.LocalDateTime;

public class Appointment {

    private long id;
    private long patientId;
    private long therapistId;
    private LocalDateTime start;
    private LocalDateTime end;
    private AppointmentState state;

    public Appointment() {
    }


    public Appointment(long id, long patientId, long therapistId,
                       LocalDateTime start, LocalDateTime end) {
        this.id = id;
        this.patientId = patientId;
        this.therapistId = therapistId;
        this.start = start;
        this.end = end;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
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

    public AppointmentState getState() {
        return state;
    }

    public void setState(AppointmentState state) {
        this.state = state;
    }
}
