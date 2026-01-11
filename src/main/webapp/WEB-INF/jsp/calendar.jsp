<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Calendario • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"  rel="stylesheet">
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
                    '<%= request.getContextPath() %>/calendar/create?date=' + info.dateStr;
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
