package controlador;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.AuditoriaDAO;
import modelo.UsuarioDAO;
import modelo.Util;

/** Eliminacion de usuarios (el filtro restringe esta ruta a administradores). */
public class EliminarUsuario extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect("listaUsuarios.jsp");
            return;
        }

        String actor = (String) request.getSession().getAttribute("nUsuario");
        String idActor = (String) request.getSession().getAttribute("idUsuario");

        // Un administrador no puede borrar su propia cuenta
        if (idActor != null && idActor.equals(String.valueOf(id))) {
            response.sendRedirect("listaUsuarios.jsp");
            return;
        }

        UsuarioDAO udao = new UsuarioDAO();
        int estatus = udao.eliminarDatos(id);

        if (estatus > 0) {
            AuditoriaDAO.registrar(actor, "USUARIO_ELIMINADO", "Usuario id=" + id, Util.ip(request));
        }
        response.sendRedirect("listaUsuarios.jsp");
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
        return "Eliminacion de usuarios";
    }
}
