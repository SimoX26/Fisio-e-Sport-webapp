<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Login • Fisio e Sport</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

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

    </style>
</head>

<body class="d-flex align-items-center justify-content-center">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="glass-card p-4 p-md-5">

                <div class="text-center mb-4">
                    <h2 class="brand">Fisio e Sport</h2>
                    <p class="text-muted">Accedi alla tua dashboard</p>
                </div>

                <form action="<%= request.getContextPath() %>/login" method="post">
                    <div class="form-floating mb-3">
                        <input type="email" class="form-control" id="email"
                               name="email" placeholder="email" required>
                        <label for="email">Email</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="password" class="form-control" id="password"
                               name="password" placeholder="password" required>
                        <label for="password">Password</label>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2">
                        Accedi
                    </button>
                </form>

                <div class="text-center mt-4 small">
                    Non hai un account?
                    <a href="<%= request.getContextPath() %>/register.jsp">Registrati</a>
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
