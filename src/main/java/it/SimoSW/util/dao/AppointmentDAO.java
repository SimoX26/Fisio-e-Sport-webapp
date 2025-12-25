package it.SimoSW.util.dao;

import it.SimoSW.model.Appointment;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface AppointmentDAO {

    Appointment save(Appointment appointment);

    Appointment update(Appointment appointment);

    Optional<Appointment> findById(long id);

    List<Appointment> findInPeriod(LocalDateTime start, LocalDateTime end);

    List<Appointment> findByTherapistInPeriod(long therapistId, LocalDateTime start, LocalDateTime end);
}
