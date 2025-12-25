package it.SimoSW.controller.graphic;

import it.SimoSW.controller.application.CalendarController;
import it.SimoSW.model.Appointment;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;


public class CalendarServlet extends HttpServlet {

    private CalendarController controller = new CalendarController();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {

        // Se il parametro "view" è presente → mostrare la JSP
        String view = req.getParameter("view");
        if (view != null && view.equals("page")) {
            req.getRequestDispatcher("/WEB-INF/jsp/calendario.jsp").forward(req, resp);
            return;
        }

        // Altrimenti → rispondi con JSON (FullCalendar richiede questo)
        resp.setContentType("application/json");

//        List<Appointment> eventi = controller.getAllEntries();
        PrintWriter out = resp.getWriter();
 //       out.print(toJson(eventi));
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) {
        String action = req.getParameter("action");

        System.out.println("ACTION = " + action);

        switch (action) {
            case "create":
                String data = req.getParameter("data");
 //               controller.entryCreated(data);
                break;

            case "delete":
                int id = Integer.parseInt(req.getParameter("id"));
 //               controller.entryDeleted(id);
                break;
        }
    }

    // JSON compatibile con FullCalendar
    private String toJson(List<Appointment> list) {
        StringBuilder sb = new StringBuilder("[");
        for (Appointment a : list) {
            sb.append("{")
                    .append("\"id\":\"").append(a.getId()).append("\",")
                    .append("\"title\":\"Paziente ").append(a.getIdPaziente()).append("\",")
                    .append("\"start\":\"").append(a.getInizio()).append("\"")
                    .append("},");
        }
        if (!list.isEmpty()) sb.deleteCharAt(sb.length() - 1);
        sb.append("]");
        return sb.toString();
    }
}