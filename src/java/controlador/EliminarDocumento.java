package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.Documento;
import modelo.DocumentoDAO;
import modelo.UsuarioDAO;
import modelo.Util;

/** Eliminacion de un documento: dueño o administrador. */
@WebServlet(name = "EliminarDocumento", urlPatterns = {"/EliminarDocumento"})
public class EliminarDocumento extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Documentos.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect("Documentos.jsp?msg=error");
            return;
        }

        Documento d = new DocumentoDAO().buscar(id);
        String idSesion = (String) request.getSession().getAttribute("idUsuario");
        String actor = String.valueOf(request.getSession().getAttribute("nUsuario"));

        if (d == null) {
            response.sendRedirect("Documentos.jsp?msg=error");
            return;
        }
        boolean admin = new UsuarioDAO().esAdministrador(idSesion);
        if (!admin && !d.getIdentificacion().equals(idSesion)) {
            AuditoriaDAO.registrar(actor, "ACCESO_DENEGADO",
                    "Intento de eliminar el documento " + id + " de otro usuario", Util.ip(request));
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No tienes acceso a este documento.");
            return;
        }

        if (new DocumentoDAO().eliminar(id) > 0) {
            AuditoriaDAO.registrar(actor, "DOCUMENTO_ELIMINADO",
                    "Archivo \"" + d.getNombreOriginal() + "\" (id=" + id + ")", Util.ip(request));
            response.sendRedirect("Documentos.jsp?msg=eliminado");
        } else {
            response.sendRedirect("Documentos.jsp?msg=error");
        }
    }
}
