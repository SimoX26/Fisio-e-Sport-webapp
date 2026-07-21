<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Invia promemoria - Fisio e Sports</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/assets/img/logo.png">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260617-4">
</head>
<body class="app-page">

<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container app-shell mt-4">
    <div class="page-header-row mb-3">
        <div>
            <h1 class="page-title mb-1">Invia promemoria</h1>
            <div class="home-subtitle">Seleziona un appuntamento e invia un messaggio WhatsApp al singolo paziente.</div>
        </div>
        <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/dashboard">Torna alla pagina iniziale</a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-warning mb-3" role="alert">
            <c:out value="${error}" />
        </div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="alert alert-success mb-3" role="alert">
            <c:out value="${success}" />
        </div>
    </c:if>
    <c:if test="${not whatsAppConfigured}">
        <div class="alert alert-warning mb-3" role="alert">
            Servizio WhatsApp non configurato per questo account. Contattare l'amministratore di sistema.
        </div>
    </c:if>

    <div class="glass-card section-card">
        <form method="get" action="<%= request.getContextPath() %>/promemoria" class="row g-3 align-items-end mb-4">
            <div class="col-12 col-md-4">
                <label class="form-label" for="date">Giorno appuntamento</label>
                <input class="form-control" type="date" id="date" name="date" value="<c:out value='${selectedDate}' />">
            </div>
            <div class="col-12 col-md-auto">
                <button type="submit" class="btn btn-outline-primary">Mostra appuntamenti</button>
            </div>
        </form>

        <div class="small text-muted mb-3">
            Appuntamenti programmati per <strong><c:out value="${selectedDateLabel}" /></strong>
        </div>

        <form method="post" action="<%= request.getContextPath() %>/promemoria">
            <input type="hidden" name="date" value="<c:out value='${selectedDate}' />">

            <div class="mb-3">
                <label class="form-label" for="appointmentId">Appuntamento</label>
                <select class="form-select" id="appointmentId" name="appointmentId" required>
                    <option value="">Seleziona appuntamento</option>
                    <c:forEach var="appointment" items="${appointments}">
                        <option value="<c:out value='${appointment.id}' />"
                                <c:if test="${not appointment.sendable}">disabled</c:if>
                                <c:if test="${appointment.id == selectedAppointmentId}">selected</c:if>>
                            <c:out value="${appointment.label}" />
                        </option>
                    </c:forEach>
                </select>
                <c:if test="${empty appointments}">
                    <div class="form-text">Nessun appuntamento programmato con paziente per il giorno selezionato.</div>
                </c:if>
            </div>

            <div class="mb-4">
                <label class="form-label" for="template">Messaggio</label>
                <textarea class="form-control" id="template" name="template" rows="5"><c:out value="${template}" /></textarea>
                <div class="form-text">
                    Puoi usare: <code>{giorno}</code>, <code>{ora inizio}</code>, <code>{ora fine}</code>, <code>{ora inizio - ora fine}</code>.
                </div>
            </div>

            <div class="d-flex gap-2 flex-wrap">
                <button type="submit" class="btn btn-primary" <c:if test="${empty appointments or not whatsAppConfigured}">disabled</c:if>>
                    Invia promemoria
                </button>
                <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/calendar?view=timeGridDay&date=${selectedDate}">
                    Apri calendario
                </a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
