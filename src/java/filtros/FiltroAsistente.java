package filtros;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import modelo.AsistenteDAO;
import modelo.ConfiguracionDAO;
import modelo.Util;

/**
 * Inyecta el widget del asistente virtual (Retell AI) en todas las paginas
 * HTML, tanto publicas como del panel. La configuracion se administra desde
 * "Configuracion" y se puede desactivar sin recompilar.
 *
 * El script se crea con JavaScript y no se carga dentro de iframes: el panel
 * usa un iframe para los modulos, y sin esa comprobacion apareceria un boton
 * flotante duplicado en cada modulo.
 */
public class FiltroAsistente implements Filter {

    private static final String SRC = "https://dashboard.retellai.com/retell-widget-v2.js";

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        if (!(req instanceof HttpServletRequest) || !(res instanceof HttpServletResponse)) {
            chain.doFilter(req, res);
            return;
        }

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        if (!ConfiguracionDAO.asistenteHabilitado()) {
            chain.doFilter(req, res);
            return;
        }

        String etiqueta = construirEtiqueta(request);
        if (etiqueta.isEmpty()) {
            chain.doFilter(req, res);
            return;
        }

        CapturaHtml captura = new CapturaHtml(response);
        chain.doFilter(req, captura);

        if (!captura.capturado() || response.isCommitted()) {
            return;
        }

        String html = captura.contenido();
        // En paginas de error no se agrega el asistente, pero si se escribe el HTML.
        if (response.getStatus() < 400 && !html.contains("id=\"retell-widget\"")) {
            html = insertar(html, etiqueta);
        }

        byte[] bytes = html.getBytes(captura.charset());
        response.setContentLength(bytes.length);
        ServletOutputStream out = response.getOutputStream();
        out.write(bytes);
        out.flush();
    }

    @Override
    public void destroy() {
    }

    private String construirEtiqueta(HttpServletRequest request) {
        String chatKey = ConfiguracionDAO.retellPublicKey();
        String chatAgent = ConfiguracionDAO.retellAgentId();
        String voiceKey = ConfiguracionDAO.retellVoicePublicKey();
        String voiceAgent = ConfiguracionDAO.retellVoiceAgentId();

        boolean chat = !chatKey.isEmpty() && !chatAgent.isEmpty();
        boolean voz = !voiceKey.isEmpty() && !voiceAgent.isEmpty();
        if (!chat && !voz) {
            return "";
        }

        StringBuilder sb = new StringBuilder(700);
        sb.append("\n<!-- Asistente virtual NovaMed (Retell AI). Se configura en Configuracion. -->\n");
        sb.append("<script>\n");
        sb.append("(function () {\n");
        sb.append("  if (window.top !== window.self) { return; }\n");
        sb.append("  if (document.getElementById('retell-widget')) { return; }\n");
        sb.append("  var s = document.createElement('script');\n");
        sb.append("  s.id = 'retell-widget';\n");
        sb.append("  s.async = true;\n");
        sb.append("  s.src = '").append(SRC).append("';\n");
        if (chat) {
            sb.append("  s.setAttribute('data-public-key', '").append(js(chatKey)).append("');\n");
            sb.append("  s.setAttribute('data-agent-id', '").append(js(chatAgent)).append("');\n");
        }
        if (voz) {
            sb.append("  s.setAttribute('data-voice-public-key', '").append(js(voiceKey)).append("');\n");
            sb.append("  s.setAttribute('data-voice-agent-id', '").append(js(voiceAgent)).append("');\n");
        }
        sb.append("  s.setAttribute('data-title', 'Asistente virtual NovaMed');\n");
        sb.append("  s.setAttribute('data-fab-text', '¿Necesitas ayuda?');\n");
        sb.append("  s.setAttribute('data-color', '#0f766e');\n");
        sb.append("  s.setAttribute('data-popup-message', 'Hola, soy el asistente virtual de Hospital NovaMed. ¿En qué te puedo ayudar?');\n");
        sb.append("  s.setAttribute('data-show-ai-popup-time', '8');\n");
        sb.append("  s.setAttribute('data-dynamic', '").append(js(jsonContexto(request))).append("');\n");
        sb.append("  document.head.appendChild(s);\n");
        sb.append("})();\n");
        sb.append("</script>\n");
        return sb.toString();
    }

    /**
     * Variables que recibe el agente para saludar y adaptar la ayuda.
     * No incluye datos clinicos ni la clave del usuario.
     */
    private String jsonContexto(HttpServletRequest request) {
        String usuario = "";
        String nombre = "";
        String perfil = "";
        HttpSession sesion = request.getSession(false);
        if (sesion != null) {
            usuario = valor(sesion.getAttribute("nUsuario"));
            nombre = valor(sesion.getAttribute("nombre"));
            perfil = valor(sesion.getAttribute("perfil"));
        }
        StringBuilder sb = new StringBuilder(220);
        sb.append("{\"hospital\":\"Hospital NovaMed\",");
        sb.append("\"pagina\":\"").append(json(request.getRequestURI())).append("\",");
        sb.append("\"logueado\":\"").append(usuario.isEmpty() ? "no" : "si").append("\",");
        sb.append("\"usuario\":\"").append(json(usuario)).append("\",");
        sb.append("\"nombre\":\"").append(json(nombre)).append("\",");
        sb.append("\"perfil\":\"").append(json(perfil)).append("\"");
        // Cifras reales solo para usuarios autenticados. Son totales agregados:
        // no incluyen nombres, documentos, correos ni datos clinicos.
        if (!usuario.isEmpty()) {
            String datos = AsistenteDAO.variablesJson();
            if (!datos.isEmpty()) {
                sb.append(',').append(datos);
            }
        }
        sb.append('}');
        return sb.toString();
    }

    private static String valor(Object o) {
        return (o == null) ? "" : String.valueOf(o);
    }

    private static String insertar(String html, String etiqueta) {
        String lower = html.toLowerCase(Locale.ROOT);
        int pos = lower.lastIndexOf("</head>");
        if (pos < 0) {
            pos = lower.lastIndexOf("</body>");
        }
        if (pos < 0) {
            return html + etiqueta;
        }
        return html.substring(0, pos) + etiqueta + html.substring(pos);
    }

    /** Escapa una cadena para usarla dentro de un literal JavaScript. */
    private static String js(String s) {
        if (s == null) {
            return "";
        }
        StringBuilder b = new StringBuilder(s.length() + 8);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '\\':
                    b.append("\\\\");
                    break;
                case '\'':
                    b.append("\\'");
                    break;
                case '"':
                    b.append("\\\"");
                    break;
                case '\n':
                    b.append("\\n");
                    break;
                case '\r':
                    b.append("\\r");
                    break;
                case '\t':
                    b.append("\\t");
                    break;
                case '<':
                    b.append("\\u003c");
                    break;
                default:
                    if (c < 0x20) {
                        b.append(String.format("\\u%04x", (int) c));
                    } else {
                        b.append(c);
                    }
            }
        }
        return b.toString();
    }

    /** Escapa una cadena para JSON (sin las comillas externas). */
    private static String json(String s) {
        if (s == null) {
            return "";
        }
        StringBuilder b = new StringBuilder(s.length() + 8);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':
                    b.append("\\\"");
                    break;
                case '\\':
                    b.append("\\\\");
                    break;
                case '\n':
                    b.append("\\n");
                    break;
                case '\r':
                    b.append("\\r");
                    break;
                case '\t':
                    b.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        b.append(String.format("\\u%04x", (int) c));
                    } else {
                        b.append(c);
                    }
            }
        }
        return b.toString();
    }

    /**
     * Guarda la respuesta HTML en memoria para insertar el script antes de
     * enviarla. Los demas tipos de contenido (PDF, imagenes, CSS, JS) pasan
     * directamente al flujo original.
     */
    private static final class CapturaHtml extends HttpServletResponseWrapper {

        private StringWriter buffer;
        private PrintWriter writer;
        private boolean capturado;

        CapturaHtml(HttpServletResponse response) {
            super(response);
        }

        boolean capturado() {
            return capturado;
        }

        String contenido() {
            if (writer != null) {
                writer.flush();
            }
            return (buffer == null) ? "" : buffer.toString();
        }

        Charset charset() {
            String enc = getCharacterEncoding();
            if (enc == null || enc.trim().isEmpty()) {
                return StandardCharsets.UTF_8;
            }
            try {
                return Charset.forName(enc);
            } catch (Exception e) {
                return StandardCharsets.UTF_8;
            }
        }

        @Override
        public PrintWriter getWriter() throws IOException {
            if (!capturado) {
                String tipo = getContentType();
                if (tipo == null || tipo.toLowerCase(Locale.ROOT).startsWith("text/html")) {
                    buffer = new StringWriter(8192);
                    writer = new PrintWriter(buffer);
                    capturado = true;
                }
            }
            return capturado ? writer : super.getWriter();
        }

        @Override
        public void flushBuffer() throws IOException {
            if (capturado) {
                if (writer != null) {
                    writer.flush();
                }
            } else {
                super.flushBuffer();
            }
        }

        @Override
        public void resetBuffer() {
            if (capturado) {
                if (buffer != null) {
                    buffer.getBuffer().setLength(0);
                }
            } else {
                super.resetBuffer();
            }
        }
    }
}
