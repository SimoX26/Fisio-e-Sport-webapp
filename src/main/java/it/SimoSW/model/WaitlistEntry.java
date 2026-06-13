package it.SimoSW.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class WaitlistEntry {
    private static final DateTimeFormatter CREATED_AT_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private long id;
    private long therapistId;
    private String firstName;
    private String lastName;
    private String phone;
    private LocalDateTime createdAt;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(long therapistId) {
        this.therapistId = therapistId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getFullName() {
        String first = firstName == null ? "" : firstName.trim();
        String last = lastName == null ? "" : lastName.trim();
        String fullName = (first + " " + last).trim();
        return fullName.isEmpty() ? "Contatto" : fullName;
    }

    public String getCreatedAtLabel() {
        if (createdAt == null) {
            return "";
        }
        return CREATED_AT_FORMATTER.format(createdAt);
    }
}
