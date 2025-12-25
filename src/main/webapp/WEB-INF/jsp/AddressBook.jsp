<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
    <title>Address Book</title>
</head>
<body>

<h1>Patients</h1>

<c:if test="${not empty error}">
    <p style="color:red">${error}</p>
</c:if>

<form method="get">
    <input type="text" name="q" placeholder="Search patient">
    <button type="submit">Search</button>
</form>

<hr>

<table border="1">
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Phone</th>
        <th>State</th>
        <th>Actions</th>
    </tr>

    <c:forEach var="p" items="${patients}">
        <tr>
            <td>${p.id}</td>
            <td>${p.fullName}</td>
            <td>${p.email}</td>
            <td>${p.phone}</td>
            <td>${p.state}</td>
            <td>
                <form method="post">
                    <input type="hidden" name="id" value="${p.id}">
                    <button name="action" value="activate">Activate</button>
                    <button name="action" value="deactivate">Deactivate</button>
                    <button name="action" value="archive">Archive</button>
                </form>
            </td>
        </tr>
    </c:forEach>
</table>

<hr>

<h2>New Patient</h2>

<form method="post">
    <input type="hidden" name="action" value="create">
    <input name="id" placeholder="ID">
    <input name="firstName" placeholder="First name">
    <input name="lastName" placeholder="Last name">
    <input name="email" placeholder="Email">
    <input name="phone" placeholder="Phone">
    <button type="submit">Add</button>
</form>

</body>
</html>
