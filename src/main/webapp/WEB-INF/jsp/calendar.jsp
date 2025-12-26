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

    <!-- THEME CSS (variabili globali) -->
    <style>
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
        }

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

        .kpi-value{
            font-size: 2rem;
            font-weight: 700;
        }

        .kpi-label{
            color: var(--text-muted);
            font-size: .9rem;
        }

        .action-card{
            cursor: pointer;
            transition: .25s ease;
        }

        .action-card:hover{
            transform: translateY(-6px);
            box-shadow: 0 14px 30px rgba(0,0,0,.4);
        }

        .icon{
            font-size: 2rem;
        }

        .btn-soft{
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            color: var(--text-main);
        }

        .btn-soft:hover{
            background: rgba(255,255,255,.14);
        }
        /* ===== NAVBAR THEME-AWARE ===== */

        .navbar .nav-link,
        .navbar .navbar-brand {
            color: var(--text-main) !important;
        }

        .navbar .nav-link:hover {
            color: #0d6efd !important;
        }

        .navbar .nav-link.text-danger {
            color: #dc3545 !important;
        }

        /* Separatore | */
        .navbar .nav-link.disabled {
            color: var(--text-muted) !important;
        }

        /* Bottone toggle tema */
        #themeToggle {
            color: var(--text-main);
            border-color: var(--border-color);
        }

        #themeToggle:hover {
            background: var(--bg-card);
        }

    </style>
</head>

<body>

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

<script>
    document.addEventListener('DOMContentLoaded', function () {

        const calendarEl = document.getElementById('calendar');

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            locale: 'it',
            height: 'auto',

            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay'
            },

            selectable: true,
            editable: false,

            /* EVENTI DI ESEMPIO (da sostituire con servlet JSON) */
            events: [
                {
                    title: 'Seduta – Rossi Mario',
                    start: '2025-01-15T10:00'
                },
                {
                    title: 'Valutazione – Bianchi Anna',
                    start: '2025-01-18T15:30'
                }
            ],

            /* Click su giorno vuoto */
            dateClick: function (info) {
                window.location.href =
                    '<%= request.getContextPath() %>/calendar/new?date=' + info.dateStr;
            },

            /* Click su evento */
            eventClick: function (info) {
                const eventId = info.event.id;
                window.location.href =
                    '<%= request.getContextPath() %>/calendar/event?id=' + eventId;
            }
        });

        calendar.render();
    });
</script>

</body>
</html>
