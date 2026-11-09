package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import modelo.ArchivoSeguro;
import modelo.AuditoriaDAO;
import modelo.Documento;
import modelo.DocumentoDAO;
import modelo.Log;
import modelo.Util;

/**
 * Carga de documentos con validacion de extension y de contenido real
 * (magic bytes). Un .exe renombrado a .pdf se rechaza y queda auditado.
 */
@WebServlet(name = "SubirDocumento", urlPatterns = {"/SubirDocumento"})
@MultipartConfig(maxFileSize = 6L * 1024 * 1024, maxRequestSize = 7L * 1024 * 1024)
public class SubirDocumento extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Documentos.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String id = (String) request.getSession().getAttribute("idUsuario");
        String actor = String.valueOf(request.getSession().getAttribute("nUsuario"));
        String descripcion = request.getParameter("descripcion");
        if (descripcion != null) {
            descripcion = descripcion.trim();
            if (descripcion.length() > 250) {
                descripcion = descripcion.substring(0, 250);
            }
        }

        Part parte;
        try {
            parte = request.getPart("archivo");
        } catch (IllegalStateException e) {
            AuditoriaDAO.registrar(actor, "ARCHIVO_RECHAZADO",
                    "El archivo supera el tamano maximo permitido", Util.ip(request));
            response.sendRedirect("Documentos.jsp?msg=tamano");
            return;
        }

        if (parte == null || parte.getSize() == 0) {
            response.sendRedirect("Documentos.jsp?msg=vacio");
            return;
        }

        byte[] contenido;
        try (InputStream in = parte.getInputStream()) {
            contenido = in.readAllBytes();
        }

        String nombreOriginal = Util.nombreArchivoSeguro(parte.getSubmittedFileName());
        String extension = ArchivoSeguro.extension(nombreOriginal);
        byte[] cabecera = Arrays.copyOf(contenido, Math.min(contenido.length, 16));

        String error = ArchivoSeguro.validar(nombreOriginal, cabecera, contenido.length);
        if (error != null) {
            Log.info("ARCHIVO RECHAZADO por @" + actor + ": " + nombreOriginal + " (" + error + ")");
            AuditoriaDAO.registrar(actor, "ARCHIVO_RECHAZADO",
                    "Archivo \"" + nombreOriginal + "\" rechazado: " + error, Util.ip(request));
            response.sendRedirect("Documentos.jsp?msg=invalido&detalle="
                    + java.net.URLEncoder.encode(error, "UTF-8"));
            return;
        }

        Documento d = new Documento();
        d.setIdentificacion(id);
        d.setNombreOriginal(nombreOriginal);
        d.setNombreGuardado(DocumentoDAO.nuevoNombreGuardado(extension));
        d.setTipo(ArchivoSeguro.mime(extension));
        d.setTamano(contenido.length);
        d.setDescripcion(descripcion);

        int nuevoId = new DocumentoDAO().guardar(d, new ByteArrayInputStream(contenido));
        if (nuevoId > 0) {
            AuditoriaDAO.registrar(actor, "DOCUMENTO_SUBIDO",
                    "Archivo \"" + nombreOriginal + "\" (" + contenido.length + " bytes, "
                    + d.getTipo() + ")", Util.ip(request));
            response.sendRedirect("Documentos.jsp?msg=ok");
        } else {
            response.sendRedirect("Documentos.jsp?msg=error");
        }
    }

    @Override
    public String getServletInfo() {
        return "Carga de documentos";
    }
}
