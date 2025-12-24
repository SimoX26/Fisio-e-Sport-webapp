<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <title>Calendario – Fisio e Sport</title>

    <!-- FullCalendar -->
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css' rel='stylesheet' />
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js'></script>

    <style>
        #calendar {
            max-width: 1000px;
            margin: 40px auto;
        }
    </style>
</head>
<body>

<%@ include file="../common/header.jspf" %>

<div id='calendar'></div>

<script>

document.addEventListener('DOMContentLoaded', function () {

    var calendarEl = document.getElementById('calendar');

    var calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',

        selectable: true,

        // 🔵 Recupero eventi dal backend Java
        events: '/FisioESport/CalendarioController',

        // 🔵 Aggiungi un appuntamento
        dateClick: function(info) {
            if (confirm("Creare appuntamento in data " + info.dateStr + " ?")) {
                fetch('/FisioESport/CalendarioController', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=create&data=' + info.dateStr
                })
                .then(() => calendar.refetchEvents());
            }
        },

        // 🔵 Clic su evento → elimina (prototipo semplice)
        eventClick: function(info) {
            if (confirm("Eliminare questo appuntamento?")) {
                fetch('/FisioESport/CalendarioController', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=delete&id=' + info.event.id
                })
                .then(() => calendar.refetchEvents());
            }
        }
    });

    calendar.render();
});
</script>

</body>
</html>
