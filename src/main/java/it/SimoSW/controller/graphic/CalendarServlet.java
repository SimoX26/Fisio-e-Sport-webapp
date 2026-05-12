package it.SimoSW.controller.graphic;

import it.SimoSW.util.bootstrap.ApplicationInitializer;
import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.controller.application.TreatmentController;
import it.SimoSW.model.Appointment;
import it.SimoSW.model.AppointmentState;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet("/calendar")
public class CalendarServlet extends HttpServlet {

    private static final DateTimeFormatter REMINDER_DAY_LABEL_FORMATTER = DateTimeFormatter.ofPattern("EEEE d MMMM yyyy", Locale.ITALIAN);
    private static final DateTimeFormatter REMINDER_TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");
    private static final String DEFAULT_REMINDER_TEMPLATE = "Gentile {nome paziente}, le ricordiamo l'appuntamento fissato per {giorno} per l'orario {ora inizio - ora fine}.";

    private CalendarController calendarController;
    private TreatmentController treatmentController;
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public void init() {
        ApplicationInitializer initializer = (ApplicationInitializer) getServletContext().getAttribute("appInitializer");

        this.calendarController = initializer.getCalendarController();
        this.treatmentController = initializer.getTreatmentController();
    }

    /* =========================
       GET
       ========================= */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        if ("true".equals(request.getParameter("reminderPreview"))) {
            loadReminderPreview(request, response);
            return;
        }

        if ("true".equals(request.getParameter("patients"))) {
            loadPatientSuggestions(request, response);
            return;
        }

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
                case "complete" -> completeAppointmentAndCreateTreatment(request);
                case "send-reminders" -> sendReminders(request, response);
                default -> throw new IllegalArgumentException("Unknown action");
            }

            if (!"send-reminders".equals(action)) {
                response.setStatus(HttpServletResponse.SC_OK);
            }

        } catch (RuntimeException ex) {
            sendClientError(response, HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        }
    }

    /* =========================
       Support methods
       ========================= */

    private void loadEvents(HttpServletRequest request, HttpServletResponse response) throws IOException {
        long therapistId = resolveTherapistIdFromSession(request);
        LocalDateTime start = parseDateTime(request.getParameter("start"));
        LocalDateTime end = parseDateTime(request.getParameter("end"));

        List<Appointment> appointments = calendarController.getAppointmentsForTherapistInPeriod(therapistId, start, end);
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
            extendedProps.put("allDay", appointment.isAllDay());
            event.put("extendedProps", extendedProps);
            event.put("allDay", appointment.isAllDay());

            events.add(event);
        }

        response.setContentType("application/json");
        mapper.writeValue(response.getWriter(), events);
    }

    private void loadPatientSuggestions(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String query = request.getParameter("q");
        List<String> names = calendarController.searchPatientNames(query, 8);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        mapper.writeValue(response.getWriter(), names);
    }

    private void loadReminderPreview(HttpServletRequest request, HttpServletResponse response) throws IOException {
        resolveTherapistIdFromSession(request);
        LocalDate targetDate = parseRequiredDate(request.getParameter("date"));
        String template = normalizeNotes(request.getParameter("template"));
        if (template == null) {
            template = DEFAULT_REMINDER_TEMPLATE;
        }

        List<Map<String, Object>> recipients = buildReminderRecipients(targetDate, template);
        Map<String, Object> payload = new HashMap<>();
        payload.put("date", targetDate.toString());
        payload.put("dayLabel", formatReminderDayLabel(targetDate));
        payload.put("template", template);
        payload.put("defaultTemplate", DEFAULT_REMINDER_TEMPLATE);
        payload.put("recipients", recipients);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        mapper.writeValue(response.getWriter(), payload);
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

        boolean allDay = parseBooleanParameter(request.getParameter("allDay"));
        String patientName = request.getParameter("patientName");
        long patientId = allDay
                ? calendarController.resolveExistingPatientId(patientName)
                : calendarController.resolveOrCreatePatientId(patientName);
        long therapistId = calendarController.resolveTherapistUserIdFromUsername(loggedUser);

        Appointment a = new Appointment();
        a.setPatientId(patientId);
        a.setStart(parseDateTime(request.getParameter("start")));
        a.setEnd(parseDateTime(request.getParameter("end")));
        a.setAllDay(allDay);
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
        boolean allDay = parseBooleanParameter(request.getParameter("allDay"));
        String notes = normalizeNotes(request.getParameter("notes"));

        calendarController.rescheduleAppointment(
                appointmentId,
                patientName,
                newStart,
                newEnd,
                allDay,
                notes
        );
    }

    private void cancelAppointment(HttpServletRequest request) {

        long appointmentId = Long.parseLong(request.getParameter("id"));

        calendarController.cancelAppointment(appointmentId);
    }

    private void sendReminders(HttpServletRequest request, HttpServletResponse response) throws IOException {
        resolveTherapistIdFromSession(request);
        LocalDate targetDate = parseRequiredDate(request.getParameter("date"));
        String template = normalizeNotes(request.getParameter("template"));
        if (template == null) {
            template = DEFAULT_REMINDER_TEMPLATE;
        }

        List<Map<String, Object>> recipients = buildReminderRecipients(targetDate, template);
        for (Map<String, Object> recipient : recipients) {
            String patientName = String.valueOf(recipient.get("patientName"));
            String email = String.valueOf(recipient.get("patientEmail"));
            String message = String.valueOf(recipient.get("message"));
            getServletContext().log("[REMINDER] date=" + targetDate + " patient=" + patientName + " email=" + email + " message=" + message);
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("date", targetDate.toString());
        payload.put("dayLabel", formatReminderDayLabel(targetDate));
        payload.put("processedCount", recipients.size());
        payload.put("channel", "LOG");
        payload.put("note", "Promemoria elaborati e registrati nel log applicativo.");

        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        mapper.writeValue(response.getWriter(), payload);
    }

    private void completeAppointmentAndCreateTreatment(HttpServletRequest request) {
        long appointmentId = Long.parseLong(request.getParameter("id"));
        Appointment completed = calendarController.completeAppointment(appointmentId);
        if (!completed.isAllDay()) {
            treatmentController.createTreatmentForCompletedAppointment(
                    appointmentId,
                    normalizeRequired(request.getParameter("planTitle"), "Titolo piano terapeutico obbligatorio"),
                    normalizeNotes(request.getParameter("goals")),
                    parseOptionalInteger(request.getParameter("frequencyPerWeek"), "Frequenza settimanale non valida"),
                    parseOptionalDate(request.getParameter("expectedEndDate"), "Fine prevista non valida"),
                    parseOptionalInteger(request.getParameter("totalSessionsPlanned"), "Numero sedute pianificate non valido"),
                    parseOptionalInteger(request.getParameter("painScorePre"), "Dolore pre non valido"),
                    parseOptionalInteger(request.getParameter("painScorePost"), "Dolore post non valido"),
                    normalizeNotes(request.getParameter("sessionOutcome")),
                    normalizeNotes(request.getParameter("homeExercises")),
                    normalizeNotes(request.getParameter("notes"))
            );
        }
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

    private String normalizeRequired(String value, String errorMessage) {
        String normalized = normalizeNotes(value);
        if (normalized == null) {
            throw new IllegalArgumentException(errorMessage);
        }
        return normalized;
    }

    private Integer parseOptionalInteger(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    private LocalDate parseOptionalDate(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    private boolean parseBooleanParameter(String value) {
        return value != null && ("true".equalsIgnoreCase(value) || "on".equalsIgnoreCase(value) || "1".equals(value));
    }

    private long resolveTherapistIdFromSession(HttpServletRequest request) {
        String loggedUser = (String) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null || loggedUser.isBlank()) {
            throw new IllegalArgumentException("Sessione non valida: utente non autenticato");
        }
        return calendarController.resolveTherapistUserIdFromUsername(loggedUser);
    }

    private LocalDate parseRequiredDate(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Data reminder mancante");
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Data reminder non valida: " + value);
        }
    }

    private List<Map<String, Object>> buildReminderRecipients(LocalDate targetDate, String template) {
        LocalDateTime start = targetDate.atStartOfDay();
        LocalDateTime end = targetDate.plusDays(1).atStartOfDay();
        List<Appointment> appointments = calendarController.getAppointmentsInPeriod(start, end);
        List<Map<String, Object>> recipients = new ArrayList<>();
        String dayLabel = formatReminderDayLabel(targetDate);

        for (Appointment appointment : appointments) {
            if (appointment.getState() != AppointmentState.SCHEDULED) {
                continue;
            }
            String patientName = calendarController.resolvePatientFullName(appointment.getPatientId());
            String startTime = appointment.getStart() == null ? "-" : appointment.getStart().toLocalTime().format(REMINDER_TIME_FORMATTER);
            String endTime = appointment.getEnd() == null ? "-" : appointment.getEnd().toLocalTime().format(REMINDER_TIME_FORMATTER);
            String timeRange = startTime + " - " + endTime;
            String renderedMessage = renderReminderMessage(template, patientName, dayLabel, startTime, endTime, timeRange);

            Map<String, Object> row = new HashMap<>();
            row.put("appointmentId", appointment.getId());
            row.put("patientName", patientName);
            row.put("patientEmail", calendarController.resolvePatientEmail(appointment.getPatientId()));
            row.put("dayLabel", dayLabel);
            row.put("startTime", startTime);
            row.put("endTime", endTime);
            row.put("timeRange", timeRange);
            row.put("message", renderedMessage);
            recipients.add(row);
        }
        return recipients;
    }

    private String formatReminderDayLabel(LocalDate date) {
        if (date == null) {
            return "-";
        }
        return date.format(REMINDER_DAY_LABEL_FORMATTER);
    }

    private String renderReminderMessage(String template, String patientName, String dayLabel, String startTime, String endTime, String timeRange) {
        String result = template == null ? DEFAULT_REMINDER_TEMPLATE : template;
        result = result.replace("{nome paziente}", patientName == null ? "" : patientName);
        result = result.replace("{giorno}", dayLabel == null ? "" : dayLabel);
        result = result.replace("{ora inizio}", startTime == null ? "" : startTime);
        result = result.replace("{ora fine}", endTime == null ? "" : endTime);
        result = result.replace("{ora inizio - ora fine}", timeRange == null ? "" : timeRange);
        return result;
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
