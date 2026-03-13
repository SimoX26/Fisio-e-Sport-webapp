document.addEventListener('DOMContentLoaded', () => {
    function toLocalDateTimeInputValue(date) {
        const pad = (n) => String(n).padStart(2, '0');
        return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
    }

    const contextPath = document.body.dataset.contextPath || '';
    const calendarEl = document.getElementById('calendar');
    const saveButton = document.getElementById('saveAppointmentBtn');
    const openModalButton = document.getElementById('openAppointmentModalBtn');
    const appointmentModalEl = document.getElementById('appointmentModal');

    if (!calendarEl || !saveButton || !appointmentModalEl || typeof FullCalendar === 'undefined') {
        return;
    }

    const appointmentModal = new bootstrap.Modal(appointmentModalEl);

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
            document.getElementById('patientName').value = '';
            document.getElementById('start').value = info.startStr.slice(0, 16);
            document.getElementById('end').value = info.endStr.slice(0, 16);
            appointmentModal.show();
        },
        eventClick(info) {
            info.jsEvent.preventDefault();
            const event = info.event;

            document.getElementById('modalTitle').innerText = event.title || '';
            document.getElementById('modalPatient').innerText =
                event.extendedProps.patient || event.extendedProps.patientId || '-';
            document.getElementById('modalType').innerText =
                event.extendedProps.type || event.extendedProps.state || '-';
            document.getElementById('modalNotes').innerText = event.extendedProps.notes || 'Nessuna nota';

            const start = event.start.toLocaleString('it-IT');
            const end = event.end ? event.end.toLocaleString('it-IT') : '';
            document.getElementById('modalTime').innerText = end ? `${start} – ${end}` : start;

            new bootstrap.Modal(document.getElementById('eventModal')).show();
        }
    });

    calendar.render();

    if (openModalButton) {
        openModalButton.addEventListener('click', () => {
            const now = new Date();
            const rounded = new Date(now);
            rounded.setMinutes(Math.ceil(now.getMinutes() / 30) * 30, 0, 0);
            const end = new Date(rounded.getTime() + 30 * 60 * 1000);

            document.getElementById('patientName').value = '';
            document.getElementById('start').value = toLocalDateTimeInputValue(rounded);
            document.getElementById('end').value = toLocalDateTimeInputValue(end);
            appointmentModal.show();
        });
    }

    saveButton.addEventListener('click', () => {
        const patientName = document.getElementById('patientName')?.value?.trim() || '';
        if (!patientName) {
            alert("Inserisci il nome del paziente.");
            return;
        }

        const data = new URLSearchParams();
        data.append('action', 'create');
        data.append('patientName', patientName);
        data.append('start', document.getElementById('start').value);
        data.append('end', document.getElementById('end').value);

        fetch(contextPath + '/calendar', {
            method: 'POST',
            body: data
        })
            .then((res) => {
                if (!res.ok) {
                    return res.text().then((text) => {
                        throw new Error(text || 'Errore nella creazione appuntamento');
                    });
                }
                return res.text();
            })
            .then(() => {
                appointmentModal.hide();
                calendar.refetchEvents();
            })
            .catch((err) => alert(err.message));
    });
});
