<%@ page contentType="text/html;charset=UTF-8" %>

<html>
<head>
    <title>Calendar</title>

    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/main.min.css" rel="stylesheet"/>

    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/main.min.js"></script>
</head>

<body>

<h1>Appointments Calendar</h1>

<div id="calendar"></div>

<script>
    document.addEventListener('DOMContentLoaded', function () {

        const calendar = new FullCalendar.Calendar(
            document.getElementById('calendar'),
            {
                initialView: 'dayGridMonth',

                events: {
                    url: '<%= request.getContextPath() %>/calendar',
                    method: 'GET',
                    extraParams: {
                        events: 'true'
                    }
                }
            }
        );

        calendar.render();
    });
</script>

</body>
</html>
