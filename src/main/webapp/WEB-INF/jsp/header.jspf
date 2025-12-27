<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="navbar navbar-expand-lg px-3 px-lg-5"
    style="border-bottom: 1px solid var(--border-color);">
    <div class="container-fluid">

        <!-- BRAND -->
        <a class="navbar-brand fw-bold"
           href="<%= request.getContextPath() %>/index.jsp">
            <span class="brand-dot"></span>
            Fisio e Sport
        </a>

        <!-- TOGGLER -->
        <button class="navbar-toggler"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- LINKS -->
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-lg-center">

                <li class="nav-item">
                    <a class="nav-link"
                       href="<%= request.getContextPath() %>/dashboard.jsp">
                        Dashboard
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link"
                       href="<%= request.getContextPath() %>/calendar">
                        Calendario
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link"
                       href="<%= request.getContextPath() %>/address-book">
                        Rubrica
                    </a>
                </li>

                <li class="nav-item d-none d-lg-block mx-2">
                    <span class="nav-link disabled nav-separator">|</span>
                </li>

                <li class="nav-item">
                    <a class="nav-link"
                       href="<%= request.getContextPath() %>/profile.jsp">
                        Profilo
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link text-danger"
                       href="<%= request.getContextPath() %>/logout">
                        Logout
                    </a>
                </li>

            </ul>
        </div>

    </div>
</nav>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const theme = localStorage.getItem('theme') || 'theme-dark';
        document.body.classList.remove('theme-dark','theme-light');
        document.body.classList.add(theme);
    });
</script>
