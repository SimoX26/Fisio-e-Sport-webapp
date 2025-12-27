package it.SimoSW.controller.graphic;

import it.SimoSW.bootstrap.ApplicationInitializer;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.model.Appointment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/calendar")
public class CalendarServlet extends HttpServlet {

    private CalendarController calendarController;
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public void init() {
        ApplicationInitializer initializer = (ApplicationInitializer) getServletContext().getAttribute("appInitializer");

        this.calendarController = initializer.getCalendarController();
    }

    /* =========================
       GET
       ========================= */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Caso 1: richiesta eventi
        if ("true".equals(request.getParameter("events"))) {
            loadEvents(request, response);
            return;
        }

        // Caso 2: richiesta dettagli appuntamento
        if ("true".equals(request.getParameter("details"))) {
            loadAppointmentDetails(request, response);
            return;
        }

        // Caso 3: visualizzazione pagina calendario
        request.getRequestDispatcher("/WEB-INF/jsp/calendar.jsp").forward(request, response);
    }

    /* =========================
       POST
       ========================= */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            switch (action) {
                case "create" -> createAppointment(request);
                case "reschedule" -> rescheduleAppointment(request);
                case "cancel" -> cancelAppointment(request);
                default -> throw new IllegalArgumentException("Unknown action");
            }

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (RuntimeException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        }
    }

    /* =========================
       Support methods
       ========================= */

    private void loadEvents(HttpServletRequest request, HttpServletResponse response) throws IOException {

        LocalDateTime start = LocalDateTime.parse(request.getParameter("start"));
        LocalDateTime end = LocalDateTime.parse(request.getParameter("end"));

        List<Appointment> appointments = calendarController.getAppointmentsInPeriod(start, end);

        response.setContentType("application/json");
        mapper.writeValue(response.getWriter(), appointments);
    }

    private void loadAppointmentDetails(HttpServletRequest request, HttpServletResponse response) throws IOException {

        long appointmentId = Long.parseLong(request.getParameter("id"));

        Appointment appointment = calendarController.getAppointmentDetails(appointmentId);

        response.setContentType("application/json");
        mapper.writeValue(response.getWriter(), appointment);
    }

    private void createAppointment(HttpServletRequest request) {

        Appointment a = new Appointment();
        a.setId(Long.parseLong(request.getParameter("id")));
        a.setPatientId(Long.parseLong(request.getParameter("patientId")));
        a.setTherapistId(Long.parseLong(request.getParameter("therapistId")));
        a.setStart(LocalDateTime.parse(request.getParameter("start")));
        a.setEnd(LocalDateTime.parse(request.getParameter("end")));

        calendarController.scheduleAppointment(a);
    }

    private void rescheduleAppointment(HttpServletRequest request) {

        long appointmentId =
                Long.parseLong(request.getParameter("id"));

        LocalDateTime newStart =
                LocalDateTime.parse(request.getParameter("start"));
        LocalDateTime newEnd =
                LocalDateTime.parse(request.getParameter("end"));

        calendarController.rescheduleAppointment(
                appointmentId,
                newStart,
                newEnd
        );
    }

    private void cancelAppointment(HttpServletRequest request) {

        long appointmentId =
                Long.parseLong(request.getParameter("id"));

        calendarController.cancelAppointment(appointmentId);
    }
}
