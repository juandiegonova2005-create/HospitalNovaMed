package modelo;

import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Datos agregados que se envian al asistente virtual (Retell AI) para que
 * pueda responder con cifras reales del sistema.
 *
 * Solo se exponen totales: nunca nombres, documentos, correos, diagnosticos ni
 * ningun dato clinico. Las cifras se cachean un minuto para no consultar la
 * base en cada pagina.
 */
public final class AsistenteDAO {

    private static final long TTL_MS = 60_000L;

    private static final Object LOCK = new Object();
    private static volatile long ultimaCarga = 0L;
    private static volatile String variables = "";

    private AsistenteDAO() {
    }

    /**
     * Fragmento JSON con las variables datos_* (sin llaves externas), listo
     * para concatenarse al contexto del widget. Devuelve "" si no hay base.
     */
    public static String variablesJson() {
        long ahora = System.currentTimeMillis();
        if (ahora - ultimaCarga < TTL_MS) {
            return variables;
        }
        synchronized (LOCK) {
            if (System.currentTimeMillis() - ultimaCarga < TTL_MS) {
                return variables;
            }
            variables = cargar();
            ultimaCarga = System.currentTimeMillis();
            return variables;
        }
    }

    private static String cargar() {
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM pacientes) AS pacientes, "
                + "(SELECT COUNT(*) FROM pacientes WHERE estado='Activo') AS pacientes_activos, "
                + "(SELECT COUNT(*) FROM medicos) AS medicos, "
                + "(SELECT COUNT(*) FROM medicos WHERE estado='Activo') AS medicos_activos, "
                + "(SELECT COUNT(*) FROM camas) AS camas, "
                + "(SELECT COUNT(*) FROM camas WHERE estado='Disponible') AS camas_disponibles, "
                + "(SELECT COUNT(*) FROM camas WHERE estado='Ocupada') AS camas_ocupadas, "
                + "(SELECT COUNT(*) FROM camas WHERE estado='Mantenimiento') AS camas_mantenimiento, "
                + "(SELECT COUNT(*) FROM especialidades) AS especialidades, "
                + "(SELECT COUNT(*) FROM medicamentos) AS medicamentos, "
                + "(SELECT COUNT(*) FROM medicamentos WHERE stock <= 5 OR estado='Agotado') AS stock_critico, "
                + "(SELECT COUNT(*) FROM inventario) AS inventario, "
                + "(SELECT COUNT(*) FROM historias_clinicas) AS historias, "
                + "(SELECT COUNT(*) FROM hospitalizaciones WHERE estado='Activa') AS hospitalizados, "
                + "(SELECT COUNT(*) FROM Usuario) AS usuarios, "
                + "(SELECT COUNT(*) FROM auditoria) AS auditoria, "
                + "(SELECT COUNT(*) FROM auditoria WHERE DATE(fecha)=CURDATE()) AS auditoria_hoy";

        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return "";
            }
            try (PreparedStatement ps = con.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return "";
                }
                StringBuilder sb = new StringBuilder(420);
                campo(sb, "datos_pacientes", rs.getInt("pacientes"));
                campo(sb, "datos_pacientes_activos", rs.getInt("pacientes_activos"));
                campo(sb, "datos_medicos", rs.getInt("medicos"));
                campo(sb, "datos_medicos_activos", rs.getInt("medicos_activos"));
                campo(sb, "datos_camas", rs.getInt("camas"));
                campo(sb, "datos_camas_disponibles", rs.getInt("camas_disponibles"));
                campo(sb, "datos_camas_ocupadas", rs.getInt("camas_ocupadas"));
                campo(sb, "datos_camas_mantenimiento", rs.getInt("camas_mantenimiento"));
                campo(sb, "datos_especialidades", rs.getInt("especialidades"));
                campo(sb, "datos_medicamentos", rs.getInt("medicamentos"));
                campo(sb, "datos_stock_critico", rs.getInt("stock_critico"));
                campo(sb, "datos_inventario", rs.getInt("inventario"));
                campo(sb, "datos_historias", rs.getInt("historias"));
                campo(sb, "datos_hospitalizados", rs.getInt("hospitalizados"));
                campo(sb, "datos_usuarios", rs.getInt("usuarios"));
                campo(sb, "datos_auditoria", rs.getInt("auditoria"));
                campo(sb, "datos_auditoria_hoy", rs.getInt("auditoria_hoy"));
                campo(sb, "datos_actualizado",
                        new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date()));
                return sb.toString();
            }
        } catch (Exception e) {
            Log.error("ERROR AL LEER DATOS AGREGADOS DEL ASISTENTE: " + e.getMessage(), e);
            return "";
        }
    }

    private static void campo(StringBuilder sb, String clave, int valor) {
        campo(sb, clave, String.valueOf(valor));
    }

    private static void campo(StringBuilder sb, String clave, String valor) {
        if (sb.length() > 0) {
            sb.append(',');
        }
        sb.append('"').append(clave).append("\":\"")
                .append(valor == null ? "" : valor.replace("\"", ""))
                .append('"');
    }
}
