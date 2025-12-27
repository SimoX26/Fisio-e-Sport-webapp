<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Calendario • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- FullCalendar -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css"
          rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

    <style>
        /* =========================
           THEME VARIABLES
           ========================= */

        :root{
            --bg-main: #ffffff;
            --bg-card: rgba(0,0,0,.03);
            --border-color: rgba(0,0,0,.12);
            --text-main: #212529;
            --text-muted: #6c757d;
        }

        body.theme-dark{
            --bg-main: #0b1220;
            --bg-card: rgba(255,255,255,.06);
            --border-color: rgba(255,255,255,.12);
            --text-main: #e9eefb;
            --text-muted: rgba(233,238,251,.65);
        }

        body{
            background:
                radial-gradient(1200px 600px at 10% 10%, rgba(13,110,253,.18), transparent 55%),
                radial-gradient(1000px 600px at 90% 20%, rgba(32,201,151,.16), transparent 55%),
                var(--bg-main);
            color: var(--text-main);
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        }

        /* =========================
           COMMON UI
           ========================= */

        .page-title{
            font-weight: 600;
        }

        .page-subtitle{
            color: var(--text-muted);
        }

        .glass-card{
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 18px;
            backdrop-filter: blur(12px);
            box-shadow: 0 14px 40px rgba(0,0,0,.45);
        }

        /* =========================
           NAVBAR (override Bootstrap)
           ========================= */

        .navbar .nav-link,
        .navbar .navbar-brand{
            color: var(--text-main) !important;
        }

        .navbar .nav-link:hover{
            color: #0d6efd !important;
        }

        .navbar .nav-link.disabled{
            color: var(--text-muted) !important;
        }

        #themeToggle{
            color: var(--text-main);
            border-color: var(--border-color);
        }

        #themeToggle:hover{
            background: var(--bg-card);
        }

        /* =========================
           FULLCALENDAR – BASE
           ========================= */

        .fc{
            color: var(--text-main);
            background: transparent;
        }

        .fc-theme-standard th,
        .fc-theme-standard td{
            border-color: var(--border-color);
        }

        .fc-daygrid-day-number{
            color: var(--text-main);
        }

        .fc-daygrid-day:hover{
            background: var(--bg-card);
        }

        .fc-day-today{
            background: rgba(13,110,253,.12) !important;
        }

        /* =========================
           FULLCALENDAR – HEADER
           ========================= */

        /* Riga intera dell’header (dove c’è “martedì”) */
        .fc .fc-scrollgrid-section-header,
        .fc .fc-scrollgrid-section-header th{
            background: var(--bg-card) !important;
        }

        /* Contenitore colonne header */
        .fc .fc-col-header{
            background: var(--bg-card) !important;
        }

        /* Singola cella header */
        .fc .fc-col-header-cell{
            background: var(--bg-card) !important;
            border-color: var(--border-color) !important;
        }

        /* Testo “martedì” (è un <a>) */
        .fc .fc-col-header-cell-cushion{
            color: var(--text-main) !important;
            text-decoration: none !important;
            font-weight: 600;
        }

        /* Hover sul giorno */
        .fc .fc-col-header-cell-cushion:hover{
            color: #0d6efd !important;
        }

        /* =========================
           FULLCALENDAR – REMOVE UNDERLINE
           ========================= */

        /* Giorni del mese (numeri) */
        .fc .fc-daygrid-day-number {
            text-decoration: none !important;
        }

        /* Giorni settimana (es. martedì) */
        .fc .fc-col-header-cell-cushion {
            text-decoration: none !important;
        }

        /* Hover (manteniamo feedback visivo) */
        .fc .fc-daygrid-day-number:hover,
        .fc .fc-col-header-cell-cushion:hover {
            text-decoration: none !important;
        }

        /* =========================
           FULLCALENDAR – BUTTONS
           ========================= */

        .fc-button{
            background: var(--bg-card) !important;
            border: 1px solid var(--border-color) !important;
            color: var(--text-main) !important;
            box-shadow: none !important;
        }

        .fc-button:hover{
            background: rgba(13,110,253,.15) !important;
        }

        .fc-button-primary:not(:disabled).fc-button-active{
            background: #0d6efd !important;
            border-color: #0d6efd !important;
            color: #fff !important;
        }

        /* =========================
           FULLCALENDAR – EVENTS
           ========================= */

        .fc-event{
            background: linear-gradient(135deg, #0d6efd, #4dabf7);
            border: none;
            border-radius: 8px;
            color: #fff !important;
            padding: 2px 4px;
        }

        .fc-event:hover{
            opacity: .9;
        }

        /* =========================
           DARK / LIGHT REFINEMENTS
           ========================= */

        body.theme-dark .fc-timegrid-slot{
            background: rgba(255,255,255,.02);
        }

        body.theme-light .fc-timegrid-slot{
            background: rgba(0,0,0,.01);
        }
    </style>
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
        <!-- MODALE DETTAGLI APPUNTAMENTO -->
        <div class="modal fade" id="eventModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content glass-card">

                    <div class="modal-header">
                        <h5 class="modal-title" id="modalTitle"></h5>
                        <button type="button"
                                class="btn-close"
                                data-bs-dismiss="modal"></button>
                    </div>

                    <div class="modal-body">
                        <p><strong>Paziente:</strong> <span id="modalPatient"></span></p>
                        <p><strong>Tipo:</strong> <span id="modalType"></span></p>
                        <p><strong>Orario:</strong> <span id="modalTime"></span></p>
                        <p><strong>Note:</strong></p>
                        <p id="modalNotes" class="text-muted"></p>
                    </div>

                    <div class="modal-footer">
                        <button class="btn btn-outline-secondary"
                                data-bs-dismiss="modal">
                            Chiudi
                        </button>

                        <a href="#"
                           id="editEventBtn"
                           class="btn btn-primary">
                            Modifica
                        </a>
                    </div>

                </div>
            </div>
        </div>

    </div>

</div>

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

            buttonText: {
                today:    'Oggi',
                month:    'Mese',
                week:     'Settimana',
                day:      'Giorno'
            },

            initialView: 'timeGridWeek',

            slotDuration: '00:30:00',

            allDayText: 'Tutto il giorno',

            nowIndicator: true,

            slotMinTime: "08:00:00",
            slotMaxTime: "21:00:00",
            scrollTime: "08:00:00",

            selectable: true,
            editable: false,

            events: [
            ],

            dateClick: function (info) {
                window.location.href =
                    '<%= request.getContextPath() %>/calendar/new?date=' + info.dateStr;
            },

            eventClick: function (info) {
                info.jsEvent.preventDefault();

                const event = info.event;

                // Titolo
                document.getElementById('modalTitle').innerText =
                    event.title;

                // Extended props
                document.getElementById('modalPatient').innerText =
                    event.extendedProps.patient || '-';

                document.getElementById('modalType').innerText =
                    event.extendedProps.type || '-';

                document.getElementById('modalNotes').innerText =
                    event.extendedProps.notes || 'Nessuna nota';

                // Orario
                const start = event.start.toLocaleString('it-IT');
                const end = event.end
                    ? event.end.toLocaleString('it-IT')
                    : '';

                document.getElementById('modalTime').innerText =
                    end ? `${start} – ${end}` : start;

                // Link modifica (opzionale)
                document.getElementById('editEventBtn').href =
                    '<%= request.getContextPath() %>/calendar/edit?id=' + event.id;

                // Apri modale
                const modal = new bootstrap.Modal(
                    document.getElementById('eventModal')
                );
                modal.show();
            }

        });

        calendar.render();
    });
</script>

</body>
</html>
