package it.SimoSW.util.dao;

import it.SimoSW.model.TreatmentSession;

import java.util.List;
import java.util.Optional;

public interface TreatmentSessionDAO {
    TreatmentSession save(TreatmentSession session);

    TreatmentSession update(TreatmentSession session);

    Optional<TreatmentSession> findById(long id);

    Optional<TreatmentSession> findByAppointmentId(long appointmentId);

    List<TreatmentSession> findByPatientId(long patientId);
}

