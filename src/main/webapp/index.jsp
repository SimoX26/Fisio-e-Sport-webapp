<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Fisio e Sport • Gestione professionale</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        /* =========================
           THEME VARIABLES
           ========================= */

        :root{
            --bg-main: #ffffff;
            --text-main: #212529;
            --text-muted: rgba(33,37,41,.7);
            --bg-card: rgba(0,0,0,.04);
            --border-color: rgba(0,0,0,.12);
        }

        body.theme-dark{
            --bg-main: #0b1220;
            --text-main: #e9eefb;
            --text-muted: rgba(233,238,251,.75);
            --bg-card: rgba(255,255,255,.06);
            --border-color: rgba(255,255,255,.12);
        }

        /* =========================
           BASE
           ========================= */

        body{
            min-height: 100vh;
            background:
                radial-gradient(1200px 600px at 10% 10%, rgba(13,110,253,.20), transparent 55%),
                radial-gradient(1000px 600px at 90% 20%, rgba(32,201,151,.18), transparent 55%),
                var(--bg-main);
            color: var(--text-main);
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        }

        /* =========================
           NAVBAR – CLEAN & INTEGRATED
           ========================= */

        .navbar{
            background: transparent;
            backdrop-filter: blur(6px);
        }

        /* Brand & links */
        .navbar .navbar-brand,
        .navbar .nav-link{
            color: var(--text-main) !important;
        }

        /* Hover */
        .navbar .navbar-brand:hover,
        .navbar .nav-link:hover{
            color: #0d6efd !important;
        }

        /* Toggle tema */
        #themeToggle{
            color: var(--text-main) !important;
            border-color: var(--border-color) !important;
        }

        /* Fix Bootstrap outline-light */
        .btn-outline-light{
            color: var(--text-main) !important;
            border-color: var(--border-color) !important;
        }

        .btn-outline-light:hover{
            background: var(--bg-card) !important;
        }

        /* Brand dot */
        .brand-dot{
            width: 10px;
            height: 10px;
            border-radius: 999px;
            background: linear-gradient(135deg,#0d6efd,#20c997);
            display: inline-block;
            margin-right: .5rem;
        }

        /* =========================
           HERO
           ========================= */

        .hero{
            padding: 6rem 1rem 4rem;
        }

        .hero h1{
            font-weight: 700;
            letter-spacing: .3px;
        }

        .hero p{
            color: var(--text-muted);
            max-width: 520px;
        }

        /* =========================
           GLASS CARD
           ========================= */

        .glass-card{
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 18px;
            backdrop-filter: blur(10px);
            box-shadow: 0 14px 40px rgba(0,0,0,.4);
        }

        .feature-icon{
            font-size: 1.4rem;
        }

        /* =========================
           FOOTER
           ========================= */

        footer{
            border-top: none; /* footer più leggero */
            color: var(--text-muted);
        }
    </style>
</head>

<body class="theme-dark">

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg px-3 px-lg-5">
    <a class="navbar-brand fw-bold" href="#">
        <span class="brand-dot"></span>Fisio e Sport
    </a>

    <div class="ms-auto d-flex gap-2 align-items-center">

        <!-- THEME TOGGLE -->
        <button class="btn btn-outline-secondary btn-sm"
                id="themeToggle"
                onclick="toggleTheme()"
                title="Cambia tema">
            🌙
        </button>

        <a href="<%= request.getContextPath() %>/login.jsp" class="btn btn-outline-light btn-sm">
            Login
        </a>
        <a href="<%= request.getContextPath() %>/register.jsp" class="btn btn-primary btn-sm">
            Registrati
        </a>
    </div>
</nav>

<!-- HERO -->
<section class="hero text-center text-lg-start">
    <div class="container">
        <div class="row align-items-center g-4">
            <div class="col-lg-6">
                <h1 class="display-5 mb-3">
                    Gestisci il tuo studio<br>
                    <span class="text-primary">in modo semplice e professionale</span>
                </h1>

                <p class="mb-4">
                    <strong>Fisio e Sport</strong> è la piattaforma pensata per fisioterapisti e professionisti
                    dello sport che vogliono organizzare pazienti, appuntamenti e trattamenti
                    in un’unica dashboard moderna.
                </p>

                <div class="d-flex gap-3 justify-content-center justify-content-lg-start">
                    <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-primary btn-lg">
                        Accedi alla dashboard
                    </a>
                    <a href="<%= request.getContextPath() %>/register.jsp" class="btn btn-outline-light btn-lg">
                        Inizia ora
                    </a>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="glass-card p-4">
                    <h5 class="mb-3">Cosa puoi fare</h5>
                    <ul class="list-unstyled mb-0">
                        <li class="mb-2">📅 Pianificare appuntamenti e sedute</li>
                        <li class="mb-2">👤 Gestire la rubrica pazienti</li>
                        <li class="mb-2">🧾 Tenere traccia dello storico trattamenti</li>
                        <li class="mb-2">📊 Avere una visione chiara del tuo lavoro</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- FEATURES -->
<section class="container my-5">
    <div class="row g-4">
        <div class="col-md-4">
            <div class="glass-card p-4 h-100">
                <div class="feature-icon mb-2">⚡</div>
                <h5>Veloce</h5>
                <p class="small text-muted">
                    Interfaccia reattiva e progettata per ridurre al minimo i click inutili.
                </p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4 h-100">
                <div class="feature-icon mb-2">🔒</div>
                <h5>Sicuro</h5>
                <p class="small text-muted">
                    Accessi controllati e gestione separata dei dati sensibili.
                </p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="glass-card p-4 h-100">
                <div class="feature-icon mb-2">🧠</div>
                <h5>Organizzato</h5>
                <p class="small text-muted">
                    Tutto ciò che serve per il tuo studio, in un’unica piattaforma.
                </p>
            </div>
        </div>
    </div>
</section>

<!-- FOOTER -->
<footer class="py-4 text-center">
    <div class="container small">
        © <%= java.time.Year.now() %> Fisio e Sport — Gestionale per fisioterapia e sport
    </div>
</footer>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function applyTheme(theme) {
        document.body.classList.remove('theme-dark', 'theme-light');
        document.body.classList.add(theme);
        localStorage.setItem('theme', theme);

        const toggleBtn = document.getElementById('themeToggle');
        if (toggleBtn) {
            toggleBtn.textContent = theme === 'theme-dark' ? '☀️' : '🌙';
        }
    }

    function toggleTheme() {
        const isDark = document.body.classList.contains('theme-dark');
        applyTheme(isDark ? 'theme-light' : 'theme-dark');
    }

    document.addEventListener('DOMContentLoaded', () => {
        const savedTheme = localStorage.getItem('theme');

        // default esplicito
        if (savedTheme === 'theme-light' || savedTheme === 'theme-dark') {
            applyTheme(savedTheme);
        } else {
            applyTheme('theme-dark');
        }
    });
</script>

</body>
</html>
