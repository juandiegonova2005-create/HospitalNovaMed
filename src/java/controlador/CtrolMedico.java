package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Medico;
import modelo.MedicoDAO;

public class CtrolMedico extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        MedicoDAO dao = new MedicoDAO();

        if ("agregar".equals(accion)) {
            Medico m = new Medico();
            m.setDocumento(request.getParameter("cdocumento"));
            m.setNombre(request.getParameter("cnombre"));
            m.setApellido(request.getParameter("capellido"));
            m.setTelefono(request.getParameter("ctelefono"));
            m.setCorreo(request.getParameter("ccorreo"));
            m.setId_especialidad(parseEntero(request.getParameter("cid_especialidad")));
            m.setEstado(request.getParameter("cestado"));
            int status = dao.agregarMedico(m);
            if (status > 0) {
                response.sendRedirect("listaMedicos.jsp");
            } else {
                request.setAttribute("error", "No se pudo registrar el médico.");
                request.getRequestDispatcher("listaMedicos.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Medico m = new Medico();
            m.setId_medico(Integer.parseInt(request.getParameter("cid_medico")));
            m.setDocumento(request.getParameter("cdocumento"));
            m.setNombre(request.getParameter("cnombre"));
            m.setApellido(request.getParameter("capellido"));
            m.setTelefono(request.getParameter("ctelefono"));
            m.setCorreo(request.getParameter("ccorreo"));
            m.setId_especialidad(parseEntero(request.getParameter("cid_especialidad")));
            m.setEstado(request.getParameter("cestado"));
            int status = dao.actualizarMedico(m);
            if (status > 0) {
                response.sendRedirect("listaMedicos.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el médico.");
                request.getRequestDispatcher("listaMedicos.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarMedico(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaMedicos.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar el médico.");
                request.getRequestDispatcher("listaMedicos.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaMedicos.jsp");
        }
    }

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
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
