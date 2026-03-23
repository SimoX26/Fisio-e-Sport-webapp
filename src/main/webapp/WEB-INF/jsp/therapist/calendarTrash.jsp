<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cestino Appuntamenti • Fisio e Sport</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/assets/img/logo.png">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260323-3">
</head>
<body class="app-page">

<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container app-shell mt-4">
    <div class="page-header-row mb-3">
        <div>
            <h2 class="page-title mb-0">Cestino appuntamenti</h2>
            <p class="page-subtitle mb-0">Visualizza gli appuntamenti cancellati e gestiscili</p>
        </div>
        <a href="<%= request.getContextPath() %>/calendar" class="btn btn-outline-secondary section-action-btn">Torna al calendario</a>
    </div>

    <div class="glass-card section-card p-4">
        <c:if test="${not empty error}">
            <div class="alert alert-warning" role="alert">
                <c:out value="${error}" />
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty cancelledAppointments}">
                <div class="empty-state py-5 text-center">
                    <h5>Nessun appuntamento nel cestino</h5>
                    <p class="mb-0">Gli appuntamenti cancellati compariranno qui.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-borderless align-middle mb-0">
                        <thead>
                        <tr>
                            <th>Paziente</th>
                            <th>Inizio</th>
                            <th>Fine</th>
                            <th>Note</th>
                            <th class="text-end">Azioni</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="row" items="${cancelledAppointments}">
                            <tr>
                                <td><strong><c:out value="${row.patientFullName}" /></strong></td>
                                <td><c:out value="${row.start}" /></td>
                                <td><c:out value="${row.end}" /></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty row.notes}">
                                            <span class="text-muted">-</span>
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${row.notes}" />
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <form method="post" action="<%= request.getContextPath() %>/calendar/trash" class="d-inline">
                                        <input type="hidden" name="action" value="restore">
                                        <input type="hidden" name="id" value="<c:out value='${row.id}'/>">
                                        <button type="submit" class="btn btn-sm btn-outline-primary">Ripristina</button>
                                    </form>
                                    <form method="post" action="<%= request.getContextPath() %>/calendar/trash" class="d-inline ms-1">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<c:out value='${row.id}'/>">
                                        <button type="submit" class="btn btn-sm btn-outline-danger"
                                                onclick="return confirm('Eliminare definitivamente questo appuntamento?');">
                                            Elimina
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
