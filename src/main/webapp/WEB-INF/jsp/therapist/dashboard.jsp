<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard • Fisio e Sports</title>

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
       <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260617-1">
</head>

<body class="app-page">

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container app-shell mt-4">
    <div class="home-topbar mb-3">
        <div>
            <h1 class="home-title mb-1"><c:out value="${greetingPrefix}" />, <c:out value="${loggedUserDisplay}" /></h1>
            <div class="home-subtitle"><c:out value="${todayLabel}" /></div>
        </div>
        <a class="btn btn-outline-secondary btn-sm home-calendar-btn" href="<%= request.getContextPath() %>/calendar">
            Apri calendario
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-warning mb-3" role="alert">
            <c:out value="${error}" />
        </div>
    </c:if>

    <div class="home-kpi-row mb-4">
        <a class="glass-card section-card home-kpi-chip text-decoration-none" href="<%= request.getContextPath() %>/calendar?view=timeGridDay&date=today">
            <span class="home-kpi-chip__label">Appuntamenti oggi</span>
            <span class="home-kpi-chip__value"><c:out value="${appointmentsToday}" /></span>
        </a>
        <a class="glass-card section-card home-kpi-chip text-decoration-none" href="<%= request.getContextPath() %>/address-book?treatedMonth=${patientsMonthParam}">
            <span class="home-kpi-chip__label">Pazienti oggi</span>
            <span class="home-kpi-chip__value"><c:out value="${patientsToday}" /></span>
        </a>
        <a class="glass-card section-card home-kpi-chip text-decoration-none" href="<%= request.getContextPath() %>/calendar?view=timeGridDay&date=today">
            <span class="home-kpi-chip__label">Reminder da inviare</span>
            <span class="home-kpi-chip__value"><c:out value="${remindersToSendToday}" /></span>
        </a>
    </div>

    <div class="row g-3 align-items-start mb-4">
        <div class="col-12 col-xl-8">
            <div class="glass-card section-card home-agenda-card">
                <div class="home-section-head">
                    <h3 class="home-section-title mb-0">Agenda di oggi</h3>
                    <a class="home-link" href="<%= request.getContextPath() %>/calendar?view=timeGridDay&date=today">Apri vista giornaliera</a>
                </div>
                <c:set var="agendaRows" value="${todayAgenda}" />
                <c:choose>
                    <c:when test="${empty agendaRows}">
                        <div class="home-empty-state">
                            Nessun appuntamento pianificato per oggi.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="home-agenda-list">
                            <c:forEach var="appointment" items="${agendaRows}">
                                <div class="home-agenda-item">
                                    <div class="home-agenda-time">
                                        <c:out value="${appointment.startTime}" /> - <c:out value="${appointment.endTime}" />
                                    </div>
                                    <div class="home-agenda-main">
                                        <div class="home-agenda-title"><c:out value="${appointment.patientName}" /> - Paziente</div>
                                        <div class="home-agenda-meta"><c:out value="${appointment.eventTitle}" /> - Evento</div>
                                    </div>
                                    <div class="home-agenda-side">
                                        <span class="home-status-badge home-status-badge--${appointment.stateClass}">
                                            <c:out value="${appointment.stateLabel}" />
                                        </span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="col-12 col-xl-4">
            <div class="glass-card section-card home-actions-card mb-3">
                <div class="home-section-head">
                    <h3 class="home-section-title mb-0">Azioni rapide</h3>
                </div>
                <div class="home-actions-grid">
                    <a class="home-action-pill" href="<%= request.getContextPath() %>/calendar?new=1">Nuovo appuntamento</a>
                    <a class="home-action-pill" href="<%= request.getContextPath() %>/address-book/create">Nuovo paziente</a>
                    <a class="home-action-pill" href="<%= request.getContextPath() %>/calendar">Apri calendario</a>
                    <a class="home-action-pill" href="<%= request.getContextPath() %>/calendar?view=timeGridDay&date=today">Invia reminder</a>
                    <a class="home-action-pill" href="<%= request.getContextPath() %>/dashboard/insights">Apri statistiche</a>
                </div>
            </div>

            <div class="glass-card section-card home-summary-card d-none d-md-block">
                <div class="home-section-head">
                    <h3 class="home-section-title mb-0">Riepilogo rapido</h3>
                </div>
                <div class="home-summary-list">
                    <div class="home-summary-row">
                        <span>Pazienti nel mese</span>
                        <strong><c:out value="${patientsThisMonth}" /></strong>
                    </div>
                    <div class="home-summary-row">
                        <span>Ore settimana</span>
                        <strong><c:out value="${bookedHoursThisWeek}" /></strong>
                    </div>
                    <div class="home-summary-row">
                        <span>Periodo pazienti</span>
                        <strong><c:out value="${patientsMonthYearLabel}" /></strong>
                    </div>
                    <div class="home-summary-row">
                        <span>Settimana</span>
                        <strong><c:out value="${weekRangeLabel}" /></strong>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
