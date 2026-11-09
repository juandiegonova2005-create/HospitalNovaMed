package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Cama;
import modelo.CamaDAO;

public class CtrolCama extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        CamaDAO dao = new CamaDAO();

        if ("agregar".equals(accion)) {
            Cama c = new Cama();
            c.setNumero(request.getParameter("cnumero"));
            c.setTipo(request.getParameter("ctipo"));
            c.setEstado(request.getParameter("cestado"));
            int status = dao.agregarCama(c);
            if (status > 0) {
                response.sendRedirect("listaCamas.jsp");
            } else {
                request.setAttribute("error", "No se pudo agregar la cama.");
                request.getRequestDispatcher("listaCamas.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Cama c = new Cama();
            c.setId_cama(Integer.parseInt(request.getParameter("cid_cama")));
            c.setNumero(request.getParameter("cnumero"));
            c.setTipo(request.getParameter("ctipo"));
            c.setEstado(request.getParameter("cestado"));
            int status = dao.actualizarCama(c);
            if (status > 0) {
                response.sendRedirect("listaCamas.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar la cama.");
                request.getRequestDispatcher("listaCamas.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarCama(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaCamas.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar la cama. Verifique que no tenga un paciente asignado.");
                request.getRequestDispatcher("listaCamas.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaCamas.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
