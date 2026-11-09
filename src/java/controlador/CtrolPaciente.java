package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import modelo.Paciente;
import modelo.PacienteDAO;

/**
 * Controlador del modulo de Pacientes.
 * Acciones soportadas: agregar, editar, eliminar, buscar.
 */
public class CtrolPaciente extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        PacienteDAO dao = new PacienteDAO();

        if ("agregar".equals(accion)) {

            Paciente p = new Paciente();
            p.setDocumento(request.getParameter("cdocumento"));
            p.setNombre(request.getParameter("cnombre"));
            p.setApellido(request.getParameter("capellido"));
            p.setFecha_nacimiento(parseFecha(request.getParameter("cfecha_nacimiento")));
            p.setTelefono(request.getParameter("ctelefono"));
            p.setDireccion(request.getParameter("cdireccion"));
            p.setCorreo(request.getParameter("ccorreo"));
            p.setEstado(request.getParameter("cestado"));
            p.setId_cama(parseEntero(request.getParameter("cid_cama")));

            int status = dao.agregarPaciente(p);
            if (status > 0) {
                response.sendRedirect("listaPacientes.jsp");
            } else {
                request.setAttribute("error", "No se pudo registrar el paciente.");
                request.getRequestDispatcher("listaPacientes.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {

            Paciente p = new Paciente();
            p.setId_paciente(Integer.parseInt(request.getParameter("cid_paciente")));
            p.setDocumento(request.getParameter("cdocumento"));
            p.setNombre(request.getParameter("cnombre"));
            p.setApellido(request.getParameter("capellido"));
            p.setFecha_nacimiento(parseFecha(request.getParameter("cfecha_nacimiento")));
            p.setTelefono(request.getParameter("ctelefono"));
            p.setDireccion(request.getParameter("cdireccion"));
            p.setCorreo(request.getParameter("ccorreo"));
            p.setEstado(request.getParameter("cestado"));
            p.setId_cama(parseEntero(request.getParameter("cid_cama")));

            int status = dao.actualizarPaciente(p);
            if (status > 0) {
                response.sendRedirect("listaPacientes.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el paciente.");
                request.getRequestDispatcher("listaPacientes.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {

            int status = dao.eliminarPaciente(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaPacientes.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar el paciente.");
                request.getRequestDispatcher("listaPacientes.jsp").forward(request, response);
            }

        } else if ("buscar".equals(accion)) {

            String texto = request.getParameter("texto");
            List<Paciente> lista = dao.buscarPacientes(texto == null ? "" : texto);
            request.setAttribute("pacientes", lista);
            request.getRequestDispatcher("listaPacientes.jsp").forward(request, response);

        } else {
            response.sendRedirect("listaPacientes.jsp");
        }
    }

    /** Convierte "yyyy-MM-dd" (input type=date) a java.sql.Date, o null si viene vacio. */
    private Date parseFecha(String valor) {
        if (valor == null || valor.trim().isEmpty()) {
            return null;
        }
        try {
            return Date.valueOf(valor);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    /** Convierte un texto a Integer, o null si viene vacio o no es numerico. */
    private Integer parseEntero(String valor) {
        if (valor == null || valor.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(valor.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Controlador CRUD de Pacientes";
    }
}
