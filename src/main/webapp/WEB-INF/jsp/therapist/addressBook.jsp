<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Rubrica Pazienti • Fisio e Sports</title>

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
   <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260323-9">

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

        <c:if test="${param.created == '1'}">
            <div class="alert alert-success" role="alert">
                Paziente inserito correttamente.
            </div>
        </c:if>

        <c:if test="${param.updated == '1'}">
            <div class="alert alert-success" role="alert">
                Dati paziente e anamnesi salvati correttamente.
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
                        <th>Telefono</th>
                        <th class="text-end">Azioni</th>
                    </tr>
                    </thead>
                    <tbody>

                    <c:forEach var="patient" items="${patients}">
                        <tr>
                            <td>
                                <c:out value="${patient.fullName}" />
                            </td>
                            <td><c:out value="${patient.phone}" /></td>
                            <td class="text-end">
                                <a href="${pageContext.request.contextPath}/treatment-history?patientId=${patient.id}"
                                   class="btn btn-sm btn-outline-secondary">
                                    Cronologia Trattamenti
                                </a>
                                <button type="button"
                                        class="btn btn-sm btn-outline-primary js-edit-patient"
                                        data-id="<c:out value='${patient.id}'/>"
                                        data-first-name="<c:out value='${patient.firstName}'/>"
                                        data-last-name="<c:out value='${patient.lastName}'/>"
                                        data-email="<c:out value='${patient.email}'/>"
                                        data-phone="<c:out value='${patient.phone}'/>">
                                    Dettagli
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
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content glass-card">
            <div class="modal-header">
                <h5 class="modal-title">Modifica paziente</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/address-book">
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editPatientId">

                    <div class="row g-3">
                        <div class="col-12 col-md-6">
                            <label class="form-label">Nome</label>
                            <input type="text" class="form-control" name="firstName" id="editPatientFirstName" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label">Cognome</label>
                            <input type="text" class="form-control" name="lastName" id="editPatientLastName">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="email" id="editPatientEmail">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label">Telefono</label>
                            <input type="text" class="form-control" name="phone" id="editPatientPhone">
                        </div>
                    </div>

                    <hr class="my-4">
                    <h6 class="mb-3">Scheda anamnesi</h6>

                    <div class="mb-3">
                        <label class="form-label">Data anamnesi</label>
                        <input type="date" class="form-control" name="assessmentDate">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Motivo del consulto</label>
                        <textarea class="form-control" name="chiefComplaint" rows="2"></textarea>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Localizzazione dolore</label>
                            <input type="text" class="form-control" name="painLocation">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Tipologia dolore</label>
                            <input type="text" class="form-control" name="painQuality">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Sintomi associati</label>
                            <textarea class="form-control" name="associatedSymptoms" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-4">
                            <label class="form-label">Esordio</label>
                            <select class="form-select" name="onsetType">
                                <option value="">-</option>
                                <option value="ACUTE">Acuto</option>
                                <option value="SUBACUTE">Subacuto</option>
                                <option value="CHRONIC">Cronico</option>
                            </select>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label">Contesto esordio</label>
                            <input type="text" class="form-control" name="onsetContext" placeholder="Trauma, stress, casuale...">
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-4">
                            <label class="form-label">Dolore invalidante</label>
                            <select class="form-select" name="isDisabling">
                                <option value="">-</option>
                                <option value="si">Si</option>
                                <option value="no">No</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Frequenza dolore</label>
                            <select class="form-select" name="painFrequency">
                                <option value="">-</option>
                                <option value="LOW">Bassa</option>
                                <option value="MEDIUM">Media</option>
                                <option value="HIGH">Alta</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Progressione dolore</label>
                            <select class="form-select" name="painProgression">
                                <option value="">-</option>
                                <option value="CONSTANT">Costante</option>
                                <option value="WORSE">Peggiorato</option>
                                <option value="BETTER">Migliorato</option>
                            </select>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-4">
                            <label class="form-label">Con movimento</label>
                            <select class="form-select" name="painWithMovement">
                                <option value="">-</option>
                                <option value="WORSE">Peggiora</option>
                                <option value="BETTER">Migliora</option>
                                <option value="UNCHANGED">Invariato</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Con riposo</label>
                            <select class="form-select" name="painWithRest">
                                <option value="">-</option>
                                <option value="WORSE">Peggiora</option>
                                <option value="BETTER">Migliora</option>
                                <option value="UNCHANGED">Invariato</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Intensita dolore (0-10)</label>
                            <input type="number" class="form-control" name="painIntensity" min="0" max="10">
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-3">
                            <label class="form-label">Dolore notturno</label>
                            <select class="form-select" name="nightPain">
                                <option value="">-</option>
                                <option value="si">Si</option>
                                <option value="no">No</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Dolore al risveglio</label>
                            <select class="form-select" name="morningPain">
                                <option value="">-</option>
                                <option value="si">Si</option>
                                <option value="no">No</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Farmaci dolore</label>
                            <select class="form-select" name="usesPainMeds">
                                <option value="">-</option>
                                <option value="si">Si</option>
                                <option value="no">No</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Efficacia farmaco</label>
                            <select class="form-select" name="painMedsEffect">
                                <option value="">-</option>
                                <option value="YES">Si</option>
                                <option value="NO">No</option>
                                <option value="PARTIAL">Poco</option>
                            </select>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-4">
                            <label class="form-label">Esami strumentali</label>
                            <textarea class="form-control" name="clinicalTests" rows="2"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Visite specialistiche</label>
                            <textarea class="form-control" name="specialistVisits" rows="2"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Trattamenti precedenti</label>
                            <textarea class="form-control" name="previousTreatments" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-6">
                            <label class="form-label">Patologie pregresse</label>
                            <textarea class="form-control" name="pathologyHistory" rows="2"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Farmaci regolari</label>
                            <textarea class="form-control" name="currentRegularDrugs" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-4">
                            <label class="form-label">Interventi chirurgici</label>
                            <textarea class="form-control" name="surgeryHistory" rows="2"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Traumi</label>
                            <textarea class="form-control" name="traumaHistory" rows="2"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Dispositivi usati</label>
                            <textarea class="form-control" name="devicesHistory" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-3">
                            <label class="form-label">Disturbi masticazione</label>
                            <select class="form-select" name="chewingDisorders">
                                <option value="">-</option>
                                <option value="si">Si</option>
                                <option value="no">No</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Infezioni/infiammazioni importanti</label>
                            <textarea class="form-control" name="majorInfectionsHistory" rows="2"></textarea>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label">Familiarita malattie</label>
                            <textarea class="form-control" name="familyHistory" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-2">
                            <label class="form-label">Altezza (cm)</label>
                            <input type="number" step="0.01" class="form-control" name="heightCm">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Peso (kg)</label>
                            <input type="number" step="0.01" class="form-control" name="weightKg">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Stile vita</label>
                            <select class="form-select" name="lifestyle">
                                <option value="">-</option>
                                <option value="SPORTY">Sportivo</option>
                                <option value="SEDENTARY">Sedentario</option>
                                <option value="MIXED">Misto</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Sport praticato</label>
                            <input type="text" class="form-control" name="sportPractice">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Fumo/alcol/sostanze</label>
                            <input type="text" class="form-control" name="substanceUse">
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-2">
                            <label class="form-label">Qualita sonno (0-4)</label>
                            <input type="number" class="form-control" name="sleepQuality" min="0" max="4">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Stress (0-4)</label>
                            <input type="number" class="form-control" name="stressLevel" min="0" max="4">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Alimentazione</label>
                            <select class="form-select" name="dietQuality">
                                <option value="">-</option>
                                <option value="HEALTHY">Sana</option>
                                <option value="IMBALANCED">Squilibrata</option>
                                <option value="MIXED">Mista</option>
                            </select>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label">Note ciclo/andrologiche-ginecologiche</label>
                            <input type="text" class="form-control" name="femaleCycleNotes">
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-6">
                            <label class="form-label">Condizioni patologiche (separate da virgola o su righe diverse)</label>
                            <textarea class="form-control" name="conditionsPathology" rows="2"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Sintomi rilevanti (separati da virgola o su righe diverse)</label>
                            <textarea class="form-control" name="conditionsSymptom" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-6">
                            <label class="form-label">Familiarita (separate da virgola o su righe diverse)</label>
                            <textarea class="form-control" name="conditionsFamilyHistory" rows="2"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Allergie/intolleranze (separate da virgola o su righe diverse)</label>
                            <textarea class="form-control" name="conditionsAllergy" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row g-3 mt-1">
                        <div class="col-md-6">
                            <label class="form-label">Farmaci rilevanti (separati da virgola o su righe diverse)</label>
                            <textarea class="form-control" name="conditionsDrug" rows="2"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Revisione sistemica (separate da virgola o su righe diverse)</label>
                            <textarea class="form-control" name="conditionsSystemReview" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="mb-3 mt-3">
                        <label class="form-label">Altre condizioni (separate da virgola o su righe diverse)</label>
                        <textarea class="form-control" name="conditionsOther" rows="2"></textarea>
                    </div>

                    <div class="mb-2">
                        <label class="form-label">Note libere</label>
                        <textarea class="form-control" name="freeNotesJson" rows="2" placeholder="Inserisci note testuali libere"></textarea>
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

<c:if test="${param.created == '1'}">
<script>
sessionStorage.setItem('addressBookCreateSubmitted', '1');
</script>
</c:if>

<script>
(function () {
    const lockKey = 'lockBackAddressBook';
    const params = new URLSearchParams(window.location.search);

    if (params.get('lockBack') === '1') {
        sessionStorage.setItem(lockKey, '1');
        params.delete('lockBack');
        const cleanUrl = window.location.pathname
            + (params.toString() ? '?' + params.toString() : '')
            + window.location.hash;
        history.replaceState(null, '', cleanUrl);
    }

    if (sessionStorage.getItem(lockKey) !== '1') {
        return;
    }

    history.pushState(null, '', window.location.href);
    window.addEventListener('popstate', function () {
        history.pushState(null, '', window.location.href);
    });
})();
</script>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const contextPath = '<%= request.getContextPath() %>';
    const editModalEl = document.getElementById('editPatientModal');
    const deleteModalEl = document.getElementById('confirmDeletePatientModal');
    const editModal = editModalEl ? new bootstrap.Modal(editModalEl) : null;
    const deleteModal = deleteModalEl ? new bootstrap.Modal(deleteModalEl) : null;
    const editForm = editModalEl ? editModalEl.querySelector('form') : null;

    const editId = document.getElementById('editPatientId');
    const editFirstName = document.getElementById('editPatientFirstName');
    const editLastName = document.getElementById('editPatientLastName');
    const editEmail = document.getElementById('editPatientEmail');
    const editPhone = document.getElementById('editPatientPhone');

    const deleteId = document.getElementById('deletePatientId');
    const deleteName = document.getElementById('deletePatientName');

    function setFormFieldValue(name, value) {
        if (!editForm) return;
        const field = editForm.elements.namedItem(name);
        if (!field) return;
        field.value = value == null ? '' : String(value);
    }

    document.querySelectorAll('.js-edit-patient').forEach(function (button) {
        button.addEventListener('click', async function () {
            if (!editModal) return;
            if (editForm) {
                editForm.reset();
            }
            editId.value = this.dataset.id || '';
            editFirstName.value = this.dataset.firstName || '';
            editLastName.value = this.dataset.lastName || '';
            editEmail.value = this.dataset.email || '';
            editPhone.value = this.dataset.phone || '';

            const patientId = this.dataset.id || '';
            if (patientId) {
                try {
                    const response = await fetch(
                        contextPath + '/address-book?action=anamnesis-details&id=' + encodeURIComponent(patientId),
                        { headers: { 'Accept': 'application/json' } }
                    );
                    if (!response.ok) {
                        throw new Error('Impossibile caricare i dettagli anamnesi');
                    }
                    const payload = await response.json();
                    const anamnesis = payload && payload.anamnesis ? payload.anamnesis : {};
                    Object.keys(anamnesis).forEach(function (key) {
                        setFormFieldValue(key, anamnesis[key]);
                    });
                } catch (error) {
                    alert('Impossibile caricare i dati anamnestici salvati.');
                }
            }
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
