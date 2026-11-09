package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.ItemInventario;
import modelo.InventarioDAO;

public class CtrolInventario extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        InventarioDAO dao = new InventarioDAO();

        if ("agregar".equals(accion)) {
            ItemInventario i = new ItemInventario();
            i.setNombre(request.getParameter("cnombre"));
            i.setCategoria(request.getParameter("ccategoria"));
            i.setCantidad(parseEntero(request.getParameter("ccantidad")));
            i.setUbicacion(request.getParameter("cubicacion"));
            i.setEstado(request.getParameter("cestado"));
            int status = dao.agregarItem(i);
            if (status > 0) {
                response.sendRedirect("listaInventario.jsp");
            } else {
                request.setAttribute("error", "No se pudo agregar el item al inventario.");
                request.getRequestDispatcher("listaInventario.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            ItemInventario i = new ItemInventario();
            i.setId_item(Integer.parseInt(request.getParameter("cid_item")));
            i.setNombre(request.getParameter("cnombre"));
            i.setCategoria(request.getParameter("ccategoria"));
            i.setCantidad(parseEntero(request.getParameter("ccantidad")));
            i.setUbicacion(request.getParameter("cubicacion"));
            i.setEstado(request.getParameter("cestado"));
            int status = dao.actualizarItem(i);
            if (status > 0) {
                response.sendRedirect("listaInventario.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el item.");
                request.getRequestDispatcher("listaInventario.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarItem(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaInventario.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar el item.");
                request.getRequestDispatcher("listaInventario.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaInventario.jsp");
        }
    }

    private int parseEntero(String valor) {
        if (valor == null || valor.trim().isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(valor.trim());
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
