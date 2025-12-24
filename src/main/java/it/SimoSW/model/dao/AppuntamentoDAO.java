package it.SimoSW.model.dao;

import it.SimoSW.model.Appointment;

import java.util.List;

public interface AppuntamentoDAO {
    List<Appointment> findAll();
    Appointment findById(int id);
    Appointment findByPaziente(int idPaziente);

    void save(Appointment a);
    void update(Appointment a);
    void delete(int id);
}
