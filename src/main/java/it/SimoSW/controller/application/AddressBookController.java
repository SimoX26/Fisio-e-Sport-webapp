package it.SimoSW.controller.application;

import it.SimoSW.model.Patient;
import it.SimoSW.util.dao.PatientDAO;

import java.util.List;

public class AddressBookController {

    private final PatientDAO patientDAO;

    public AddressBookController(PatientDAO patientDAO) {
        this.patientDAO = patientDAO;
    }

    public Patient registerPatient(Patient patient) {
        // 1. verifiche di dominio
        // 2. stato iniziale
        // 3. persistenza
        // 4. ritorno paziente persistito

        return null;

    }

    public Patient updatePatientProfile(Patient patient) {
        // 1. verifica esistenza
        // 2. verifica stato
        // 3. aggiornamento

        return null;

    }

    public Patient getPatientById(long patientId) {
        // 1. recupero
        // 2. se non esiste → eccezione

        return null;

    }

    public List<Patient> searchPatients(String query) {
        // delega al DAO

        return null;

    }

    public void activatePatient(long patientId) {
        // recupero
        // cambio stato
        // aggiornamento
    }

    public void deactivatePatient(long patientId) {
        // recupero
        // verifica vincoli
        // cambio stato
    }

    public void archivePatient(long patientId) {
        // recupero
        // verifica vincoli
        // cambio stato
    }


}
