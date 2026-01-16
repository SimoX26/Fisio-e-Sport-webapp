package it.SimoSW.controller.graphic;

import it.SimoSW.controller.application.UserController;
import it.SimoSW.exception.InvalidUserDataException;
import it.SimoSW.exception.UsernameAlreadyExistsException;
import it.SimoSW.util.bootstrap.ApplicationInitializer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/create-user")
public class CreateUserServlet extends HttpServlet {

    private UserController userController;

    @Override
    public void init() {
        ApplicationInitializer initializer = (ApplicationInitializer) getServletContext().getAttribute("appInitializer");

        this.userController = initializer.getUserController();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        boolean active = request.getParameter("active") != null;

        try {
            userController.createUser(username, password, role, active);

            response.sendRedirect(request.getContextPath() + "/admin/users");

        } catch (InvalidUserDataException | UsernameAlreadyExistsException e) {

            request.setAttribute("error", e.getMessage());
            request.setAttribute("username", username);
            request.setAttribute("role", role);
            request.setAttribute("active", active);

            request.getRequestDispatcher("/WEB-INF/jsp/admin/newUser.jsp")
                    .forward(request, response);

        }
    }
}
