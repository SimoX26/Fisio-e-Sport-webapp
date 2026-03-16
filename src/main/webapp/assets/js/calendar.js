document.addEventListener('DOMContentLoaded', () => {
    const DEFAULT_APPOINTMENT_DURATION_MINUTES = 60;

    function toLocalDateTimeInputValue(date) {
        const pad = (n) => String(n).padStart(2, '0');
        return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
    }

    function addMinutes(date, minutes) {
        return new Date(date.getTime() + minutes * 60 * 1000);
    }

    function ceilToHour(date) {
        const rounded = new Date(date);
        const minutes = rounded.getMinutes();
        const seconds = rounded.getSeconds();
        const ms = rounded.getMilliseconds();

        if (minutes !== 0 || seconds !== 0 || ms !== 0) {
            rounded.setHours(rounded.getHours() + 1);
        }

        rounded.setMinutes(0, 0, 0);
        return rounded;
    }

    const contextPath = document.body.dataset.contextPath || '';
    const calendarEl = document.getElementById('calendar');
    const saveButton = document.getElementById('saveAppointmentBtn');
    const openModalButton = document.getElementById('openAppointmentModalBtn');
    const appointmentModalEl = document.getElementById('appointmentModal');
    const startInput = document.getElementById('start');
    const endInput = document.getElementById('end');
    const notesInput = document.getElementById('notes');

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
        slotDuration: '01:00:00',
        snapDuration: '01:00:00',
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
            const startDate = ceilToHour(new Date(info.start));
            const defaultEndDate = addMinutes(startDate, DEFAULT_APPOINTMENT_DURATION_MINUTES);

            document.getElementById('patientName').value = '';
            startInput.value = toLocalDateTimeInputValue(startDate);
            endInput.value = toLocalDateTimeInputValue(defaultEndDate);
            if (notesInput) {
                notesInput.value = '';
            }
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
            const rounded = ceilToHour(now);
            const end = addMinutes(rounded, DEFAULT_APPOINTMENT_DURATION_MINUTES);

            document.getElementById('patientName').value = '';
            startInput.value = toLocalDateTimeInputValue(rounded);
            endInput.value = toLocalDateTimeInputValue(end);
            if (notesInput) {
                notesInput.value = '';
            }
            appointmentModal.show();
        });
    }

    if (startInput && endInput) {
        startInput.addEventListener('change', () => {
            if (!startInput.value) {
                return;
            }

            const normalizedStart = ceilToHour(new Date(startInput.value));
            const normalizedEnd = addMinutes(normalizedStart, DEFAULT_APPOINTMENT_DURATION_MINUTES);

            startInput.value = toLocalDateTimeInputValue(normalizedStart);
            endInput.value = toLocalDateTimeInputValue(normalizedEnd);
        });
    }

    saveButton.addEventListener('click', () => {
        const patientName = document.getElementById('patientName')?.value?.trim() || '';
        if (!patientName) {
            alert("Inserisci il nome del paziente.");
            return;
        }
        if (!startInput || !startInput.value) {
            alert("Inserisci un orario di inizio valido.");
            return;
        }

        const data = new URLSearchParams();
        data.append('action', 'create');
        data.append('patientName', patientName);
        const startDate = ceilToHour(new Date(startInput.value));
        const endDate = addMinutes(startDate, DEFAULT_APPOINTMENT_DURATION_MINUTES);
        const normalizedStart = toLocalDateTimeInputValue(startDate);
        const normalizedEnd = toLocalDateTimeInputValue(endDate);

        startInput.value = normalizedStart;
        endInput.value = normalizedEnd;

        data.append('start', normalizedStart);
        data.append('end', normalizedEnd);
        data.append('notes', notesInput ? notesInput.value.trim() : '');

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
