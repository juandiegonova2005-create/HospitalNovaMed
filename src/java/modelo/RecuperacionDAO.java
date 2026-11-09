package modelo;

import config.Conexion;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/** Tokens de un solo uso para restablecer la contraseña. En BD solo se guarda el hash SHA-256. */
public class RecuperacionDAO {

    public static final int MINUTOS_VALIDEZ = 30;
    private static final SecureRandom RND = new SecureRandom();

    private static String sha256(String s) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] h = md.digest(s.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : h) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    /** Crea un token nuevo (invalida los anteriores del usuario) y lo devuelve en claro. */
    public String crearToken(String identificacion) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return null;
            }
            byte[] raw = new byte[32];
            RND.nextBytes(raw);
            StringBuilder sb = new StringBuilder();
            for (byte b : raw) {
                sb.append(String.format("%02x", b));
            }
            String token = sb.toString();

            try (PreparedStatement del = con.prepareStatement(
                    "DELETE FROM reset_token WHERE identificacion = ? OR expira < NOW()")) {
                del.setString(1, identificacion);
                del.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO reset_token (token_hash, identificacion, expira) "
                    + "VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? MINUTE))")) {
                ps.setString(1, sha256(token));
                ps.setString(2, identificacion);
                ps.setInt(3, MINUTOS_VALIDEZ);
                ps.executeUpdate();
            }
            return token;
        } catch (Exception e) {
            Log.error("ERROR AL CREAR TOKEN DE RECUPERACION: " + e.getMessage(), e);
            return null;
        }
    }

    /** Devuelve la identificacion dueña del token si es valido y no ha vencido; si no, null. */
    public String validarToken(String token) {
        if (token == null || token.length() != 64) {
            return null;
        }
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return null;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT identificacion FROM reset_token WHERE token_hash = ? AND expira > NOW()")) {
                ps.setString(1, sha256(token));
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getString(1) : null;
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL VALIDAR TOKEN: " + e.getMessage(), e);
            return null;
        }
    }

    public void consumir(String token) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return;
            }
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM reset_token WHERE token_hash = ?")) {
                ps.setString(1, sha256(token));
                ps.executeUpdate();
            }
        } catch (Exception e) {
            Log.error("ERROR AL CONSUMIR TOKEN: " + e.getMessage(), e);
        }
    }
}
