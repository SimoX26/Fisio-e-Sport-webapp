package it.SimoSW.controller.graphic;

import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.controller.application.CalendarController;
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

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private CalendarController calendarController;
    private AddressBookController addressBookController;

    @Override
    public void init() {
        ApplicationInitializer initializer = (ApplicationInitializer) getServletContext().getAttribute("appInitializer");
        this.calendarController = initializer.getCalendarController();
        this.addressBookController = initializer.getAddressBookController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int appointmentsToday = 0;
        int totalPatients = 0;
        int treatmentsThisWeek = 0;

        try {
            String loggedUser = (String) request.getSession().getAttribute("loggedUser");
            if (loggedUser != null && !loggedUser.isBlank()) {
                long therapistId = calendarController.resolveTherapistUserIdFromUsername(loggedUser);

                LocalDate today = LocalDate.now();
                LocalDateTime todayStart = today.atStartOfDay();
                LocalDateTime tomorrowStart = today.plusDays(1).atStartOfDay();
                appointmentsToday = calendarController
                        .getAppointmentsForTherapistInPeriod(therapistId, todayStart, tomorrowStart)
                        .size();

                LocalDate weekStartDate = today.with(DayOfWeek.MONDAY);
                LocalDateTime weekStart = weekStartDate.atStartOfDay();
                LocalDateTime weekEnd = weekStart.plusDays(7);
                treatmentsThisWeek = calendarController
                        .getAppointmentsForTherapistInPeriod(therapistId, weekStart, weekEnd)
                        .size();
            }

            totalPatients = addressBookController.searchPatients("").size();
        } catch (RuntimeException ex) {
            request.setAttribute("error", "Impossibile caricare i dati panoramici in questo momento.");
        }

        request.setAttribute("appointmentsToday", appointmentsToday);
        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("treatmentsThisWeek", treatmentsThisWeek);
        request.getRequestDispatcher("/WEB-INF/jsp/therapist/dashboard.jsp").forward(request, response);
    }
}
