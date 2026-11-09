package modelo;

import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import org.mindrot.jbcrypt.BCrypt;

public class LoginDAO {

    /** Valores por defecto (se pueden ajustar en Configuracion). */
    public static final int MAX_INTENTOS = 5;
    public static final int MINUTOS_BLOQUEO = 15;

    public static final String OK = "OK";
    public static final String INVALIDO = "INVALIDO";
    public static final String BLOQUEADO = "BLOQUEADO";
    public static final String ERROR = "ERROR";

    /** Hash de relleno para que un usuario inexistente tarde lo mismo que uno real. */
    private static final String HASH_RELLENO =
            "$2a$12$cCdEEZbAWOnena82vlxew.5qZ1e.cG.HMdBfL3tckl4xdsgtPG/IS";

    private String estado = INVALIDO;
    private int minutosRestantes = 0;
    private boolean bloqueoNuevo = false;
    private int intentosFallidos = 0;
    private int maxIntentos = MAX_INTENTOS;
    private int minutosBloqueo = MINUTOS_BLOQUEO;

    public String getEstado() { return estado; }
    /** Intentos fallidos acumulados del usuario tras este intento (0 si no aplica). */
    public int getIntentosFallidos() { return intentosFallidos; }
    public int getIntentosRestantes() { return Math.max(0, maxIntentos - intentosFallidos); }
    public int getMinutosRestantes() { return minutosRestantes; }
    /** true si ESTE intento fue el que provoco el bloqueo. */
    public boolean isBloqueoNuevo() { return bloqueoNuevo; }
    public int getMaxIntentos() { return maxIntentos; }
    public int getMinutosBloqueo() { return minutosBloqueo; }

    private static boolean pareceHash(String valor) {
        return valor != null
                && (valor.startsWith("$2a$") || valor.startsWith("$2b$") || valor.startsWith("$2y$"))
                && valor.length() >= 55;
    }

    /**
     * Valida credenciales. Acepta el nombre de usuario o el correo electronico.
     */
    public Usuario Login_datos(String usuario, String clave) {
        estado = INVALIDO;
        minutosRestantes = 0;
        bloqueoNuevo = false;
        intentosFallidos = 0;
        maxIntentos = ConfiguracionDAO.maxIntentos();
        minutosBloqueo = ConfiguracionDAO.minutosBloqueo();

        if (usuario == null || clave == null || usuario.trim().isEmpty() || clave.isEmpty()) {
            return null;
        }
        String ident = usuario.trim();
        if (ident.length() > 100 || clave.length() > 200) {
            return null;
        }

        try (Connection conn = new Conexion().crearConexion()) {
            if (conn == null) {
                estado = ERROR;
                return null;
            }

            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT u.*, p.perfil AS perfil_nombre FROM Usuario u "
                    + "LEFT JOIN Perfil p ON p.id_perfil = u.id_perfil "
                    + "WHERE u.usuario = ? OR u.email = ? LIMIT 1")) {
                stmt.setString(1, ident);
                stmt.setString(2, ident);
                try (ResultSet rs = stmt.executeQuery()) {

                    if (!rs.next()) {
                        // Mismo costo de CPU que un usuario real (evita enumeracion por tiempo).
                        try {
                            BCrypt.checkpw(clave, HASH_RELLENO);
                        } catch (IllegalArgumentException ignorar) {
                        }
                        return null; // usuario inexistente (mismo mensaje que clave mala)
                    }

                    String id = rs.getString("identificacion");
                    String hash = rs.getString("clave");
                    long ahora = System.currentTimeMillis();
                    Timestamp bloqueadoHasta = rs.getTimestamp("bloqueado_hasta");

                    if (bloqueadoHasta != null && bloqueadoHasta.getTime() > ahora) {
                        estado = BLOQUEADO;
                        minutosRestantes = (int) Math.ceil((bloqueadoHasta.getTime() - ahora) / 60000.0);
                        return null;
                    }

                    boolean correcta = false;
                    boolean hashAntiguo = false;
                    if (!pareceHash(hash)) {
                        // Compatibilidad con claves antiguas en texto plano: si coincide,
                        // se migra a BCrypt en este mismo inicio de sesion.
                        hashAntiguo = true;
                        correcta = hash != null && hash.equals(clave);
                    } else {
                        try {
                            correcta = BCrypt.checkpw(clave, hash);
                        } catch (IllegalArgumentException e) {
                            Log.error("HASH INVALIDO para usuario id=" + id + ": " + e.getMessage());
                        }
                    }

                    if (correcta) {
                        String hashNuevo = null;
                        if (hashAntiguo) {
                            hashNuevo = BCrypt.hashpw(clave, BCrypt.gensalt(12));
                            Log.info("Clave antigua migrada a BCrypt para id=" + id);
                        }
                        registrarIntentos(conn, id, 0, null, hashNuevo);
                        Usuario datos = new Usuario();
                        datos.setIdentificacion(id);
                        datos.setNombre(rs.getString("nombre"));
                        datos.setApellido(rs.getString("apellido"));
                        datos.setEmail(rs.getString("email"));
                        datos.setUsuario(rs.getString("usuario"));
                        datos.setIdperfil(rs.getInt("id_perfil"));
                        datos.setPerfil(rs.getString("perfil_nombre"));
                        estado = OK;
                        return datos;
                    }

                    // Clave incorrecta. Si el bloqueo anterior ya vencio, el conteo reinicia.
                    int previos = (bloqueadoHasta != null) ? 0 : rs.getInt("intentos_fallidos");
                    int intentos = previos + 1;
                    intentosFallidos = intentos;

                    if (intentos >= maxIntentos) {
                        Timestamp hasta = new Timestamp(ahora + minutosBloqueo * 60_000L);
                        registrarIntentos(conn, id, 0, hasta, null);
                        estado = BLOQUEADO;
                        minutosRestantes = minutosBloqueo;
                        bloqueoNuevo = true;
                    } else {
                        registrarIntentos(conn, id, intentos, null, null);
                    }
                    return null;
                }
            }
        } catch (Exception e) {
            estado = ERROR;
            Log.error("ERROR LOGIN: " + e.getMessage(), e);
            return null;
        }
    }

    private void registrarIntentos(Connection conn, String id, int intentos,
            Timestamp bloqueadoHasta, String hashNuevo) throws Exception {
        String sql = (hashNuevo != null)
                ? "UPDATE Usuario SET intentos_fallidos = ?, bloqueado_hasta = ?, clave = ? WHERE identificacion = ?"
                : "UPDATE Usuario SET intentos_fallidos = ?, bloqueado_hasta = ? WHERE identificacion = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, intentos);
            ps.setTimestamp(2, bloqueadoHasta);
            if (hashNuevo != null) {
                ps.setString(3, hashNuevo);
                ps.setString(4, id);
            } else {
                ps.setString(3, id);
            }
            ps.executeUpdate();
        }
    }
}
