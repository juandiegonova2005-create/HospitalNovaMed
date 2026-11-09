package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.Usuario;
import modelo.UsuarioDAO;
import modelo.Util;
import org.mindrot.jbcrypt.BCrypt;

/** Autoservicio: el usuario actualiza SU correo y/o SU contraseña (exige la clave actual). */
@WebServlet(name = "ActualizarMiPerfil", urlPatterns = {"/ActualizarMiPerfil"})
public class ActualizarMiPerfil extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("MiPerfil.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession ses = request.getSession(false);
        String id = (ses == null) ? null : (String) ses.getAttribute("idUsuario");
        String nUsuario = (ses == null) ? null : (String) ses.getAttribute("nUsuario");
        if (id == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String actual = request.getParameter("cclave_actual");
        String email = Util.normalizarEmail(request.getParameter("cmail"));
        String nueva = request.getParameter("cclave_nueva");
        String nueva2 = request.getParameter("cclave_nueva2");

        UsuarioDAO udao = new UsuarioDAO();
        Usuario u = udao.listadoDatos_Id(Integer.parseInt(id));
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 1) Siempre se exige la clave actual (con compatibilidad para hashes antiguos)
        boolean claveOk = false;
        String guardada = u.getClave();
        if (actual != null && guardada != null) {
            if (guardada.startsWith("$2")) {
                try {
                    claveOk = BCrypt.checkpw(actual, guardada);
                } catch (IllegalArgumentException e) {
                    claveOk = false;
                }
            } else {
                // Registro antiguo en texto plano: se acepta y se migra al guardar
                claveOk = guardada.equals(actual);
                if (claveOk && (nueva == null || nueva.isEmpty())) {
                    nueva = actual;
                    nueva2 = actual;
                }
            }
        }
        if (!claveOk) {
            AuditoriaDAO.registrar(nUsuario, "PERFIL_CLAVE_ACTUAL_INCORRECTA",
                    "Intento de cambio de datos propios con clave actual incorrecta", Util.ip(request));
            response.sendRedirect("MiPerfil.jsp?msg=clave_actual");
            return;
        }

        // 2) Correo (solo si cambio)
        String emailNuevo = null;
        if (email != null && !email.trim().equalsIgnoreCase(u.getEmail() == null ? "" : u.getEmail())) {
            if (!Util.emailValido(email.trim())) {
                response.sendRedirect("MiPerfil.jsp?msg=email_invalido");
                return;
            }
            if (udao.existeEmail(email.trim(), id)) {
                response.sendRedirect("MiPerfil.jsp?msg=email_duplicado");
                return;
            }
            emailNuevo = email.trim();
        }

        // 3) Clave nueva (solo si la escribio)
        String claveNueva = null;
        if (nueva != null && !nueva.isEmpty()) {
            String errorClave = Util.validarClave(nueva);
            if (errorClave != null) {
                response.sendRedirect("MiPerfil.jsp?msg=clave_debil&detalle="
                        + java.net.URLEncoder.encode(errorClave, "UTF-8"));
                return;
            }
            if (!nueva.equals(nueva2)) {
                response.sendRedirect("MiPerfil.jsp?msg=clave_distinta");
                return;
            }
            claveNueva = nueva;
        }

        if (emailNuevo == null && claveNueva == null) {
            response.sendRedirect("MiPerfil.jsp?msg=sin_cambios");
            return;
        }

        if (udao.actualizarCredenciales(id, emailNuevo, claveNueva) > 0) {
            AuditoriaDAO.registrar(nUsuario, "PERFIL_PROPIO_ACTUALIZADO",
                    (emailNuevo != null ? "correo cambiado a " + emailNuevo : "")
                    + (emailNuevo != null && claveNueva != null ? "; " : "")
                    + (claveNueva != null ? "clave cambiada" : ""), Util.ip(request));
            response.sendRedirect("MiPerfil.jsp?msg=ok");
        } else {
            response.sendRedirect("MiPerfil.jsp?msg=error");
        }
    }
}
