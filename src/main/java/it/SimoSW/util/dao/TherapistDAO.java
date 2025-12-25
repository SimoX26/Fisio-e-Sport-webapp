package it.SimoSW.util.dao;

import it.SimoSW.model.Therapist;

import java.util.List;
import java.util.Optional;

public interface TherapistDAO {

    Therapist save(Therapist therapist);

    Therapist update(Therapist therapist);

    Optional<Therapist> findById(long id);

    List<Therapist> findAll();
}
