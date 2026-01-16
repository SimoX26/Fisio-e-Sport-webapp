<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>

    <!-- Bootstrap (se già usato nel progetto) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
</head>
<body>

<div class="container mt-5">

    <h2 class="mb-4">Admin Dashboard</h2>

    <!-- =========================
         SEZIONE GESTIONE UTENTI
         ========================= -->
    <div class="card shadow-sm">
        <div class="card-body">

            <h5 class="card-title mb-3">Gestione Utenti</h5>

            <p class="card-text">
                Da questa sezione è possibile creare nuovi utenti del sistema.
            </p>

            <a href="${pageContext.request.contextPath}/admin/new-user"
               class="btn btn-primary">
                Aggiungi nuovo utente
            </a>

        </div>
    </div>

</div>

</body>
</html>
