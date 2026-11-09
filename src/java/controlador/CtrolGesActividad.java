package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.GesActividad;
import modelo.GesActividadDAO;
import java.io.IOException;

public class CtrolGesActividad extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        GesActividadDAO dao = new GesActividadDAO();

        if (accion.equals("agregar")) {
            GesActividad g = new GesActividad();
            g.setId_perfil(Integer.parseInt(request.getParameter("cid_perfil")));
            g.setId_actividad(Integer.parseInt(request.getParameter("cid_actividad")));
            int status = dao.agregarGesActividad(g);
            if (status > 0) response.sendRedirect("listaGesActividad.jsp");

        } else if (accion.equals("editar")) {
            GesActividad g = new GesActividad();
            g.setIdgesActividad(Integer.parseInt(request.getParameter("cidgesActividad")));
            g.setId_perfil(Integer.parseInt(request.getParameter("cid_perfil")));
            g.setId_actividad(Integer.parseInt(request.getParameter("cid_actividad")));
            int status = dao.actualizarGesActividad(g);
            if (status > 0) response.sendRedirect("listaGesActividad.jsp");

        } else if (accion.equals("eliminar")) {
            int status = dao.eliminarGesActividad(Integer.parseInt(request.getParameter("id")));
            if (status > 0) response.sendRedirect("listaGesActividad.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
