<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/assets/img/logo.png">
    <link rel="apple-touch-icon" href="<%= request.getContextPath() %>/assets/img/logo-192.png">
    <link rel="manifest" href="<%= request.getContextPath() %>/manifest.webmanifest">
    <meta name="theme-color" content="#1a73e8">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-title" content="FisioSport">

      <!-- Custom CSS -->
       <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260322-2">
</head>

<body class="app-page">

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container app-shell mt-4">

    <!-- HEADER DASHBOARD -->
    <div class="mb-4">
        <h2 class="page-title">Home</h2>
        <p class="page-subtitle">
            Panoramica generale dello studio
        </p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-warning" role="alert">
            <c:out value="${error}" />
        </div>
    </c:if>

    <!-- KPI -->
    <div class="row g-4 mb-5">
        <div class="col-md-4">
            <a class="glass-card section-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/calendar?view=timeGridDay&date=today">
                <div class="kpi-value"><c:out value="${appointmentsToday}" /></div>
                <div class="kpi-label">
                    Appuntamenti oggi <c:out value="${todayLabel}" />
                </div>
            </a>
        </div>

        <div class="col-md-4">
            <a class="glass-card section-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/address-book">
                <div class="kpi-value"><c:out value="${patientsThisMonth}" /></div>
                <div class="kpi-label">
                    Pazienti trattati a <c:out value="${patientsMonthYearLabel}" />
                </div>
            </a>
        </div>

        <div class="col-md-4">
            <a class="glass-card section-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/calendar?view=timeGridWeek&date=today">
                <div class="kpi-value"><c:out value="${bookedHoursThisWeek}" /></div>
                <div class="kpi-label">
                    Ore prenotate nella settimana <c:out value="${weekRangeLabel}" />
                </div>
            </a>
        </div>
    </div>

    <!-- AZIONI PRINCIPALI -->
    <div class="row g-4">

        <div class="col-md-4">
            <a class="glass-card section-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/calendar">
                <div class="kpi-label mb-2">Calendario</div>
                <h5>Calendario</h5>
                <p class="page-subtitle">
                    Visualizza e gestisci gli appuntamenti
                </p>
            </a>
        </div>

        <div class="col-md-4">
            <a class="glass-card section-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/address-book">
                <div class="kpi-label mb-2">Rubrica</div>
                <h5>Rubrica Pazienti</h5>
                <p class="page-subtitle">
                    Consulta l’elenco dei pazienti
                </p>
            </a>
        </div>

        <div class="col-md-4">
            <a class="glass-card section-card p-4 action-card h-100 d-block text-decoration-none"
               href="<%= request.getContextPath() %>/treatment-history">
                <div class="kpi-label mb-2">Storico</div>
                <h5>Storico Trattamenti</h5>
                <p class="page-subtitle">
                    Visualizza le sedute effettuate
                </p>
            </a>
        </div>

    </div>

</div>

</body>
</html>
