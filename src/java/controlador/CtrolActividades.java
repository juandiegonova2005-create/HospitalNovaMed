package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.Actividades;
import modelo.ActividadesDAO;
import java.io.IOException;

public class CtrolActividades extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        ActividadesDAO dao = new ActividadesDAO();

        if ("agregar".equals(accion)) {
            Actividades a = new Actividades();
            a.setNom_actividad(request.getParameter("cnom_actividad"));
            a.setEnlace(request.getParameter("cenlace"));
            int status = dao.agregarActividad(a);
            if (status > 0) {
                response.sendRedirect("listaActividades.jsp");
            } else {
                request.setAttribute("error", "No se pudo agregar la actividad.");
                request.getRequestDispatcher("listaActividades.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Actividades a = new Actividades();
            a.setId_actividad(Integer.parseInt(request.getParameter("cid_actividad")));
            a.setNom_actividad(request.getParameter("cnom_actividad"));
            a.setEnlace(request.getParameter("cenlace"));
            int status = dao.actualizarActividad(a);
            if (status > 0) {
                response.sendRedirect("listaActividades.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar la actividad.");
                request.getRequestDispatcher("listaActividades.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarActividad(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaActividades.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar la actividad.");
                request.getRequestDispatcher("listaActividades.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaActividades.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
