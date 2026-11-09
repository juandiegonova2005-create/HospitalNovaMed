package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import modelo.Perfil;
import modelo.PerfilDAO;
import java.io.IOException;

public class CtrolPerfil extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        PerfilDAO dao = new PerfilDAO();

        if ("agregar".equals(accion)) {
            Perfil p = new Perfil();
            p.setPerfil(request.getParameter("cperfil"));
            int status = dao.agregarPerfil(p);
            if (status > 0) {
                response.sendRedirect("listaPerfiles.jsp");
            } else {
                request.setAttribute("error", "No se pudo agregar el perfil.");
                request.getRequestDispatcher("listaPerfiles.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Perfil p = new Perfil();
            p.setId_perfil(Integer.parseInt(request.getParameter("cid_perfil")));
            p.setPerfil(request.getParameter("cperfil"));
            int status = dao.actualizarPerfil(p);
            if (status > 0) {
                response.sendRedirect("listaPerfiles.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el perfil.");
                request.getRequestDispatcher("listaPerfiles.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarPerfil(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaPerfiles.jsp");
            } else if (status == -1) {
                request.setAttribute("error",
                    "No se puede eliminar: hay usuarios asignados a este perfil. Reasígnalos primero.");
                request.getRequestDispatcher("listaPerfiles.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "No se pudo eliminar el perfil.");
                request.getRequestDispatcher("listaPerfiles.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaPerfiles.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}