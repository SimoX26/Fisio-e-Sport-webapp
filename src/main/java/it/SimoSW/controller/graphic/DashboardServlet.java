package it.SimoSW.controller.graphic;

import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.model.Appointment;
import it.SimoSW.util.bootstrap.ApplicationInitializer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.TextStyle;
import java.time.temporal.ChronoUnit;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private CalendarController calendarController;

    @Override
    public void init() {
        ApplicationInitializer initializer = (ApplicationInitializer) getServletContext().getAttribute("appInitializer");
        this.calendarController = initializer.getCalendarController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int appointmentsToday = 0;
        int patientsThisMonth = 0;
        long bookedHoursThisWeek = 0;
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();
        String todayLabel = formatFullDateLabel(today);
        String patientsMonthYearLabel = formatMonthYearLabel(today);
        String weekRangeLabel = formatWeekRangeLabel(today);
        String loggedUserDisplay = "";
        String greetingPrefix = now.getHour() > 15 ? "Buonasera" : "Buongiorno";

        try {
            String loggedUser = (String) request.getSession().getAttribute("loggedUser");
            if (loggedUser != null && !loggedUser.isBlank()) {
                loggedUserDisplay = loggedUser.trim().toUpperCase(Locale.ROOT);
                long therapistId = calendarController.resolveTherapistUserIdFromUsername(loggedUser);

                LocalDateTime todayStart = today.atStartOfDay();
                LocalDateTime tomorrowStart = today.plusDays(1).atStartOfDay();
                appointmentsToday = calendarController
                        .getAppointmentsForTherapistInPeriod(therapistId, todayStart, tomorrowStart)
                        .size();

                LocalDate weekStartDate = today.with(DayOfWeek.MONDAY);
                LocalDateTime weekStart = weekStartDate.atStartOfDay();
                LocalDateTime weekEnd = weekStart.plusDays(7);
                List<Appointment> weekAppointments = calendarController
                        .getAppointmentsForTherapistInPeriod(therapistId, weekStart, weekEnd);
                bookedHoursThisWeek = weekAppointments.stream()
                        .filter(a -> !a.isAllDay())
                        .mapToLong(a -> ChronoUnit.HOURS.between(a.getStart(), a.getEnd()))
                        .sum();

                LocalDate monthStartDate = today.withDayOfMonth(1);
                LocalDateTime monthStart = monthStartDate.atStartOfDay();
                LocalDateTime monthEnd = monthStart.plusMonths(1);
                List<Appointment> monthAppointments = calendarController
                        .getAppointmentsForTherapistInPeriod(therapistId, monthStart, monthEnd);
                Set<Long> patientIds = new HashSet<>();
                for (Appointment appointment : monthAppointments) {
                    patientIds.add(appointment.getPatientId());
                }
                patientsThisMonth = patientIds.size();
            }
        } catch (RuntimeException ex) {
            request.setAttribute("error", "Impossibile caricare i dati panoramici in questo momento.");
        }

        request.setAttribute("appointmentsToday", appointmentsToday);
        request.setAttribute("todayLabel", todayLabel);
        request.setAttribute("patientsThisMonth", patientsThisMonth);
        request.setAttribute("bookedHoursThisWeek", bookedHoursThisWeek);
        request.setAttribute("patientsMonthYearLabel", patientsMonthYearLabel);
        request.setAttribute("weekRangeLabel", weekRangeLabel);
        request.setAttribute("greetingPrefix", greetingPrefix);
        request.setAttribute("loggedUserDisplay", loggedUserDisplay);
        request.getRequestDispatcher("/WEB-INF/jsp/therapist/dashboard.jsp").forward(request, response);
    }

    private String formatFullDateLabel(LocalDate date) {
        String month = date.getMonth().getDisplayName(TextStyle.FULL, Locale.ITALIAN);
        return date.getDayOfMonth() + " " + month + " " + date.getYear();
    }

    private String formatMonthYearLabel(LocalDate date) {
        String month = date.getMonth().getDisplayName(TextStyle.FULL, Locale.ITALIAN);
        return month + " " + date.getYear();
    }

    private String formatWeekRangeLabel(LocalDate date) {
        LocalDate weekStart = date.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = weekStart.plusDays(6);

        String startMonth = weekStart.getMonth().getDisplayName(TextStyle.FULL, Locale.ITALIAN);
        String endMonth = weekEnd.getMonth().getDisplayName(TextStyle.FULL, Locale.ITALIAN);

        if (weekStart.getMonth() == weekEnd.getMonth()) {
            return weekStart.getDayOfMonth() + " - " + weekEnd.getDayOfMonth() + " " + startMonth;
        }

        return weekStart.getDayOfMonth() + " " + startMonth + " - " + weekEnd.getDayOfMonth() + " " + endMonth;
    }
}
