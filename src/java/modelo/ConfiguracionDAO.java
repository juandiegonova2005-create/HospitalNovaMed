package modelo;

import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Parametros editables desde la pantalla "Configuracion": seguridad de la
 * sesion y datos del asistente virtual (Retell AI).
 * Se guardan en la tabla configuracion y se cachean unos segundos para no
 * consultar la base en cada peticion.
 */
public class ConfiguracionDAO {

    public static final String CLAVE_SESION = "sesion_minutos";
    public static final String CLAVE_INTENTOS = "max_intentos";
    public static final String CLAVE_BLOQUEO = "minutos_bloqueo";

    // Asistente virtual (Retell AI). La public key es publica por diseno; la
    // API key secreta NUNCA se guarda aqui ni se envia al navegador.
    public static final String CLAVE_RETELL_HABILITADO = "retell_habilitado";
    public static final String CLAVE_RETELL_PUBLIC_KEY = "retell_public_key";
    public static final String CLAVE_RETELL_AGENT_ID = "retell_agent_id";
    public static final String CLAVE_RETELL_VOICE_PUBLIC_KEY = "retell_voice_public_key";
    public static final String CLAVE_RETELL_VOICE_AGENT_ID = "retell_voice_agent_id";

    private static final long TTL_MS = 10_000L;

    private static volatile long ultimaCarga = 0L;
    private static volatile int minutosSesion = 30;
    private static volatile int maxIntentos = 5;
    private static volatile int minutosBloqueo = 15;
    private static volatile boolean retellHabilitado = false;
    private static volatile String retellPublicKey = "";
    private static volatile String retellAgentId = "";
    private static volatile String retellVoicePublicKey = "";
    private static volatile String retellVoiceAgentId = "";

    public static int minutosSesion() {
        cargarSiHaceFalta();
        return minutosSesion;
    }

    public static int maxIntentos() {
        cargarSiHaceFalta();
        return maxIntentos;
    }

    public static int minutosBloqueo() {
        cargarSiHaceFalta();
        return minutosBloqueo;
    }

    /** Valor guardado del interruptor (puede estar activo pero incompleto). */
    public static boolean retellHabilitado() {
        cargarSiHaceFalta();
        return retellHabilitado;
    }

    public static String retellPublicKey() {
        cargarSiHaceFalta();
        return retellPublicKey;
    }

    public static String retellAgentId() {
        cargarSiHaceFalta();
        return retellAgentId;
    }

    public static String retellVoicePublicKey() {
        cargarSiHaceFalta();
        return retellVoicePublicKey;
    }

    public static String retellVoiceAgentId() {
        cargarSiHaceFalta();
        return retellVoiceAgentId;
    }

    /** Hay al menos un canal (chat o voz) con su clave y su agente. */
    public static boolean asistenteConfigurado() {
        cargarSiHaceFalta();
        boolean chat = !retellPublicKey.isEmpty() && !retellAgentId.isEmpty();
        boolean voz = !retellVoicePublicKey.isEmpty() && !retellVoiceAgentId.isEmpty();
        return chat || voz;
    }

    /** El widget solo se inyecta si esta activo Y hay un canal completo. */
    public static boolean asistenteHabilitado() {
        cargarSiHaceFalta();
        return retellHabilitado && asistenteConfigurado();
    }

    private static void cargarSiHaceFalta() {
        long ahora = System.currentTimeMillis();
        if (ahora - ultimaCarga < TTL_MS) {
            return;
        }
        synchronized (ConfiguracionDAO.class) {
            if (ahora - ultimaCarga < TTL_MS) {
                return;
            }
            try (Connection con = new Conexion().crearConexion()) {
                if (con != null) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT clave, valor FROM configuracion");
                            ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String clave = rs.getString("clave");
                            String valor = rs.getString("valor");
                            if (clave == null || valor == null) {
                                continue;
                            }
                            aplicar(clave, valor);
                        }
                    }
                }
            } catch (Exception e) {
                Log.error("ERROR AL LEER CONFIGURACION: " + e.getMessage(), e);
            }
            ultimaCarga = ahora;
        }
    }

    private static void aplicar(String clave, String valor) {
        if (CLAVE_SESION.equals(clave)) {
            int v = parseInt(valor, -1);
            if (v >= 1 && v <= 1440) {
                minutosSesion = v;
            }
        } else if (CLAVE_INTENTOS.equals(clave)) {
            int v = parseInt(valor, -1);
            if (v >= 3 && v <= 20) {
                maxIntentos = v;
            }
        } else if (CLAVE_BLOQUEO.equals(clave)) {
            int v = parseInt(valor, -1);
            if (v >= 1 && v <= 1440) {
                minutosBloqueo = v;
            }
        } else if (CLAVE_RETELL_HABILITADO.equals(clave)) {
            retellHabilitado = "1".equals(valor.trim())
                    || "true".equalsIgnoreCase(valor.trim())
                    || "si".equalsIgnoreCase(valor.trim());
        } else if (CLAVE_RETELL_PUBLIC_KEY.equals(clave)) {
            retellPublicKey = recortar(valor);
        } else if (CLAVE_RETELL_AGENT_ID.equals(clave)) {
            retellAgentId = recortar(valor);
        } else if (CLAVE_RETELL_VOICE_PUBLIC_KEY.equals(clave)) {
            retellVoicePublicKey = recortar(valor);
        } else if (CLAVE_RETELL_VOICE_AGENT_ID.equals(clave)) {
            retellVoiceAgentId = recortar(valor);
        }
    }

    private static String recortar(String valor) {
        String v = valor.trim();
        return v.length() > 100 ? v.substring(0, 100) : v;
    }

    private static int parseInt(String s, int porDefecto) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return porDefecto;
        }
    }

    public static boolean guardar(String clave, int valor) {
        return guardar(clave, String.valueOf(valor));
    }

    public static boolean guardar(String clave, String valor) {
        if (clave == null || clave.trim().isEmpty()) {
            return false;
        }
        String v = (valor == null) ? "" : valor.trim();
        if (v.length() > 100) {
            v = v.substring(0, 100);
        }
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return false;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO configuracion (clave, valor) VALUES (?, ?) "
                    + "ON DUPLICATE KEY UPDATE valor = VALUES(valor)")) {
                ps.setString(1, clave);
                ps.setString(2, v);
                ps.executeUpdate();
            }
            invalidarCache();
            return true;
        } catch (Exception e) {
            Log.error("ERROR AL GUARDAR CONFIGURACION: " + e.getMessage(), e);
            return false;
        }
    }

    public static void invalidarCache() {
        ultimaCarga = 0L;
    }
}
