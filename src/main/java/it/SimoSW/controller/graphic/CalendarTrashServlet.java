package it.SimoSW.controller.graphic;

import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.util.bootstrap.ApplicationInitializer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/calendar/trash")
public class CalendarTrashServlet extends HttpServlet {

    private CalendarController calendarController;

    @Override
    public void init() {
        ApplicationInitializer initializer = (ApplicationInitializer) getServletContext().getAttribute("appInitializer");
        this.calendarController = initializer.getCalendarController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String loggedUser = (String) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null || loggedUser.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long therapistId = calendarController.resolveTherapistUserIdFromUsername(loggedUser);
        List<CalendarController.CancelledAppointmentView> cancelledAppointments =
                calendarController.getCancelledAppointmentsForTherapist(therapistId);

        request.setAttribute("error", request.getParameter("error"));
        request.setAttribute("cancelledAppointments", cancelledAppointments);
        request.getRequestDispatcher("/WEB-INF/jsp/therapist/calendarTrash.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String loggedUser = (String) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null || loggedUser.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long therapistId = calendarController.resolveTherapistUserIdFromUsername(loggedUser);
            String action = request.getParameter("action");
            long appointmentId = Long.parseLong(request.getParameter("id"));

            if ("restore".equals(action)) {
                calendarController.restoreAppointment(appointmentId, therapistId);
            } else if ("delete".equals(action)) {
                calendarController.deleteCancelledAppointment(appointmentId, therapistId);
            } else {
                throw new IllegalArgumentException("Azione non valida");
            }

            response.sendRedirect(request.getContextPath() + "/calendar/trash");
        } catch (RuntimeException ex) {
            String error = ex.getMessage() == null ? "Operazione non riuscita" : ex.getMessage();
            String encoded = URLEncoder.encode(error, StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/calendar/trash?error=" + encoded);
        }
    }
}
