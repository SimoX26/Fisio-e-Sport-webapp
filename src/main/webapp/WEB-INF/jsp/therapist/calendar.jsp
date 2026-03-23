<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Calendario • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/assets/img/logo.png">
    <link rel="apple-touch-icon" href="<%= request.getContextPath() %>/assets/img/logo-192.png">
    <link rel="manifest" href="<%= request.getContextPath() %>/manifest.webmanifest">
    <meta name="theme-color" content="#1a73e8">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-title" content="FisioSport">

    <!-- FullCalendar -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js" defer></script>

    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260323-4">
    <script src="<%= request.getContextPath() %>/assets/js/calendar.js?v=20260323-6" defer></script>
</head>

<body data-context-path="<%= request.getContextPath() %>" class="calendar-gcal-page">

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container-fluid calendar-gcal-wrap mt-4">

    <!-- HEADER PAGINA -->
    <div class="page-header-row calendar-gcal-head mb-3">
        <div>
            <h2 class="page-title mb-0">Calendario</h2>
        </div>
        <div class="d-flex align-items-center gap-2">
            <a href="<%= request.getContextPath() %>/calendar/trash"
               class="btn btn-outline-secondary section-action-btn">
                Cestino
            </a>
            <button type="button"
                    class="btn btn-primary calendar-add-btn gcal-create-btn"
                    id="openAppointmentModalBtn"
                    aria-label="Nuovo appuntamento">
                <span>+</span>
                <span>Crea</span>
            </button>
        </div>
    </div>

    <!-- CALENDAR -->
    <div class="calendar-host">
        <div class="calendar-scroll-shell">
            <div id="calendar"></div>
        </div>
    </div>
</div>

<!-- =========================
     MODALE DETTAGLI EVENTO
     ========================= -->
<div class="modal fade" id="eventModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-card">

            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle"></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <p><strong>Paziente:</strong> <span id="modalPatient"></span></p>
                <p><strong>Orario:</strong> <span id="modalTime"></span></p>
                <p><strong>Note:</strong></p>
                <p id="modalNotes" class="text-muted"></p>
                <span id="modalType" class="d-none" aria-hidden="true"></span>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-success" id="completeAppointmentBtn">
                    Completa e crea trattamento
                </button>
                <button type="button" class="btn btn-outline-primary" id="editAppointmentBtn">
                    Modifica
                </button>
                <button type="button" class="btn btn-outline-danger" id="deleteAppointmentBtn">
                    Elimina
                </button>
            </div>

        </div>
    </div>
</div>

<!-- =========================
     MODALE CREAZIONE EVENTO
     ========================= -->
<div class="modal fade" id="appointmentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-card">

            <div class="modal-header">
                <h5 class="modal-title" id="appointmentModalTitle">Nuovo appuntamento</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <form id="appointmentForm">

                    <!-- Paziente -->
                    <div class="mb-3">
                        <label class="form-label">Paziente</label>
                        <input type="text"
                               class="form-control"
                               id="patientName"
                               placeholder="Nome e cognome paziente"
                               required>
                    </div>

                    <!-- Giorno e orario -->
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label">Inizio</label>
                            <input type="datetime-local" class="form-control" id="start" step="3600" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label">Fine</label>
                            <input type="datetime-local" class="form-control" id="end" step="3600" readonly required>
                        </div>
                    </div>

                    <div class="mt-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="allDay">
                            <label class="form-check-label" for="allDay">
                                Tutto il giorno (evento non collegato ai trattamenti)
                            </label>
                        </div>
                    </div>

                    <div class="mt-3">
                        <label class="form-label">Note</label>
                        <textarea class="form-control"
                                  id="notes"
                                  rows="3"
                                  placeholder="Inserisci eventuali note sull'appuntamento"></textarea>
                    </div>

                </form>
            </div>

            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Annulla</button>
                <button class="btn btn-primary" id="saveAppointmentBtn">Salva</button>
            </div>

        </div>
    </div>
</div>

<!-- =========================
     MODALE CONFERMA ELIMINAZIONE
     ========================= -->
<div class="modal fade" id="confirmDeleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-card">
            <div class="modal-header">
                <h5 class="modal-title">Conferma eliminazione</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p class="mb-0">Vuoi eliminare questo appuntamento?</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Annulla</button>
                <button class="btn btn-danger" id="confirmDeleteAppointmentBtn">Elimina</button>
            </div>
        </div>
    </div>
</div>

</body>
</html>
