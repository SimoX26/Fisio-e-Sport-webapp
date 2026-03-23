package it.SimoSW.controller.graphic;

import it.SimoSW.controller.application.AccessRequestController;
import it.SimoSW.exception.InvalidUserDataException;
import it.SimoSW.exception.UsernameAlreadyExistsException;
import it.SimoSW.util.bootstrap.ApplicationInitializer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterPageServlet extends HttpServlet {

    private AccessRequestController accessRequestController;

    @Override
    public void init() {
        ApplicationInitializer initializer =
                (ApplicationInitializer) getServletContext().getAttribute("appInitializer");
        this.accessRequestController = initializer.getAccessRequestController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String firstName = request.getParameter("nome");
        String lastName = request.getParameter("cognome");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            accessRequestController.submitAccessRequest(firstName, lastName, email, username, password);
            request.setAttribute("success", "Richiesta inviata. Un admin la valutera prima di abilitare l'account.");
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
        } catch (InvalidUserDataException | UsernameAlreadyExistsException ex) {
            request.setAttribute("error", ex.getMessage());
            request.setAttribute("nome", firstName);
            request.setAttribute("cognome", lastName);
            request.setAttribute("email", email);
            request.setAttribute("username", username);
            request.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(request, response);
        }
    }
}
