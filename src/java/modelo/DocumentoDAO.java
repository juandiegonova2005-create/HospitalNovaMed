package modelo;

import config.Conexion;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/** Persistencia de los documentos adjuntos (tabla documentos + carpeta de archivos). */
public class DocumentoDAO {

    /**
     * Carpeta fisica de archivos.
     *
     * Orden de preferencia (se usa la primera carpeta escribible):
     *   1. variable de entorno NOVAMED_UPLOAD_DIR
     *   2. {catalina.base}/novamed-documentos   (Tomcat local)
     *   3. {HOME}/novamed-documentos            (Azure App Service)
     *   4. carpeta temporal del sistema
     *
     * En Azure conviene definir NOVAMED_UPLOAD_DIR=/home/data/documentos,
     * porque el resto del sistema de archivos es de solo lectura.
     */
    public static String directorio() {
        String configurado = System.getenv("NOVAMED_UPLOAD_DIR");
        if (configurado != null && !configurado.trim().isEmpty() && escribible(configurado.trim())) {
            return configurado.trim();
        }
        String base = System.getProperty("catalina.base");
        if (base != null && !base.isEmpty()) {
            String ruta = new File(base, "novamed-documentos").getPath();
            if (escribible(ruta)) {
                return ruta;
            }
        }
        String home = System.getenv("HOME");
        if (home != null && !home.isEmpty()) {
            String ruta = new File(home, "novamed-documentos").getPath();
            if (escribible(ruta)) {
                return ruta;
            }
        }
        return new File(System.getProperty("java.io.tmpdir"), "novamed-documentos").getPath();
    }

    private static boolean escribible(String ruta) {
        try {
            File dir = new File(ruta);
            if (!dir.exists() && !dir.mkdirs()) {
                return false;
            }
            File prueba = new File(dir, ".prueba-" + System.nanoTime());
            if (!prueba.createNewFile()) {
                return false;
            }
            prueba.delete();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static File carpeta() {
        File dir = new File(directorio());
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    /** Guarda el archivo en disco y registra la fila. Devuelve el id o -1. */
    public int guardar(Documento d, InputStream contenido) {
        File destino = new File(carpeta(), d.getNombreGuardado());
        try (FileOutputStream out = new FileOutputStream(destino)) {
            byte[] buffer = new byte[8192];
            int leidos;
            while ((leidos = contenido.read(buffer)) > 0) {
                out.write(buffer, 0, leidos);
            }
        } catch (Exception e) {
            Log.error("ERROR AL GUARDAR ARCHIVO: " + e.getMessage(), e);
            return -1;
        }

        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                destino.delete();
                return -1;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO documentos (identificacion, nombre_original, nombre_guardado, tipo, tamano, descripcion) "
                    + "VALUES (?,?,?,?,?,?)",
                    PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, d.getIdentificacion());
                ps.setString(2, d.getNombreOriginal());
                ps.setString(3, d.getNombreGuardado());
                ps.setString(4, d.getTipo());
                ps.setLong(5, d.getTamano());
                ps.setString(6, d.getDescripcion());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
                return 1;
            }
        } catch (Exception e) {
            Log.error("ERROR AL REGISTRAR DOCUMENTO: " + e.getMessage(), e);
            destino.delete();
            return -1;
        }
    }

    public static String nuevoNombreGuardado(String extension) {
        return UUID.randomUUID().toString().replace("-", "") + "." + extension;
    }

    /** Lista los documentos del usuario; el administrador ve todos. */
    public List<Documento> listar(String identificacion, boolean administrador) {
        List<Documento> lista = new ArrayList<>();
        String sql = administrador
                ? "SELECT d.*, u.usuario FROM documentos d LEFT JOIN Usuario u ON u.identificacion = d.identificacion "
                + "ORDER BY d.fecha DESC, d.id_documento DESC LIMIT 300"
                : "SELECT d.*, u.usuario FROM documentos d LEFT JOIN Usuario u ON u.identificacion = d.identificacion "
                + "WHERE d.identificacion = ? ORDER BY d.fecha DESC, d.id_documento DESC LIMIT 300";
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return lista;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                if (!administrador) {
                    ps.setString(1, identificacion);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        lista.add(mapear(rs));
                    }
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL LISTAR DOCUMENTOS: " + e.getMessage(), e);
        }
        return lista;
    }

    public Documento buscar(int id) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return null;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT d.*, u.usuario FROM documentos d LEFT JOIN Usuario u ON u.identificacion = d.identificacion "
                    + "WHERE d.id_documento = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapear(rs);
                    }
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL BUSCAR DOCUMENTO: " + e.getMessage(), e);
        }
        return null;
    }

    public int eliminar(int id) {
        Documento d = buscar(id);
        if (d == null) {
            return 0;
        }
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM documentos WHERE id_documento = ?")) {
                ps.setInt(1, id);
                int filas = ps.executeUpdate();
                if (filas > 0) {
                    new File(carpeta(), d.getNombreGuardado()).delete();
                }
                return filas;
            }
        } catch (Exception e) {
            Log.error("ERROR AL ELIMINAR DOCUMENTO: " + e.getMessage(), e);
            return 0;
        }
    }

    private Documento mapear(ResultSet rs) throws Exception {
        Documento d = new Documento();
        d.setId(rs.getInt("id_documento"));
        d.setIdentificacion(rs.getString("identificacion"));
        d.setNombreOriginal(rs.getString("nombre_original"));
        d.setNombreGuardado(rs.getString("nombre_guardado"));
        d.setTipo(rs.getString("tipo"));
        d.setTamano(rs.getLong("tamano"));
        d.setDescripcion(rs.getString("descripcion"));
        d.setFecha(rs.getTimestamp("fecha"));
        try {
            d.setUsuario(rs.getString("usuario"));
        } catch (Exception ignorar) {
        }
        return d;
    }
}
