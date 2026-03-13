<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="navbar navbar-expand-lg px-3 px-lg-5 app-navbar">
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
                data-bs-target="#navbarNav"
                aria-controls="navbarNav"
                aria-expanded="false"
                aria-label="Apri menu di navigazione">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- LINKS -->
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-lg-center">

                <li class="nav-item">
                    <a class="nav-link"
                       href="<%= request.getContextPath() %>/dashboard">
                        Home
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
                    <a class="nav-link logout-link"
                       href="<%= request.getContextPath() %>/logout">
                        Logout
                    </a>
                </li>

            </ul>
        </div>

    </div>
</nav>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" defer></script>
