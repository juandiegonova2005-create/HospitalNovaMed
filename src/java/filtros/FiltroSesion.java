package filtros;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;
import modelo.AuditoriaDAO;
import modelo.ConfiguracionDAO;
import modelo.PermisosDAO;
import modelo.UsuarioDAO;
import modelo.Util;

/**
 * Control central de acceso:
 *  - exige sesion y valida la huella del navegador,
 *  - aplica el tiempo de inactividad configurable,
 *  - restringe las secciones administrativas,
 *  - comprueba los permisos por actividad (tabla usuario_actividad).
 */
public class FiltroSesion implements Filter {

    // Rutas publicas (no requieren sesion)
    private static final Set<String> PUBLICAS = Set.of(
            "/", "/index.jsp", "/login.jsp", "/Register.jsp", "/mensaje.jsp",
            "/quienesSomos.jsp", "/contactanos.jsp", "/productos.jsp",
            "/CtrolValidar", "/ControladorUsuario", "/CerrarSesion",
            "/olvide.jsp", "/RecuperarClave", "/restablecer.jsp", "/RestablecerClave",
            "/error.jsp"
    );

    // Rutas de administracion de seguridad: solo usuarios con perfil Administrador
    private static final Set<String> SOLO_ADMIN = Set.of(
            "/listaUsuarios.jsp", "/EditarUsuario.jsp", "/EditarUsuario", "/EliminarUsuario",
            "/DesbloquearUsuario", "/PermisosUsuario.jsp", "/PermisosUsuario",
            "/CambiarPerfil.jsp", "/CambiarPerfil",
            "/listaPerfiles.jsp", "/EditarPerfil.jsp", "/CtrolPerfil",
            "/listaActividades.jsp", "/EditarActividad.jsp", "/CtrolActividades",
            "/listaGesActividad.jsp", "/EditarGesActividad.jsp", "/CtrolGesActividad",
            "/listaAuditoria.jsp",
            "/Configuracion.jsp", "/Configuracion", "/SimularError"
    );

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String ruta = request.getServletPath();
        if (request.getPathInfo() != null) {
            ruta += request.getPathInfo();
        }

        if (esPublica(ruta)) {
            chain.doFilter(req, res);
            return;
        }

        if (!sesionValida(request)) {
            redirigirLogin(request, response, null);
            return;
        }

        HttpSession sesion = request.getSession(false);
        if (expiradaPorInactividad(sesion)) {
            sesion.invalidate();
            redirigirLogin(request, response, "expirada");
            return;
        }

        // Cabeceras de seguridad para contenido autenticado
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "SAMEORIGIN");
        response.setHeader("Referrer-Policy", "same-origin");
        if (request.isSecure()) {
            response.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
        }

        String id = (String) sesion.getAttribute("idUsuario");
        String quien = String.valueOf(sesion.getAttribute("nUsuario"));

        if (SOLO_ADMIN.contains(ruta) && !esAdministrador(request)) {
            AuditoriaDAO.registrar(quien, "ACCESO_DENEGADO",
                    "Intento de acceder a " + ruta + " sin ser administrador", Util.ip(request));
            error403(response, "No tienes permisos para acceder a esta sección.");
            return;
        }

        // Permisos por actividad: si el modulo esta dado de alta, se exige.
        if (id != null && !PermisosDAO.puede(id, ruta)) {
            String actividad = PermisosDAO.actividadDe(ruta);
            AuditoriaDAO.registrar(quien, "ACCESO_DENEGADO",
                    "Sin permiso para " + ruta + " (actividad " + actividad + ")", Util.ip(request));
            error403(response, "No tienes permiso para abrir este módulo. "
                    + "Solicita acceso al administrador.");
            return;
        }

        chain.doFilter(req, res);
    }

    private boolean esPublica(String ruta) {
        if (PUBLICAS.contains(ruta)) {
            return true;
        }
        String r = ruta.toLowerCase();
        return r.endsWith(".css") || r.endsWith(".js") || r.endsWith(".png")
                || r.endsWith(".jpg") || r.endsWith(".jpeg") || r.endsWith(".gif")
                || r.endsWith(".svg") || r.endsWith(".ico") || r.endsWith(".woff2");
    }

    private boolean sesionValida(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nUsuario") == null) {
            return false;
        }
        String uaGuardado = (String) sesion.getAttribute("uaLogin");
        String uaActual = request.getHeader("User-Agent");
        return uaGuardado != null && uaGuardado.equals(uaActual);
    }

    /**
     * Control de inactividad propio (independiente del session-timeout de
     * Tomcat). Se puede cambiar desde Configuracion sin reiniciar el servidor.
     */
    private boolean expiradaPorInactividad(HttpSession sesion) {
        if (sesion == null) {
            return true;
        }
        int minutos = ConfiguracionDAO.minutosSesion();
        long ahora = System.currentTimeMillis();
        Object ultima = sesion.getAttribute("ultimaActividad");
        if (ultima instanceof Long) {
            if (ahora - (Long) ultima > minutos * 60_000L) {
                return true;
            }
        }
        sesion.setAttribute("ultimaActividad", ahora);
        sesion.setMaxInactiveInterval(minutos * 60);
        return false;
    }

    // Se consulta la BD en cada peticion a rutas de admin: si le quitan el rol, el cambio es inmediato
    private boolean esAdministrador(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        if (sesion == null) {
            return false;
        }
        return new UsuarioDAO().esAdministrador((String) sesion.getAttribute("idUsuario"));
    }

    private void redirigirLogin(HttpServletRequest request, HttpServletResponse response, String msg)
            throws IOException {
        HttpSession sesion = request.getSession(false);
        if (sesion != null) {
            sesion.invalidate();
        }
        String login = request.getContextPath() + "/login.jsp"
                + (msg == null ? "" : "?msg=" + msg);
        response.setHeader("Cache-Control", "no-store");
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().write(
                "<!DOCTYPE html><html><head><meta charset=\"UTF-8\">"
                + "<meta http-equiv=\"refresh\" content=\"0;url=" + login + "\">"
                + "</head><body><script>window.top.location.replace('" + login + "');</script></body></html>");
    }

    private void error403(HttpServletResponse response, String mensaje) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.getWriter().write("<!DOCTYPE html><html><head><meta charset=\"UTF-8\">"
                + "<title>Acceso denegado</title></head><body style=\"font-family:Arial;padding:40px\">"
                + "<h2>403 - Acceso denegado</h2><p>" + Util.esc(mensaje) + "</p>"
                + "<p><a href=\"" + response.encodeURL("cpanel.jsp") + "\">Volver al panel</a></p>"
                + "</body></html>");
    }
}
