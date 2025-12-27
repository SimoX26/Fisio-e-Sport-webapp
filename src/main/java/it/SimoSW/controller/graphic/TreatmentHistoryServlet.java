package it.SimoSW.controller.graphic;

import it.SimoSW.util.bootstrap.ApplicationInitializer;
import it.SimoSW.controller.application.TreatmentHistoryController;
import it.SimoSW.model.TreatmentSession;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

        import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/treatment-history")
public class TreatmentHistoryServlet extends HttpServlet {

    private TreatmentHistoryController treatmentHistoryController;

    @Override
    public void init() {
        ApplicationInitializer initializer =
                (ApplicationInitializer) getServletContext()
                        .getAttribute("appInitializer");

        this.treatmentHistoryController =
                initializer.getTreatmentHistoryController();
    }

    /* =========================
       GET → storico sedute
       ========================= */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        long patientId =
                Long.parseLong(request.getParameter("patientId"));

        List<TreatmentSession> sessions =
                treatmentHistoryController
                        .getTreatmentHistoryForPatient(patientId);

        request.setAttribute("sessions", sessions);
        request.setAttribute("patientId", patientId);

        request.getRequestDispatcher("/WEB-INF/jsp/treatmentHistory.jsp")
                .forward(request, response);
    }

    /* =========================
       POST → azioni
       ========================= */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            switch (action) {

                case "create" -> createSession(request);
                case "finalize" -> finalizeSession(request);
                default -> throw new IllegalArgumentException("Unknown action");
            }

            long patientId =
                    Long.parseLong(request.getParameter("patientId"));

            response.sendRedirect(
                    request.getContextPath()
                            + "/treatment-history?patientId=" + patientId
            );

        } catch (RuntimeException ex) {
            request.setAttribute("error", ex.getMessage());
            doGet(request, response);
        }
    }

    /* =========================
       Support methods
       ========================= */

    private void createSession(HttpServletRequest request) {

        TreatmentSession session = new TreatmentSession();

        session.setId(
                Long.parseLong(request.getParameter("id"))
        );
        session.setAppointmentId(
                Long.parseLong(request.getParameter("appointmentId"))
        );
        session.setPatientId(
                Long.parseLong(request.getParameter("patientId"))
        );
        session.setTherapistId(
                Long.parseLong(request.getParameter("therapistId"))
        );
        session.setStart(
                LocalDateTime.parse(request.getParameter("start"))
        );
        session.setEnd(
                LocalDateTime.parse(request.getParameter("end"))
        );
        session.setNotes(
                request.getParameter("notes")
        );

        treatmentHistoryController
                .recordTreatmentSession(session);
    }

    private void finalizeSession(HttpServletRequest request) {

        long sessionId =
                Long.parseLong(request.getParameter("sessionId"));

        treatmentHistoryController
                .finalizeTreatment(sessionId);
    }
}
