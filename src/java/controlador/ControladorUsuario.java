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

public class ControladorUsuario extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String identificacion = limpiar(request.getParameter("cidentificacion"));
        String nombre = limpiar(request.getParameter("cnombre"));
        String apellido = limpiar(request.getParameter("capellido"));
        String email = Util.normalizarEmail(request.getParameter("cmail"));
        String telefono = limpiar(request.getParameter("ctelefono"));
        String usuario = limpiar(request.getParameter("cusuario"));
        String clave = request.getParameter("cclave");

        int idperfil;
        try {
            idperfil = Integer.parseInt(request.getParameter("cidperfil"));
        } catch (NumberFormatException e) {
            mostrarError(request, response, "Selecciona un perfil válido.");
            return;
        }

        // 1) Datos personales
        if (!Util.identificacionValida(identificacion)) {
            mostrarError(request, response, "La identificación debe tener entre 6 y 15 dígitos.");
            return;
        }
        if (!Util.nombreValido(nombre) || !Util.nombreValido(apellido)) {
            mostrarError(request, response, "Nombre y apellido deben tener entre 2 y 30 letras.");
            return;
        }
        if (!Util.emailValido(email)) {
            mostrarError(request, response, "Ingresa un correo válido (máximo 60 caracteres).");
            return;
        }
        if (!Util.telefonoValido(telefono)) {
            mostrarError(request, response, "El teléfono debe tener entre 7 y 15 dígitos.");
            return;
        }
        if (!Util.usuarioValido(usuario)) {
            mostrarError(request, response,
                    "El usuario debe tener entre 4 y 20 caracteres (letras, números, punto, guion o guion bajo).");
            return;
        }

        // 2) Regla unica de contrasena (rechaza 1 caracter, 123456789012345, etc.)
        String errorClave = Util.validarClave(clave);
        if (errorClave != null) {
            mostrarError(request, response, errorClave);
            return;
        }

        // 3) No se permite registrarse como Administrador
        PerfilDAO pdao = new PerfilDAO();
        Perfil perfil = pdao.listadoPerfil_Id(idperfil);
        if (perfil == null || "Administrador".equalsIgnoreCase(perfil.getPerfil())) {
            mostrarError(request, response, "Ese perfil no está permitido en el registro.");
            return;
        }

        UsuarioDAO udao = new UsuarioDAO();

        // 4) Correo, usuario e identificacion no pueden repetirse
        if (udao.existeEmail(email, null)) {
            mostrarError(request, response, "Ya existe un usuario registrado con ese correo electrónico.");
            return;
        }
        if (udao.existeUsuario(usuario, null)) {
            mostrarError(request, response, "Ese nombre de usuario ya está en uso.");
            return;
        }
        if (udao.existeIdentificacion(identificacion)) {
            mostrarError(request, response, "Ya existe un usuario con esa identificación.");
            return;
        }

        Usuario u = new Usuario();
        u.setIdentificacion(identificacion);
        u.setNombre(nombre);
        u.setApellido(apellido);
        u.setEmail(email);
        u.setTelefono(telefono);
        u.setUsuario(usuario);
        u.setClave(clave);
        u.setIdperfil(idperfil);

        int status = udao.agregarUsuario(u);

        if (status > 0) {
            AuditoriaDAO.registrar(usuario, "USUARIO_REGISTRADO",
                    "Autoregistro de usuario id=" + identificacion + ", perfil=" + idperfil,
                    Util.ip(request));
            request.getRequestDispatcher("mensaje.jsp").forward(request, response);
        } else if (status == -2) {
            mostrarError(request, response,
                    "No se pudo registrar: el correo, el usuario o la identificación ya existen.");
        } else {
            mostrarError(request, response, "No se pudo registrar el usuario. Intenta de nuevo.");
        }
    }

    private static String limpiar(String s) {
        return (s == null) ? "" : s.trim();
    }

    private void mostrarError(HttpServletRequest request, HttpServletResponse response, String mensaje)
            throws IOException {
        response.getWriter().println("<p style=\"font-family:Arial\">" + Util.esc(mensaje) + "</p>"
                + "<a style=\"font-family:Arial\" href=\"" + request.getContextPath()
                + "/Register.jsp\">Volver al registro</a>");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Registrar solo por POST; si abren la URL directo, se manda al formulario
        response.sendRedirect(request.getContextPath() + "/Register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Registro de usuarios";
    }
}
