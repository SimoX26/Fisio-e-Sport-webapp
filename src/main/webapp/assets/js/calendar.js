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
    const eventModalEl = document.getElementById('eventModal');
    const confirmDeleteModalEl = document.getElementById('confirmDeleteModal');
    const startInput = document.getElementById('start');
    const endInput = document.getElementById('end');
    const notesInput = document.getElementById('notes');
    const patientNameInput = document.getElementById('patientName');
    const appointmentModalTitleEl = document.getElementById('appointmentModalTitle');
    const modalTitleEl = document.getElementById('modalTitle');
    const modalPatientEl = document.getElementById('modalPatient');
    const modalNotesEl = document.getElementById('modalNotes');
    const modalTimeEl = document.getElementById('modalTime');
    const editAppointmentBtn = document.getElementById('editAppointmentBtn');
    const deleteAppointmentBtn = document.getElementById('deleteAppointmentBtn');
    const confirmDeleteAppointmentBtn = document.getElementById('confirmDeleteAppointmentBtn');

    if (!calendarEl || !saveButton || !appointmentModalEl || typeof FullCalendar === 'undefined') {
        return;
    }

    const appointmentModal = new bootstrap.Modal(appointmentModalEl);
    const eventModal = eventModalEl ? new bootstrap.Modal(eventModalEl) : null;
    const confirmDeleteModal = confirmDeleteModalEl ? new bootstrap.Modal(confirmDeleteModalEl) : null;
    let selectedEvent = null;
    let editingAppointmentId = null;
    let currentHeightMode = 'auto';

    function applyDesktopWeekFillMode(calendarInstance) {
        const isDesktop = window.innerWidth >= 992;
        const isWeekView = calendarInstance.view && calendarInstance.view.type === 'timeGridWeek';
        const shouldFillHeight = isDesktop && isWeekView;
        const desiredHeight = shouldFillHeight ? '100%' : 'auto';

        if (desiredHeight !== currentHeightMode) {
            currentHeightMode = desiredHeight;
            calendarInstance.setOption('height', desiredHeight);
        }

        document.body.classList.toggle('calendar-week-fill', shouldFillHeight);
    }

    const calendar = new FullCalendar.Calendar(calendarEl, {
        locale: 'it',
        allDayText: 'Tutto il giorno',
        buttonText: {
            today: 'oggi',
            day: 'giorno',
            week: 'settimana',
            month: 'mese'
        },
        firstDay: 1,
        height: 'auto',
        expandRows: true,
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
        displayEventTime: true,
        eventTimeFormat: {
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        },
        eventContent(arg) {
            const timeText = arg.timeText || '';
            const title = arg.event.title || '';
            if (arg.view && arg.view.type === 'dayGridMonth') {
                return {
                    html: `
                        <span class="fc-event-time-inline">${timeText}</span>
                        <span class="fc-event-title-inline">${title}</span>
                    `
                };
            }
            return {
                html: `
                    <div class="fc-event-time-line">${timeText}</div>
                    <div class="fc-event-title-line">${title}</div>
                `
            };
        },
        eventDidMount(info) {
            info.el.style.background = '#eaf1fb';
            info.el.style.backgroundImage = 'none';
            info.el.style.border = '1px solid var(--calendar-event-border)';
            info.el.style.color = '#1f2d3d';
            info.el.style.boxShadow = 'none';
        },
        datesSet() {
            applyDesktopWeekFillMode(calendar);
        },
        events: {
            url: contextPath + '/calendar',
            method: 'GET',
            extraParams: { events: 'true' }
        },
        select(info) {
            const startDate = ceilToHour(new Date(info.start));
            const defaultEndDate = addMinutes(startDate, DEFAULT_APPOINTMENT_DURATION_MINUTES);

            editingAppointmentId = null;
            if (appointmentModalTitleEl) {
                appointmentModalTitleEl.innerText = 'Nuovo appuntamento';
            }
            if (patientNameInput) {
                patientNameInput.value = '';
                patientNameInput.readOnly = false;
            }
            startInput.value = toLocalDateTimeInputValue(startDate);
            endInput.value = toLocalDateTimeInputValue(defaultEndDate);
            if (notesInput) {
                notesInput.value = '';
                notesInput.readOnly = false;
            }
            appointmentModal.show();
        },
        eventClick(info) {
            info.jsEvent.preventDefault();
            const event = info.event;
            selectedEvent = event;

            if (modalTitleEl) {
                modalTitleEl.innerText = event.title || '';
            }
            if (modalPatientEl) {
                modalPatientEl.innerText = event.extendedProps.patient || event.extendedProps.patientId || '-';
            }
            if (modalNotesEl) {
                modalNotesEl.innerText = event.extendedProps.notes || 'Nessuna nota';
            }

            const start = event.start.toLocaleString('it-IT');
            const end = event.end ? event.end.toLocaleString('it-IT') : '';
            if (modalTimeEl) {
                modalTimeEl.innerText = end ? `${start} – ${end}` : start;
            }

            if (eventModal) {
                eventModal.show();
            }
        }
    });

    calendar.render();
    applyDesktopWeekFillMode(calendar);
    window.addEventListener('resize', () => applyDesktopWeekFillMode(calendar));

    if (openModalButton) {
        openModalButton.addEventListener('click', () => {
            const now = new Date();
            const rounded = ceilToHour(now);
            const end = addMinutes(rounded, DEFAULT_APPOINTMENT_DURATION_MINUTES);

            editingAppointmentId = null;
            if (appointmentModalTitleEl) {
                appointmentModalTitleEl.innerText = 'Nuovo appuntamento';
            }
            if (patientNameInput) {
                patientNameInput.value = '';
                patientNameInput.readOnly = false;
            }
            startInput.value = toLocalDateTimeInputValue(rounded);
            endInput.value = toLocalDateTimeInputValue(end);
            if (notesInput) {
                notesInput.value = '';
                notesInput.readOnly = false;
            }
            appointmentModal.show();
        });
    }

    if (editAppointmentBtn) {
        editAppointmentBtn.addEventListener('click', () => {
            if (!selectedEvent) {
                return;
            }

            const startDate = selectedEvent.start ? ceilToHour(new Date(selectedEvent.start)) : null;
            if (!startDate) {
                alert('Impossibile modificare questo appuntamento.');
                return;
            }
            const endDate = addMinutes(startDate, DEFAULT_APPOINTMENT_DURATION_MINUTES);

            editingAppointmentId = selectedEvent.id;
            if (appointmentModalTitleEl) {
                appointmentModalTitleEl.innerText = 'Modifica appuntamento';
            }
            if (patientNameInput) {
                patientNameInput.value = selectedEvent.extendedProps.patient || '';
                patientNameInput.readOnly = false;
            }
            if (notesInput) {
                notesInput.value = selectedEvent.extendedProps.notes || '';
                notesInput.readOnly = false;
            }

            startInput.value = toLocalDateTimeInputValue(startDate);
            endInput.value = toLocalDateTimeInputValue(endDate);
            if (eventModal) {
                eventModal.hide();
            }
            appointmentModal.show();
        });
    }

    if (deleteAppointmentBtn) {
        deleteAppointmentBtn.addEventListener('click', () => {
            if (!selectedEvent || !confirmDeleteModal) {
                return;
            }
            confirmDeleteModal.show();
        });
    }

    if (confirmDeleteAppointmentBtn) {
        confirmDeleteAppointmentBtn.addEventListener('click', () => {
            if (!selectedEvent) {
                return;
            }

            const data = new URLSearchParams();
            data.append('action', 'cancel');
            data.append('id', String(selectedEvent.id));

            fetch(contextPath + '/calendar', {
                method: 'POST',
                body: data
            })
                .then((res) => {
                    if (!res.ok) {
                        return res.text().then((text) => {
                            let message = '';
                            try {
                                const parsed = JSON.parse(text);
                                message = parsed?.error || '';
                            } catch (e) {
                                message = text || '';
                            }
                            throw new Error(message || 'Errore durante eliminazione appuntamento');
                        });
                    }
                    return res.text();
                })
                .then(() => {
                    if (confirmDeleteModal) {
                        confirmDeleteModal.hide();
                    }
                    if (eventModal) {
                        eventModal.hide();
                    }
                    selectedEvent = null;
                    calendar.refetchEvents();
                })
                .catch((err) => alert(err.message));
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
        if (!startInput || !startInput.value) {
            alert("Inserisci un orario di inizio valido.");
            return;
        }

        const data = new URLSearchParams();
        const startDate = ceilToHour(new Date(startInput.value));
        const endDate = addMinutes(startDate, DEFAULT_APPOINTMENT_DURATION_MINUTES);
        const normalizedStart = toLocalDateTimeInputValue(startDate);
        const normalizedEnd = toLocalDateTimeInputValue(endDate);

        startInput.value = normalizedStart;
        endInput.value = normalizedEnd;

        if (editingAppointmentId) {
            data.append('action', 'reschedule');
            data.append('id', String(editingAppointmentId));
        } else {
            const patientName = patientNameInput?.value?.trim() || '';
            if (!patientName) {
                alert("Inserisci il nome del paziente.");
                return;
            }
            data.append('action', 'create');
            data.append('patientName', patientName);
            data.append('notes', notesInput ? notesInput.value.trim() : '');
        }

        data.append('start', normalizedStart);
        data.append('end', normalizedEnd);

        fetch(contextPath + '/calendar', {
            method: 'POST',
            body: data
        })
            .then((res) => {
                if (!res.ok) {
                    return res.text().then((text) => {
                        let message = '';
                        try {
                            const parsed = JSON.parse(text);
                            message = parsed?.error || '';
                        } catch (e) {
                            message = text || '';
                        }
                        throw new Error(message || 'Errore nella creazione appuntamento');
                    });
                }
                return res.text();
            })
            .then(() => {
                appointmentModal.hide();
                editingAppointmentId = null;
                if (patientNameInput) {
                    patientNameInput.readOnly = false;
                }
                if (notesInput) {
                    notesInput.readOnly = false;
                }
                calendar.refetchEvents();
            })
            .catch((err) => alert(err.message));
    });
});
