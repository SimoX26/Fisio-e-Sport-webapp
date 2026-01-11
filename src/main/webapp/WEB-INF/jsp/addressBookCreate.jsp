<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Nuovo Paziente • Fisio e Sport</title>

      <!-- Bootstrap -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

          <!-- Custom CSS -->
           <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>


<body>

<%@ include file="/WEB-INF/jsp/header.jspf" %>

<div class="container mt-5">

    <!-- HEADER -->
    <div class="mb-4">
        <h2 class="page-title">Nuovo paziente</h2>
        <p class="page-subtitle">
            Inserisci i dati del paziente
        </p>
    </div>

    <!-- FORM -->
    <div class="glass-card p-4">

        <form action="<%= request.getContextPath() %>/address-book"
              method="POST">

            <!-- ACTION -->
            <input type="hidden" name="action" value="create"/>

            <!-- ID (temporaneamente, perché la servlet lo richiede) -->
            <input type="hidden" name="id" value="0"/>

            <!-- NOME -->
            <div class="mb-3">
                <label class="form-label">Nome</label>
                <input type="text"
                       name="firstName"
                       class="form-control"
                       required>
            </div>

            <!-- COGNOME -->
            <div class="mb-3">
                <label class="form-label">Cognome</label>
                <input type="text"
                       name="lastName"
                       class="form-control"
                       required>
            </div>

            <!-- EMAIL -->
            <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email"
                       name="email"
                       class="form-control">
            </div>

            <!-- TELEFONO -->
            <div class="mb-3">
                <label class="form-label">Telefono</label>
                <input type="text"
                       name="phone"
                       class="form-control">
            </div>

            <!-- AZIONI -->
            <div class="d-flex justify-content-end gap-2 mt-4">
                <a href="<%= request.getContextPath() %>/address-book"
                   class="btn btn-outline-secondary">
                    Annulla
                </a>

                <button type="submit"
                        class="btn btn-primary">
                    Salva paziente
                </button>
            </div>

        </form>

    </div>

</div>

</body>
</html>
