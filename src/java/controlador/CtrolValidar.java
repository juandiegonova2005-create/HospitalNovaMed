package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.ConfiguracionDAO;
import modelo.LoginDAO;
import modelo.Usuario;
import modelo.Util;

@WebServlet(name = "CtrolValidar", urlPatterns = {"/CtrolValidar"})
public class CtrolValidar extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Si alguien abre /CtrolValidar pegando la URL, se lleva al login
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");

        if (accion != null && accion.equalsIgnoreCase("Ingresar")) {
            String usu = request.getParameter("cusuario");
            String cla = request.getParameter("cclave");
            String ip = Util.ip(request);

            // 1) Validacion previa: evita consultas y simbolos raros (p. ej. 15 caracteres especiales)
            if (!Util.loginValido(usu)) {
                AuditoriaDAO.registrar(usu, "LOGIN_RECHAZADO",
                        "Identificador con formato invalido o demasiado largo", ip);
                request.setAttribute("error",
                        "Escribe un usuario o correo válido (sin espacios ni símbolos extraños).");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            if (cla == null || cla.isEmpty()) {
                request.setAttribute("error", "La contraseña es obligatoria.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            LoginDAO logindao = new LoginDAO();
            Usuario datos = logindao.Login_datos(usu, cla);

            if (datos != null && datos.getUsuario() != null) {
                // Descartar cualquier sesion previa y crear una nueva (evita fijacion de sesion)
                HttpSession anterior = request.getSession(false);
                if (anterior != null) {
                    anterior.invalidate();
                }
                HttpSession sesion_cli = request.getSession(true);
                int minutos = ConfiguracionDAO.minutosSesion();

                sesion_cli.setAttribute("nUsuario", datos.getUsuario());
                sesion_cli.setAttribute("idUsuario", datos.getIdentificacion());
                sesion_cli.setAttribute("nombre", datos.getNombre());
                sesion_cli.setAttribute("perfil", datos.getPerfil());
                // Huella del navegador que inicio sesion (la valida el filtro)
                sesion_cli.setAttribute("uaLogin", request.getHeader("User-Agent"));
                sesion_cli.setAttribute("ultimaActividad", System.currentTimeMillis());
                sesion_cli.setAttribute("sesionInicio", System.currentTimeMillis());
                sesion_cli.setMaxInactiveInterval(minutos * 60);

                AuditoriaDAO.registrar(datos.getUsuario(), "LOGIN_OK",
                        "Inicio de sesion correcto (navegador: "
                        + recortar(request.getHeader("User-Agent"), 120) + ")", ip);
                response.sendRedirect(request.getContextPath() + "/cpanel.jsp");
                return;
            }

            String mensaje;
            if (LoginDAO.BLOQUEADO.equals(logindao.getEstado())) {
                mensaje = "Cuenta bloqueada por demasiados intentos fallidos. Intenta de nuevo en "
                        + logindao.getMinutosRestantes() + " minuto(s) o restablece tu contraseña.";
                request.setAttribute("intentos", logindao.getMaxIntentos());
                request.setAttribute("maxIntentos", logindao.getMaxIntentos());
                AuditoriaDAO.registrar(usu, logindao.isBloqueoNuevo() ? "CUENTA_BLOQUEADA" : "LOGIN_BLOQUEADO",
                        logindao.isBloqueoNuevo()
                                ? "Cuenta bloqueada tras " + logindao.getMaxIntentos() + " intentos fallidos"
                                : "Intento de ingreso con la cuenta bloqueada", ip);
            } else if (LoginDAO.ERROR.equals(logindao.getEstado())) {
                mensaje = "El servicio no está disponible en este momento. Intenta más tarde.";
            } else {
                mensaje = "Usuario/correo o contraseña incorrectos.";
                if (logindao.getIntentosFallidos() > 0) {
                    request.setAttribute("intentos", logindao.getIntentosFallidos());
                    request.setAttribute("maxIntentos", logindao.getMaxIntentos());
                }
                AuditoriaDAO.registrar(usu, "LOGIN_FALLIDO", "Credenciales incorrectas", ip);
            }
            request.setAttribute("error", mensaje);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private static String recortar(String s, int max) {
        if (s == null) {
            return "?";
        }
        return s.length() > max ? s.substring(0, max) : s;
    }
}
