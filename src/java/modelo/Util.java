package modelo;

import java.util.Locale;

/**
 * Utilidades comunes: escape HTML, validacion de entradas y reglas de
 * contrasena. Centralizar aqui evita que cada formulario aplique reglas
 * distintas (era una de las debilidades del proyecto).
 */
public class Util {

    /** Longitud minima y maxima de una contrasena (BCrypt solo usa 72 bytes). */
    public static final int CLAVE_MIN = 8;
    public static final int CLAVE_MAX = 72;

    private static final String SIMBOLOS = "!@#$%^&*()-_=+[]{};:,.?/|~";
    private static final String[] SECUENCIAS = {
        "0123456789", "1234567890", "0987654321",
        "abcdefghijklmnopqrstuvwxyz", "qwertyuiop", "asdfghjkl", "zxcvbnm"
    };
    private static final String[] COMUNES = {
        "password", "contrasena", "contraseña", "admin123", "novamed",
        "12345678", "123456789", "qwerty123", "abc12345", "iloveyou",
        "bienvenido", "hospital", "medico123"
    };

    // Escapa HTML para evitar XSS al mostrar datos en las paginas JSP
    public static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    /**
     * Regla unica de contrasena para TODO el sistema.
     *
     * @return null si la clave es aceptable; si no, un mensaje para el usuario.
     */
    public static String validarClave(String clave) {
        if (clave == null || clave.isEmpty()) {
            return "La contraseña es obligatoria.";
        }
        if (clave.length() < CLAVE_MIN) {
            return "La contraseña debe tener al menos " + CLAVE_MIN + " caracteres.";
        }
        if (clave.getBytes(java.nio.charset.StandardCharsets.UTF_8).length > CLAVE_MAX) {
            return "La contraseña no puede superar " + CLAVE_MAX + " bytes.";
        }
        if (clave.chars().anyMatch(Character::isWhitespace)) {
            return "La contraseña no puede contener espacios.";
        }
        boolean mayus = clave.chars().anyMatch(Character::isUpperCase);
        boolean minus = clave.chars().anyMatch(Character::isLowerCase);
        boolean digito = clave.chars().anyMatch(Character::isDigit);
        boolean simbolo = clave.chars().anyMatch(c -> SIMBOLOS.indexOf(c) >= 0);
        if (!mayus || !minus || !digito || !simbolo) {
            return "La contraseña debe incluir mayúscula, minúscula, número y símbolo (!@#$%^&*-_).";
        }

        String baja = clave.toLowerCase(Locale.ROOT);
        // Secuencias obvias: 123456789012345, abcdefgh, qwerty...
        for (String seq : SECUENCIAS) {
            for (int i = 0; i + 6 <= seq.length(); i++) {
                String trozo = seq.substring(i, i + 6);
                if (baja.contains(trozo) || baja.contains(new StringBuilder(trozo).reverse().toString())) {
                    return "La contraseña no puede contener secuencias como 123456, abcdef o qwerty.";
                }
            }
        }
        // Un solo caracter repetido: aaaaaaaa
        if (baja.chars().distinct().count() < 3) {
            return "La contraseña es demasiado repetitiva; usa caracteres variados.";
        }
        for (String comun : COMUNES) {
            if (baja.contains(comun)) {
                return "Esa contraseña es demasiado común; elige otra.";
            }
        }
        return null;
    }

    public static boolean claveSegura(String clave) {
        return validarClave(clave) == null;
    }

    /** Nombre de usuario permitido al registrarse o editarse. */
    public static boolean usuarioValido(String usuario) {
        return usuario != null && usuario.matches("^[A-Za-z0-9._-]{4,20}$");
    }

    /**
     * Identificador de login: acepta el nombre de usuario o el correo.
     * Rechaza cadenas raras (p. ej. 15 simbolos) antes de tocar la BD.
     */
    public static boolean loginValido(String identificador) {
        if (identificador == null) {
            return false;
        }
        String v = identificador.trim();
        if (v.isEmpty() || v.length() > 100) {
            return false;
        }
        if (v.contains("@")) {
            return emailValido(v);
        }
        return v.matches("^[A-Za-z0-9._-]{1,20}$");
    }

    public static String normalizarEmail(String email) {
        return (email == null) ? null : email.trim().toLowerCase(Locale.ROOT);
    }

    public static boolean emailValido(String email) {
        return email != null && email.length() <= 60
                && email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    }

    /** Nombre o apellido: letras (con acentos), espacios, apostrofo y guion. */
    public static boolean nombreValido(String nombre) {
        return nombre != null && nombre.matches("^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]{2,30}$");
    }

    /** Cedula / documento: solo digitos. */
    public static boolean identificacionValida(String id) {
        return id != null && id.matches("^\\d{6,15}$");
    }

    /** Telefono opcional: solo digitos, 7 a 15. */
    public static boolean telefonoValido(String tel) {
        return tel == null || tel.trim().isEmpty() || tel.trim().matches("^\\d{7,15}$");
    }

    /**
     * Normaliza los enlaces del menu lateral.
     *
     * En bases de datos antiguas algunas actividades quedaron guardadas como
     *   http://localhost:8080/ProyectoFina8semestre/listaX.jsp
     * Eso funciona en local pero rompe en la nube (el navegador intenta abrir
     * localhost). Aqui se deja solo el nombre del JSP, que es relativo y
     * funciona tanto en local como en Azure.
     */
    public static String enlaceMenu(String enlace) {
        if (enlace == null) {
            return "";
        }
        String e = enlace.trim();
        if (e.matches("(?i)^https?://.*")) {
            int q = e.indexOf('?');
            String cola = (q >= 0) ? e.substring(q) : "";
            String ruta = (q >= 0) ? e.substring(0, q) : e;
            int barra = ruta.lastIndexOf('/');
            e = ((barra >= 0) ? ruta.substring(barra + 1) : ruta) + cola;
        }
        return e;
    }

    // IP del cliente para la bitacora de auditoria
    public static String ip(jakarta.servlet.http.HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty()) {
            int coma = ip.indexOf(',');
            return (coma > 0) ? ip.substring(0, coma).trim() : ip.trim();
        }
        return request.getRemoteAddr();
    }

    /** Nombre de archivo sin rutas ni caracteres de control. */
    public static String nombreArchivoSeguro(String nombre) {
        if (nombre == null) {
            return "archivo";
        }
        String n = nombre.replace('\\', '/');
        int barra = n.lastIndexOf('/');
        if (barra >= 0) {
            n = n.substring(barra + 1);
        }
        n = n.replaceAll("[\\r\\n\\t\\x00]", "").trim();
        if (n.isEmpty() || n.equals(".") || n.equals("..")) {
            n = "archivo";
        }
        return n.length() > 200 ? n.substring(0, 200) : n;
    }
}
