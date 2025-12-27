package it.SimoSW.model;

import it.SimoSW.util.PasswordHasher;

import java.util.Objects;

public class User {

    private final int id;
    private final String username;
    private final String passwordHash;
    private final UserRole role;
    private final boolean active;

    public User(int id, String username, String passwordHash, UserRole role, boolean active) {
        this.id = id;
        this.username = username;
        this.passwordHash = passwordHash;
        this.role = role;
        this.active = active;
    }

    public int getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public UserRole getRole() {
        return role;
    }

    public boolean isActive() {
        return active;
    }

    public boolean checkPassword(String plainPassword) {
        if (plainPassword == null) {
            return false;
        }

        String hashedInput = PasswordHasher.hash(plainPassword);
        return Objects.equals(passwordHash, hashedInput);
    }
}
