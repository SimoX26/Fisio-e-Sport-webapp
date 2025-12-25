package it.SimoSW.dao.filesystem;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.SimoSW.model.Patient;
import it.SimoSW.dao.PatientDAO;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class FileSystemPatientDAO extends FileSystemDAOBase implements PatientDAO {

    private final ObjectMapper mapper = new ObjectMapper();

    public FileSystemPatientDAO(Path baseDir) {
        super(baseDir);
    }

    @Override
    public Patient save(Patient patient) {
        return write(patient);
    }

    @Override
    public Patient update(Patient patient) {
        return write(patient);
    }

    @Override
    public Optional<Patient> findById(long id) {
        Path file = fileOf(id);
        if (!Files.exists(file)) return Optional.empty();
        return Optional.of(read(file, Patient.class));
    }

    @Override
    public List<Patient> search(String query) {
        try {
            return Files.list(baseDir)
                    .map(p -> read(p, Patient.class))
                    .filter(p -> p.getFullName().toLowerCase().contains(query.toLowerCase()))
                    .collect(Collectors.toList());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private Patient write(Patient patient) {
        try {
            mapper.writeValue(fileOf(patient.getId()).toFile(), patient);
            return patient;
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