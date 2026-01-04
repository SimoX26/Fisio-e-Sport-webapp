package it.SimoSW.model.dao.database;

import it.SimoSW.model.dao.UserDAO;
import it.SimoSW.model.User;
import it.SimoSW.model.UserRole;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;

public class DatabaseUserDAO implements UserDAO {

    private static final String FIND_BY_USERNAME =
            "SELECT id, username, password_hash, role, active " +
                    "FROM users WHERE username = ?";

    @Override
    public Optional<User> findByUsername(String username) {

        try (Connection conn = ConnectionFactory.getConnection();
             PreparedStatement stmt = conn.prepareStatement(FIND_BY_USERNAME)) {

            stmt.setString(1, username);

            try (ResultSet rs = stmt.executeQuery()) {

                if (!rs.next()) {
                    return Optional.empty();
                }

                User user = new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("password_hash"),
                        UserRole.valueOf(rs.getString("role")),
                        rs.getBoolean("active")
                );

                return Optional.of(user);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Error accessing user data", e);
        }
    }
}
