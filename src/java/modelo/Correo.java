package modelo;

/**
 * Punto unico de envio de correos.
 *
 * IMPORTANTE: por ahora NO envia correo real; escribe el mensaje en el log
 * (novamed-error.log) para poder probar el flujo de recuperacion en desarrollo.
 * Para produccion, agregar la libreria jakarta.mail y enviar por SMTP aqui dentro;
 * el resto de la aplicacion no necesita cambios.
 */
public class Correo {

    public static void enviar(String destino, String asunto, String cuerpo) {
        Log.info("CORREO (simulado) para " + destino + " | " + asunto + " | " + cuerpo);
    }
}
