package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import modelo.Log;

public class Conexion {

    // Se pueden sobrescribir con variables de entorno (NOVAMED_DB_USER, NOVAMED_DB_PASS,
    // NOVAMED_DB_HOST, NOVAMED_DB_NAME) para no dejar credenciales fijas en el codigo.
    private static String env(String nombre, String porDefecto) {
        String v = System.getenv(nombre);
        return (v == null || v.isEmpty()) ? porDefecto : v;
    }

    public static String usuario = env("NOVAMED_DB_USER", "root");
    public static String clave = env("NOVAMED_DB_PASS", "123");
    public static String servidor = env("NOVAMED_DB_HOST", "localhost:3306");
    public static String BD = env("NOVAMED_DB_NAME", "HospitalDB");

    /** URL JDBC. En la nube se puede definir completa con NOVAMED_DB_URL. */
    public static String url() {
        String url = System.getenv("NOVAMED_DB_URL");
        if (url != null && !url.isEmpty()) {
            return url;
        }
        boolean local = servidor.startsWith("localhost") || servidor.startsWith("127.0.0.1");
        String params = local
                ? "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8"
                : "?sslMode=REQUIRED&serverTimezone=UTC&characterEncoding=UTF-8";
        return "jdbc:mysql://" + servidor + "/" + BD + params;
    }

    public Connection crearConexion() {
        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(url(), usuario, clave);
        } catch (java.lang.ClassNotFoundException ex) {
            Log.error("Driver MySQL no encontrado: " + ex.getMessage(), ex);
        } catch (SQLException e) {
            Log.error("ERROR DE CONEXION A LA BASE DE DATOS: " + e.getMessage(), e);
        }

        return con;
    }

    public Connection getConnection() {
        return crearConexion();
    }
}
