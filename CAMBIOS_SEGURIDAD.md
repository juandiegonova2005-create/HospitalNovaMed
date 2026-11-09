# Cambios de seguridad – Hospital NovaMed

Documento actualizado tras la ronda de seguridad y calidad de noviembre de 2026.
Cubre los 20 casos de prueba acordados, en local y en Azure.

## 1. ANTES DE EJECUTAR (obligatorio)

Si tu base `HospitalDB` ya existe, ejecuta **una sola vez** (en este orden):

    mysql -uroot -p --default-character-set=utf8mb4 < src/java/modelo/migracion_seguridad.sql
    mysql -uroot -p --default-character-set=utf8mb4 < src/java/modelo/migracion_mejoras.sql

Instalación desde cero: usa `src/java/modelo/BD.sql`, que ya incluye tablas,
permisos y datos iniciales.

`migracion_mejoras.sql` es **idempotente**: crea `configuracion`,
`usuario_actividad` y `documentos`, agrega las actividades nuevas y normaliza
las contraseñas que no sean BCrypt. Se puede ejecutar varias veces.

Después: **Clean and Build** en NetBeans y volver a desplegar.

### Cuentas de demostración

Las 399 cuentas demo migradas (usuarios `usr2051`…`usr2068`, entre otras)
quedaron con la clave temporal:

    Temporal#2026

Se cambió desde `NovaMed#2026` porque la política de contraseñas rechaza la
palabra común “novamed”. Cámbiala desde **Mi perfil** o desde **Editar Usuario**.

La cuenta `admin` de instalaciones nuevas se siembra con `Admin#2026`
(solo en `BD.sql`). En una base ya existente **no se toca** la clave del admin.

## 2. Qué se cambió (por caso de prueba)

| Caso | Cambio |
|---|---|
| 1. Sesión entre navegadores | La sesión está ligada al navegador (huella de `User-Agent`) y se permiten sesiones simultáneas, cada una auditada (`LOGIN_OK` con el navegador). |
| 2. 15 caracteres especiales en login | `Util` valida el identificador y los filtros capturan entradas extremas; nunca se devuelve un 500 ni se refleja el valor en la página. |
| 3. Olvidé mi contraseña | `olvide.jsp` → `RecuperarClave` → `restablecer.jsp` → `RestablecerClave`. Token de 64 hex, en BD solo su SHA-256, un solo uso, vence en 30 min. Respuesta idéntica exista o no el correo. El enlace se escribe en el log (correo simulado). |
| 4. Bloqueo tras 5 fallos | 5 intentos fallidos bloquean la cuenta 15 min (`LoginDAO`). El admin puede desbloquear desde **Usuarios**; restablecer la clave también desbloquea. Intentos y minutos son configurables. |
| 5. Rol nuevo para 2 usuarios | **Perfiles** crea/edita/elimina roles. `PermisosUsuario` permite asignar varios roles a un usuario y definir permisos puntuales por módulo; dos usuarios con el mismo rol nuevo pueden tener permisos efectivos distintos. |
| 6. Correo duplicado | Correo y usuario únicos (índice UNIQUE + validación con mensaje claro) al registrar y al editar. |
| 7. Admin cambia clave con 1 carácter | Toda clave pasa por `Util.validarClave`, también las que define un administrador. |
| 8. Dos roles y modificar todos los permisos | Perfil principal (`Usuario.id_perfil`) + perfiles adicionales (`usuario_perfil`) + concesiones/denegaciones por usuario (`usuario_actividad`). Una denegación siempre gana. El menú y el acceso directo usan los permisos efectivos. |
| 9. Auditoría visible | Tabla `auditoria` y pantalla **Auditoría** (solo admin) con filtro. Registra login ok/fallido, bloqueo, logout, altas, ediciones, cambios de clave/perfil, eliminaciones, recuperación, documentos y accesos denegados. |
| 10/11. Expiración por inactividad | `configuracion.sesion_minutos` se lee en cada petición desde `FiltroSesion`; se puede reducir o ampliar desde **Configuración de seguridad** sin reiniciar el servidor. |
| 11b. Clave `1..15` al crear usuario | `ControladorUsuario` aplica la misma política antes de insertar; el usuario no se crea. |
| 12. `ABC` enmascarada y no copiable | `type="password"`, `autocomplete="new-password"` y `js/seguridad.js` bloquea copiar/cortar/menú contextual en los campos de clave. |
| 13. `.exe` renombrado a `.pdf` | Módulo **Documentos**: valida extensión permitida y *magic bytes* reales. Un ejecutable renombrado se rechaza y queda auditado (`ARCHIVO_RECHAZADO`). |
| 14. Login simultáneo en 2 navegadores | Permitido y auditado; no se comparte la sesión entre navegadores. |
| 15. Fallo forzado en el error log | `FiltroErrores` captura la excepción, escribe `novamed-error.log` con un identificador y muestra `error.jsp` sin trazas. El admin tiene el botón **Simular error** para probarlo. |
| 16. URL copiada y logout en otra pestaña | `CerrarSesion` invalida la sesión en el servidor; la URL copiada deja de funcionar en cualquier pestaña. |
| 17. Contraseñas cifradas | BCrypt (coste 12). Compatibilidad temporal con texto plano que se migra al iniciar sesión; la migración normaliza lo que quede. En Azure no hay filas sin BCrypt. |
| 18. Actualizar correo y contraseña desde el perfil | `MiPerfil.jsp`: exige la contraseña actual, valida la nueva con la política y audita el cambio. |

### Otros endurecimientos

- `FiltroSesion` exige rol Administrador en usuarios, perfiles, actividades,
  permisos, configuración y auditoría, y comprueba permisos por actividad en el
  resto de módulos (antes cualquier usuario autenticado podía abrirlos por URL).
- `web.xml`: `error-page` para 404 y 500, cookie `HttpOnly` y
  `SameSite=Strict`; `secure` se activa al publicar con HTTPS.
- `cpanel.jsp` usa `PreparedStatement` para el menú (SQL de segundo orden).
- `EliminarUsuario` impide que el admin se borre a sí mismo; `EditarUsuario`
  conserva el teléfono si no se envía.
- Salidas HTML escapadas con `Util.esc`.

## 3. Dónde quedan los registros

- Errores y eventos: `novamed-error.log`.
  - Local: `{catalina.base}/logs/novamed-error.log`.
  - Azure: `/home/LogFiles/novamed-error.log` (variable `NOVAMED_LOG_DIR`).
  - Si ninguna carpeta es escribible, usa `{HOME}/LogFiles` o la carpeta temporal.
- Documentos: `NOVAMED_UPLOAD_DIR` (Azure: `/home/data/documentos`); si no,
  `{catalina.base}/novamed-documentos` o `{HOME}/novamed-documentos`.
- El correo de recuperación **no se envía**: `modelo/Correo.java` escribe el
  mensaje en el log para poder probar el flujo. Para producción se agrega
  `jakarta.mail` dentro de `Correo.enviar(...)`.

## 4. Matriz de pruebas ejecutada

### Local (Tomcat 11 + MySQL 8.0.41)

| Fase | Comprobaciones | Resultado |
|---|---|---|
| 1b: bloqueo/desbloqueo, 2 roles, permisos puntuales, 403, auditoría | 17 | 17 OK |
| 2b: perfil propio, correo/clave, logout en otra pestaña, sesiones simultáneas | 16 | 16 OK |
| 3b: log de errores, recuperación con token, expiración 1 ↔ 60 min | 18 | 18 OK |
| 2: documentos (`.exe`→`.pdf`, descarga, borrado) | 7 | 7 OK |

### Azure (`https://novamed-app-88257.azurewebsites.net`)

| Bloque | Comprobaciones | Resultado |
|---|---|---|
| Matriz general (login, bloqueo, roles, 403, auditoría, documentos, error 500, perfil, logout, expiración, sesiones) | 56 | 56 OK |
| Recuperación de contraseña con token real | 6 | 6 OK |
| Rol nuevo para 2 usuarios + clave `1..15` al crear | 14 | 14 OK |

Cubiertos los 20 casos en ambos entornos.

## 5. Limitaciones que debes conocer

- El correo de recuperación es simulado (ver arriba).
- No hay sesión única: se permite el login simultáneo y se audita.
- Los módulos clínicos se controlan por permisos de actividad; si agregas una
  ruta nueva, regístrala en `PermisosDAO.RUTAS` para que también quede protegida.
- En Azure, la regla de firewall para la IP de desarrollo debe eliminarse al
  terminar. La app usa el usuario MySQL `novamed` con permisos mínimos.
