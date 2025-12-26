<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Dashboard • Fisio e Sport</title>

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

<body class="theme-dark">

<!-- HEADER -->
<%@ include file="/WEB-INF/jsp/header.jspf" %>

<div class="container mt-5">

    <!-- HEADER DASHBOARD -->
    <div class="mb-4">
        <h2 class="page-title">Dashboard</h2>
        <p class="page-subtitle">
            Panoramica generale dello studio
        </p>
    </div>

    <!-- KPI -->
    <div class="row g-4 mb-5">

        <div class="col-md-4">
            <div class="glass-card p-4">
                <div class="kpi-value">12</div>
                <div class="kpi-label">Appuntamenti oggi</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4">
                <div class="kpi-value">86</div>
                <div class="kpi-label">Pazienti totali</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4">
                <div class="kpi-value">5</div>
                <div class="kpi-label">Trattamenti questa settimana</div>
            </div>
        </div>

    </div>

    <!-- AZIONI PRINCIPALI -->
    <div class="row g-4">

        <div class="col-md-4">
            <div class="glass-card p-4 action-card h-100"
                 onclick="location.href='<%= request.getContextPath() %>/calendar'">
                <div class="icon mb-3">📅</div>
                <h5>Calendario</h5>
                <p class="page-subtitle">
                    Visualizza e gestisci gli appuntamenti
                </p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4 action-card h-100"
                 onclick="location.href='<%= request.getContextPath() %>/address-book'">
                <div class="icon mb-3">👤</div>
                <h5>Rubrica Pazienti</h5>
                <p class="page-subtitle">
                    Consulta l’elenco dei pazienti
                </p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4 action-card h-100"
                 onclick="location.href='<%= request.getContextPath() %>/treatment-history'">
                <div class="icon mb-3">🧾</div>
                <h5>Storico Trattamenti</h5>
                <p class="page-subtitle">
                    Visualizza le sedute effettuate
                </p>
            </div>
        </div>

    </div>

    <!-- CTA -->
    <div class="mt-5">
        <div class="glass-card p-4 d-flex justify-content-between align-items-center">
            <div>
                <h5 class="mb-1">Nuovo appuntamento</h5>
                <p class="page-subtitle mb-0">
                    Inserisci rapidamente una nuova seduta
                </p>
            </div>
            <a href="<%= request.getContextPath() %>/calendar/new"
               class="btn btn-primary">
                ➕ Crea
            </a>
        </div>
    </div>

</div>

</body>
</html>
