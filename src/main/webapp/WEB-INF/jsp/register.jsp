<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Registrazione • Fisio e Sport</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

      <!-- Custom CSS -->
       <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>

<body class="d-flex align-items-center justify-content-center">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-7 col-lg-6">
            <div class="glass-card p-4 p-md-5">

                <div class="text-center mb-4">
                    <h2 class="brand">Fisio e Sport</h2>
                    <p class="text-muted">Crea il tuo account</p>
                </div>

                <form action="<%= request.getContextPath() %>/register" method="post">
                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" id="nome"
                               name="nome" placeholder="nome" required>
                        <label for="nome">Nome</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" id="cognome"
                               name="cognome" placeholder="cognome" required>
                        <label for="cognome">Cognome</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="email" class="form-control" id="email"
                               name="email" placeholder="email" required>
                        <label for="email">Email</label>
                    </div>

                    <div class="form-floating mb-4">
                        <input type="password" class="form-control" id="password"
                               name="password" placeholder="password" required minlength="6">
                        <label for="password">Password</label>
                    </div>

                    <button type="submit" class="btn btn-success w-100 py-2">
                        Registrati
                    </button>
                </form>

                <div class="text-center mt-4 small">
                    Hai già un account?
                    <a href="<%= request.getContextPath() %>/login.jsp">Accedi</a>
                </div>

                <div class="text-center mt-3 small">
                    <a href="<%= request.getContextPath() %>/index.jsp">← Torna alla home</a>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
