package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Tratamiento;
import modelo.TratamientoDAO;

public class CtrolTratamiento extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        TratamientoDAO dao = new TratamientoDAO();

        try {
        if ("agregar".equals(accion)) {
            Tratamiento o = new Tratamiento();
            o.setId_diagnostico(Integer.parseInt(request.getParameter("cid_diagnostico")));
            o.setId_medicamento(Integer.parseInt(request.getParameter("cid_medicamento")));
            o.setDosis(request.getParameter("cdosis"));
            o.setDuracion_dias(Integer.parseInt(request.getParameter("cduracion_dias")));
            o.setEstado(request.getParameter("cestado"));
            int status = dao.agregarTratamiento(o);
            if (status > 0) {
                response.sendRedirect("listaTratamientos.jsp");
            } else {
                request.setAttribute("error", "No se pudo registrar el dato. Verifique la informacion ingresada.");
                request.getRequestDispatcher("listaTratamientos.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Tratamiento o = new Tratamiento();
            o.setId_tratamiento(Integer.parseInt(request.getParameter("cid_tratamiento")));
            o.setId_diagnostico(Integer.parseInt(request.getParameter("cid_diagnostico")));
            o.setId_medicamento(Integer.parseInt(request.getParameter("cid_medicamento")));
            o.setDosis(request.getParameter("cdosis"));
            o.setDuracion_dias(Integer.parseInt(request.getParameter("cduracion_dias")));
            o.setEstado(request.getParameter("cestado"));
            int status = dao.actualizarTratamiento(o);
            if (status > 0) {
                response.sendRedirect("listaTratamientos.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el dato.");
                request.getRequestDispatcher("listaTratamientos.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarTratamiento(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaTratamientos.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar. Verifique que no tenga registros relacionados.");
                request.getRequestDispatcher("listaTratamientos.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaTratamientos.jsp");
        }
        } catch (NumberFormatException ex) {
            request.setAttribute("error", "Datos numericos invalidos.");
            request.getRequestDispatcher("listaTratamientos.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
