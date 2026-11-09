package controlador;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.AuditoriaDAO;
import modelo.Perfil;
import modelo.PerfilDAO;
import modelo.Usuario;
import modelo.UsuarioDAO;
import modelo.Util;

/** Edicion de usuarios por el administrador (el filtro restringe esta ruta a administradores). */
public class EditarUsuario extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String idOriginal = request.getParameter("cidd");
        String clave = request.getParameter("cclave");
        String email = Util.normalizarEmail(request.getParameter("cmail"));
        String usuario = limpiar(request.getParameter("cusuario"));
        String nombre = limpiar(request.getParameter("cnombre"));
        String apellido = limpiar(request.getParameter("capellido"));
        int idperfil;

        try {
            Integer.parseInt(idOriginal);
            idperfil = Integer.parseInt(request.getParameter("cperfil"));
        } catch (NumberFormatException e) {
            mostrarError(response, "Datos inválidos.");
            return;
        }

        UsuarioDAO udao = new UsuarioDAO();
        Usuario anterior = udao.listadoDatos_Id(Integer.parseInt(idOriginal));
        if (anterior == null) {
            mostrarError(response, "El usuario indicado no existe.");
            return;
        }

        // El perfil debe existir
        Perfil perfil = new PerfilDAO().listadoPerfil_Id(idperfil);
        if (perfil == null) {
            mostrarError(response, "El perfil indicado no existe.");
            return;
        }

        // Clave vacia = se conserva la actual. Si viene una nueva, debe cumplir los requisitos.
        boolean cambiaClave = clave != null && !clave.isEmpty();
        if (cambiaClave) {
            String errorClave = Util.validarClave(clave);
            if (errorClave != null) {
                mostrarError(response, errorClave);
                return;
            }
        }

        if (!Util.emailValido(email)) {
            mostrarError(response, "Ingresa un correo válido (máximo 60 caracteres).");
            return;
        }
        if (!Util.usuarioValido(usuario)) {
            mostrarError(response,
                    "El usuario debe tener entre 4 y 20 caracteres (letras, números, punto, guion o guion bajo).");
            return;
        }
        if (!Util.nombreValido(nombre) || !Util.nombreValido(apellido)) {
            mostrarError(response, "Nombre y apellido deben tener entre 2 y 30 letras.");
            return;
        }
        if (udao.existeEmail(email, idOriginal)) {
            mostrarError(response, "Ya existe otro usuario registrado con ese correo electrónico.");
            return;
        }
        if (udao.existeUsuario(usuario, idOriginal)) {
            mostrarError(response, "Ese nombre de usuario ya está en uso.");
            return;
        }

        Usuario a = new Usuario();
        a.setIdentificacion(idOriginal); // la identificacion original no se modifica
        a.setNombre(nombre);
        a.setApellido(apellido);
        a.setEmail(email);
        a.setUsuario(usuario);
        a.setClave(clave);
        a.setIdperfil(idperfil);
        // El formulario no trae telefono: se conserva el actual para no borrarlo
        a.setTelefono(anterior.getTelefono());

        int status = udao.actualizarDatos(a);

        if (status > 0) {
            String actor = (String) request.getSession().getAttribute("nUsuario");
            StringBuilder detalle = new StringBuilder();
            detalle.append("Usuario id=").append(idOriginal).append(" (@").append(a.getUsuario()).append(")");
            if (anterior.getEmail() != null && !anterior.getEmail().equalsIgnoreCase(a.getEmail())) {
                detalle.append(": correo ").append(anterior.getEmail()).append(" -> ").append(a.getEmail());
            }
            if (anterior.getIdperfil() != idperfil) {
                detalle.append(": perfil ").append(anterior.getIdperfil()).append(" -> ").append(idperfil);
            }
            detalle.append("; clave ").append(cambiaClave ? "CAMBIADA (cuenta desbloqueada)" : "sin cambios");
            AuditoriaDAO.registrar(actor, "USUARIO_EDITADO", detalle.toString(), Util.ip(request));
            response.sendRedirect("listaUsuarios.jsp");
        } else if (status == -2) {
            mostrarError(response, "No se pudo actualizar: el correo o el usuario ya están en uso.");
        } else {
            mostrarError(response, "No se pudo actualizar el usuario.");
        }
    }

    private static String limpiar(String s) {
        return (s == null) ? "" : s.trim();
    }

    private void mostrarError(HttpServletResponse response, String mensaje) throws IOException {
        response.getWriter().println("<p style=\"font-family:Arial\">" + Util.esc(mensaje) + "</p>"
                + "<a style=\"font-family:Arial\" href=\"javascript:history.back()\">Volver</a>");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("listaUsuarios.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Edicion de usuarios";
    }
}
