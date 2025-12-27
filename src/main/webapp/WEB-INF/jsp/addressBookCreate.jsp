<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <title>Nuovo Paziente • Fisio e Sport</title>

      <!-- Bootstrap -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <!-- THEME CSS (variabili globali) -->
        <style>
            /* =========================
               THEME VARIABLES
               ========================= */

            :root{
                --bg-main: #ffffff;
                --bg-card: rgba(0,0,0,.03);
                --border-color: rgba(0,0,0,.12);
                --text-main: #212529;
                --text-muted: rgba(33,37,41,.7);
                --input-bg: #ffffff;
            }

            body.theme-dark{
                --bg-main: #0b1220;
                --bg-card: rgba(255,255,255,.06);
                --border-color: rgba(255,255,255,.12);
                --text-main: #e9eefb;
                --text-muted: rgba(233,238,251,.65);
                --input-bg: rgba(255,255,255,.08);
            }

            /* =========================
               BASE
               ========================= */

            body{
                min-height: 100vh;
                background:
                    radial-gradient(1200px 600px at 10% 10%, rgba(13,110,253,.18), transparent 55%),
                    radial-gradient(1000px 600px at 90% 20%, rgba(32,201,151,.16), transparent 55%),
                    var(--bg-main);
                color: var(--text-main);
                font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            }

            /* =========================
               PAGE HEADER
               ========================= */

            .page-title{
                font-weight: 600;
            }

            .page-subtitle{
                color: var(--text-muted);
            }

            /* =========================
               CARD
               ========================= */

            .glass-card{
                background: var(--bg-card);
                border: 1px solid var(--border-color);
                border-radius: 18px;
                backdrop-filter: blur(12px);
                box-shadow: 0 14px 40px rgba(0,0,0,.35);
            }

            /* =========================
               FORM
               ========================= */

            .form-label{
                font-weight: 500;
            }

            .form-control{
                background: var(--input-bg);
                border: 1px solid var(--border-color);
                color: var(--text-main);
            }

            .form-control::placeholder{
                color: var(--text-muted);
            }

            .form-control:focus{
                background: var(--input-bg);
                color: var(--text-main);
                border-color: #0d6efd;
                box-shadow: 0 0 0 .2rem rgba(13,110,253,.15);
            }

            /* =========================
               BUTTONS
               ========================= */

            .btn-outline-secondary{
                border-color: var(--border-color);
                color: var(--text-main);
            }

            .btn-outline-secondary:hover{
                background: var(--bg-card);
            }

            /* =========================
               NAVBAR (inherit global style)
               ========================= */

            .navbar .navbar-brand,
            .navbar .nav-link{
                color: var(--text-main) !important;
            }

            .navbar .nav-link:hover{
                color: #0d6efd !important;
            }

        </style>
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
