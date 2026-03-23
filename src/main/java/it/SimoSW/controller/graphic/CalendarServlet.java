package it.SimoSW.controller.graphic;

import it.SimoSW.util.bootstrap.ApplicationInitializer;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.model.Appointment;
import it.SimoSW.model.AppointmentState;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

        /*
        // Caso 2: richiesta dettagli appuntamento
        if ("true".equals(request.getParameter("details"))) {
            loadAppointmentDetails(request, response);
            return;
        }
         */

        // Caso 3: visualizzazione pagina calendario
        request.getRequestDispatcher("/WEB-INF/jsp/therapist/calendar.jsp").forward(request, response);
    }

    /* =========================
       POST
       ========================= */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if (action == null || action.isBlank()) {
                throw new IllegalArgumentException("Azione mancante");
            }

            switch (action) {
                case "create" -> createAppointment(request);
                case "reschedule" -> rescheduleAppointment(request);
                case "cancel" -> cancelAppointment(request);
                default -> throw new IllegalArgumentException("Unknown action");
            }

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (RuntimeException ex) {
            sendClientError(response, HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        }
    }

    /* =========================
       Support methods
       ========================= */

    private void loadEvents(HttpServletRequest request, HttpServletResponse response) throws IOException {

        LocalDateTime start = parseDateTime(request.getParameter("start"));
        LocalDateTime end = parseDateTime(request.getParameter("end"));

        List<Appointment> appointments = calendarController.getAppointmentsInPeriod(start, end);
        List<Map<String, Object>> events = new ArrayList<>();

        for (Appointment appointment : appointments) {
            if (appointment.getState() == AppointmentState.CANCELLED) {
                continue;
            }
            Map<String, Object> event = new HashMap<>();
            String patientFullName = calendarController.resolvePatientFullName(appointment.getPatientId());
            event.put("id", appointment.getId());
            event.put("title", patientFullName);
            event.put("start", appointment.getStart().toString());
            event.put("end", appointment.getEnd().toString());
            event.put("backgroundColor", "#eaf1fb");
            event.put("borderColor", "#7f9fcd");
            event.put("textColor", "#1f2d3d");

            Map<String, Object> extendedProps = new HashMap<>();
            extendedProps.put("patientId", appointment.getPatientId());
            extendedProps.put("patient", patientFullName);
            extendedProps.put("therapistId", appointment.getTherapistId());
            extendedProps.put("state", appointment.getState().name());
            extendedProps.put("notes", appointment.getNotes());
            event.put("extendedProps", extendedProps);

            events.add(event);
        }

        response.setContentType("application/json");
        mapper.writeValue(response.getWriter(), events);
    }

/*
    private void loadAppointmentDetails(HttpServletRequest request, HttpServletResponse response) throws IOException {

        long appointmentId = Long.parseLong(request.getParameter("id"));

        Appointment appointment = calendarController.getAppointmentDetails(appointmentId);

        response.setContentType("application/json");
        mapper.writeValue(response.getWriter(), appointment);
    }
*/

    private void createAppointment(HttpServletRequest request) {
        String loggedUser = (String) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null || loggedUser.isBlank()) {
            throw new IllegalArgumentException("Sessione non valida: utente non autenticato");
        }

        String patientName = request.getParameter("patientName");
        long patientId = calendarController.resolveOrCreatePatientId(patientName);
        long therapistId = calendarController.resolveTherapistUserIdFromUsername(loggedUser);

        Appointment a = new Appointment();
        a.setPatientId(patientId);
        a.setStart(parseDateTime(request.getParameter("start")));
        a.setEnd(parseDateTime(request.getParameter("end")));
        a.setNotes(normalizeNotes(request.getParameter("notes")));
        a.setTherapistId(therapistId);

        calendarController.scheduleAppointment(a);
    }

    private void rescheduleAppointment(HttpServletRequest request) {

        long appointmentId =
                Long.parseLong(request.getParameter("id"));

        String patientName = request.getParameter("patientName");
        LocalDateTime newStart = parseDateTime(request.getParameter("start"));
        LocalDateTime newEnd = parseDateTime(request.getParameter("end"));
        String notes = normalizeNotes(request.getParameter("notes"));

        calendarController.rescheduleAppointment(
                appointmentId,
                patientName,
                newStart,
                newEnd,
                notes
        );
    }

    private void cancelAppointment(HttpServletRequest request) {

        long appointmentId = Long.parseLong(request.getParameter("id"));

        calendarController.cancelAppointment(appointmentId);
    }

    private LocalDateTime parseDateTime(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Date-time mancante");
        }

        try {
            return LocalDateTime.parse(value);
        } catch (DateTimeParseException ignored) {
        }

        try {
            return OffsetDateTime.parse(value).toLocalDateTime();
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Formato data/ora non valido: " + value);
        }
    }

    private String normalizeNotes(String notes) {
        if (notes == null) {
            return null;
        }

        String normalized = notes.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private void sendClientError(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Map<String, String> payload = new HashMap<>();
        payload.put("error", message == null || message.isBlank() ? "Richiesta non valida" : message);
        mapper.writeValue(response.getWriter(), payload);
    }
}
