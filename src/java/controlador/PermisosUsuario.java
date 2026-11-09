package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import modelo.Actividades;
import modelo.AuditoriaDAO;
import modelo.PermisosDAO;
import modelo.Usuario;
import modelo.UsuarioDAO;
import modelo.Util;

/**
 * Administracion conjunta de roles y permisos por actividad de un usuario.
 *
 * - Perfil principal + perfiles adicionales (un usuario puede tener 2 roles).
 * - Para cada actividad se puede dejar "heredar del rol", "permitir" o
 *   "denegar". La denegacion siempre gana.
 */
@WebServlet(name = "PermisosUsuario", urlPatterns = {"/PermisosUsuario"})
public class PermisosUsuario extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        response.sendRedirect("PermisosUsuario.jsp" + (id == null ? "" : "?id=" + id));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String id = request.getParameter("identificacion");
        String actor = (String) request.getSession().getAttribute("nUsuario");

        UsuarioDAO udao = new UsuarioDAO();
        Usuario u = null;
        try {
            u = udao.listadoDatos_Id(Integer.parseInt(id));
        } catch (Exception e) {
            u = null;
        }
        if (u == null) {
            response.sendRedirect("listaUsuarios.jsp?msg=error");
            return;
        }

        // 1) Perfil principal
        int principal;
        try {
            principal = Integer.parseInt(request.getParameter("id_perfil"));
        } catch (Exception e) {
            principal = u.getIdperfil();
        }

        // 2) Perfiles adicionales
        List<Integer> extras = new ArrayList<>();
        String[] marcados = request.getParameterValues("extras");
        if (marcados != null) {
            for (String m : marcados) {
                try {
                    int valor = Integer.parseInt(m);
                    if (valor != principal && !extras.contains(valor)) {
                        extras.add(valor);
                    }
                } catch (NumberFormatException ignorar) {
                }
            }
        }

        // 3) Permisos puntuales por actividad
        Map<Integer, Integer> overrides = new LinkedHashMap<>();
        for (Actividades a : PermisosDAO.listarTodas()) {
            String valor = request.getParameter("perm_" + a.getId_actividad());
            if ("1".equals(valor) || "0".equals(valor)) {
                overrides.put(a.getId_actividad(), Integer.valueOf(valor));
            }
        }

        boolean okRoles = udao.actualizarPerfil(id, principal) > 0;
        boolean okExtras = udao.guardarPerfilesAdicionales(id, extras);
        boolean okPermisos = PermisosDAO.guardarOverrides(id, overrides);

        if (okRoles && okExtras && okPermisos) {
            AuditoriaDAO.registrar(actor, "PERMISOS_ACTUALIZADOS",
                    "Usuario id=" + id + " (@" + u.getUsuario() + "): perfil principal=" + principal
                    + ", roles adicionales=" + extras + ", overrides=" + overrides,
                    Util.ip(request));
            response.sendRedirect("PermisosUsuario.jsp?id=" + id + "&msg=ok");
        } else {
            response.sendRedirect("PermisosUsuario.jsp?id=" + id + "&msg=error");
        }
    }

    @Override
    public String getServletInfo() {
        return "Permisos por usuario";
    }
}
