package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.RecuperacionDAO;
import modelo.UsuarioDAO;
import modelo.Util;

/** Paso 2 de "Olvide mi contraseña": fija la clave nueva usando el token del correo. */
@WebServlet(name = "RestablecerClave", urlPatterns = {"/RestablecerClave"})
public class RestablecerClave extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String token = request.getParameter("token");
        String clave = request.getParameter("cclave");
        String clave2 = request.getParameter("cclave2");
        String base = request.getContextPath();

        RecuperacionDAO rdao = new RecuperacionDAO();
        String id = rdao.validarToken(token);
        if (id == null) {
            String t = (token != null && token.matches("[0-9a-f]{64}")) ? token : "";
            response.sendRedirect(base + "/restablecer.jsp?token=" + t);
            return;
        }
        String errorClave = Util.validarClave(clave);
        if (errorClave != null) {
            response.sendRedirect(base + "/restablecer.jsp?token=" + token + "&err=segura");
            return;
        }
        if (clave2 == null || !clave.equals(clave2)) {
            response.sendRedirect(base + "/restablecer.jsp?token=" + token + "&err=igual");
            return;
        }

        if (new UsuarioDAO().restablecerClave(id, clave) > 0) {
            rdao.consumir(token);
            AuditoriaDAO.registrar("id=" + id, "CLAVE_RESTABLECIDA",
                    "Clave restablecida mediante enlace de recuperacion", Util.ip(request));
            response.sendRedirect(base + "/login.jsp?msg=reset");
        } else {
            response.sendRedirect(base + "/restablecer.jsp?token=" + token + "&err=bd");
        }
    }
}
