<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <title>Fisio e Sport – Dashboard</title>

    <!-- Bootstrap (CDN) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js">
    </script>

    <style>
        body {
            background: #f6f7fb;
            font-family: Arial, sans-serif;
        }

        .dashboard-card {
            transition: 0.2s;
            cursor: pointer;
        }

        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
        }
    </style>
</head>

<body>

<%@ include file="/WEB-INF/jsp/header.jspf" %>

<div class="container mt-5">

    <h2 class="text-center mb-4">
        Benvenuto in <strong>Fisio e Sport</strong>
    </h2>

    <div class="row justify-content-center g-4">

        <!-- 🔵 CALENDARIO -->
        <div class="col-md-4">
            <div class="card dashboard-card"
                 onclick="location.href='<%= request.getContextPath() %>/calendar'">
                <div class="card-body text-center">
                    <h3>📅 Calendario</h3>
                    <p>Visualizza e gestisci gli appuntamenti del centro</p>
                </div>
            </div>
        </div>

        <!-- 🟢 RUBRICA PAZIENTI -->
        <div class="col-md-4">
            <div class="card dashboard-card"
                 onclick="location.href='<%= request.getContextPath() %>/address-book'">
                <div class="card-body text-center">
                    <h3>👤 Rubrica Pazienti</h3>
                    <p>Consulta l’elenco dei pazienti registrati</p>
                </div>
            </div>
        </div>

        <!-- 🟣 STORICO TRATTAMENTI -->
        <!--
        <div class="col-md-4">
            <div class="card dashboard-card"
                 onclick="location.href='<%= request.getContextPath() %>/treatment-history?patientId=1'">
                <div class="card-body text-center">
                    <h3>🩺 Storico Trattamenti</h3>
                    <p>Consulta lo storico delle sedute cliniche</p>
                </div>
            </div>
        </div>
        -->

    </div>
</div>

</body>
</html>
