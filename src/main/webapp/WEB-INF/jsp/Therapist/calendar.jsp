<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Calendario • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- FullCalendar -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>

<body class="theme-dark">

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/header.jspf" %>

<div class="container mt-5">

    <!-- HEADER PAGINA -->
    <div class="mb-4">
        <h2 class="page-title">Calendario</h2>
        <p class="page-subtitle mb-0">
            Gestisci appuntamenti e sedute del centro
        </p>
    </div>

    <!-- CALENDAR -->
    <div class="glass-card p-4">
        <div id="calendar"></div>
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

                    <!-- Giorno e orario -->
                    <div class="row">
                        <div class="col">
                            <label class="form-label">Inizio</label>
                            <input type="datetime-local" class="form-control" id="start" required>
                        </div>
                        <div class="col">
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

<!-- =========================
     SCRIPT
     ========================= -->
<script>
document.addEventListener('DOMContentLoaded', function () {

    const calendarEl = document.getElementById('calendar');

    const calendar = new FullCalendar.Calendar(calendarEl, {
        locale: 'it',
        height: 'auto',

        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'timeGridDay,timeGridWeek,dayGridMonth'
        },

        initialView: 'timeGridWeek',
        slotDuration: '00:30:00',
        nowIndicator: true,

        slotMinTime: "08:00:00",
        slotMaxTime: "21:00:00",
        scrollTime: "08:00:00",

        selectable: true,
        editable: false,

        events: {
            url: '<%= request.getContextPath() %>/calendar',
            method: 'GET',
            extraParams: {
                events: 'true'
            }
        },

        select: function(info) {
            document.getElementById('start').value = info.startStr.slice(0,16);
            document.getElementById('end').value = info.endStr.slice(0,16);

            const modal = new bootstrap.Modal(
                document.getElementById('appointmentModal')
            );
            modal.show();
        },

        eventClick: function (info) {
            info.jsEvent.preventDefault();

            const event = info.event;

            document.getElementById('modalTitle').innerText = event.title || '';
            document.getElementById('modalPatient').innerText =
                event.extendedProps.patient || '-';
            document.getElementById('modalType').innerText =
                event.extendedProps.type || '-';
            document.getElementById('modalNotes').innerText =
                event.extendedProps.notes || 'Nessuna nota';

            const start = event.start.toLocaleString('it-IT');
            const end = event.end ? event.end.toLocaleString('it-IT') : '';
            document.getElementById('modalTime').innerText =
                end ? `${start} – ${end}` : start;

            new bootstrap.Modal(
                document.getElementById('eventModal')
            ).show();
        }
    });

    calendar.render();

    document.getElementById('saveAppointmentBtn').addEventListener('click', () => {

        const data = new URLSearchParams();
        data.append('action', 'create');
        data.append('patientId', document.getElementById('patientId').value);
        data.append('therapistId', document.getElementById('therapistId').value);
        data.append('start', document.getElementById('start').value);
        data.append('end', document.getElementById('end').value);

        fetch('<%= request.getContextPath() %>/calendar', {
            method: 'POST',
            body: data
        })
        .then(res => {
            if (!res.ok) throw new Error('Errore nella creazione appuntamento');
            return res;
        })
        .then(() => {
            bootstrap.Modal.getInstance(
                document.getElementById('appointmentModal')
            ).hide();

            calendar.refetchEvents();
        })
        .catch(err => alert(err.message));
    });

});
</script>

</body>
</html>
