package it.SimoSW.util.dao.filesystem;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

abstract class FileSystemDAOBase {

    protected final Path baseDir;

    protected FileSystemDAOBase(Path baseDir) {
        this.baseDir = baseDir;
        try {
            Files.createDirectories(baseDir);
        } catch (IOException e) {
            throw new RuntimeException("Cannot create base directory: " + baseDir, e);
        }
    }

    protected Path fileOf(long id) {
        return baseDir.resolve(id + ".json");
    }
}