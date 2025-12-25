package it.SimoSW.dao;

import it.SimoSW.model.Patient;

import java.util.List;
import java.util.Optional;

public interface PatientDAO {

    Patient save(Patient patient);

    Patient update(Patient patient);

    Optional<Patient> findById(long id);

    List<Patient> search(String query);
}
