package modelo;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Date;
import java.util.Properties;

/**
 * Punto unico de envio de correos.
 *
 * Se configura con variables de entorno, nunca con datos en el codigo:
 *
 *   NOVAMED_SMTP_HOST  servidor SMTP (ej. smtp.gmail.com)
 *   NOVAMED_SMTP_PORT  puerto: 587 con STARTTLS (por defecto) o 465 con SSL
 *   NOVAMED_SMTP_USER  cuenta remitente (ej. micorreo@gmail.com)
 *   NOVAMED_SMTP_PASS  clave de aplicacion o clave SMTP del proveedor
 *   NOVAMED_SMTP_FROM  remitente visible (por defecto igual al usuario)
 *   NOVAMED_SMTP_SSL   "true" para SSL directo (usar con el puerto 465)
 *
 * Si NOVAMED_SMTP_HOST no esta definido, el mensaje se escribe en el log
 * (modo desarrollo) para que el flujo de recuperacion siga funcionando.
 */
public class Correo {

    private static String env(String nombre) {
        String valor = System.getenv(nombre);
        return (valor == null || valor.trim().isEmpty()) ? null : valor.trim();
    }

    public static void enviar(String destino, String asunto, String cuerpo) {
        String host = env("NOVAMED_SMTP_HOST");

        // Sin servidor configurado: modo simulado (no rompe nada).
        if (host == null) {
            Log.info("CORREO (simulado) para " + destino + " | " + asunto + " | " + cuerpo);
            return;
        }

        String puerto = env("NOVAMED_SMTP_PORT");
        if (puerto == null) {
            puerto = "587";
        }
        String usuario = env("NOVAMED_SMTP_USER");
        String clave = env("NOVAMED_SMTP_PASS");
        String remitente = env("NOVAMED_SMTP_FROM");
        if (remitente == null) {
            remitente = usuario;
        }
        boolean ssl = "true".equalsIgnoreCase(env("NOVAMED_SMTP_SSL"));

        if (remitente == null) {
            Log.error("ERROR AL ENVIAR CORREO: falta NOVAMED_SMTP_FROM o NOVAMED_SMTP_USER");
            Log.info("CORREO (no enviado) para " + destino + " | " + asunto + " | " + cuerpo);
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", puerto);
        props.put("mail.smtp.auth", String.valueOf(usuario != null && clave != null));
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");
        if (ssl) {
            props.put("mail.smtp.ssl.enable", "true");
        } else {
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
        }

        Session sesion;
        if (usuario != null && clave != null) {
            final String usuarioFinal = usuario;
            final String claveFinal = clave;
            sesion = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(usuarioFinal, claveFinal);
                }
            });
        } else {
            sesion = Session.getInstance(props);
        }

        try {
            MimeMessage msg = new MimeMessage(sesion);
            msg.setFrom(new InternetAddress(remitente, "Hospital NovaMed", "UTF-8"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destino, false));
            msg.setSubject(asunto, "UTF-8");
            msg.setText(cuerpo, "UTF-8");
            msg.setSentDate(new Date());
            Transport.send(msg);
            Log.info("CORREO enviado a " + destino + " | " + asunto);
        } catch (Throwable e) {
            // Se captura Throwable a proposito: si falta una libreria (por ejemplo
            // jakarta.activation), la JVM lanza NoClassDefFoundError, que no es una
            // Exception y tumbaría la peticion HTTP. El flujo de recuperacion debe
            // seguir respondiendo aunque el correo no se pueda enviar.
            // La clave nunca se registra; solo el motivo del fallo.
            Log.error("ERROR AL ENVIAR CORREO a " + destino + ": " + e.getMessage(), e);
            Log.info("CORREO (no enviado) para " + destino + " | " + asunto + " | " + cuerpo);
        }
    }
}
