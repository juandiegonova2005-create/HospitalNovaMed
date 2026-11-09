package modelo;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Registro central de errores/eventos de la aplicacion.
 *
 * Escribe SIEMPRE en el mismo archivo, sin bloqueos ni rotaciones que dejen
 * registros en otros nombres. Se usa un bloqueo propio y se abre el archivo en
 * modo "append" en cada escritura, de modo que:
 *
 *  - el registro sigue funcionando aunque el servidor recargue la aplicacion,
 *  - no queda ningun archivo .lck abierto,
 *  - cada linea se escribe completa (no se mezclan eventos de varios hilos).
 *
 * Ubicacion del archivo (la primera carpeta en la que se pueda escribir):
 *   1. variable de entorno NOVAMED_LOG_DIR
 *   2. {catalina.base}/logs           (Tomcat local)
 *   3. {HOME}/LogFiles                (Azure App Service, Linux)
 *   4. carpeta temporal del sistema
 *
 * En Azure App Service los registros se descargan con:
 *   az webapp log download --resource-group <grupo> --name <app> --log-file logs.zip
 */
public final class Log {

    private static final Object CANDADO = new Object();
    private static File destino;
    private static boolean resuelto = false;

    private Log() {
    }

    public static void error(String mensaje) {
        escribir("SEVERE", mensaje, null);
    }

    public static void error(String mensaje, Throwable t) {
        escribir("SEVERE", mensaje, t);
    }

    public static void info(String mensaje) {
        escribir("INFO", mensaje, null);
    }

    private static void escribir(String nivel, String mensaje, Throwable t) {
        String marca = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss", Locale.ROOT).format(new Date());
        synchronized (CANDADO) {
            File archivo = archivo();
            if (archivo == null) {
                System.err.println(marca + " " + nivel + " " + mensaje);
                if (t != null) {
                    t.printStackTrace(System.err);
                }
                return;
            }
            try (PrintWriter out = new PrintWriter(new FileWriter(archivo, true))) {
                out.println(marca + " " + nivel + " " + mensaje);
                if (t != null) {
                    t.printStackTrace(out);
                }
                out.flush();
            } catch (Exception e) {
                System.err.println("No se pudo escribir en el registro de errores: " + e.getMessage());
                System.err.println(marca + " " + nivel + " " + mensaje);
                if (t != null) {
                    t.printStackTrace(System.err);
                }
            }
        }
    }

    /** Devuelve el archivo de log utilizable, o null si ninguna carpeta es escribible. */
    private static synchronized File archivo() {
        if (!resuelto) {
            resuelto = true;
            destino = resolver();
        }
        return destino;
    }

    private static File resolver() {
        String configurado = System.getenv("NOVAMED_LOG_DIR");
        File f = probar(configurado, "novamed-error.log");
        if (f != null) {
            return f;
        }
        String base = System.getProperty("catalina.base");
        f = probar(base == null ? null : new File(base, "logs").getPath(), "novamed-error.log");
        if (f != null) {
            return f;
        }
        String home = System.getenv("HOME");
        f = probar(home == null ? null : new File(home, "LogFiles").getPath(), "novamed-error.log");
        if (f != null) {
            return f;
        }
        return probar(System.getProperty("java.io.tmpdir"), "novamed-error.log");
    }

    /** Comprueba que la carpeta existe (o se puede crear) y acepta escritura. */
    private static File probar(String carpeta, String nombre) {
        if (carpeta == null || carpeta.trim().isEmpty()) {
            return null;
        }
        try {
            File dir = new File(carpeta.trim());
            if (!dir.exists() && !dir.mkdirs()) {
                return null;
            }
            File archivo = new File(dir, nombre);
            try (FileWriter prueba = new FileWriter(archivo, true)) {
                prueba.write("");
            }
            return archivo;
        } catch (Exception e) {
            return null;
        }
    }
}
