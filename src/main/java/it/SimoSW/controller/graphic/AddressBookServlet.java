package it.SimoSW.controller.graphic;

import it.SimoSW.bootstrap.ApplicationInitializer;
import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.model.Patient;
import it.SimoSW.exception.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/address-book")
public class AddressBookServlet extends HttpServlet {

    private AddressBookController addressBookController;

    @Override
    public void init() {
        ApplicationInitializer initializer =
                (ApplicationInitializer) getServletContext()
                        .getAttribute("appInitializer");

        this.addressBookController = initializer.getAddressBookController();
    }

    /* =========================
       GET → visualizzazione
       ========================= */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("q");
        List<Patient> patients =
                addressBookController.searchPatients(
                        query != null ? query : ""
                );

        request.setAttribute("patients", patients);
        request.getRequestDispatcher("/WEB-INF/jsp/addressBook.jsp")
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

                case "create" -> createPatient(request);
                case "update" -> updatePatient(request);
                case "activate" -> changeState(request, "activate");
                case "deactivate" -> changeState(request, "deactivate");
                case "archive" -> changeState(request, "archive");

                default -> throw new IllegalArgumentException("Unknown action");
            }

            response.sendRedirect(request.getContextPath() + "/address-book");

        } catch (RuntimeException ex) {
            request.setAttribute("error", ex.getMessage());
            doGet(request, response);
        }
    }

    /* =========================
       Metodi di supporto
       ========================= */

    private void createPatient(HttpServletRequest request) {
        Patient p = new Patient();
        p.setId(Long.parseLong(request.getParameter("id")));
        p.setFirstName(request.getParameter("firstName"));
        p.setLastName(request.getParameter("lastName"));
        p.setEmail(request.getParameter("email"));
        p.setPhone(request.getParameter("phone"));

        addressBookController.registerPatient(p);
    }

    private void updatePatient(HttpServletRequest request) {
        Patient p = new Patient();
        p.setId(Long.parseLong(request.getParameter("id")));
        p.setFirstName(request.getParameter("firstName"));
        p.setLastName(request.getParameter("lastName"));
        p.setEmail(request.getParameter("email"));
        p.setPhone(request.getParameter("phone"));

        addressBookController.updatePatientProfile(p);
    }

    private void changeState(HttpServletRequest request, String state) {
        long patientId = Long.parseLong(request.getParameter("id"));

        switch (state) {
            case "activate" ->
                    addressBookController.activatePatient(patientId);
            case "deactivate" ->
                    addressBookController.deactivatePatient(patientId);
            case "archive" ->
                    addressBookController.archivePatient(patientId);
        }
    }
}
