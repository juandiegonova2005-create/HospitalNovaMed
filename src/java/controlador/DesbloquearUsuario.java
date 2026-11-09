package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.UsuarioDAO;
import modelo.Util;

/**
 * Quita el bloqueo de una cuenta sin cambiar la contrasena.
 * Solo administradores (lo exige FiltroSesion). Solo por POST.
 */
@WebServlet(name = "DesbloquearUsuario", urlPatterns = {"/DesbloquearUsuario"})
public class DesbloquearUsuario extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("listaUsuarios.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String actor = (String) request.getSession().getAttribute("nUsuario");

        if (id == null || !id.matches("\\d{1,15}")) {
            response.sendRedirect("listaUsuarios.jsp?msg=id");
            return;
        }

        int filas = new UsuarioDAO().desbloquear(id);
        if (filas > 0) {
            AuditoriaDAO.registrar(actor, "CUENTA_DESBLOQUEADA",
                    "Se desbloqueo la cuenta id=" + id, Util.ip(request));
            response.sendRedirect("listaUsuarios.jsp?msg=desbloqueado");
        } else {
            response.sendRedirect("listaUsuarios.jsp?msg=error");
        }
    }

    @Override
    public String getServletInfo() {
        return "Desbloqueo de cuentas";
    }
}
