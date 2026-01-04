package it.SimoSW.model.dao;

import it.SimoSW.model.User;

import java.util.Optional;

public interface UserDAO {
    Optional<User> findByUsername(String username);
}
