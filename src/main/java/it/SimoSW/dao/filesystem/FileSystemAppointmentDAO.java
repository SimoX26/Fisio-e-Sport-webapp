package it.SimoSW.dao.filesystem;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.SimoSW.model.Appointment;
import it.SimoSW.dao.AppointmentDAO;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class FileSystemAppointmentDAO extends FileSystemDAOBase implements AppointmentDAO {

    private final ObjectMapper mapper = new ObjectMapper();

    public FileSystemAppointmentDAO(Path baseDir) {
        super(baseDir);
    }

    @Override
    public Appointment save(Appointment appointment) {
        return write(appointment);
    }

    @Override
    public Appointment update(Appointment appointment) {
        return write(appointment);
    }

    @Override
    public Optional<Appointment> findById(long id) {
        Path file = fileOf(id);
        if (!Files.exists(file)) return Optional.empty();
        return Optional.of(read(file, Appointment.class));
    }

    @Override
    public List<Appointment> findInPeriod(LocalDateTime start, LocalDateTime end) {
        return loadAll().stream()
                .filter(a -> !a.getEnd().isBefore(start) && !a.getStart().isAfter(end))
                .collect(Collectors.toList());
    }

    @Override
    public List<Appointment> findByTherapistInPeriod(long therapistId,
                                                     LocalDateTime start,
                                                     LocalDateTime end) {
        return loadAll().stream()
                .filter(a -> a.getTherapistId() == therapistId)
                .filter(a -> a.getStart().isBefore(end) && a.getEnd().isAfter(start))
                .collect(Collectors.toList());
    }

    private List<Appointment> loadAll() {
        try {
            return Files.list(baseDir)
                    .map(p -> read(p, Appointment.class))
                    .collect(Collectors.toList());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private Appointment write(Appointment appointment) {
        try {
            mapper.writeValue(fileOf(appointment.getId()).toFile(), appointment);
            return appointment;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private <T> T read(Path file, Class<T> type) {
        try {
            return mapper.readValue(file.toFile(), type);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
