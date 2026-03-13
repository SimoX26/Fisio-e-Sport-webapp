<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Fisio e Sport • Centro di fisioterapia e riabilitazione</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root{
            --primary: #0d6efd;
            --secondary: #20c997;
            --bg-soft: #f3fbff;
            --text-main: #1f2d3d;
            --text-muted: #5f6f82;
            --card-border: rgba(13, 110, 253, .15);
        }

        body{
            margin: 0;
            font-family: "Segoe UI", Roboto, Arial, sans-serif;
            color: var(--text-main);
            background: #ffffff;
        }

        .landing-navbar{
            background: #ffffff;
            border-bottom: 1px solid rgba(0,0,0,.06);
        }

        .brand-dot{
            width: 10px;
            height: 10px;
            border-radius: 999px;
            display: inline-block;
            margin-right: .45rem;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
        }

        .hero{
            color: #ffffff;
            min-height: 68vh;
            display: flex;
            align-items: center;
            background:
                linear-gradient(110deg, rgba(13,110,253,.82), rgba(32,201,151,.60)),
                url('<%= request.getContextPath() %>/assets/img/hero-fisioterapia.jpg') center/cover no-repeat;
        }

        .hero-title{
            font-size: clamp(2rem, 5vw, 3.2rem);
            line-height: 1.15;
            font-weight: 700;
        }

        .hero-subtitle{
            font-size: 1.05rem;
            color: rgba(255,255,255,.95);
            max-width: 760px;
        }

        .btn-hero-primary{
            background: #ffffff;
            border: 1px solid #ffffff;
            color: var(--primary);
            font-weight: 600;
            padding: .7rem 1.1rem;
        }

        .btn-hero-primary:hover{
            color: #0a58ca;
            border-color: #ffffff;
            background: #f7faff;
        }

        .btn-hero-secondary{
            border: 1px solid rgba(255,255,255,.85);
            color: #ffffff;
            font-weight: 600;
            padding: .7rem 1.1rem;
        }

        .btn-hero-secondary:hover{
            background: rgba(255,255,255,.15);
            color: #ffffff;
        }

        .section-soft{
            background: var(--bg-soft);
        }

        .feature-card{
            background: #ffffff;
            border: 1px solid var(--card-border);
            border-radius: 14px;
            height: 100%;
        }

        .feature-title{
            color: #0a58ca;
            font-size: 1.05rem;
            font-weight: 600;
        }

        .feature-text{
            color: var(--text-muted);
            margin: 0;
        }

        footer{
            color: var(--text-muted);
        }

        @media (max-width: 767.98px){
            .hero{
                min-height: 76vh;
            }

            .hero .btn{
                width: 100%;
            }
        }
    </style>
</head>
<body>

<nav class="landing-navbar py-3">
    <div class="container d-flex justify-content-between align-items-center">
        <a href="#" class="navbar-brand m-0 fw-semibold text-dark">
            <span class="brand-dot"></span>Fisio e Sport
        </a>

        <div class="d-flex gap-2">
            <a href="<%= request.getContextPath() %>/login" class="btn btn-outline-primary btn-sm">Login</a>
            <a href="<%= request.getContextPath() %>/register" class="btn btn-primary btn-sm">Registrati</a>
        </div>
    </div>
</nav>

<header class="hero">
    <div class="container py-5">
        <h1 class="hero-title mb-3">Centro di fisioterapia e riabilitazione</h1>
        <p class="hero-subtitle mb-4">
            Supportiamo il recupero funzionale con percorsi personalizzati: valutazione clinica,
            pianificazione trattamenti e monitoraggio progressi in un flusso semplice e chiaro.
        </p>

        <div class="d-flex flex-column flex-sm-row gap-2">
            <a href="<%= request.getContextPath() %>/login" class="btn btn-hero-primary btn-lg">Accedi al gestionale</a>
            <a href="<%= request.getContextPath() %>/register" class="btn btn-hero-secondary btn-lg">Richiedi accesso</a>
        </div>
    </div>
</header>

<section class="section-soft py-5">
    <div class="container">
        <div class="row g-3">
            <div class="col-md-4">
                <div class="feature-card p-4">
                    <h3 class="feature-title mb-2">Agenda sedute</h3>
                    <p class="feature-text">Gestione appuntamenti e disponibilita terapisti con vista chiara settimanale.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card p-4">
                    <h3 class="feature-title mb-2">Schede paziente</h3>
                    <p class="feature-text">Anagrafica, stato clinico e storico sedute ordinati e consultabili rapidamente.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card p-4">
                    <h3 class="feature-title mb-2">Continuita terapeutica</h3>
                    <p class="feature-text">Tracciamento del percorso riabilitativo per seguire i progressi nel tempo.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<footer class="py-4 text-center small">
    © <%= java.time.Year.now() %> Fisio e Sport • Fisioterapia e riabilitazione
</footer>

</body>
</html>
