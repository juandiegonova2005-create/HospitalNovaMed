package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import modelo.AuditoriaDAO;
import modelo.ConfiguracionDAO;
import modelo.Util;

/** Pantalla de administracion: seguridad de la sesion y asistente virtual. */
@WebServlet(name = "Configuracion", urlPatterns = {"/Configuracion"})
public class Configuracion extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("Configuracion.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession ses = request.getSession(false);
        String actor = (ses == null) ? "?" : String.valueOf(ses.getAttribute("nUsuario"));

        if ("asistente".equals(request.getParameter("seccion"))) {
            guardarAsistente(request, response, actor);
            return;
        }

        int minutosSesion = leer(request.getParameter("sesion_minutos"), 30);
        int maxIntentos = leer(request.getParameter("max_intentos"), 5);
        int minutosBloqueo = leer(request.getParameter("minutos_bloqueo"), 15);

        if (minutosSesion < 1 || minutosSesion > 1440) {
            response.sendRedirect("Configuracion.jsp?msg=sesion");
            return;
        }
        if (maxIntentos < 3 || maxIntentos > 20) {
            response.sendRedirect("Configuracion.jsp?msg=intentos");
            return;
        }
        if (minutosBloqueo < 1 || minutosBloqueo > 1440) {
            response.sendRedirect("Configuracion.jsp?msg=bloqueo");
            return;
        }

        boolean ok = ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_SESION, minutosSesion)
                && ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_INTENTOS, maxIntentos)
                && ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_BLOQUEO, minutosBloqueo);

        if (ok) {
            if (ses != null) {
                ses.setMaxInactiveInterval(minutosSesion * 60);
            }
            AuditoriaDAO.registrar(actor, "CONFIGURACION_ACTUALIZADA",
                    "sesion=" + minutosSesion + " min, intentos=" + maxIntentos
                    + ", bloqueo=" + minutosBloqueo + " min", Util.ip(request));
            response.sendRedirect("Configuracion.jsp?msg=ok");
        } else {
            response.sendRedirect("Configuracion.jsp?msg=error");
        }
    }

    /**
     * Guarda los datos del asistente virtual (Retell AI).
     * Solo se exponen public keys; la API key secreta nunca se pide ni se guarda.
     */
    private void guardarAsistente(HttpServletRequest request, HttpServletResponse response, String actor)
            throws IOException {

        String publicKey = limpiar(request.getParameter("retell_public_key"));
        String agentId = limpiar(request.getParameter("retell_agent_id"));
        String voiceKey = limpiar(request.getParameter("retell_voice_public_key"));
        String voiceAgentId = limpiar(request.getParameter("retell_voice_agent_id"));
        boolean habilitado = request.getParameter("retell_habilitado") != null;

        // En Retell la public key empieza por "public_key_" y la API key secreta
        // por "key_". Se rechaza la secreta para no exponerla en el navegador.
        if (esApiKeySecreta(publicKey) || esApiKeySecreta(voiceKey)) {
            response.sendRedirect("Configuracion.jsp?msg=secreta");
            return;
        }
        if ((!publicKey.isEmpty() && !publicKey.startsWith("public_key_"))
                || (!voiceKey.isEmpty() && !voiceKey.startsWith("public_key_"))) {
            response.sendRedirect("Configuracion.jsp?msg=formato");
            return;
        }
        if ((!agentId.isEmpty() && !agentId.startsWith("agent_"))
                || (!voiceAgentId.isEmpty() && !voiceAgentId.startsWith("agent_"))) {
            response.sendRedirect("Configuracion.jsp?msg=formato");
            return;
        }
        // Cada canal necesita su clave y su agente; no se permite media pareja.
        if ((!publicKey.isEmpty()) != (!agentId.isEmpty())
                || (!voiceKey.isEmpty()) != (!voiceAgentId.isEmpty())) {
            response.sendRedirect("Configuracion.jsp?msg=pareja");
            return;
        }
        if (habilitado && publicKey.isEmpty() && voiceKey.isEmpty()) {
            response.sendRedirect("Configuracion.jsp?msg=sinconfig");
            return;
        }

        boolean ok = true;
        ok &= ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_RETELL_HABILITADO, habilitado ? "1" : "0");
        ok &= ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_RETELL_PUBLIC_KEY, publicKey);
        ok &= ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_RETELL_AGENT_ID, agentId);
        ok &= ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_RETELL_VOICE_PUBLIC_KEY, voiceKey);
        ok &= ConfiguracionDAO.guardar(ConfiguracionDAO.CLAVE_RETELL_VOICE_AGENT_ID, voiceAgentId);

        if (ok) {
            AuditoriaDAO.registrar(actor, "CONFIGURACION_ASISTENTE",
                    "habilitado=" + (habilitado ? "si" : "no")
                    + ", chat=" + (publicKey.isEmpty() ? "no" : "si")
                    + ", voz=" + (voiceKey.isEmpty() ? "no" : "si"), Util.ip(request));
            response.sendRedirect("Configuracion.jsp?msg=ok");
        } else {
            response.sendRedirect("Configuracion.jsp?msg=error");
        }
    }

    /** La API key secreta empieza por "key_", pero nunca por "public_key_". */
    private static boolean esApiKeySecreta(String valor) {
        return !valor.isEmpty() && valor.startsWith("key_");
    }

    private static String limpiar(String valor) {
        if (valor == null) {
            return "";
        }
        String v = valor.replaceAll("[\\r\\n\\t]", "").trim();
        return (v.length() > 100) ? v.substring(0, 100) : v;
    }

    private static int leer(String valor, int porDefecto) {
        try {
            return Integer.parseInt(valor.trim());
        } catch (Exception e) {
            return porDefecto;
        }
    }
}
