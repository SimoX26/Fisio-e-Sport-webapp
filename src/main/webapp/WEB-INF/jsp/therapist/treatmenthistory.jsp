<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Storico Trattamenti • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">

      <!-- Custom CSS -->
       <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260322-2">
</head>

<body class="app-page">

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container app-shell mt-4">

    <!-- HEADER PAGINA -->
    <div class="page-header-row mb-4">
        <div>
            <h2 class="page-title">Storico Trattamenti</h2>
            <p class="page-subtitle mb-0">
                Visualizza e consulta le sedute effettuate
            </p>
        </div>

        <a href="<%= request.getContextPath() %>/calendar"
           class="btn btn-primary section-action-btn">
            Nuovo trattamento
        </a>
    </div>

    <!-- LISTA TRATTAMENTI -->
    <div class="glass-card section-card p-4">

        <%--
            Il controller dovrebbe settare:
            request.setAttribute("sessions", List<TreatmentSession>);
        --%>

        <c:choose>
            <c:when test="${empty sessions}">

            <!-- EMPTY STATE -->
            <div class="text-center py-5 empty-state">
                <h5>Nessun trattamento registrato</h5>
                <p class="mb-3">
                    Inizia aggiungendo una nuova seduta
                </p>
                <a href="<%= request.getContextPath() %>/calendar"
                   class="btn btn-soft">
                    Aggiungi trattamento
                </a>
            </div>

            </c:when>
            <c:otherwise>

            <!-- TABELLA -->
            <div class="table-responsive">
                <table class="table table-borderless align-middle mb-0">
                    <thead>
                    <tr>
                        <th>Data</th>
                        <th>Paziente</th>
                        <th>Tipo trattamento</th>
                        <th>Stato</th>
                        <th class="text-end">Azioni</th>
                    </tr>
                    </thead>
                    <tbody>

                    <c:forEach var="session" items="${sessions}">
                        <tr>
                            <td><c:out value="${session.start}" /></td>
                            <td><c:out value="${session.patientId}" /></td>
                            <td><c:out value="${session.appointmentId}" /></td>
                            <td>
                                <span class="badge-state state-completed">
                                    <c:out value="${session.state}" />
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="#"
                                   class="btn btn-sm btn-soft">
                                    Dettagli
                                </a>
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
