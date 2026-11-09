package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import modelo.AuditoriaDAO;
import modelo.Documento;
import modelo.DocumentoDAO;
import modelo.UsuarioDAO;
import modelo.Util;

/** Descarga controlada: solo el dueño del archivo o un administrador. */
@WebServlet(name = "DescargarDocumento", urlPatterns = {"/DescargarDocumento"})
public class DescargarDocumento extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Documento d = new DocumentoDAO().buscar(id);
        if (d == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String idSesion = (String) request.getSession().getAttribute("idUsuario");
        String actor = String.valueOf(request.getSession().getAttribute("nUsuario"));
        boolean admin = new UsuarioDAO().esAdministrador(idSesion);
        if (!admin && !d.getIdentificacion().equals(idSesion)) {
            AuditoriaDAO.registrar(actor, "ACCESO_DENEGADO",
                    "Intento de descargar el documento " + id + " de otro usuario", Util.ip(request));
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No tienes acceso a este documento.");
            return;
        }

        File archivo = new File(DocumentoDAO.carpeta(), d.getNombreGuardado());
        if (!archivo.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "El archivo ya no está disponible.");
            return;
        }

        String nombre = d.getNombreOriginal() == null ? "documento" : d.getNombreOriginal();
        String nombreAscii = nombre.replaceAll("[^A-Za-z0-9._-]", "_");
        String encoded = URLEncoder.encode(nombre, "UTF-8").replace("+", "%20");

        response.setContentType(d.getTipo() == null ? "application/octet-stream" : d.getTipo());
        response.setContentLengthLong(archivo.length());
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + nombreAscii + "\"; filename*=UTF-8''" + encoded);
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "no-store");

        try (FileInputStream in = new FileInputStream(archivo);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int leidos;
            while ((leidos = in.read(buffer)) > 0) {
                out.write(buffer, 0, leidos);
            }
        }

        AuditoriaDAO.registrar(actor, "DOCUMENTO_DESCARGADO",
                "Archivo \"" + nombre + "\" (id=" + id + ")", Util.ip(request));
    }

    @Override
    public String getServletInfo() {
        return "Descarga de documentos";
    }
}
