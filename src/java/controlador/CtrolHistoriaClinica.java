package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.HistoriaClinica;
import modelo.HistoriaClinicaDAO;

public class CtrolHistoriaClinica extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        HistoriaClinicaDAO dao = new HistoriaClinicaDAO();

        try {
        if ("agregar".equals(accion)) {
            HistoriaClinica o = new HistoriaClinica();
            o.setId_paciente(Integer.parseInt(request.getParameter("cid_paciente")));
            o.setId_medico(Integer.parseInt(request.getParameter("cid_medico")));
            o.setFecha(request.getParameter("cfecha"));
            o.setAntecedentes(request.getParameter("cantecedentes"));
            o.setMotivo(request.getParameter("cmotivo"));
            int status = dao.agregarHistoriaClinica(o);
            if (status > 0) {
                response.sendRedirect("listaHistoriasClinicas.jsp");
            } else {
                request.setAttribute("error", "No se pudo registrar el dato. Verifique la informacion ingresada.");
                request.getRequestDispatcher("listaHistoriasClinicas.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            HistoriaClinica o = new HistoriaClinica();
            o.setId_historia(Integer.parseInt(request.getParameter("cid_historia")));
            o.setId_paciente(Integer.parseInt(request.getParameter("cid_paciente")));
            o.setId_medico(Integer.parseInt(request.getParameter("cid_medico")));
            o.setFecha(request.getParameter("cfecha"));
            o.setAntecedentes(request.getParameter("cantecedentes"));
            o.setMotivo(request.getParameter("cmotivo"));
            int status = dao.actualizarHistoriaClinica(o);
            if (status > 0) {
                response.sendRedirect("listaHistoriasClinicas.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el dato.");
                request.getRequestDispatcher("listaHistoriasClinicas.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarHistoriaClinica(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaHistoriasClinicas.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar. Verifique que no tenga registros relacionados.");
                request.getRequestDispatcher("listaHistoriasClinicas.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaHistoriasClinicas.jsp");
        }
        } catch (NumberFormatException ex) {
            request.setAttribute("error", "Datos numericos invalidos.");
            request.getRequestDispatcher("listaHistoriasClinicas.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
