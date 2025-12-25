package it.SimoSW.util.dao.filesystem;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.SimoSW.model.Therapist;
import it.SimoSW.util.dao.TherapistDAO;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class FileSystemTherapistDAO extends FileSystemDAOBase implements TherapistDAO {

    private final ObjectMapper mapper = new ObjectMapper();

    public FileSystemTherapistDAO(Path baseDir) {
        super(baseDir);
    }

    @Override
    public Therapist save(Therapist therapist) {
        return write(therapist);
    }

    @Override
    public Therapist update(Therapist therapist) {
        return write(therapist);
    }

    @Override
    public Optional<Therapist> findById(long id) {
        Path file = fileOf(id);
        if (!Files.exists(file)) return Optional.empty();
        return Optional.of(read(file, Therapist.class));
    }

    @Override
    public List<Therapist> findAll() {
        try {
            return Files.list(baseDir)
                    .map(p -> read(p, Therapist.class))
                    .collect(Collectors.toList());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private Therapist write(Therapist therapist) {
        try {
            mapper.writeValue(fileOf(therapist.getId()).toFile(), therapist);
            return therapist;
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
