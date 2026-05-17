<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Statistiche • Fisio e Sports</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/assets/img/logo.png">
    <link rel="apple-touch-icon" href="<%= request.getContextPath() %>/assets/img/logo-192.png">
    <link rel="manifest" href="<%= request.getContextPath() %>/manifest.webmanifest">
    <meta name="theme-color" content="#1a73e8">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-title" content="FisioSport">

    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css?v=20260617-1">
</head>
<body class="app-page" data-context-path="<%= request.getContextPath() %>">

<%@ include file="/WEB-INF/jsp/includes/header.jsp" %>

<div id="appNoticeContainer" class="app-notice-container" aria-live="polite" aria-atomic="true"></div>

<div class="container app-shell mt-4">
    <div class="page-header-row mb-4">
        <div>
            <h2 class="page-title mb-0">Statistiche</h2>
        </div>
        <div class="d-flex gap-2">
            <select id="kpiScopeSelect" class="form-select form-select-sm">
                <option value="me">I miei dati</option>
                <option value="global">Dati globali</option>
            </select>
            <select id="kpiMonthsSelect" class="form-select form-select-sm">
                <option value="6">Ultimi 6 mesi</option>
                <option value="12" selected>Ultimi 12 mesi</option>
                <option value="24">Ultimi 24 mesi</option>
            </select>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="glass-card section-card p-4 h-100">
                <div class="kpi-label mb-1">Trattamenti completati (<span id="kpiReferenceMonthLabel">mese corrente</span>)</div>
                <div class="kpi-value" id="kpiCompletedMonth">0</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="glass-card section-card p-4 h-100">
                <div class="kpi-label mb-1">Nuovi pazienti (<span id="kpiReferenceMonthLabel2">mese corrente</span>)</div>
                <div class="kpi-value" id="kpiNewPatientsMonth">0</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="glass-card section-card p-4 h-100">
                <div class="kpi-label mb-1">Ore prenotate (<span id="kpiReferenceMonthLabel3">mese corrente</span>)</div>
                <div class="kpi-value" id="kpiBookedHoursMonth">0</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="glass-card section-card p-4 h-100">
                <div class="kpi-label mb-1">Tasso cancellazione</div>
                <div class="kpi-value" id="kpiCancellationRate">0%</div>
            </div>
        </div>
    </div>

    <div class="glass-card section-card p-4 mb-4">
        <h5 class="mb-3">Trend ultimi mesi</h5>
        <div class="kpi-chart-wrap">
            <canvas id="kpiTrendChart"></canvas>
        </div>
    </div>

    <div class="glass-card section-card p-4">
        <h5 class="mb-3">Dettaglio mensile</h5>
        <div class="table-responsive">
            <table class="table table-borderless align-middle mb-0">
                <thead>
                <tr>
                    <th>Mese</th>
                    <th>Creati</th>
                    <th>Completati</th>
                    <th>Cancellati</th>
                    <th>Nuovi pazienti</th>
                    <th>Ore prenotate</th>
                </tr>
                </thead>
                <tbody id="kpiTableBody">
                <tr><td colspan="6" class="text-muted">Nessun dato disponibile</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    const contextPath = document.body.dataset.contextPath || '';
    const scopeSelect = document.getElementById('kpiScopeSelect');
    const monthsSelect = document.getElementById('kpiMonthsSelect');
    const tableBody = document.getElementById('kpiTableBody');
    const kpiCompletedMonth = document.getElementById('kpiCompletedMonth');
    const kpiNewPatientsMonth = document.getElementById('kpiNewPatientsMonth');
    const kpiBookedHoursMonth = document.getElementById('kpiBookedHoursMonth');
    const kpiCancellationRate = document.getElementById('kpiCancellationRate');
    const kpiReferenceMonthLabel = document.getElementById('kpiReferenceMonthLabel');
    const kpiReferenceMonthLabel2 = document.getElementById('kpiReferenceMonthLabel2');
    const kpiReferenceMonthLabel3 = document.getElementById('kpiReferenceMonthLabel3');
    const chartCanvas = document.getElementById('kpiTrendChart');
    let trendChart = null;

    function showNotice(message, variant) {
        const container = document.getElementById('appNoticeContainer');
        if (!container) return;
        const box = document.createElement('div');
        box.className = 'app-notice app-notice--' + (variant || 'info');
        box.innerHTML = '<div class="app-notice__body"></div><button type="button" class="app-notice__close" aria-label="Chiudi">&times;</button>';
        box.querySelector('.app-notice__body').textContent = message;
        box.querySelector('.app-notice__close').addEventListener('click', function () { box.remove(); });
        container.appendChild(box);
        requestAnimationFrame(function () { box.classList.add('app-notice--visible'); });
        setTimeout(function () { box.remove(); }, 4500);
    }

    function monthLabel(year, month) {
        const date = new Date(year, month - 1, 1);
        return date.toLocaleDateString('it-IT', { month: 'short', year: 'numeric' });
    }

    function monthLabelLong(year, month) {
        const date = new Date(year, month - 1, 1);
        return date.toLocaleDateString('it-IT', { month: 'long', year: 'numeric' });
    }

    function formatNumber(value) {
        return Number(value || 0).toLocaleString('it-IT');
    }

    function formatPercent(num, den) {
        if (!den) return '0%';
        return ((num / den) * 100).toFixed(1).replace('.', ',') + '%';
    }

    function formatHoursFromMinutes(minutes) {
        const value = Number(minutes || 0) / 60;
        return Math.round(value).toLocaleString('it-IT');
    }

    function updateCards(series) {
        const latest = series[0];
        if (!latest) {
            kpiCompletedMonth.textContent = '0';
            kpiNewPatientsMonth.textContent = '0';
            kpiBookedHoursMonth.textContent = '0';
            kpiCancellationRate.textContent = '0%';
            if (kpiReferenceMonthLabel) kpiReferenceMonthLabel.textContent = 'mese corrente';
            if (kpiReferenceMonthLabel2) kpiReferenceMonthLabel2.textContent = 'mese corrente';
            if (kpiReferenceMonthLabel3) kpiReferenceMonthLabel3.textContent = 'mese corrente';
            return;
        }
        const referenceMonth = monthLabelLong(latest.year, latest.month);
        if (kpiReferenceMonthLabel) kpiReferenceMonthLabel.textContent = referenceMonth;
        if (kpiReferenceMonthLabel2) kpiReferenceMonthLabel2.textContent = referenceMonth;
        if (kpiReferenceMonthLabel3) kpiReferenceMonthLabel3.textContent = referenceMonth;
        kpiCompletedMonth.textContent = formatNumber(latest.appointmentsCompleted);
        kpiNewPatientsMonth.textContent = formatNumber(latest.newPatientsMonth);
        kpiBookedHoursMonth.textContent = formatHoursFromMinutes(latest.totalBookedMinutes);
        kpiCancellationRate.textContent = formatPercent(latest.appointmentsCancelled, latest.appointmentsCreated);
    }

    function updateTable(series) {
        if (!series.length) {
            tableBody.innerHTML = '<tr><td colspan="6" class="text-muted">Nessun dato disponibile</td></tr>';
            return;
        }
        tableBody.innerHTML = series.map(function (row) {
            return '<tr>'
                + '<td>' + monthLabel(row.year, row.month) + '</td>'
                + '<td>' + formatNumber(row.appointmentsCreated) + '</td>'
                + '<td>' + formatNumber(row.appointmentsCompleted) + '</td>'
                + '<td>' + formatNumber(row.appointmentsCancelled) + '</td>'
                + '<td>' + formatNumber(row.newPatientsMonth) + '</td>'
                + '<td>' + formatHoursFromMinutes(row.totalBookedMinutes) + '</td>'
                + '</tr>';
        }).join('');
    }

    function updateChart(series) {
        const ordered = series.slice().reverse();
        const labels = ordered.map(function (r) { return monthLabel(r.year, r.month); });
        const completed = ordered.map(function (r) { return r.appointmentsCompleted || 0; });
        const cancelled = ordered.map(function (r) { return r.appointmentsCancelled || 0; });
        const newPatients = ordered.map(function (r) { return r.newPatientsMonth || 0; });

        if (trendChart) trendChart.destroy();
        trendChart = new Chart(chartCanvas, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    { label: 'Completati', data: completed, borderColor: '#1a73e8', backgroundColor: 'rgba(26,115,232,.12)', tension: .35, fill: false },
                    { label: 'Cancellati', data: cancelled, borderColor: '#d93025', backgroundColor: 'rgba(217,48,37,.12)', tension: .35, fill: false },
                    { label: 'Nuovi pazienti', data: newPatients, borderColor: '#188038', backgroundColor: 'rgba(24,128,56,.12)', tension: .35, fill: false }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'top' } },
                scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
            }
        });
    }

    async function loadKpis() {
        const scope = scopeSelect.value || 'me';
        const months = monthsSelect.value || '12';
        const url = contextPath + '/dashboard/kpi?scope=' + encodeURIComponent(scope) + '&months=' + encodeURIComponent(months);
        try {
            const response = await fetch(url, { headers: { Accept: 'application/json' } });
            if (!response.ok) throw new Error('Errore caricamento KPI');
            const payload = await response.json();
            const series = Array.isArray(payload.series) ? payload.series : [];
            updateCards(series);
            updateTable(series);
            updateChart(series);
        } catch (error) {
            updateCards([]);
            updateTable([]);
            if (trendChart) {
                trendChart.destroy();
                trendChart = null;
            }
            showNotice('Impossibile caricare i KPI in questo momento.', 'error');
        }
    }

    scopeSelect.addEventListener('change', loadKpis);
    monthsSelect.addEventListener('change', loadKpis);
    loadKpis();
});
</script>
</body>
</html>
