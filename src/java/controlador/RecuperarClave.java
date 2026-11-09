package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.Correo;
import modelo.RecuperacionDAO;
import modelo.Usuario;
import modelo.UsuarioDAO;
import modelo.Util;

/** Paso 1 de "Olvide mi contraseña": genera un enlace de un solo uso y lo envia por correo. */
@WebServlet(name = "RecuperarClave", urlPatterns = {"/RecuperarClave"})
public class RecuperarClave extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/olvide.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("cmail");

        if (Util.emailValido(email)) {
            UsuarioDAO udao = new UsuarioDAO();
            Usuario u = udao.buscarPorEmail(email);
            if (u != null) {
                String token = new RecuperacionDAO().crearToken(u.getIdentificacion());
                if (token != null) {
                    String enlace = request.getScheme() + "://" + request.getServerName()
                            + ((request.getServerPort() == 80 || request.getServerPort() == 443)
                                    ? "" : ":" + request.getServerPort())
                            + request.getContextPath() + "/restablecer.jsp?token=" + token;
                    Correo.enviar(u.getEmail(), "Restablecer contraseña - Hospital NovaMed",
                            "Hola " + u.getNombre() + ", usa este enlace (vence en "
                            + RecuperacionDAO.MINUTOS_VALIDEZ + " minutos): " + enlace);
                    AuditoriaDAO.registrar(u.getUsuario(), "RECUPERACION_SOLICITADA",
                            "Se genero enlace de restablecimiento", Util.ip(request));
                }
            }
        }

        // Respuesta identica exista o no el correo (no revela que correos estan registrados)
        response.sendRedirect(request.getContextPath() + "/olvide.jsp?enviado=1");
    }
}
