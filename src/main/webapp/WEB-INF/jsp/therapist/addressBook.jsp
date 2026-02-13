<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Rubrica Pazienti • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

   <!-- Custom CSS -->
   <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">

</head>

<body>

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/therapist/header.jspf" %>

<div class="container mt-5">

    <!-- HEADER PAGINA -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="page-title">Rubrica Pazienti</h2>
            <p class="page-subtitle mb-0">
                Gestisci e consulta i pazienti registrati
            </p>
        </div>

        <a href="<%= request.getContextPath() %>/address-book/create"
           class="btn btn-primary">
            ➕ Nuovo paziente
        </a>
    </div>

    <!-- LISTA PAZIENTI -->
    <div class="glass-card p-4">

        <%--
            Qui il controller dovrebbe settare:
            request.setAttribute("patients", List<Patient>);
        --%>

        <c:choose>
            <c:when test="${empty patients}">

            <!-- EMPTY STATE -->
            <div class="text-center py-5 empty-state">
                <h5>Nessun paziente presente</h5>
                <p class="mb-3">
                    Inizia aggiungendo il primo paziente alla rubrica
                </p>
                <a href="<%= request.getContextPath() %>/address-book/create"
                   class="btn btn-soft">
                    Aggiungi paziente
                </a>
            </div>

            </c:when>
            <c:otherwise>

            <!-- TABELLA -->
            <div class="table-responsive">
                <table class="table table-borderless align-middle mb-0">
                    <thead>
                    <tr>
                        <th>Nome</th>
                        <th>Email</th>
                        <th>Telefono</th>
                        <th class="text-end">Azioni</th>
                    </tr>
                    </thead>
                    <tbody>

                    <c:forEach var="patient" items="${patients}">
                        <tr>
                            <td>
                                <strong><c:out value="${patient.fullName}" /></strong>
                            </td>
                            <td><c:out value="${patient.email}" /></td>
                            <td><c:out value="${patient.phone}" /></td>
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
