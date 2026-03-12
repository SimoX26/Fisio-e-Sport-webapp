<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

      <!-- Custom CSS -->
       <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>

<body>

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container mt-5">

    <!-- HEADER DASHBOARD -->
    <div class="mb-4">
        <h2 class="page-title">Dashboard</h2>
        <p class="page-subtitle">
            Panoramica generale dello studio
        </p>
    </div>

    <!-- KPI -->
    <div class="row g-4 mb-5">

        <div class="col-md-4">
            <div class="glass-card p-4">
                <div class="kpi-value">12</div>
                <div class="kpi-label">Appuntamenti oggi</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4">
                <div class="kpi-value">86</div>
                <div class="kpi-label">Pazienti totali</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4">
                <div class="kpi-value">5</div>
                <div class="kpi-label">Trattamenti questa settimana</div>
            </div>
        </div>

    </div>

    <!-- AZIONI PRINCIPALI -->
    <div class="row g-4">

        <div class="col-md-4">
            <a class="glass-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/calendar">
                <div class="icon mb-3">📅</div>
                <h5>Calendario</h5>
                <p class="page-subtitle">
                    Visualizza e gestisci gli appuntamenti
                </p>
            </a>
        </div>

        <div class="col-md-4">
            <a class="glass-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/address-book">
                <div class="icon mb-3">👤</div>
                <h5>Rubrica Pazienti</h5>
                <p class="page-subtitle">
                    Consulta l’elenco dei pazienti
                </p>
            </a>
        </div>

        <div class="col-md-4">
            <a class="glass-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/treatment-history">
                <div class="icon mb-3">🧾</div>
                <h5>Storico Trattamenti</h5>
                <p class="page-subtitle">
                    Visualizza le sedute effettuate
                </p>
            </a>
        </div>

    </div>

    <!-- CTA -->
    <div class="mt-5">
        <div class="glass-card p-4 dashboard-cta">
            <div>
                <h5 class="mb-1">Nuovo appuntamento</h5>
                <p class="page-subtitle mb-0">
                    Inserisci rapidamente una nuova seduta
                </p>
            </div>
            <a href="<%= request.getContextPath() %>/calendar"
               class="btn btn-primary">
                ➕ Crea
            </a>
        </div>
    </div>

</div>

</body>
</html>
