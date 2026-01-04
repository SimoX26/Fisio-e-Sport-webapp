package it.SimoSW.controller.application;

import it.SimoSW.model.dao.UserDAO;
import it.SimoSW.exception.AuthenticationFailedException;
import it.SimoSW.model.User;

import java.util.Optional;

public class AuthenticationController {

    private final UserDAO userDAO;

    public AuthenticationController(UserDAO userDAO) { this.userDAO = userDAO; }

    public User authenticate(String username, String password) {

        if (username == null || password == null) {
            throw new AuthenticationFailedException("Invalid credentials");
        }

        Optional<User> optionalUser = userDAO.findByUsername(username);

        if (optionalUser.isEmpty()) {
            throw new AuthenticationFailedException("Invalid credentials");
        }

        User user = optionalUser.get();

        if (!user.checkPassword(password)) {
            throw new AuthenticationFailedException("Invalid credentials");
        }

        return user;
    }
}
