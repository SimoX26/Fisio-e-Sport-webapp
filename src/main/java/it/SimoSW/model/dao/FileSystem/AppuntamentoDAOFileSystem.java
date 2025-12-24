package it.SimoSW.model.dao.FileSystem;

import it.SimoSW.model.Appointment;
import it.SimoSW.model.dao.AppuntamentoDAO;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AppuntamentoDAOFileSystem implements AppuntamentoDAO {
    // Percorso del file JSON sul file system
    private static final Path FILE_PATH = Paths.get("data", "appuntamenti.csv");

    // Cache in memoria degli appuntamenti
    private final List<Appointment> cache = new ArrayList<>();

    private int autoIncrementId = 1; // Simula il comportamento di un DB autoreferenziale

    public AppuntamentoDAOFileSystem() {
        System.out.println("Tipologia di memorizzazione: CSV file");
        loadFromFileIfExists(); // All'avvio, popola la cache dal JSON
    }

    @Override
    public List<Appointment> findAll() {
        return new ArrayList<>(cache);
    }

    @Override
    public Appointment findById(int id) {
        for (Appointment a : cache) {
            if (a.getId() == id) {
                return a;
            }
        }
        return null;

         /* Si può fare anche in questo modo
         return memory.stream().filter(a -> a.getId() == id)
                .findFirst()
                .orElse(null);
          */
    }

    @Override
    public Appointment findByPaziente(int idPaziente) {
        for (Appointment a : cache) {
            if (a.getIdPaziente() == idPaziente) {
                return a;
            }
        }
        return null;    }

    @Override
    public void save(Appointment a) {
        System.out.println("\nSaving " + a.getTitolo() + " on cache..");
        if (a.getId() == 0) { // Se l'appuntamento non ha ID, ne generiamo uno nuovo
            a.setId(autoIncrementId++);
        }

        cache.add(a);

        flushToFile(); // scrivo su disco ad ogni salvataggio
    }

    @Override
    public void update(Appointment a) {
        System.out.println("\nUpdating..");
        for (int i = 0; i < cache.size(); i++) {
            if (cache.get(i).getId() == a.getId()) {
                cache.set(i, a);   // sostituisco l'oggetto vecchio con quello nuovo
                flushToFile();     // riscrivo tutto sul file
                return;
            }
        }
    }

    @Override
    public void delete(int id) {
        cache.removeIf(a -> a.getId() == id);
        flushToFile();
    }

    // ==== CARICAMENTO DAL FILE CSV ====
    private void loadFromFileIfExists() {
        System.out.println("\nLoading from file..");
        if (Files.notExists(FILE_PATH)) {
            System.out.println("\n* File inesistente *");
            return; // Se non c'è ancora nessun file
        }

        try (BufferedReader br = Files.newBufferedReader(FILE_PATH)) {
            String line;

            // Leggo la prima riga (header)
            String header = br.readLine();
            if (header == null) return;

            while((line = br.readLine()) != null){
                String[] parts = line.split(",", -1);
                if(parts.length != 5) continue;

                Appointment a = new Appointment();
                a.setId(Integer.parseInt(parts[0]));
                a.setIdPaziente(Integer.parseInt(parts[1]));
                a.setTitolo(parts[2]);
                a.setInizio(LocalDateTime.parse(parts[3]));
                a.setFine(LocalDateTime.parse(parts[4]));

                cache.add(a);
            }

            autoIncrementId = cache.stream()
                    .mapToInt(Appointment::getId)
                    .max()
                    .orElse(0) + 1;

        } catch (IOException e) {
            // GESTIONE DELL'ERRORE !
        }
    }

    private void flushToFile() {
        System.out.println("\nFlushing to file..");
        try {
            Files.createDirectories(FILE_PATH.getParent());

            try (BufferedWriter bw = Files.newBufferedWriter(FILE_PATH)) {

                // Header del CSV
                bw.write("id,id_paziente,titolo,inizio,fine");
                bw.newLine();

                for (Appointment a : cache) {
                    bw.write(
                            a.getId() + "," +
                                    a.getIdPaziente() + "," +
                                    sanitize(a.getTitolo()) + "," +
                                    a.getInizio() + "," +
                                    a.getFine()
                    );
                    bw.newLine();
                }
            }

        } catch (IOException e) {
            // GESTIONE DELL'ERRORE !
        }
    }

    // Evita che virgole o newline rompano il CSV
    private String sanitize(String s) {
        if (s == null) return "";
        return s.replace(",", "\\,")
                .replace("\n", " ")
                .replace("\r", " ");
    }
}
