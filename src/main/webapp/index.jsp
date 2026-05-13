<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Fisio e Sports • Centro di fisioterapia e riabilitazione</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/assets/img/logo.png">
    <link rel="apple-touch-icon" href="<%= request.getContextPath() %>/assets/img/logo-192.png">
    <link rel="manifest" href="<%= request.getContextPath() %>/manifest.webmanifest">
    <meta name="theme-color" content="#1a73e8">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-title" content="FisioSport">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260323-1">
</head>
<body class="landing-page">

<nav class="landing-navbar py-3">
    <div class="container d-flex justify-content-between align-items-center">
        <a href="#" class="navbar-brand m-0 fw-semibold text-dark">
            <span class="landing-brand-dot"></span>Fisio e Sports
        </a>

        <div class="d-flex gap-2">
            <a href="<%= request.getContextPath() %>/login" class="btn btn-outline-primary btn-sm">Login</a>
            <a href="<%= request.getContextPath() %>/register" class="btn btn-primary btn-sm">Richiedi accesso</a>
        </div>
    </div>
</nav>

<header class="landing-hero">
    <div class="container py-5">
        <div class="landing-hero-content">
            <h1 class="landing-hero-title mb-3">Fisio e Sports: recupero, performance e continuita atletica</h1>
            <p class="landing-hero-subtitle mb-4">
                Accompagniamo atleti e persone attive dal post-infortunio al ritorno in campo:
                fisioterapia personalizzata, supporto al recupero e pianificazione degli allenamenti in sicurezza.
            </p>

            <div class="d-flex flex-column flex-sm-row gap-2">
                <a href="<%= request.getContextPath() %>/login" class="btn btn-primary section-action-btn">Accedi al gestionale</a>
                <a href="<%= request.getContextPath() %>/register" class="btn btn-outline-light section-action-btn">Richiedi accesso</a>
            </div>
        </div>
    </div>
</header>

<section class="landing-soft-section py-5">
    <div class="container">
        <div class="row g-3">
            <div class="col-md-4">
                <div class="landing-feature-card p-4">
                    <h3 class="landing-feature-title mb-2">Recupero Sportivo</h3>
                    <p class="landing-feature-text">Percorsi mirati per prevenzione infortuni, recupero funzionale e ritorno progressivo alla performance.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="landing-feature-card p-4">
                    <h3 class="landing-feature-title mb-2">Supporto agli Allenamenti</h3>
                    <p class="landing-feature-text">Integrazione tra trattamento fisioterapico e carichi di lavoro per allenarsi con continuita e controllo.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="landing-feature-card p-4">
                    <h3 class="landing-feature-title mb-2">Monitoraggio Atleta</h3>
                    <p class="landing-feature-text">Valutazioni, sedute e progressi sempre tracciati per decisioni cliniche rapide e obiettive.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<footer class="py-4 text-center small">
    © <%= java.time.Year.now() %> Fisio e Sports • Fisioterapia e riabilitazione
</footer>

<script src="<%= request.getContextPath() %>/assets/js/loading-overlay.js?v=20260513-11" defer></script>
<script>
(function () {
    const lockKey = 'lockBackLanding';
    const params = new URLSearchParams(window.location.search);

    if (params.get('lockBack') === '1') {
        sessionStorage.setItem(lockKey, '1');
        params.delete('lockBack');
        const cleanUrl = window.location.pathname
            + (params.toString() ? '?' + params.toString() : '')
            + window.location.hash;
        history.replaceState(null, '', cleanUrl);
    }

    if (sessionStorage.getItem(lockKey) !== '1') {
        return;
    }

    history.pushState(null, '', window.location.href);
    window.addEventListener('popstate', function () {
        history.pushState(null, '', window.location.href);
    });
})();
</script>

</body>
</html>
