package modelo;

import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/** Registro y consulta de la bitacora de auditoria (tabla auditoria). */
public class AuditoriaDAO {

    private static String corta(String s, int max) {
        if (s == null) {
            return "";
        }
        return s.length() > max ? s.substring(0, max) : s;
    }

    /** Nunca lanza excepcion: un fallo de auditoria no debe tumbar la operacion. */
    public static void registrar(String actor, String accion, String detalle, String ip) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                Log.error("AUDITORIA no registrada (sin conexion): " + accion + " / " + actor);
                return;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO auditoria (actor, accion, detalle, ip) VALUES (?,?,?,?)")) {
                ps.setString(1, corta(actor, 60));
                ps.setString(2, corta(accion, 40));
                ps.setString(3, corta(detalle, 500));
                ps.setString(4, corta(ip, 45));
                ps.executeUpdate();
            }
        } catch (Exception e) {
            Log.error("ERROR AL REGISTRAR AUDITORIA: " + e.getMessage(), e);
        }
    }

    public List<Auditoria> listar(String filtro, int limite) {
        List<Auditoria> lista = new ArrayList<>();
        String f = (filtro == null) ? "" : filtro.trim();
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return lista;
            }
            String sql = "SELECT id, fecha, actor, accion, detalle, ip FROM auditoria";
            if (!f.isEmpty()) {
                sql += " WHERE actor LIKE ? OR accion LIKE ? OR detalle LIKE ?";
            }
            sql += " ORDER BY id DESC LIMIT ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                int i = 1;
                if (!f.isEmpty()) {
                    String like = "%" + f + "%";
                    ps.setString(i++, like);
                    ps.setString(i++, like);
                    ps.setString(i++, like);
                }
                ps.setInt(i, limite);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Auditoria a = new Auditoria();
                        a.setId(rs.getLong("id"));
                        a.setFecha(rs.getTimestamp("fecha"));
                        a.setActor(rs.getString("actor"));
                        a.setAccion(rs.getString("accion"));
                        a.setDetalle(rs.getString("detalle"));
                        a.setIp(rs.getString("ip"));
                        lista.add(a);
                    }
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL LISTAR AUDITORIA: " + e.getMessage(), e);
        }
        return lista;
    }
}
