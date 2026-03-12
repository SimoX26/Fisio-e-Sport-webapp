<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Calendario • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- FullCalendar -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js" defer></script>

    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    <script src="<%= request.getContextPath() %>/assets/js/calendar.js" defer></script>
</head>

<body data-context-path="<%= request.getContextPath() %>">

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container mt-5">

    <!-- HEADER PAGINA -->
    <div class="mb-4">
        <h2 class="page-title">Calendario</h2>
        <p class="page-subtitle mb-0">
            Gestisci appuntamenti e sedute del centro
        </p>
    </div>

    <!-- CALENDAR -->
    <div class="glass-card p-4 calendar-card">
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
                <p><strong>Tipo:</strong> <span id="modalType"></span></p>
                <p><strong>Orario:</strong> <span id="modalTime"></span></p>
                <p><strong>Note:</strong></p>
                <p id="modalNotes" class="text-muted"></p>
            </div>

            <div class="modal-footer">
                <button class="btn btn-outline-secondary" data-bs-dismiss="modal">
                    Chiudi
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
                <h5 class="modal-title">Nuovo appuntamento</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <form id="appointmentForm">

                    <!-- Paziente -->
                    <div class="mb-3">
                        <label class="form-label">Paziente</label>
                        <select class="form-select" id="patientId" required>
                            <option value="">Seleziona paziente</option>
                            <!-- popolabile via JSP o JS -->
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Terapista (ID)</label>
                        <input type="number" class="form-control" id="therapistId" min="1" required>
                    </div>

                    <!-- Giorno e orario -->
                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label">Inizio</label>
                            <input type="datetime-local" class="form-control" id="start" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label">Fine</label>
                            <input type="datetime-local" class="form-control" id="end" required>
                        </div>
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

</body>
</html>
