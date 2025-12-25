package it.SimoSW.dao.filesystem;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.SimoSW.model.TreatmentSession;
import it.SimoSW.dao.TreatmentSessionDAO;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class FileSystemTreatmentSessionDAO extends FileSystemDAOBase implements TreatmentSessionDAO {

    private final ObjectMapper mapper = new ObjectMapper();

    public FileSystemTreatmentSessionDAO(Path baseDir) {
        super(baseDir);
    }

    @Override
    public TreatmentSession save(TreatmentSession session) {
        return write(session);
    }

    @Override
    public TreatmentSession update(TreatmentSession session) {
        return write(session);
    }

    @Override
    public Optional<TreatmentSession> findById(long id) {
        Path file = fileOf(id);
        if (!Files.exists(file)) return Optional.empty();
        return Optional.of(read(file, TreatmentSession.class));
    }

    @Override
    public Optional<TreatmentSession> findByAppointmentId(long appointmentId) {
        return loadAll().stream()
                .filter(s -> s.getAppointmentId() == appointmentId)
                .findFirst();
    }

    @Override
    public List<TreatmentSession> findByPatientId(long patientId) {
        return loadAll().stream()
                .filter(s -> s.getPatientId() == patientId)
                .collect(Collectors.toList());
    }

    private List<TreatmentSession> loadAll() {
        try {
            return Files.list(baseDir)
                    .map(p -> read(p, TreatmentSession.class))
                    .collect(Collectors.toList());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private TreatmentSession write(TreatmentSession session) {
        try {
            mapper.writeValue(fileOf(session.getId()).toFile(), session);
            return session;
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
