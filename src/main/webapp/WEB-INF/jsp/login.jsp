<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Login • Fisio e Sport</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

      <!-- Custom CSS -->
       <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260322-2">
</head>

<body class="auth-page app-page d-flex align-items-center justify-content-center">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="glass-card p-4 p-md-5">

                <div class="text-center mb-4">
                    <h2 class="brand">Fisio e Sport</h2>
                    <p class="text-muted">Accedi alla tua dashboard</p>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger" role="alert">
                        <c:out value="${error}" />
                    </div>
                </c:if>

                <form action="<%= request.getContextPath() %>/login" method="post">
                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" id="username"
                               name="username" placeholder="Inserisci username"
                               value="<c:out value='${username}' />" required>
                        <label for="username">Username</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="password" class="form-control" id="password"
                               name="password" placeholder="Inserisci password" required>
                        <label for="password">Password</label>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2">
                        Accedi
                    </button>
                </form>

                <div class="text-center mt-4 small">
                    Non hai un account?
                    <a href="<%= request.getContextPath() %>/register">Registrati</a>
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
