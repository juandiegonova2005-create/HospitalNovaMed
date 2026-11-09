# Correcciones aplicadas – Hospital NovaMed

Esta versión parte del zip actualizado (con los módulos de seguridad y auditoría)
y aplica únicamente limpieza de contenido, archivos muertos y portabilidad.
**La lógica de seguridad, los filtros y la auditoría no se modificaron.**

## 1. Archivos eliminados (no se usaban)

| Archivo / carpeta | Motivo |
|---|---|
| `web/EditarPaciente_1.jsp` | Copia byte a byte de `EditarPaciente.jsp`, sin referencias. |
| `web/VerPaciente_1.jsp` | Copia byte a byte de `VerPaciente.jsp`, sin referencias. |
| `web/regUsuario.jsp` | Copia del panel con otra paleta; solo la enlazaba un archivo muerto. |
| `web/listaContactos.jsp` | Importaba `modelo.Contacto` / `ContactoDAO`, que no existen. |
| `web/EditarContacto.jsp` | Apuntaba al servlet inexistente `editarContacto`. |
| `web/files/` | Versiones viejas de `EditarUsuario.jsp`, `listaUsuarios.jsp` y `mensajes.jsp`, sin uso y con errores de codificación. |
| `src/java/config/NewClass.java` | Clase vacía generada por el IDE. |
| `src/java/config/PruebaConexion.java` | `main` de prueba sin uso en la aplicación. |
| `src/java/confij/` | Carpeta vacía. |
| `test/` | Carpeta vacía de pruebas. |

También se quitó `/regUsuario.jsp` de la lista `SOLO_ADMIN` en
`src/java/filtros/FiltroSesion.java`, porque la página ya no existe.

## 2. Contenido corregido (ya no se promete lo que no hay)

- `web/index.jsp`
  - El hero ya no menciona “signos vitales”; ahora habla de pacientes,
    hospitalizaciones, diagnósticos y tratamientos.
  - Las cifras decorativas (“48+ médicos”, “9.800 pacientes”, “120 camas”)
    se reemplazaron por datos reales del proyecto: **16 módulos integrados,
    2 perfiles de acceso y cierre de sesión por 30 min de inactividad**.
  - Las tarjetas de “Programación de Citas” y “Eliminación de Registros” se
    sustituyeron por los módulos que sí existen: Historias Clínicas,
    Hospitalizaciones, Diagnósticos y Tratamientos, Medicamentos e Inventario,
    Reportes y Auditoría.
- `web/productos.jsp`
  - Título de sección: “Módulos del sistema”.
  - Seis tarjetas con los módulos reales (pacientes, historias clínicas,
    hospitalización, diagnósticos/tratamientos, medicamentos/inventario,
    reportes/auditoría).
  - “Login” → “Acceso”, igual que en el resto del menú.
- `web/contactanos.jsp`
  - “Login” → “Acceso”.
  - Se eliminó el formulario que no tenía `action` ni backend (nunca enviaba
    nada). En su lugar hay un bloque con el correo de contacto y un botón
    `mailto:`.
- `web/quienesSomos.jsp`
  - La misión ya no menciona “signos vitales”; se ajustó a los módulos reales.
  - Se conserva el crédito académico y el equipo, por ser un proyecto de curso.

## 3. Registro de usuarios

- `web/Register.jsp`: el desplegable de perfiles ya no muestra
  **Administrador**. El servidor (`ControladorUsuario.java`) ya lo rechazaba;
  ahora la interfaz es coherente con esa regla.

## 4. Base de datos

- `src/java/modelo/BD.sql`: se eliminó la tabla `contactos`, que no tenía
  modelo, DAO ni controlador.
- Si ya creaste la base con el script anterior, puedes borrarla una vez:

      DROP TABLE IF EXISTS contactos;

- `migracion_seguridad.sql` no se tocó.

## 5. Portabilidad de librerías

- Se creó la carpeta `lib/` dentro del proyecto con:
  - `lib/mysql-connector-j-9.6.0.jar`
  - `lib/jbcrypt-0.4.jar`
- `nbproject/project.properties` ahora usa rutas relativas:

      file.reference.jbcrypt-0.4.jar=${basedir}/lib/jbcrypt-0.4.jar
      file.reference.mysql-connector-j-9.6.0.jar=${basedir}/lib/mysql-connector-j-9.6.0.jar

  Ya no depende de `C:\Users\...\Downloads\...`, así que el proyecto compila
  en otro equipo sin reconfigurar librerías.

## 6. Dashboard (nuevo)

- Se agregó `web/dashboard.jsp` con datos leídos en vivo de `HospitalDB`:
  - Pacientes, médicos activos, hospitalizaciones activas y porcentaje de
    ocupación de camas.
  - Historias clínicas, diagnósticos, tratamientos en curso, medicamentos
    disponibles, stock crítico y eventos de auditoría del día.
  - Barras de ocupación de camas, tratamientos y medicamentos.
  - Tablas de stock crítico, hospitalizaciones activas y últimos 8 eventos de
    auditoría.
- La lógica de consulta está en `src/java/modelo/DashboardDAO.java`. Cada
  consulta es independiente: si una tabla no existe en tu base, esa tarjeta
  muestra “—” y el resto del panel sigue funcionando.
- Se registra como **actividad** del menú (`Dashboard` → `dashboard.jsp`) y el
  menú la coloca de primera, sin importar el orden de los IDs:

      ORDER BY CASE WHEN a.enlace='dashboard.jsp' THEN 0 ELSE 1 END, a.id_actividad

- En `BD.sql` ya viene incluida para instalaciones nuevas. Para una base
  existente se agregó `src/java/modelo/migracion_dashboard.sql` (idempotente):

      mysql -uroot -p < src/java/modelo/migracion_dashboard.sql

  El script asigna el dashboard al perfil Administrador y deja comentada la
  línea para habilitarlo también al perfil Usuario.
- `front.jsp` (panel de bienvenida) ahora tiene un botón **“Ver dashboard”**.

## 7. Cómo abrir el proyecto

1. Tener la carpeta del proyecto (en NetBeans se abrió como
   `ProyectoFina8semestre`).
2. En NetBeans: *File → Open Project* y elegir la carpeta
   `ProyectoFina8semestre`.
3. Verificar que las dos librerías de `lib/` aparezcan en *Libraries*.
4. Ejecutar `src/java/modelo/BD.sql` si es una instalación nueva, o
   `migracion_seguridad.sql` + `migracion_dashboard.sql` si ya tenías la base.
5. *Clean and Build* y desplegar en Tomcat.

## 8. Pendientes conscientes (no se tocaron)

- El correo de recuperación de contraseña solo se escribe en
  `novamed-error.log`; no se envía realmente. Está documentado en
  `CAMBIOS_SEGURIDAD.md`.
- El formulario público de contacto ya no existe; se usa correo directo.

## 9. Preparación para publicar en la nube

- `src/java/config/Conexion.java` ahora arma la URL JDBC desde variables de
  entorno y usa SSL automáticamente cuando el host no es local:

      NOVAMED_DB_HOST, NOVAMED_DB_NAME, NOVAMED_DB_USER, NOVAMED_DB_PASS
      NOVAMED_DB_URL   (opcional, tiene prioridad)

  Así no quedan credenciales fijas en el código.
- `nbproject/project.properties`: se compila con Java 17
  (`javac.source=17`, `javac.target=17`) para ser compatible con los runtimes
  de Azure App Service.
- `deploy/build-war.ps1`: genera `dist/ProyectoFina8semestre.war` de forma
  reproducible (compila contra Tomcat, copia librerías y excluye
  `META-INF/context.xml`).
- `deploy/deploy-war.ps1`: publica el WAR en un App Service ya creado.
- `deploy/desplegar-azure.ps1`: despliegue completo en un comando. Crea el
  grupo de recursos, MySQL, la base y el App Service; exporta la base local,
  importa los datos, crea el usuario de la aplicación, configura las variables
  de entorno, genera el WAR y lo publica. Guarda nombres y contraseñas en
  `deploy/azure-deploy.json` (excluido de Git) y permite reintentar sin crear
  recursos duplicados.
  - Tolera los mensajes de `stderr` de `az` y de `mysql` (con
    `$ErrorActionPreference = "Stop"` PowerShell los convertía en errores
    fatales antes de poder leer el código de salida).
  - Localiza `az.cmd` aunque el `PATH` de la sesión no se haya actualizado
    tras instalarlo.
  - Usa `--version 8.0.21`, que es el valor aceptado por Azure CLI 2.92+
    (antes `8.0` producía `Incorrect value for --version`).
  - La región por defecto es `chilecentral`, porque Azure for Students aplica
    la política `Allowed resource deployment regions` (solo `chilecentral`,
    `brazilsouth`, `spaincentral`, `francecentral` y `northcentralus`). Al
    reutilizar el estado, `-Location` permite cambiar la región.
  - Registra los proveedores `Microsoft.DBforMySQL`, `Microsoft.Web`,
    `Microsoft.Storage` y `Microsoft.Insights` si la suscripción aún no los
    tiene habilitados (error `MissingSubscriptionRegistration`).
  - `Invoke-Native` devuelve solo el código de salida; antes la salida del
    comando se mezclaba con él y el build del WAR se marcaba como fallido
    aunque hubiera terminado bien.
  - El plan de App Service se crea con `--location $state.location` (antes
    caía siempre en Brazil South) y, si ya existe en otra región, la app y el
    plan se eliminan y se recrean en la región correcta.
  - No se usa `az webapp config set --linux-fx-version`: `--runtime
    TOMCAT:11.0-java17` ya configura Tomcat y el carácter `|` rompe `cmd`.
  - `webapp delete` se ejecuta sin `--yes` (no lo acepta) y el plan se borra
    solo si sigue existiendo.
  - `NOVAMED_DB_HOST` se arma con `${mysqlHost}:3306`; antes
    `$mysqlHost:3306` se interpretaba como variable con ámbito `3306` y la
    variable quedaba vacía (el login respondía "servicio no disponible").
  - `az webapp deploy --type war` publica el WAR en la **raíz** del dominio:
    la URL pública es `https://<app>.azurewebsites.net/` (sin
    `/ProyectoFina8semestre/`). La verificación final comprueba contenido real
    (`NovaMed`), no solo el código 200.
- `Dockerfile` + `.dockerignore`: alternativa para ejecutar la app en
  cualquier host con Docker (Tomcat 11 + Java 17).
- `DESPLIEGUE_AZURE.md`: guía paso a paso (MySQL, App Service, variables de
  entorno, importación de datos, costos, seguridad y solución de problemas).
- `src/java/modelo/migracion_clinicas.sql`: crea con `CREATE TABLE IF NOT
  EXISTS` las tablas `hospitalizaciones`, `historias_clinicas`,
  `diagnosticos` y `tratamientos` que faltaban en la base actual. No borra ni
  modifica datos. Ya se aplicó a `HospitalDB` (quedaron vacías) y el script de
  despliegue la ejecuta también en Azure después de importar el respaldo.
- Prueba local del WAR: se desplegó en un Tomcat 11 temporal y
  `dashboard.jsp` respondió `200` con datos reales de `HospitalDB`.
- Pendiente para publicar: contar con una suscripción de Azure y ejecutar los
  comandos de `DESPLIEGUE_AZURE.md`.

## 10. Corrección: Usuarios, Hospitalizaciones e Historias clínicas en Azure

Al probar la aplicación publicada, estos tres módulos fallaban. El problema
**no estaba en la base de datos ni en los DAO** (se probaron contra Azure y
funcionaban), sino en dos detalles que solo aparecen al usar MySQL remoto:

| Módulo | Síntoma | Causa | Corrección |
|---|---|---|---|
| Hospitalizaciones e Historias clínicas | El panel quedaba en blanco: el enlace abría `localhost:8080` | En `actividades.enlace` esas dos filas tenían la URL absoluta `http://localhost:8080/ProyectoFina8semestre/...` (datos viejos). En local funcionaba; en Azure el navegador intentaba abrir la máquina del usuario | `Util.enlaceMenu()` convierte cualquier enlace absoluto guardado en la base a su JSP relativo, y `cpanel.jsp` lo usa al pintar el menú. También se corrigieron las filas en `HospitalDB` (local) y en la base de Azure |
| Usuarios | La tabla no terminaba de cargar (se cortaba a los ~50 s, respuesta parcial de 16 KB) | `listaUsuarios.jsp` hacía una consulta **por cada usuario** para obtener su perfil (458 conexiones nuevas a MySQL). En local tarda milisegundos; contra MySQL Flexible Server cada conexión paga TLS y latencia | Los perfiles se cargan **una sola vez** en un `Map` (`PerfilDAO.listadoPerfiles()`). El listado pasó de ~35 s a **1,9 s** |

Archivos tocados: `src/java/modelo/Util.java`, `web/cpanel.jsp`,
`web/listaUsuarios.jsp`.

Verificado en `https://novamed-app-88257.azurewebsites.net/` con una cuenta de
prueba temporal (ya eliminada): los tres módulos abren desde el menú, listan y
registran datos.

> Lección para el resto del proyecto: dentro de un bucle nunca se debe abrir una
> conexión a la base por iteración. Si algún listado vuelve a ponerse lento en
> Azure, buscar el patrón "consulta por fila" y resolverlo con un `JOIN` o un
> `Map` cargado una sola vez.

## 11. Ronda de seguridad y calidad (noviembre de 2026)

Se completaron los 20 casos de prueba de autenticación, roles, auditoría,
sesiones, contraseñas, archivos y registro de errores. El detalle funcional está
en `CAMBIOS_SEGURIDAD.md`; aquí quedan los cambios de infraestructura y los
ajustes que afectan el despliegue.

### 11.1 Módulos y pantallas nuevas

| Archivo | Función |
|---|---|
| `Configuracion.jsp` + `controlador/Configuracion.java` | Tiempo de sesión, intentos y minutos de bloqueo, editables sin reiniciar. |
| `PermisosUsuario.jsp` + `controlador/PermisosUsuario.java` | Roles múltiples y permisos puntuales por usuario (concede/deniega/hereda). |
| `MiPerfil.jsp` + `controlador/ActualizarMiPerfil.java` | Cambio de correo y contraseña con la clave actual. |
| `Documentos.jsp` + servlets `SubirDocumento`, `DescargarDocumento`, `EliminarDocumento` | Carga validada por extensión y *magic bytes*, descarga y borrado. |
| `error.jsp` + `FiltroErrores` + `controlador/SimularError` | Página de error amigable, código de referencia y prueba controlada del log. |
| `js/seguridad.js` | Evita copiar/cortar el contenido de los campos de contraseña. |

### 11.2 Registro de errores y carpetas de datos

- `modelo/Log.java` se reescribió: escribe siempre en el mismo archivo, en modo
  *append*, con bloqueo propio y sin archivos `.lck` ni rotaciones.
- Orden de carpetas para el log: `NOVAMED_LOG_DIR` → `{catalina.base}/logs` →
  `{HOME}/LogFiles` → carpeta temporal.
- `DocumentoDAO.directorio()` elige la primera carpeta escribible:
  `NOVAMED_UPLOAD_DIR` → `{catalina.base}/novamed-documentos` →
  `{HOME}/novamed-documentos` → carpeta temporal.
- En Azure se configuraron `NOVAMED_LOG_DIR=/home/LogFiles` y
  `NOVAMED_UPLOAD_DIR=/home/data/documentos`.

### 11.3 Correcciones puntuales

- `web/listaPerfiles.jsp` estaba guardado en Windows-1252: los acentos y los
  emojis se veían corruptos. Se reescribió en UTF-8, con el mismo buscador y la
  misma tabla.
- La clave temporal de las cuentas demo pasó de `NovaMed#2026` a
  `Temporal#2026` porque la política rechaza la palabra común “novamed”.
- `BD.sql` siembra `admin` con `Admin#2026` (solo instalaciones nuevas).
- `migracion_mejoras.sql` actualiza el hash temporal y es idempotente.
- En Azure el WAR debe publicarse como `ROOT.war`: si se sube con el nombre
  `ProyectoFina8semestre.war`, queda en `/home/site/wwwroot` pero Tomcat sigue
  sirviendo el `ROOT.war` anterior. Con `ROOT.war` la app queda en la raíz del
  dominio.

### 11.4 Pruebas ejecutadas

| Entorno | Comprobaciones | Resultado |
|---|---|---|
| Local (Tomcat 11, MySQL 8.0.41) | 51 automatizadas en tres fases + 7 de documentos | 58 OK |
| Azure (App Service + MySQL Flexible Server) | 56 generales + 6 de recuperación + 14 de roles/creación | 76 OK |
| Local - asistente Retell | 24 (inyección, contexto, validaciones, binarios, auditoría, desactivación) | 24 OK |
| Azure - asistente Retell | 9 (activación, widget en login/panel, contexto, desactivación y limpieza) | 9 OK |

La matriz cubre los 20 casos: sesión entre navegadores, entradas extremas,
recuperación, bloqueo, roles y permisos, duplicados, claves débiles, auditoría,
expiración configurable, archivos, log de errores, logout y perfil propio.

### 11.5 Asistente virtual (Retell AI)

- `filtros/FiltroAsistente.java` inyecta el widget en todo el sitio (páginas
  públicas y panel) sin duplicarlo dentro del iframe de los módulos y sin tocar
  PDF, imágenes, CSS ni JS.
- `ConfiguracionDAO` y `Configuracion` leen, validan y guardan los parámetros
  `retell_*`; la pantalla **Configuración** incluye la tarjeta del asistente.
- Solo se usan *public keys* y *agent IDs*: la API key secreta de Retell nunca
  se guarda ni se envía al navegador.
- El agente recibe `hospital`, `pagina`, `logueado`, `usuario`, `nombre` y
  `perfil` para adaptar el saludo y la ayuda (sin datos clínicos).
- Pasos para crear el agente, prompt sugerido y solución de problemas en
  `ASISTENTE_RETELL.md`. La migración es `migracion_asistente.sql`.
