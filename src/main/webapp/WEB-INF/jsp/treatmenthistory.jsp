<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
    <title>Treatment History</title>
</head>
<body>

<h1>Treatment History</h1>

<c:if test="${not empty error}">
    <p style="color:red">${error}</p>
</c:if>

<table border="1">
    <tr>
        <th>ID</th>
        <th>Appointment</th>
        <th>State</th>
        <th>Notes</th>
        <th>Actions</th>
    </tr>

    <c:forEach var="s" items="${sessions}">
        <tr>
            <td>${s.id}</td>
            <td>${s.appointmentId}</td>
            <td>${s.state}</td>
            <td>${s.notes}</td>
            <td>
                <c:if test="${s.state != 'COMPLETED'}">
                    <form method="post">
                        <input type="hidden" name="action" value="finalize"/>
                        <input type="hidden" name="sessionId" value="${s.id}"/>
                        <input type="hidden" name="patientId" value="${patientId}"/>
                        <button type="submit">Finalize</button>
                    </form>
                </c:if>
            </td>
        </tr>
    </c:forEach>
</table>

<hr>

<h2>Register New Session</h2>

<form method="post">
    <input type="hidden" name="action" value="create"/>
    <input type="hidden" name="patientId" value="${patientId}"/>

    <input name="id" placeholder="Session ID"/>
    <input name="appointmentId" placeholder="Appointment ID"/>
    <input name="therapistId" placeholder="Therapist ID"/>
    <input name="start" placeholder="Start (YYYY-MM-DDTHH:MM)"/>
    <input name="end" placeholder="End (YYYY-MM-DDTHH:MM)"/>
    <textarea name="notes" placeholder="Notes"></textarea>

    <button type="submit">Save</button>
</form>

</body>
</html>
