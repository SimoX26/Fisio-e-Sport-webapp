package it.SimoSW.controller.application;

import it.SimoSW.exception.InvalidPatientStateException;
import it.SimoSW.exception.PatientNotFoundException;
import it.SimoSW.model.Patient;
import it.SimoSW.model.PatientState;
import it.SimoSW.dao.PatientDAO;

import java.util.List;

/**
 * Application controller responsible for managing patients in the address book.
 *
 * <p>This controller encapsulates the application-level business logic related to
 * patient lifecycle management (registration, update, activation, deactivation,
 * and archiving), acting as a boundary between the presentation layer and
 * the persistence layer.</p>
 *
 * <p>It enforces domain rules such as valid state transitions and prevents
 * illegal operations on archived patients.</p>
 */
public class AddressBookController {


    /**
     * Data Access Object used to persist and retrieve Patient entities.
     */
    private final PatientDAO patientDAO;


    /**
     * Constructs an AddressBookController with the given PatientDAO.
     *
     * @param patientDAO the DAO responsible for patient persistence
     */
    public AddressBookController(PatientDAO patientDAO) {
        this.patientDAO = patientDAO;
    }


    /**
     * Registers a new patient in the system.
     *
     * <p>The patient is always initialized with the {@code ACTIVE} domain state,
     * regardless of any external input, ensuring a consistent starting state.</p>
     *
     * @param patient the patient to be registered
     * @return the persisted patient instance
     * @throws IllegalArgumentException if the patient is null
     */
    public Patient registerPatient(Patient patient) {
        if (patient == null) {
            throw new IllegalArgumentException("Patient cannot be null");
        }

        // Stato iniziale di dominio
        patient.setState(PatientState.ACTIVE);

        // Persistenza tecnica
        return patientDAO.save(patient);
    }


    /**
     * Updates an existing patient's profile.
     *
     * <p>This method does not allow modifications to archived patients and
     * preserves the current patient state, unless explicitly changed by
     * a dedicated state-transition method.</p>
     *
     * @param patient the patient containing updated data
     * @return the updated patient
     * @throws IllegalArgumentException if the patient or its ID is null
     * @throws PatientNotFoundException if the patient does not exist
     * @throws InvalidPatientStateException if the patient is archived
     */
    public Patient updatePatientProfile(Patient patient) {
        if (patient == null || patient.getId() == 0) {
            throw new IllegalArgumentException("Patient or patient id cannot be null");
        }

        Patient existing = patientDAO.findById(patient.getId())
                .orElseThrow(() -> new PatientNotFoundException(patient.getId()));

        if (existing.getState() == PatientState.ARCHIVED) {
            throw new InvalidPatientStateException("Archived patient cannot be modified");
        }

        // Manteniamo lo stato corrente se non deve cambiare qui
        patient.setState(existing.getState());

        return patientDAO.update(patient);
    }


    /**
     * Retrieves a patient by its unique identifier.
     *
     * @param patientId the patient ID
     * @return the corresponding patient
     * @throws PatientNotFoundException if no patient is found
     */
    public Patient getPatientById(long patientId) {
        return patientDAO.findById(patientId)
                .orElseThrow(() -> new PatientNotFoundException(patientId));
    }


    /**
     * Searches patients using a free-text query.
     *
     * <p>The search logic is delegated to the DAO layer.</p>
     *
     * @param query the search query
     * @return a list of matching patients
     */
    public List<Patient> searchPatients(String query) {
        return patientDAO.search(query);
    }


    /**
     * Activates a patient, if allowed by the domain rules.
     *
     * @param patientId the patient ID
     * @throws InvalidPatientStateException if the patient is archived
     */
    public void activatePatient(long patientId) {
        Patient patient = getPatientById(patientId);

        if (patient.getState() == PatientState.ARCHIVED) {
            throw new InvalidPatientStateException("Archived patient cannot be activated");
        }

        patient.setState(PatientState.ACTIVE);
        patientDAO.update(patient);
    }


    /**
     * Deactivates a patient, if allowed by the domain rules.
     *
     * @param patientId the patient ID
     * @throws InvalidPatientStateException if the patient is archived
     */
    public void deactivatePatient(long patientId) {
        Patient patient = getPatientById(patientId);

        if (patient.getState() == PatientState.ARCHIVED) {
            throw new InvalidPatientStateException("Archived patient cannot be deactivated");
        }

        patient.setState(PatientState.INACTIVE);
        patientDAO.update(patient);
    }


    /**
     * Archives a patient.
     *
     * <p>Once archived, a patient becomes immutable and cannot transition
     * to any other state.</p>
     *
     * @param patientId the patient ID
     * @throws InvalidPatientStateException if the patient is already archived
     */
    public void archivePatient(long patientId) {
        Patient patient = getPatientById(patientId);

        if (patient.getState() == PatientState.ARCHIVED) {
            throw new InvalidPatientStateException("Patient already archived");
        }

        patient.setState(PatientState.ARCHIVED);
        patientDAO.update(patient);
    }

}