<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Storico Trattamenti • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

      <!-- Custom CSS -->
       <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>

<body>

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/header.jspf" %>

<div class="container mt-5">

    <!-- HEADER PAGINA -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="page-title">Storico Trattamenti</h2>
            <p class="page-subtitle mb-0">
                Visualizza e consulta le sedute effettuate
            </p>
        </div>

        <a href="<%= request.getContextPath() %>/treatments/new"
           class="btn btn-primary">
            ➕ Nuovo trattamento
        </a>
    </div>

    <!-- LISTA TRATTAMENTI -->
    <div class="glass-card p-4">

        <%--
            Il controller dovrebbe settare:
            request.setAttribute("treatments", List<TreatmentSession>);
        --%>

        <%
            java.util.List<?> treatments =
                    (java.util.List<?>) request.getAttribute("treatments");
        %>

        <% if (treatments == null || treatments.isEmpty()) { %>

            <!-- EMPTY STATE -->
            <div class="text-center py-5 empty-state">
                <h5>Nessun trattamento registrato</h5>
                <p class="mb-3">
                    Inizia aggiungendo una nuova seduta
                </p>
                <a href="<%= request.getContextPath() %>/treatments/new"
                   class="btn btn-soft">
                    Aggiungi trattamento
                </a>
            </div>

        <% } else { %>

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

                    <% for (Object obj : treatments) {
                           // cast reale: TreatmentSession session = (TreatmentSession) obj;
                    %>
                        <tr>
                            <td><!-- ${session.data} --></td>
                            <td><!-- ${session.paziente.nome} --></td>
                            <td><!-- ${session.tipo} --></td>
                            <td>
                                <%-- esempio stato --%>
                                <span class="badge-state state-completed">
                                    Completato
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="#"
                                   class="btn btn-sm btn-soft">
                                    Dettagli
                                </a>
                            </td>
                        </tr>
                    <% } %>

                    </tbody>
                </table>
            </div>

        <% } %>

    </div>

</div>

</body>
</html>
