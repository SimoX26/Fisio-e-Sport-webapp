package it.SimoSW.bootstrap;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class ApplicationContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        ApplicationInitializer initializer = new ApplicationInitializer();
        initializer.init();

        ServletContext context = sce.getServletContext();
        context.setAttribute("appInitializer", initializer);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Chiusura eventuale delle connessioni al DB
    }
}

