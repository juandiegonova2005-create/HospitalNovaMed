package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Especialidad;
import modelo.EspecialidadDAO;

public class CtrolEspecialidad extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        EspecialidadDAO dao = new EspecialidadDAO();

        if ("agregar".equals(accion)) {
            Especialidad e = new Especialidad();
            e.setNombre(request.getParameter("cnombre"));
            e.setDescripcion(request.getParameter("cdescripcion"));
            int status = dao.agregarEspecialidad(e);
            if (status > 0) {
                response.sendRedirect("listaEspecialidades.jsp");
            } else {
                request.setAttribute("error", "No se pudo agregar la especialidad.");
                request.getRequestDispatcher("listaEspecialidades.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Especialidad e = new Especialidad();
            e.setId_especialidad(Integer.parseInt(request.getParameter("cid_especialidad")));
            e.setNombre(request.getParameter("cnombre"));
            e.setDescripcion(request.getParameter("cdescripcion"));
            int status = dao.actualizarEspecialidad(e);
            if (status > 0) {
                response.sendRedirect("listaEspecialidades.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar la especialidad.");
                request.getRequestDispatcher("listaEspecialidades.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarEspecialidad(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaEspecialidades.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar la especialidad. Verifique que no tenga médicos asociados.");
                request.getRequestDispatcher("listaEspecialidades.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaEspecialidades.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
