# Hospital NovaMed

Sistema de gestión hospitalaria desarrollado en **Java (JSP + Servlets)** sobre **Jakarta EE / Tomcat 11**, con base de datos **MySQL 8**, panel administrativo, auditoría, control de acceso por perfiles y un asistente virtual integrado.

El proyecto está **dockerizado** (aplicación + base de datos) y además se encuentra desplegado en **Azure App Service**.

---

## Contenido

- [Descripción](#descripción)
- [Módulos del sistema](#módulos-del-sistema)
- [Seguridad implementada](#seguridad-implementada)
- [Tecnologías](#tecnologías)
- [Requisitos](#requisitos)
- [Ejecución rápida con Docker](#ejecución-rápida-con-docker)
- [Ejecución en NetBeans / Tomcat local](#ejecución-en-netbeans--tomcat-local)
- [Despliegue en Azure](#despliegue-en-azure)
- [Credenciales de prueba](#credenciales-de-prueba)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Documentación](#documentación)
- [Datos y privacidad](#datos-y-privacidad)

---

## Descripción

Hospital NovaMed permite administrar la operación de un hospital: pacientes, médicos, especialidades, camas, hospitalizaciones, historias clínicas, diagnósticos, tratamientos, medicamentos, inventario, actividades y usuarios.

Incluye:

- **Panel de control** con indicadores generales.
- **Menú dinámico según el perfil** del usuario autenticado.
- **Auditoría** de accesos y acciones relevantes.
- **Configuración de seguridad** editable desde el panel (sin recompilar).
- **Asistente virtual (Retell AI)** visible en todo el sitio, activable o desactivable desde configuración.
- **Gestión de documentos** con validación de extensión y contenido real del archivo.

La base de datos de demostración contiene **5.547 pacientes sintéticos** y 20 tablas.

---

## Módulos del sistema

| Módulo | Descripción |
|---|---|
| Pacientes | Registro, consulta, edición y eliminación |
| Médicos | Gestión de médicos y su especialidad |
| Especialidades | Catálogo de especialidades médicas |
| Camas | Ocupación y estado de camas |
| Hospitalizaciones | Ingreso y egreso de pacientes |
| Historias clínicas | Antecedentes y motivos de consulta |
| Diagnósticos | Diagnósticos asociados a cada historia |
| Tratamientos | Tratamientos indicados |
| Medicamentos | Catálogo de medicamentos |
| Inventario | Existencias y control de insumos |
| Actividades | Actividades y gestión por usuario |
| Usuarios | Cuentas, perfiles y permisos |
| Perfiles | Roles del sistema |
| Auditoría | Registro de eventos y accesos |
| Documentos | Carga y descarga segura de archivos |
| Configuración | Parámetros de seguridad y del asistente |
| Mi perfil | Datos propios y cambio de contraseña |
| Reportes | Consolidados del sistema |

---

## Seguridad implementada

- Contraseñas almacenadas con **BCrypt**.
- Política de contraseñas centralizada (longitud y caracteres especiales).
- **Bloqueo de cuenta** tras varios intentos fallidos (configurable).
- **Expiración de sesión** por inactividad, configurable sin reiniciar.
- Validación de la **huella del navegador** en la sesión.
- **Permisos por actividad** con concesión/denegación por usuario.
- Recuperación de contraseña mediante **token temporal**.
- **Auditoría** de inicios de sesión y acciones.
- Protección contra **CSRF** en formularios.
- Validación de archivos por **extensión y magic bytes**.
- Manejo centralizado de errores con **log** y página genérica (sin trazas al usuario).
- Mensajes de error genéricos en el login (no revelan si el usuario existe).

El detalle de cada control y sus pruebas está en [`CAMBIOS_SEGURIDAD.md`](CAMBIOS_SEGURIDAD.md).

---

## Tecnologías

| Componente | Versión / Detalle |
|---|---|
| Lenguaje | Java 17 |
| Web | JSP + Servlets (Jakarta EE 11) |
| Servidor | Apache Tomcat 11 |
| Base de datos | MySQL 8.0 |
| Driver | mysql-connector-j 9.6.0 |
| Hash | jBCrypt 0.4 |
| Contenedores | Docker + Docker Compose |
| Nube | Azure App Service (Linux) + Azure Database for MySQL Flexible Server |

---

## Requisitos

**Opción Docker (recomendada para revisión):**

- Docker Desktop con Docker Compose.

**Opción local:**

- JDK 17 o superior.
- Apache Tomcat 11.
- MySQL 8 en `localhost:3306`.
- NetBeans (opcional, para abrir el proyecto).

---

## Ejecución rápida con Docker

Desde la raíz del proyecto:

```bash
docker compose up -d --build
```

La primera vez se crea el contenedor de MySQL y se importa automáticamente el dump `docker/mysql/init/01-hospitaldb.sql`.

| Servicio | URL / Puerto |
|---|---|
| Aplicación | http://localhost:8081/ProyectoFina8semestre/ |
| MySQL | `127.0.0.1:3307` (solo accesible desde el equipo) |

Detener:

```bash
docker compose down
```

Detener y borrar la base de datos (vuelve a importar el dump en el siguiente arranque):

```bash
docker compose down -v
```

Guía completa: [`DOCKER.md`](DOCKER.md).

---

## Ejecución en NetBeans / Tomcat local

1. **Crear la base de datos** con el esquema base:

   ```bash
   mysql -u root -p < src/java/modelo/BD.sql
   ```

   Para tener los 5.547 pacientes de demostración, importa el dump completo:

   ```bash
   mysql -u root -p < docker/mysql/init/01-hospitaldb.sql
   ```

2. **Abrir el proyecto** en NetBeans (`File > Open Project`).

3. **Configurar Tomcat 11** como servidor del proyecto (Java 17).

4. **Configurar la conexión.** La clase `src/java/modelo/Conexion.java` lee variables de entorno y, si no existen, usa valores locales por defecto:

   | Variable | Valor por defecto |
   |---|---|
   | `NOVAMED_DB_HOST` | `localhost:3306` |
   | `NOVAMED_DB_NAME` | `HospitalDB` |
   | `NOVAMED_DB_USER` | `root` |
   | `NOVAMED_DB_PASS` | `123` |
   | `NOVAMED_DB_URL` | (opcional, URL JDBC completa) |

5. **Ejecutar** el proyecto. La aplicación queda en:

   ```
   http://localhost:8080/ProyectoFina8semestre/
   ```

> `web/META-INF/context.xml` contiene `suspendWrappedResponseAfterForward="false"`, necesario en Tomcat 11 para que el filtro del asistente pueda inyectar el widget después de un `forward()`. No lo elimines.

---

## Despliegue en Azure

Resumen del proceso:

1. Crear un **Azure Database for MySQL Flexible Server**.
2. Crear un **App Service (Linux)** con runtime `TOMCAT:11.0-java17`.
3. Configurar en el App Service las variables `NOVAMED_DB_URL`, `NOVAMED_DB_USER` y `NOVAMED_DB_PASS`.
4. Generar el WAR:

   ```powershell
   powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1
   ```

5. Publicarlo como `ROOT.war`:

   ```powershell
   powershell -ExecutionPolicy Bypass -File deploy\deploy-war.ps1 `
     -ResourceGroup "rg-novamed" -AppName "novamed-app-88257"
   ```

Guía paso a paso: [`DESPLIEGUE_AZURE.md`](DESPLIEGUE_AZURE.md).
Costos y administración de la base: [`COSTOS_AZURE.md`](COSTOS_AZURE.md).

> **Las credenciales de la infraestructura de Azure no se incluyen en el repositorio.** El archivo `deploy/azure-deploy.json` está excluido por `.gitignore`.

---

## Credenciales de prueba

| Usuario | Contraseña | Perfil |
|---|---|---|
| `admin` | `Admin#2026` | Administrador |
| `usr2000` | `Temporal#2026` | Usuario |

En Docker, el usuario de la base de datos es `novamed` / `NovaMed#2026` (valor local de demostración, definido en `docker-compose.yml`).

---

## Estructura del proyecto

```
ProyectoFina8semestre/
├── src/java/
│   ├── config/          Configuración general
│   ├── controlador/     Servlets (uno por módulo)
│   ├── filtros/         FiltroErrores, FiltroSesion, FiltroAsistente
│   ├── Interfaces/      Interfaces DAO
│   └── modelo/          DAOs, entidades, conexión y scripts SQL
├── web/                 JSPs, CSS, JS, imágenes y WEB-INF
│   └── META-INF/        context.xml de Tomcat
├── lib/                 Dependencias (MySQL Connector, jBCrypt)
├── deploy/              Scripts de build y despliegue en Azure
├── docker/              Inicialización de MySQL y logs
├── Dockerfile
├── docker-compose.yml
└── *.md                 Documentación
```

---

## Documentación

| Documento | Contenido |
|---|---|
| [`CAMBIOS_SEGURIDAD.md`](CAMBIOS_SEGURIDAD.md) | Controles de seguridad y casos de prueba |
| [`CAMBIOS_APLICADOS.md`](CAMBIOS_APLICADOS.md) | Correcciones, limpieza y portabilidad |
| [`DESPLIEGUE_AZURE.md`](DESPLIEGUE_AZURE.md) | Publicación paso a paso en Azure |
| [`DOCKER.md`](DOCKER.md) | Ejecución con contenedores |
| [`COSTOS_AZURE.md`](COSTOS_AZURE.md) | Costos y administración de la base en Azure |
| [`ASISTENTE_RETELL.md`](ASISTENTE_RETELL.md) | Integración del asistente virtual |
| [`PROMPT_AGENTE_RETELL.txt`](PROMPT_AGENTE_RETELL.txt) | Instrucciones del agente de Retell |

---

## Datos y privacidad

El dump incluido (`docker/mysql/init/01-hospitaldb.sql`) contiene **datos completamente sintéticos**: nombres, documentos, teléfonos, direcciones y correos fueron generados para la demostración (por ejemplo `DOC0000401`, `paciente401@example.test`). **No contiene información real de pacientes.**

Las claves de infraestructura, tokens y archivos de estado se mantienen fuera del repositorio mediante `.gitignore`.

---

## Autor

Proyecto académico — Ingeniería de Sistemas.
