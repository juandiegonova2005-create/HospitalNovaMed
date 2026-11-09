package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Hospitalizacion;
import modelo.HospitalizacionDAO;

public class CtrolHospitalizacion extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        HospitalizacionDAO dao = new HospitalizacionDAO();

        try {
        if ("agregar".equals(accion)) {
            Hospitalizacion o = new Hospitalizacion();
            o.setId_paciente(Integer.parseInt(request.getParameter("cid_paciente")));
            o.setId_cama(Integer.parseInt(request.getParameter("cid_cama")));
            o.setId_medico(Integer.parseInt(request.getParameter("cid_medico")));
            o.setFecha_ingreso(request.getParameter("cfecha_ingreso"));
            o.setEstado(request.getParameter("cestado"));
            o.setMotivo(request.getParameter("cmotivo"));
            int status = dao.agregarHospitalizacion(o);
            if (status > 0) {
                response.sendRedirect("listaHospitalizaciones.jsp");
            } else {
                request.setAttribute("error", "No se pudo registrar el dato. Verifique la informacion ingresada.");
                request.getRequestDispatcher("listaHospitalizaciones.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Hospitalizacion o = new Hospitalizacion();
            o.setId_hospitalizacion(Integer.parseInt(request.getParameter("cid_hospitalizacion")));
            o.setId_paciente(Integer.parseInt(request.getParameter("cid_paciente")));
            o.setId_cama(Integer.parseInt(request.getParameter("cid_cama")));
            o.setId_medico(Integer.parseInt(request.getParameter("cid_medico")));
            o.setFecha_ingreso(request.getParameter("cfecha_ingreso"));
            o.setEstado(request.getParameter("cestado"));
            o.setMotivo(request.getParameter("cmotivo"));
            int status = dao.actualizarHospitalizacion(o);
            if (status > 0) {
                response.sendRedirect("listaHospitalizaciones.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el dato.");
                request.getRequestDispatcher("listaHospitalizaciones.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarHospitalizacion(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaHospitalizaciones.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar. Verifique que no tenga registros relacionados.");
                request.getRequestDispatcher("listaHospitalizaciones.jsp").forward(request, response);
            }
        } else if ("egresar".equals(accion)) {
            int status = dao.egresarHospitalizacion(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaHospitalizaciones.jsp");
            } else {
                request.setAttribute("error", "No se pudo registrar el egreso.");
                request.getRequestDispatcher("listaHospitalizaciones.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaHospitalizaciones.jsp");
        }
        } catch (NumberFormatException ex) {
            request.setAttribute("error", "Datos numericos invalidos.");
            request.getRequestDispatcher("listaHospitalizaciones.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
