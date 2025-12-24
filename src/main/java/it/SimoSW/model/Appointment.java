package it.SimoSW.model;

import java.time.LocalDateTime;

public class Appointment {
    private int id;
    private int idPaziente;
    private String titolo;
    private String descrizione;
    private LocalDateTime inizio;
    private LocalDateTime fine;
    private String colore;

    public Appointment(){
        // Costruttore vuoto
    }

    public Appointment(int id, int idPaziente, String titolo, String descrizione, LocalDateTime inizio, LocalDateTime fine, String colore){
        this.id = id;
        this.idPaziente = idPaziente;
        this.titolo = titolo;
        this.descrizione = descrizione;
        this.inizio = inizio;
        this.fine = fine;
        this.colore = colore;
    }

    // GETTER
    public int getId() {
        return id;
    }

    public int getIdPaziente() {
        return idPaziente;
    }

    public String getTitolo() {
        return titolo;
    }

    public String getDescrizione() {
        return descrizione;
    }

    public LocalDateTime getInizio() {
        return inizio;
    }

    public LocalDateTime getFine() {
        return fine;
    }

    public String getColore() {
        return colore;
    }

    // SETTER
    public void setId(int id) {
        this.id = id;
    }

    public void setIdPaziente(int idPaziente) {
        this.idPaziente = idPaziente;
    }

    public void setTitolo(String title) {
        this.titolo = title;
    }

    public void setDescrizione(String descrizione) {
        this.descrizione = descrizione;
    }

    public void setInizio(LocalDateTime inizio) {
        this.inizio = inizio;
    }

    public void setFine(LocalDateTime fine) {
        this.fine = fine;
    }

    public void setColore(String colore) {
        this.colore = colore;
    }}
