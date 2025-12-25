package it.SimoSW.controller.application;

import it.SimoSW.exception.InvalidPatientStateException;
import it.SimoSW.exception.PatientNotFoundException;
import it.SimoSW.model.Patient;
import it.SimoSW.model.PatientState;
import it.SimoSW.util.dao.PatientDAO;

import java.util.List;

public class AddressBookController {

    private final PatientDAO patientDAO;

    public AddressBookController(PatientDAO patientDAO) {
        this.patientDAO = patientDAO;
    }

    public Patient registerPatient(Patient patient) {
        if (patient == null) {
            throw new IllegalArgumentException("Patient cannot be null");
        }

        // Stato iniziale di dominio
        patient.setState(PatientState.ACTIVE);

        // Persistenza tecnica
        return patientDAO.save(patient);
    }

    public Patient updatePatientProfile(Patient patient) {
        if (patient == null || patient.getId() == null) {
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

    public Patient getPatientById(long patientId) {
        return patientDAO.findById(patientId)
                .orElseThrow(() -> new PatientNotFoundException(patientId));
    }

    public List<Patient> searchPatients(String query) {
        return patientDAO.search(query);
    }

    public void activatePatient(long patientId) {
        Patient patient = getPatientById(patientId);

        if (patient.getState() == PatientState.ARCHIVED) {
            throw new InvalidPatientStateException("Archived patient cannot be activated");
        }

        patient.setState(PatientState.ACTIVE);
        patientDAO.update(patient);
    }

    public void deactivatePatient(long patientId) {
        Patient patient = getPatientById(patientId);

        if (patient.getState() == PatientState.ARCHIVED) {
            throw new InvalidPatientStateException("Archived patient cannot be deactivated");
        }

        patient.setState(PatientState.INACTIVE);
        patientDAO.update(patient);
    }

    public void archivePatient(long patientId) {
        Patient patient = getPatientById(patientId);

        if (patient.getState() == PatientState.ARCHIVED) {
            throw new InvalidPatientStateException("Patient already archived");
        }

        patient.setState(PatientState.ARCHIVED);
        patientDAO.update(patient);
    }

}