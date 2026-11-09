package controlador;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import modelo.AuditoriaDAO;
import modelo.Util;

public class CerrarSesion extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        HttpSession ses = request.getSession(false);
        if (ses != null) {
            String quien = (String) ses.getAttribute("nUsuario");
            if (quien != null) {
                AuditoriaDAO.registrar(quien, "LOGOUT", "Cierre de sesion", Util.ip(request));
            }
            ses.invalidate();
        }
        response.setHeader("Cache-Control", "no-store");
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Cierra la sesion del usuario";
    }
}
