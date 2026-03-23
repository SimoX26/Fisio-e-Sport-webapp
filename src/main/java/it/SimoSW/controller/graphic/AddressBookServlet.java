package it.SimoSW.controller.graphic;

import it.SimoSW.util.bootstrap.ApplicationInitializer;
import it.SimoSW.controller.application.AddressBookController;
import it.SimoSW.model.ConditionCategory;
import it.SimoSW.model.PatientAnamnesis;
import it.SimoSW.model.PatientCondition;
import it.SimoSW.model.Patient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.math.BigDecimal;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collections;
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

        List<Patient> patients = Collections.emptyList();
        String query = request.getParameter("q");

        try {
            patients = addressBookController.searchPatients(
                    query != null ? query : ""
            );
        } catch (RuntimeException ex) {
            request.setAttribute("error", "Impossibile caricare la rubrica in questo momento.");
        }

        request.setAttribute("patients", patients);
        request.getRequestDispatcher("/WEB-INF/jsp/therapist/addressBook.jsp")
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
                case "delete" -> deletePatient(request);
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
        p.setFirstName(normalizeRequired(request.getParameter("firstName"), "Il nome e obbligatorio"));
        p.setLastName(normalizeOptional(request.getParameter("lastName")));
        p.setEmail(normalizeOptional(request.getParameter("email")));
        p.setPhone(normalizeOptional(request.getParameter("phone")));

        addressBookController.registerPatient(p);
    }

    private void updatePatient(HttpServletRequest request) {
        Patient p = new Patient();
        p.setId(Long.parseLong(request.getParameter("id")));
        p.setFirstName(normalizeRequired(request.getParameter("firstName"), "Il nome e obbligatorio"));
        p.setLastName(normalizeOptional(request.getParameter("lastName")));
        p.setEmail(normalizeOptional(request.getParameter("email")));
        p.setPhone(normalizeOptional(request.getParameter("phone")));

        addressBookController.updatePatientProfile(p);

        PatientAnamnesis anamnesis = parseAnamnesis(request);
        List<PatientCondition> conditions = parseConditions(request);

        if (!hasAnamnesisData(anamnesis, conditions)) {
            return;
        }

        Object loggedUser = request.getSession().getAttribute("loggedUser");
        if (loggedUser == null) {
            throw new IllegalArgumentException("Sessione terapista non valida");
        }
        String therapistUsername = String.valueOf(loggedUser).trim();
        if (therapistUsername.isEmpty()) {
            throw new IllegalArgumentException("Sessione terapista non valida");
        }

        addressBookController.savePatientAnamnesis(p.getId(), therapistUsername, anamnesis, conditions);
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

    private void deletePatient(HttpServletRequest request) {
        long patientId = Long.parseLong(request.getParameter("id"));
        addressBookController.deletePatient(patientId);
    }

    private String normalizeOptional(String value) {
        if (value == null) {
            return "";
        }
        return value.trim();
    }

    private String normalizeRequired(String value, String errorMessage) {
        String normalized = normalizeOptional(value);
        if (normalized.isEmpty()) {
            throw new IllegalArgumentException(errorMessage);
        }
        return normalized;
    }

    private PatientAnamnesis parseAnamnesis(HttpServletRequest request) {
        PatientAnamnesis a = new PatientAnamnesis();
        a.setAssessmentDate(parseDateOrToday(request.getParameter("assessmentDate")));

        a.setChiefComplaint(normalizeOptional(request.getParameter("chiefComplaint")));
        a.setPainLocation(normalizeOptional(request.getParameter("painLocation")));
        a.setPainQuality(normalizeOptional(request.getParameter("painQuality")));
        a.setAssociatedSymptoms(normalizeOptional(request.getParameter("associatedSymptoms")));

        a.setOnsetType(normalizeEnum(request.getParameter("onsetType")));
        a.setOnsetContext(normalizeOptional(request.getParameter("onsetContext")));
        a.setDisabling(parseBoolean(request.getParameter("isDisabling")));
        a.setPainFrequency(normalizeEnum(request.getParameter("painFrequency")));
        a.setPainProgression(normalizeEnum(request.getParameter("painProgression")));
        a.setPainWithMovement(normalizeEnum(request.getParameter("painWithMovement")));
        a.setPainWithRest(normalizeEnum(request.getParameter("painWithRest")));
        a.setNightPain(parseBoolean(request.getParameter("nightPain")));
        a.setMorningPain(parseBoolean(request.getParameter("morningPain")));
        a.setPainIntensity(parseInteger(request.getParameter("painIntensity"), 0, 10));
        a.setUsesPainMeds(parseBoolean(request.getParameter("usesPainMeds")));
        a.setPainMedsEffect(normalizeEnum(request.getParameter("painMedsEffect")));

        a.setClinicalTests(normalizeOptional(request.getParameter("clinicalTests")));
        a.setSpecialistVisits(normalizeOptional(request.getParameter("specialistVisits")));
        a.setPreviousTreatments(normalizeOptional(request.getParameter("previousTreatments")));
        a.setPathologyHistory(normalizeOptional(request.getParameter("pathologyHistory")));
        a.setCurrentRegularDrugs(normalizeOptional(request.getParameter("currentRegularDrugs")));
        a.setSurgeryHistory(normalizeOptional(request.getParameter("surgeryHistory")));
        a.setTraumaHistory(normalizeOptional(request.getParameter("traumaHistory")));
        a.setDevicesHistory(normalizeOptional(request.getParameter("devicesHistory")));
        a.setChewingDisorders(parseBoolean(request.getParameter("chewingDisorders")));
        a.setMajorInfectionsHistory(normalizeOptional(request.getParameter("majorInfectionsHistory")));
        a.setFamilyHistory(normalizeOptional(request.getParameter("familyHistory")));

        a.setHeightCm(parseDecimal(request.getParameter("heightCm")));
        a.setWeightKg(parseDecimal(request.getParameter("weightKg")));
        a.setLifestyle(normalizeEnum(request.getParameter("lifestyle")));
        a.setSportPractice(normalizeOptional(request.getParameter("sportPractice")));
        a.setSubstanceUse(normalizeOptional(request.getParameter("substanceUse")));
        a.setSleepQuality(parseInteger(request.getParameter("sleepQuality"), 0, 4));
        a.setStressLevel(parseInteger(request.getParameter("stressLevel"), 0, 4));
        a.setDietQuality(normalizeEnum(request.getParameter("dietQuality")));
        a.setFemaleCycleNotes(normalizeOptional(request.getParameter("femaleCycleNotes")));
        a.setFreeNotesJson(normalizeOptional(request.getParameter("freeNotesJson")));

        return a;
    }

    private List<PatientCondition> parseConditions(HttpServletRequest request) {
        List<PatientCondition> conditions = new ArrayList<>();
        appendConditions(conditions, request.getParameter("conditionsPathology"), ConditionCategory.PATHOLOGY);
        appendConditions(conditions, request.getParameter("conditionsSymptom"), ConditionCategory.SYMPTOM);
        appendConditions(conditions, request.getParameter("conditionsFamilyHistory"), ConditionCategory.FAMILY_HISTORY);
        appendConditions(conditions, request.getParameter("conditionsAllergy"), ConditionCategory.ALLERGY);
        appendConditions(conditions, request.getParameter("conditionsDrug"), ConditionCategory.DRUG);
        appendConditions(conditions, request.getParameter("conditionsSystemReview"), ConditionCategory.SYSTEM_REVIEW);
        appendConditions(conditions, request.getParameter("conditionsOther"), ConditionCategory.OTHER);
        return conditions;
    }

    private void appendConditions(List<PatientCondition> target, String rawValue, ConditionCategory category) {
        String normalized = normalizeOptional(rawValue);
        if (normalized.isEmpty()) {
            return;
        }

        String[] parts = normalized.split("[,;\\n]+");
        for (String part : parts) {
            String label = part == null ? "" : part.trim();
            if (label.isEmpty()) {
                continue;
            }

            PatientCondition condition = new PatientCondition();
            condition.setCategory(category);
            condition.setLabel(label);
            condition.setStatus("PRESENT");
            target.add(condition);
        }
    }

    private boolean hasAnamnesisData(PatientAnamnesis a, List<PatientCondition> conditions) {
        return !normalizeOptional(a.getChiefComplaint()).isEmpty()
                || !normalizeOptional(a.getPainLocation()).isEmpty()
                || !normalizeOptional(a.getPainQuality()).isEmpty()
                || !normalizeOptional(a.getAssociatedSymptoms()).isEmpty()
                || !normalizeOptional(a.getOnsetType()).isEmpty()
                || !normalizeOptional(a.getOnsetContext()).isEmpty()
                || a.getDisabling() != null
                || !normalizeOptional(a.getPainFrequency()).isEmpty()
                || !normalizeOptional(a.getPainProgression()).isEmpty()
                || !normalizeOptional(a.getPainWithMovement()).isEmpty()
                || !normalizeOptional(a.getPainWithRest()).isEmpty()
                || a.getNightPain() != null
                || a.getMorningPain() != null
                || a.getPainIntensity() != null
                || a.getUsesPainMeds() != null
                || !normalizeOptional(a.getPainMedsEffect()).isEmpty()
                || !normalizeOptional(a.getClinicalTests()).isEmpty()
                || !normalizeOptional(a.getSpecialistVisits()).isEmpty()
                || !normalizeOptional(a.getPreviousTreatments()).isEmpty()
                || !normalizeOptional(a.getPathologyHistory()).isEmpty()
                || !normalizeOptional(a.getCurrentRegularDrugs()).isEmpty()
                || !normalizeOptional(a.getSurgeryHistory()).isEmpty()
                || !normalizeOptional(a.getTraumaHistory()).isEmpty()
                || !normalizeOptional(a.getDevicesHistory()).isEmpty()
                || a.getChewingDisorders() != null
                || !normalizeOptional(a.getMajorInfectionsHistory()).isEmpty()
                || !normalizeOptional(a.getFamilyHistory()).isEmpty()
                || a.getHeightCm() != null
                || a.getWeightKg() != null
                || !normalizeOptional(a.getLifestyle()).isEmpty()
                || !normalizeOptional(a.getSportPractice()).isEmpty()
                || !normalizeOptional(a.getSubstanceUse()).isEmpty()
                || a.getSleepQuality() != null
                || a.getStressLevel() != null
                || !normalizeOptional(a.getDietQuality()).isEmpty()
                || !normalizeOptional(a.getFemaleCycleNotes()).isEmpty()
                || !normalizeOptional(a.getFreeNotesJson()).isEmpty()
                || (conditions != null && !conditions.isEmpty());
    }

    private LocalDate parseDateOrToday(String value) {
        String normalized = normalizeOptional(value);
        if (normalized.isEmpty()) {
            return LocalDate.now();
        }
        try {
            return LocalDate.parse(normalized);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Data anamnesi non valida");
        }
    }

    private Boolean parseBoolean(String value) {
        String normalized = normalizeOptional(value).toLowerCase();
        if (normalized.isEmpty()) {
            return null;
        }
        if ("si".equals(normalized) || "yes".equals(normalized) || "true".equals(normalized) || "1".equals(normalized)) {
            return true;
        }
        if ("no".equals(normalized) || "false".equals(normalized) || "0".equals(normalized)) {
            return false;
        }
        throw new IllegalArgumentException("Valore booleano non valido: " + value);
    }

    private Integer parseInteger(String value, int min, int max) {
        String normalized = normalizeOptional(value);
        if (normalized.isEmpty()) {
            return null;
        }
        try {
            int parsed = Integer.parseInt(normalized);
            if (parsed < min || parsed > max) {
                throw new IllegalArgumentException("Valore fuori intervallo: " + value);
            }
            return parsed;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Numero non valido: " + value);
        }
    }

    private BigDecimal parseDecimal(String value) {
        String normalized = normalizeOptional(value);
        if (normalized.isEmpty()) {
            return null;
        }
        normalized = normalized.replace(",", ".");
        try {
            return new BigDecimal(normalized);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Numero decimale non valido: " + value);
        }
    }

    private String normalizeEnum(String value) {
        String normalized = normalizeOptional(value);
        if (normalized.isEmpty()) {
            return "";
        }
        return normalized.toUpperCase();
    }
}
