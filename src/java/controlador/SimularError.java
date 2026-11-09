package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.Util;

/**
 * Solo para pruebas: provoca una excepcion controlada para comprobar que el
 * registro de errores (novamed-error.log) y la pagina de error funcionan.
 * La ruta esta restringida a administradores por FiltroSesion.
 */
@WebServlet(name = "SimularError", urlPatterns = {"/SimularError"})
public class SimularError extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String actor = (String) request.getSession().getAttribute("nUsuario");
        AuditoriaDAO.registrar(actor, "PRUEBA_ERROR", "El administrador solicito una prueba de error",
                Util.ip(request));
        throw new RuntimeException("Error de prueba solicitado desde Configuracion por " + actor);
    }
}
