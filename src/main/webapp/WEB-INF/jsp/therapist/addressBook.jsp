<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Rubrica Pazienti • Fisio e Sport</title>

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

    <!-- HEADER PAGINA -->
    <div class="page-header-row mb-4">
        <div>
            <h2 class="page-title">Rubrica Pazienti</h2>
        </div>

        <a href="<%= request.getContextPath() %>/address-book/create"
           class="btn btn-primary section-action-btn">
            Nuovo paziente
        </a>
    </div>

    <!-- LISTA PAZIENTI -->
    <div class="glass-card section-card p-4">

        <c:if test="${not empty error}">
            <div class="alert alert-warning" role="alert">
                <c:out value="${error}" />
            </div>
        </c:if>

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
                                <button type="button"
                                        class="btn btn-sm btn-outline-primary js-edit-patient"
                                        data-id="<c:out value='${patient.id}'/>"
                                        data-first-name="<c:out value='${patient.firstName}'/>"
                                        data-last-name="<c:out value='${patient.lastName}'/>"
                                        data-email="<c:out value='${patient.email}'/>"
                                        data-phone="<c:out value='${patient.phone}'/>">
                                    Modifica
                                </button>
                                <button type="button"
                                        class="btn btn-sm btn-outline-danger js-delete-patient"
                                        data-id="<c:out value='${patient.id}'/>"
                                        data-name="<c:out value='${patient.fullName}'/>">
                                    Elimina
                                </button>
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

<!-- MODALE MODIFICA PAZIENTE -->
<div class="modal fade" id="editPatientModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-card">
            <div class="modal-header">
                <h5 class="modal-title">Modifica paziente</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/address-book">
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editPatientId">

                    <div class="mb-3">
                        <label class="form-label">Nome</label>
                        <input type="text" class="form-control" name="firstName" id="editPatientFirstName" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Cognome</label>
                        <input type="text" class="form-control" name="lastName" id="editPatientLastName">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" name="email" id="editPatientEmail">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Telefono</label>
                        <input type="text" class="form-control" name="phone" id="editPatientPhone">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annulla</button>
                    <button type="submit" class="btn btn-primary">Salva</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODALE CONFERMA ELIMINAZIONE -->
<div class="modal fade" id="confirmDeletePatientModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content glass-card">
            <div class="modal-header">
                <h5 class="modal-title">Conferma eliminazione</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/address-book">
                <div class="modal-body">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deletePatientId">
                    <p class="mb-0">Vuoi eliminare il paziente <strong id="deletePatientName"></strong>?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annulla</button>
                    <button type="submit" class="btn btn-danger">Elimina</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const editModalEl = document.getElementById('editPatientModal');
    const deleteModalEl = document.getElementById('confirmDeletePatientModal');
    const editModal = editModalEl ? new bootstrap.Modal(editModalEl) : null;
    const deleteModal = deleteModalEl ? new bootstrap.Modal(deleteModalEl) : null;

    const editId = document.getElementById('editPatientId');
    const editFirstName = document.getElementById('editPatientFirstName');
    const editLastName = document.getElementById('editPatientLastName');
    const editEmail = document.getElementById('editPatientEmail');
    const editPhone = document.getElementById('editPatientPhone');

    const deleteId = document.getElementById('deletePatientId');
    const deleteName = document.getElementById('deletePatientName');

    document.querySelectorAll('.js-edit-patient').forEach(function (button) {
        button.addEventListener('click', function () {
            if (!editModal) return;
            editId.value = this.dataset.id || '';
            editFirstName.value = this.dataset.firstName || '';
            editLastName.value = this.dataset.lastName || '';
            editEmail.value = this.dataset.email || '';
            editPhone.value = this.dataset.phone || '';
            editModal.show();
        });
    });

    document.querySelectorAll('.js-delete-patient').forEach(function (button) {
        button.addEventListener('click', function () {
            if (!deleteModal) return;
            deleteId.value = this.dataset.id || '';
            deleteName.textContent = this.dataset.name || 'questo paziente';
            deleteModal.show();
        });
    });
});
</script>

</body>
</html>
