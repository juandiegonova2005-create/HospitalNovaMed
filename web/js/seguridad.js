/*
 * Hospital NovaMed - utilidades de seguridad del lado del cliente.
 * Este archivo es solo una ayuda de usabilidad: TODAS las reglas se
 * vuelven a validar en el servidor (modelo.Util y filtros.FiltroSesion).
 */
(function () {
    'use strict';

    // Impide copiar o cortar el contenido de los campos de contrasena.
    function bloquearCopia(e) {
        if (e.target && e.target.type === 'password') {
            e.preventDefault();
        }
    }
    document.addEventListener('copy', bloquearCopia);
    document.addEventListener('cut', bloquearCopia);

    /**
     * Devuelve la lista de requisitos que faltan en una contrasena.
     * Se usa para mostrar mensajes claros antes de enviar el formulario.
     */
    window.novamedErroresClave = function (clave) {
        var errores = [];
        if (!clave || clave.length < 8) errores.push('al menos 8 caracteres');
        if (clave && clave.length > 72) errores.push('maximo 72 caracteres');
        if (clave && !/[A-Z]/.test(clave)) errores.push('una mayuscula');
        if (clave && !/[a-z]/.test(clave)) errores.push('una minuscula');
        if (clave && !/[0-9]/.test(clave)) errores.push('un numero');
        if (clave && !/[!@#$%^&*()\-_=+\[\]{};:,.?\/|~]/.test(clave)) errores.push('un simbolo');
        if (clave && /\s/.test(clave)) errores.push('sin espacios');
        if (clave && /012345|123456|234567|345678|456789|567890|abcdef|qwerty|asdfgh|zxcvbn/i.test(clave)) {
            errores.push('sin secuencias faciles de adivinar');
        }
        return errores;
    };
})();
