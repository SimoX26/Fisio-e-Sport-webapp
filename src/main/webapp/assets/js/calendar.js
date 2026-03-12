document.addEventListener('DOMContentLoaded', () => {
    const contextPath = document.body.dataset.contextPath || '';
    const calendarEl = document.getElementById('calendar');
    const saveButton = document.getElementById('saveAppointmentBtn');

    if (!calendarEl || !saveButton || typeof FullCalendar === 'undefined') {
        return;
    }

    const calendar = new FullCalendar.Calendar(calendarEl, {
        locale: 'it',
        height: 'auto',
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'timeGridDay,timeGridWeek,dayGridMonth'
        },
        initialView: 'timeGridWeek',
        slotDuration: '00:30:00',
        nowIndicator: true,
        slotMinTime: '08:00:00',
        slotMaxTime: '21:00:00',
        scrollTime: '08:00:00',
        selectable: true,
        editable: false,
        events: {
            url: contextPath + '/calendar',
            method: 'GET',
            extraParams: { events: 'true' }
        },
        select(info) {
            document.getElementById('start').value = info.startStr.slice(0, 16);
            document.getElementById('end').value = info.endStr.slice(0, 16);
            new bootstrap.Modal(document.getElementById('appointmentModal')).show();
        },
        eventClick(info) {
            info.jsEvent.preventDefault();
            const event = info.event;

            document.getElementById('modalTitle').innerText = event.title || '';
            document.getElementById('modalPatient').innerText = event.extendedProps.patient || '-';
            document.getElementById('modalType').innerText = event.extendedProps.type || '-';
            document.getElementById('modalNotes').innerText = event.extendedProps.notes || 'Nessuna nota';

            const start = event.start.toLocaleString('it-IT');
            const end = event.end ? event.end.toLocaleString('it-IT') : '';
            document.getElementById('modalTime').innerText = end ? `${start} – ${end}` : start;

            new bootstrap.Modal(document.getElementById('eventModal')).show();
        }
    });

    calendar.render();

    saveButton.addEventListener('click', () => {
        const therapistId = document.getElementById('therapistId')?.value || '';

        if (!therapistId) {
            alert("Seleziona un terapista prima di salvare l'appuntamento.");
            return;
        }

        const data = new URLSearchParams();
        data.append('action', 'create');
        data.append('patientId', document.getElementById('patientId').value);
        data.append('therapistId', therapistId);
        data.append('start', document.getElementById('start').value);
        data.append('end', document.getElementById('end').value);

        fetch(contextPath + '/calendar', {
            method: 'POST',
            body: data
        })
            .then((res) => {
                if (!res.ok) throw new Error('Errore nella creazione appuntamento');
                return res;
            })
            .then(() => {
                bootstrap.Modal.getInstance(document.getElementById('appointmentModal')).hide();
                calendar.refetchEvents();
            })
            .catch((err) => alert(err.message));
    });
});
