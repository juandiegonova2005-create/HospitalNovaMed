package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import modelo.Diagnostico;
import modelo.DiagnosticoDAO;

public class CtrolDiagnostico extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String accion = request.getParameter("accion");
        DiagnosticoDAO dao = new DiagnosticoDAO();

        try {
        if ("agregar".equals(accion)) {
            Diagnostico o = new Diagnostico();
            o.setId_historia(Integer.parseInt(request.getParameter("cid_historia")));
            o.setCodigo_cie10(request.getParameter("ccodigo_cie10"));
            o.setFecha(request.getParameter("cfecha"));
            o.setDescripcion(request.getParameter("cdescripcion"));
            int status = dao.agregarDiagnostico(o);
            if (status > 0) {
                response.sendRedirect("listaDiagnosticos.jsp");
            } else {
                request.setAttribute("error", "No se pudo registrar el dato. Verifique la informacion ingresada.");
                request.getRequestDispatcher("listaDiagnosticos.jsp").forward(request, response);
            }

        } else if ("editar".equals(accion)) {
            Diagnostico o = new Diagnostico();
            o.setId_diagnostico(Integer.parseInt(request.getParameter("cid_diagnostico")));
            o.setId_historia(Integer.parseInt(request.getParameter("cid_historia")));
            o.setCodigo_cie10(request.getParameter("ccodigo_cie10"));
            o.setFecha(request.getParameter("cfecha"));
            o.setDescripcion(request.getParameter("cdescripcion"));
            int status = dao.actualizarDiagnostico(o);
            if (status > 0) {
                response.sendRedirect("listaDiagnosticos.jsp");
            } else {
                request.setAttribute("error", "No se pudo actualizar el dato.");
                request.getRequestDispatcher("listaDiagnosticos.jsp").forward(request, response);
            }

        } else if ("eliminar".equals(accion)) {
            int status = dao.eliminarDiagnostico(Integer.parseInt(request.getParameter("id")));
            if (status > 0) {
                response.sendRedirect("listaDiagnosticos.jsp");
            } else {
                request.setAttribute("error", "No se pudo eliminar. Verifique que no tenga registros relacionados.");
                request.getRequestDispatcher("listaDiagnosticos.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("listaDiagnosticos.jsp");
        }
        } catch (NumberFormatException ex) {
            request.setAttribute("error", "Datos numericos invalidos.");
            request.getRequestDispatcher("listaDiagnosticos.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }
}
