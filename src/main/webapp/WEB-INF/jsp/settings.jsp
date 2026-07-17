<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Impostazioni • Fisio e Sports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/assets/img/logo.png">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260717-1">
</head>
<body class="app-page settings-page">

<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<main class="container app-shell mt-4">
    <div class="settings-hero mb-4">
        <div>
            <p class="settings-eyebrow mb-1">Sistema</p>
            <h1 class="page-title mb-2">Impostazioni</h1>
            <p class="text-muted mb-0">Gestisci il Servizio WhatsApp usato per i reminder.</p>
        </div>
    </div>

    <c:if test="${not empty success}">
        <div class="alert alert-success" role="alert">
            <c:out value="${success}" />
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-warning" role="alert">
            <c:out value="${error}" />
        </div>
    </c:if>

    <section class="glass-card section-card settings-card">
        <div class="settings-card__head">
            <div>
                <h2 class="settings-card__title mb-1">Servizio WhatsApp</h2>
                <p class="text-muted mb-0">Il calendario invia i reminder solo quando questo servizio risulta connesso.</p>
            </div>
            <c:choose>
                <c:when test="${baileysStatus.ready}">
                    <span class="settings-status settings-status--ok">Connesso</span>
                </c:when>
                <c:when test="${baileysStatus.reachable}">
                    <span class="settings-status settings-status--wait">Da autenticare</span>
                </c:when>
                <c:otherwise>
                    <span class="settings-status settings-status--off">Non attivo</span>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="settings-grid mt-4">
            <div class="settings-panel">
                <dl class="settings-details mb-4">
                    <div>
                        <dt>Stato</dt>
                        <dd><c:out value="${baileysStatus.state}" /></dd>
                    </div>
                    <div>
                        <dt>QR generato</dt>
                        <dd>#<c:out value="${baileysStatus.qrCounter}" /></dd>
                    </div>
                    <c:if test="${not empty baileysStatus.lastError}">
                        <div>
                            <dt>Messaggio</dt>
                            <dd><c:out value="${baileysStatus.lastError}" /></dd>
                        </div>
                    </c:if>
                </dl>

                <form method="post" action="<%= request.getContextPath() %>/settings" class="d-flex flex-wrap gap-2">
                    <input type="hidden" name="action" value="start-baileys">
                    <button type="submit" class="btn btn-primary">
                        Avvia Servizio WhatsApp
                    </button>
                    <a class="btn btn-outline-secondary" href="<%= request.getContextPath() %>/settings">
                        Aggiorna stato
                    </a>
                </form>
            </div>

            <div class="settings-panel settings-qr-panel">
                <c:choose>
                    <c:when test="${baileysStatus.ready}">
                        <div class="settings-ready-box">
                            <h3 class="h5 mb-2">WhatsApp collegato</h3>
                            <p class="text-muted mb-0">Puoi tornare al calendario e inviare i reminder.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <h3 class="h5 mb-3">Codice QR</h3>
                        <iframe class="settings-qr-frame"
                                src="<%= request.getContextPath() %>/settings/whatsapp-qr"
                                title="QR Servizio WhatsApp"></iframe>
                        <p class="text-muted small mt-3 mb-0">
                            Se il QR cambia durante la scansione, resta su questa pagina: il riquadro si aggiorna automaticamente.
                        </p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>
</main>

</body>
</html>
