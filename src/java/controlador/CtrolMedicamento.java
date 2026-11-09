package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import modelo.Medicamento;
import modelo.MedicamentoDAO;

public class CtrolMedicamento extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        MedicamentoDAO dao = new MedicamentoDAO();

        if ("agregar".equals(accion)) {
            Medicamento m = new Medicamento();
            m.setNombre(request.getParameter("cnombre"));
            m.setDescripcion(request.getParameter("cdescripcion"));
            m.setStock(parseEntero(request.getParameter("cstock"), 0));
            m.setPrecio(parseDecimal(request.getParameter("cprecio")));
            m.setEstado(request.getParameter("cestado"));
            int status = dao.agregarMedicamento(m);
            if (status > 0) {
                response.sendRedirect("listaMedicamentos.jsp");
            } else {
                request.setAttribute("error", "No se pudo agregar el medicamento.");
                request.getRequestDispatcher("listaMedicamentos.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Medicamento m = new Medicamento();
            m.setId_medicamento(Integer.parseInt(request.getParameter("cid_medicamento")));
            m.setNombre(request.getParameter("cnombre"));
            m.setDescripcion(request.getParameter("cdescripcion"));
            m.setStock(parseEntero(request.getParameter("cstock"), 0));
            m.setPrecio(parseDecimal(request.getParameter("cprecio")));
            m.setEstado(request.getParameter("cestado"));
            int status = dao.actualizarMedicamento(m);
            if (status > 0) {
                response.sendRedirect("listaMedicamentos.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el medicamento.");
                request.getRequestDispatcher("listaMedicamentos.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarMedicamento(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaMedicamentos.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar el medicamento.");
                request.getRequestDispatcher("listaMedicamentos.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaMedicamentos.jsp");
        }
    }

    private int parseEntero(String valor, int porDefecto) {
        if (valor == null || valor.trim().isEmpty()) {
            return porDefecto;
        }
        try {
            return Integer.parseInt(valor.trim());
        } catch (NumberFormatException ex) {
            return porDefecto;
        }
    }

    private BigDecimal parseDecimal(String valor) {
        if (valor == null || valor.trim().isEmpty()) {
            return BigDecimal.ZERO;
        }
        try {
            return new BigDecimal(valor.trim());
        } catch (NumberFormatException ex) {
            return BigDecimal.ZERO;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
