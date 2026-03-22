<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=20260322-2">
</head>
<body class="app-page">

<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div class="container app-shell mt-4">

    <div class="mb-4">
        <h2 class="page-title">Dashboard amministrativa</h2>
        <p class="page-subtitle mb-0">Gestione utenti e configurazione operativa</p>
    </div>

    <!-- =========================
         SEZIONE GESTIONE UTENTI
         ========================= -->
    <div class="glass-card section-card p-4">

        <h5 class="mb-3">Gestione utenti</h5>

        <p class="page-subtitle">
            Da questa sezione è possibile creare nuovi utenti del sistema.
        </p>

        <a href="${pageContext.request.contextPath}/admin/new-user"
           class="btn btn-primary section-action-btn">
            Aggiungi nuovo utente
        </a>

    </div>

</div>

</body>
</html>
