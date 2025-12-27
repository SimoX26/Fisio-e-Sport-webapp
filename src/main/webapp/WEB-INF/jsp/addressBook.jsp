<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Rubrica Pazienti • Fisio e Sport</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- THEME CSS (variabili globali) -->
    <style>
        :root{
            --bg-main: #ffffff;
            --bg-card: rgba(0,0,0,.03);
            --border-color: rgba(0,0,0,.12);
            --text-main: #212529;
            --text-muted: #6c757d;
        }

        body.theme-dark{
            --bg-main: #0b1220;
            --bg-card: rgba(255,255,255,.06);
            --border-color: rgba(255,255,255,.12);
            --text-main: #e9eefb;
            --text-muted: rgba(233,238,251,.65);
        }

        body{
            background:
                radial-gradient(1200px 600px at 10% 10%, rgba(13,110,253,.18), transparent 55%),
                radial-gradient(1000px 600px at 90% 20%, rgba(32,201,151,.16), transparent 55%),
                var(--bg-main);
            color: var(--text-main);
        }

        .page-title{
            font-weight: 600;
        }

        .page-subtitle{
            color: var(--text-muted);
        }

        .glass-card{
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 18px;
            backdrop-filter: blur(12px);
            box-shadow: 0 14px 40px rgba(0,0,0,.45);
        }

        .kpi-value{
            font-size: 2rem;
            font-weight: 700;
        }

        .kpi-label{
            color: var(--text-muted);
            font-size: .9rem;
        }

        .action-card{
            cursor: pointer;
            transition: .25s ease;
        }

        .action-card:hover{
            transform: translateY(-6px);
            box-shadow: 0 14px 30px rgba(0,0,0,.4);
        }

        .icon{
            font-size: 2rem;
        }

        .btn-soft{
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            color: var(--text-main);
        }

        .btn-soft:hover{
            background: rgba(255,255,255,.14);
        }

        /* ===== NAVBAR THEME-AWARE ===== */

        .navbar .nav-link,
        .navbar .navbar-brand {
            color: var(--text-main) !important;
        }

        .navbar .nav-link:hover {
            color: #0d6efd !important;
        }

        .navbar .nav-link.text-danger {
            color: #dc3545 !important;
        }

        /* Separatore | */
        .navbar .nav-link.disabled {
            color: var(--text-muted) !important;
        }

        /* Bottone toggle tema */
        #themeToggle {
            color: var(--text-main);
            border-color: var(--border-color);
        }

        #themeToggle:hover {
            background: var(--bg-card);
        }

    </style>
</head>

<body>

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/header.jspf" %>

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
            request.setAttribute("patients", List<PazienteBean>);
        --%>

        <%
            java.util.List<?> patients =
                    (java.util.List<?>) request.getAttribute("patients");
        %>

        <% if (patients == null || patients.isEmpty()) { %>

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

        <% } else { %>

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

                    <% for (Object obj : patients) {
                           // cast reale nel tuo progetto (es. PazienteBean)
                    %>
                        <tr>
                            <td>
                                <strong><!-- ${paziente.nome} ${paziente.cognome} --></strong>
                            </td>
                            <td><!-- ${paziente.email} --></td>
                            <td><!-- ${paziente.telefono} --></td>
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
