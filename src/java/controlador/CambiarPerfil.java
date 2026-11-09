package controlador;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.AuditoriaDAO;
import modelo.PerfilDAO;
import modelo.UsuarioDAO;
import modelo.Util;

/**
 * Asigna el perfil principal y los perfiles adicionales de un usuario.
 * Solo por POST y solo administradores (lo exige el filtro).
 */
public class CambiarPerfil extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("listaUsuarios.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String identificacion = request.getParameter("identificacion");
        String nuevoPerfil = request.getParameter("nuevo_perfil");

        if (identificacion == null || nuevoPerfil == null
                || identificacion.isEmpty() || nuevoPerfil.isEmpty()) {
            response.sendRedirect("listaUsuarios.jsp");
            return;
        }

        try {
            int idPerfil = Integer.parseInt(nuevoPerfil);
            PerfilDAO pdao = new PerfilDAO();
            UsuarioDAO udao = new UsuarioDAO();

            if (pdao.listadoPerfil_Id(idPerfil) == null) {
                response.sendRedirect("CambiarPerfil.jsp?id=" + identificacion + "&msg=error");
                return;
            }

            // Perfiles adicionales (checkboxes); se descartan repetidos, el principal y los inexistentes
            List<Integer> extras = new ArrayList<>();
            String[] marcados = request.getParameterValues("extras");
            if (marcados != null) {
                for (String m : marcados) {
                    try {
                        int idExtra = Integer.parseInt(m);
                        if (idExtra != idPerfil && !extras.contains(idExtra)
                                && pdao.listadoPerfil_Id(idExtra) != null) {
                            extras.add(idExtra);
                        }
                    } catch (NumberFormatException ignorar) {
                    }
                }
            }

            int status = udao.actualizarPerfil(identificacion, idPerfil);
            boolean okExtras = udao.guardarPerfilesAdicionales(identificacion, extras);

            if (status > 0 && okExtras) {
                String actor = (String) request.getSession().getAttribute("nUsuario");
                AuditoriaDAO.registrar(actor, "PERFIL_ASIGNADO",
                        "Usuario id=" + identificacion + ": perfil principal=" + idPerfil
                        + ", perfiles adicionales=" + extras, Util.ip(request));
                response.sendRedirect("CambiarPerfil.jsp?id=" + identificacion + "&msg=ok");
            } else {
                response.sendRedirect("CambiarPerfil.jsp?id=" + identificacion + "&msg=error");
            }

        } catch (NumberFormatException e) {
            modelo.Log.error("ERROR CambiarPerfil: " + e.getMessage(), e);
            response.sendRedirect("listaUsuarios.jsp");
        }
    }
}
