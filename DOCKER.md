# Docker – Hospital NovaMed

El proyecto completo (aplicación + base de datos) se levanta con **dos contenedores**:

| Contenedor | Imagen | Función | Puerto en el host |
|---|---|---|---|
| `novamed-app` | Tomcat 11 + Java 17 construida desde `Dockerfile` | Sirve el WAR en `/ProyectoFina8semestre` | **8081** |
| `novamed-db` | `mysql:8.0.41` | Base `HospitalDB` con los datos iniciales | **3307** |

```
Navegador → localhost:8081 → Tomcat → db:3306 (MySQL) → volumen db_data
```

La app se compila **dentro de la imagen** (igual que `deploy\build-war.ps1`), así que no necesitas Java ni NetBeans para construirla: solo Docker.

---

## 1. Requisitos

- Docker Desktop instalado y **corriendo**.
- Puertos **8081** y **3307** libres (se cambian en `.env`).
- ~1 GB de disco para las imágenes.

Comprueba:

```powershell
docker info
```

Si falla, abre Docker Desktop y espera a que diga *Engine running*.

---

## 2. Levantar todo

Desde la raíz del proyecto:

```powershell
docker compose up -d --build
```

O con el helper, que además espera a que esté saludable:

```powershell
powershell -ExecutionPolicy Bypass -File deploy\docker-up.ps1
```

Abrir: **<http://localhost:8081/ProyectoFina8semestre/>**

Credenciales de los datos cargados:

| Usuario | Clave | Perfil |
|---|---|---|
| `admin` | `Admin#2026` | Administrador |
| `usr2000` | `Temporal#2026` | Administrador (demo) |

> Si cambiaste la clave de `admin` en tu MySQL local, en Docker se carga la que tenía el dump. Para regenerarlo, ver la sección 6.

### Ver el estado y los logs

```powershell
docker compose ps
docker compose logs -f app
docker compose logs -f db
```

El log de errores de la aplicación queda en `docker\logs\novamed-error.log`.

---

## 3. Qué contiene cada archivo

| Archivo | Función |
|---|---|
| `Dockerfile` | Etapa 1: compila `src/java` y arma el WAR. Etapa 2: Tomcat 11 + WAR + curl para healthcheck. |
| `docker-compose.yml` | Servicios `app` y `db`, red interna, volúmenes, healthchecks y variables. |
| `.dockerignore` | Deja fuera del build lo que no se necesita y los archivos con secretos. |
| `.env.example` | Puertos y claves; cópialo como `.env` si quieres cambiarlos. |
| `docker/mysql/init/01-hospitaldb.sql` | Dump de la base local (estructura + datos). Se carga **solo** la primera vez. |
| `docker/logs/` | Log de la aplicación visible desde Windows. |
| `deploy/docker-up.ps1` | Levanta y espera el healthcheck. |
| `deploy/docker-dump.ps1` | Regenera el dump desde el MySQL local. |

### Variables de entorno de la app

| Variable | Valor en Docker |
|---|---|
| `NOVAMED_DB_URL` | `jdbc:mysql://db:3306/HospitalDB?useSSL=false&allowPublicKeyRetrieval=true...` |
| `NOVAMED_DB_HOST` | `db:3306` |
| `NOVAMED_DB_NAME` | `HospitalDB` |
| `NOVAMED_DB_USER` | `novamed` |
| `NOVAMED_DB_PASS` | `NovaMed#2026` (cambiable en `.env`) |
| `NOVAMED_LOG_DIR` | `/usr/local/tomcat/logs` |
| `NOVAMED_UPLOAD_DIR` | `/data/uploads` |
| `TZ` | `UTC` (igual que Azure) |

La URL completa se usa porque dentro de la red de Docker no hace falta TLS. Fuera de ella, `Conexion.java` sigue exigiendo SSL cuando el host no es localhost.

---

## 4. Base de datos

### Desde el host

- Host: `127.0.0.1`
- Puerto: **3307**
- Base: `HospitalDB`
- Usuario: `novamed`
- Clave: `NovaMed#2026`

```powershell
mysql -h 127.0.0.1 -P 3307 -u novamed -p HospitalDB
```

### Desde otro contenedor

Host `db`, puerto `3306`.

### Consola dentro del contenedor

```powershell
docker compose exec db mysql -unovamed -pNovaMed#2026 HospitalDB
```

### Por qué `lower-case-table-names=1`

El código escribe `Usuario`, `Perfil`, `gesActividad`, pero en Linux MySQL
distingue mayúsculas y minúsculas. El contenedor se inicializa con
`lower_case_table_names=1` para que `Usuario` y `usuario` sean la misma tabla,
igual que en Windows y en Azure.

> Ese valor **solo se puede fijar al crear el volumen**. Si el volumen ya
> existe con otro valor, MySQL no arranca. Solución: `docker compose down -v`
> (borra los datos) y vuelve a levantar.

---

## 5. Comandos útiles

```powershell
# Detener sin borrar datos (los contenedores quedan creados)
docker compose stop

# Volver a encender
docker compose start

# Detener y eliminar contenedores (los volumenes se conservan)
docker compose down

# Reiniciar
docker compose restart

# Reconstruir solo la app tras cambiar codigo
docker compose build app
docker compose up -d

# Ver uso de recursos
docker stats

# Entrar al contenedor de la app
docker compose exec app bash

# Copiar un archivo subido
docker compose cp novamed-app:/data/uploads/. .\docker\uploads\
```

### Respaldo de la base

```powershell
docker compose exec -T db mysqldump -uroot -pnovamed_root_2026 `
  --single-transaction HospitalDB > respaldo-docker.sql
```

### Restaurar un respaldo

```powershell
Get-Content respaldo-docker.sql | docker compose exec -T db `
  mysql -uroot -pnovamed_root_2026 HospitalDB
```

---

## 6. Actualizar los datos iniciales

El dump se carga **solo cuando el volumen `db_data` está vacío**. Para refrescarlo desde tu MySQL local:

```powershell
powershell -ExecutionPolicy Bypass -File deploy\docker-dump.ps1
docker compose down -v
docker compose up -d --build
```

`down -v` borra la base y los documentos subidos en Docker. No afecta tu MySQL local ni Azure.

También puedes importar un respaldo de Azure:

```powershell
Get-Content hospitaldb.sql | docker compose exec -T db `
  mysql -uroot -pnovamed_root_2026 HospitalDB
```

---

## 7. Solución de problemas

| Síntoma | Causa / solución |
|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop no está corriendo. |
| `port is already allocated` | El 8081 o 3307 están ocupados. Cámbialos en `.env` (`NOVAMED_HTTP_PORT`, `NOVAMED_DB_PORT`). |
| MySQL reinicia en bucle con error de `lower_case_table_names` | El volumen se creó con otro valor. `docker compose down -v` y volver a levantar. |
| La app muestra error de conexión | Revisa `docker compose logs db`; espera el healthcheck. La app reintenta en cada petición. |
| `Table 'HospitalDB.Usuario' doesn't exist` | El contenedor no tiene `lower-case-table-names=1` o el dump no se cargó. Revisa `docker compose logs db` y recrea el volumen. |
| El asistente Retell no aparece | El dump trae `retell_habilitado=1` con la public key del proyecto. Si usaste otra base, revisa **Configuración**. |
| El healthcheck sigue en `starting` | Tomcat tarda ~30–60 s en desplegar el WAR. Espera o mira `docker compose logs -f app`. |
| Los acentos se ven mal | El WAR se compila con `-encoding UTF-8` y la base usa `utf8mb4`; verifica que el navegador no esté forzando otra codificación. |

---

## 8. Diferencias con Azure

| | Docker local | Azure |
|---|---|---|
| URL | `http://localhost:8081/ProyectoFina8semestre/` | `https://novamed-app-88257.azurewebsites.net/` |
| Contexto del WAR | `ProyectoFina8semestre.war` | `ROOT.war` (raíz) |
| Base | Contenedor MySQL 8.0.41 | MySQL Flexible Server 8.0.21 |
| SSL | Desactivado en la red interna | Obligatorio |
| Datos | Dump de `docker/mysql/init` | Datos reales migrados |
| Zona horaria | UTC | UTC |

El mismo WAR funciona en ambos: la conexión se decide por variables de entorno.

---

## 9. Seguridad

- `.dockerignore` excluye `.env`, `deploy/azure-deploy.json` y `deploy/azure-secrets.txt`.
- El contenedor de la app **no** corre como root de MySQL: usa el usuario `novamed`, con permisos solo sobre `HospitalDB`.
- No publiques el puerto 3307 en Internet. Por defecto queda atado a `127.0.0.1`, así que solo tu equipo puede conectarse a MySQL.
- El dump incluye datos de demostración y la **public key** de Retell (pública por diseño). No incluye la API key secreta.
- Si el proyecto se publica en un repositorio, revisa el contenido de `docker/mysql/init/01-hospitaldb.sql` antes de subirlo.
