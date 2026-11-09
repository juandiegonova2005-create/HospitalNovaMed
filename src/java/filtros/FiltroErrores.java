package filtros;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import modelo.Log;

/**
 * Captura cualquier excepcion no controlada, la registra con contexto en
 * novamed-error.log y muestra una pagina generica (sin trazas al usuario).
 */
public class FiltroErrores implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String idError = Long.toString(System.currentTimeMillis(), 36).toUpperCase();

        try {
            chain.doFilter(req, res);
        } catch (Throwable t) {
            String usuario = "?";
            HttpSession sesion = request.getSession(false);
            if (sesion != null && sesion.getAttribute("nUsuario") != null) {
                usuario = String.valueOf(sesion.getAttribute("nUsuario"));
            }
            Log.error("ERROR NO CONTROLADO id=" + idError
                    + " usuario=" + usuario
                    + " ruta=" + request.getMethod() + " " + request.getRequestURI()
                    + " ip=" + modelo.Util.ip(request), t);

            if (response.isCommitted()) {
                return;
            }
            response.reset();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("text/html;charset=UTF-8");
            request.setAttribute("errorId", idError);
            request.setAttribute("errorMensaje",
                    "Ocurrió un error inesperado. El equipo técnico ya tiene el registro.");
            try {
                request.getRequestDispatcher("/error.jsp").forward(request, response);
            } catch (Exception e) {
                Log.error("ERROR AL MOSTRAR error.jsp: " + e.getMessage(), e);
                response.getWriter().write("<h2>Error interno</h2><p>ID: " + idError + "</p>");
            }
        }
    }

    @Override
    public void destroy() {
    }
}
