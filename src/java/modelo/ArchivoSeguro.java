package modelo;

import java.util.Locale;
import java.util.Set;

/**
 * Validacion de archivos subidos.
 *
 * No basta con mirar la extension: un ejecutable renombrado a .pdf se detecta
 * leyendo los primeros bytes (firma o "magic bytes") del archivo. Esta clase
 * concentra las reglas para que cualquier modulo de carga las use igual.
 */
public final class ArchivoSeguro {

    /** Tamano maximo aceptado: 5 MB. */
    public static final long MAX_BYTES = 5L * 1024 * 1024;

    private static final Set<String> PERMITIDAS = Set.of(
            "pdf", "jpg", "jpeg", "png", "gif", "txt", "doc", "docx", "xls", "xlsx", "rtf"
    );

    private ArchivoSeguro() {
    }

    public static String extension(String nombre) {
        if (nombre == null) {
            return "";
        }
        String n = nombre.trim();
        int punto = n.lastIndexOf('.');
        if (punto < 0 || punto == n.length() - 1) {
            return "";
        }
        return n.substring(punto + 1).toLowerCase(Locale.ROOT);
    }

    public static String mime(String extension) {
        switch (extension) {
            case "pdf":
                return "application/pdf";
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            case "png":
                return "image/png";
            case "gif":
                return "image/gif";
            case "txt":
                return "text/plain";
            case "doc":
                return "application/msword";
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "xls":
                return "application/vnd.ms-excel";
            case "xlsx":
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case "rtf":
                return "application/rtf";
            default:
                return "application/octet-stream";
        }
    }

    /**
     * Valida nombre, tamano y firma del archivo.
     *
     * @param nombreOriginal nombre tal como lo envia el navegador
     * @param cabecera primeros bytes del archivo (se recomiendan al menos 8)
     * @param tamano tamano real en bytes
     * @return null si el archivo es aceptable; si no, el motivo del rechazo
     */
    public static String validar(String nombreOriginal, byte[] cabecera, long tamano) {
        String ext = extension(nombreOriginal);
        if (ext.isEmpty()) {
            return "El archivo debe tener una extensión (por ejemplo .pdf, .jpg o .docx).";
        }
        if (!PERMITIDAS.contains(ext)) {
            return "Extensión ." + ext + " no permitida. Solo se aceptan: "
                    + "pdf, jpg, jpeg, png, gif, txt, doc, docx, xls, xlsx y rtf.";
        }
        if (tamano <= 0) {
            return "El archivo está vacío.";
        }
        if (tamano > MAX_BYTES) {
            return "El archivo supera el máximo permitido de 5 MB.";
        }
        if (cabecera == null || cabecera.length < 4) {
            return "No se pudo leer el contenido del archivo.";
        }
        if (esEjecutable(cabecera)) {
            return "El archivo es un ejecutable. Aunque lo hayas renombrado, el sistema "
                    + "detecta su contenido real y lo bloquea.";
        }
        if (!coincideConExtension(ext, cabecera)) {
            return "El contenido del archivo no corresponde a la extensión ." + ext
                    + ". Verifica que no esté renombrado.";
        }
        return null;
    }

    /** Firmas de ejecutables y scripts que nunca se aceptan. */
    private static boolean esEjecutable(byte[] b) {
        // MZ (Windows .exe/.dll), ELF (Linux), Mach-O (macOS), shebang (scripts)
        if (b.length >= 2 && b[0] == 0x4D && b[1] == 0x5A) {
            return true;
        }
        if (b.length >= 4 && b[0] == 0x7F && b[1] == 0x45 && b[2] == 0x4C && b[3] == 0x46) {
            return true;
        }
        if (b.length >= 4) {
            int f = ((b[0] & 0xFF) << 24) | ((b[1] & 0xFF) << 16) | ((b[2] & 0xFF) << 8) | (b[3] & 0xFF);
            if (f == 0xCFfaedfe || f == 0xCEfaedfe || f == 0xFEEDface || f == 0xFEEDfacf) {
                return true;
            }
        }
        if (b.length >= 2 && b[0] == 0x23 && b[1] == 0x21) {
            return true;
        }
        // Cabecera DOS "This program cannot be run in DOS mode"
        return false;
    }

    private static boolean coincideConExtension(String ext, byte[] b) {
        switch (ext) {
            case "pdf":
                return empieza(b, "%PDF");
            case "jpg":
            case "jpeg":
                return b.length >= 3 && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF;
            case "png":
                return b.length >= 8 && (b[0] & 0xFF) == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47
                        && b[4] == 0x0D && b[5] == 0x0A && b[6] == 0x1A && b[7] == 0x0A;
            case "gif":
                return empieza(b, "GIF8");
            case "docx":
            case "xlsx":
                // Los formatos modernos de Office son contenedores ZIP
                return b.length >= 4 && b[0] == 0x50 && b[1] == 0x4B
                        && (b[2] == 0x03 || b[2] == 0x05 || b[2] == 0x07);
            case "doc":
            case "xls":
                // Formato OLE2 compuesto
                return b.length >= 8 && (b[0] & 0xFF) == 0xD0 && (b[1] & 0xFF) == 0xCF
                        && (b[2] & 0xFF) == 0x11 && (b[3] & 0xFF) == 0xE0
                        && (b[4] & 0xFF) == 0xA1 && (b[5] & 0xFF) == 0xB1
                        && (b[6] & 0xFF) == 0x1A && (b[7] & 0xFF) == 0xE1;
            case "rtf":
                return empieza(b, "{\\rtf");
            case "txt":
                // Texto plano: basta con que no sea binario con NUL
                for (byte x : b) {
                    if (x == 0) {
                        return false;
                    }
                }
                return true;
            default:
                return false;
        }
    }

    private static boolean empieza(byte[] b, String firma) {
        if (b == null || b.length < firma.length()) {
            return false;
        }
        for (int i = 0; i < firma.length(); i++) {
            if ((b[i] & 0xFF) != (firma.charAt(i) & 0xFF)) {
                return false;
            }
        }
        return true;
    }
}
