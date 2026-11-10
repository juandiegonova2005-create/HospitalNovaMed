# Despliegue en Azure — Hospital NovaMed

Guía para publicar el proyecto **JSP + Tomcat + MySQL** en Internet usando:

- **Azure App Service (Linux)** con **Tomcat 11 + Java 17** → ejecuta el WAR.
- **Azure Database for MySQL Flexible Server** → base de datos administrada.

Resultado: `https://<tu-app>.azurewebsites.net/`

> Para ver dónde está la base de datos, dónde se configura la aplicación y
> cuánto consume al día, consulta [`COSTOS_AZURE.md`](COSTOS_AZURE.md).

> El proyecto ya está preparado: compila para Java 17, lee la conexión desde
> variables de entorno y el WAR no incluye `context.xml`.
>
> En App Service (Tomcat en Linux) el WAR **debe llamarse `ROOT.war`** para
> publicarse en la **raíz** del dominio (`/`). Si lo subes con el nombre
> `ProyectoFina8semestre.war`, el archivo llega a `/home/site/wwwroot` pero
> Tomcat sigue sirviendo el `ROOT.war` anterior. Renómbralo antes de desplegar:

```powershell
Copy-Item dist\ProyectoFina8semestre.war "$env:TEMP\ROOT.war" -Force
az webapp deploy -g <grupo> -n <app> --src-path "$env:TEMP\ROOT.war" --type war
```

---

## Ruta rápida (recomendada)

Con Azure CLI instalado y la sesión iniciada (`az login`), un solo comando hace
todo: crea los recursos, **exporta tu `HospitalDB` local**, importa los datos,
crea el usuario de la aplicación, configura las variables de entorno, genera el
WAR y lo publica.

```powershell
cd "C:\Users\JUAN DIEGO\OneDrive\Documentos\NetBeansProjects\ProyectoFina8semestre"
powershell -ExecutionPolicy Bypass -File deploy\desplegar-azure.ps1
```

- Guarda nombres y contraseñas en `deploy\azure-deploy.json` (privado).
- Si algo falla, puedes volver a ejecutarlo: reutiliza los mismos recursos.
- Registra automáticamente los proveedores de Azure que falten
  (`Microsoft.DBforMySQL`, `Microsoft.Web`, `Microsoft.Storage`,
  `Microsoft.Insights`); en cuentas nuevas esto es habitual y no tiene costo.
- Para empezar de cero: agrega `-Reset` (no borra recursos de Azure).
- Para cambiar región o tamaño: `-Location "chilecentral" -Sku "B1"`.

El resto de la guía explica cada paso manualmente por si prefieres hacerlo tú o
necesitas ajustar algo.

---

## 1. Qué necesitas

1. Una cuenta de Azure:
   - **Azure for Students** (gratis, 100 USD de crédito, sin tarjeta) o
   - una suscripción de pago.
2. **Azure CLI** instalado: <https://aka.ms/installazurecli>
3. **Cliente MySQL** (opcional, para importar datos):
   `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`
4. El WAR generado con:

```powershell
cd "C:\Users\JUAN DIEGO\OneDrive\Documentos\NetBeansProjects\ProyectoFina8semestre"
powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1 `
  -TomcatHome "C:\Program Files\Apache Software Foundation\Tomcat 11.0"
```

Salida esperada: `dist\ProyectoFina8semestre.war`.

---

## 2. Variables de conexión que entiende la aplicación

`src/java/config/Conexion.java` lee estas variables de entorno:

| Variable | Ejemplo | Obligatoria |
|---|---|---|
| `NOVAMED_DB_HOST` | `novamed-mysql.mysql.database.azure.com:3306` | Sí (si no usas URL) |
| `NOVAMED_DB_NAME` | `HospitalDB` | Sí (si no usas URL) |
| `NOVAMED_DB_USER` | `novamed` | Sí |
| `NOVAMED_DB_PASS` | `••••••••` | Sí |
| `NOVAMED_DB_URL` | `jdbc:mysql://host:3306/HospitalDB?sslMode=REQUIRED&serverTimezone=UTC&characterEncoding=UTF-8` | Opcional, tiene prioridad |

Si `NOVAMED_DB_URL` está definida, se usa tal cual y se ignoran host/nombre.
Si el host es `localhost` o `127.0.0.1`, la app agrega `useSSL=false`; en la nube
agrega `sslMode=REQUIRED` automáticamente.

---

## 3. Crear recursos en Azure

Abre **PowerShell** y define tus datos. Cambia la contraseña.

```powershell
# --- Ajusta estos valores ---
$RG      = "rg-novamed"
$LOC     = "chilecentral"
$SUFFIX  = Get-Random -Maximum 99999
$MYSQL   = "novamed-mysql-$SUFFIX"
$APP     = "novamed-app-$SUFFIX"
$DBADMIN = "novamedadmin"
$DBPASS  = "CambiaEstaClave!2026"     # mínimo 8, mayúscula, número y símbolo
$APPUSER = "novamed"
$APPPASS = "OtraClaveSegura!2026"
```

> **Regiones en Azure for Students:** la suscripción tiene la política
> `Allowed resource deployment regions`, que solo permite
> `chilecentral`, `brazilsouth`, `spaincentral`, `francecentral` y
> `northcentralus`. Si usas otra región verás
> `RequestDisallowedByAzure`. Además, cada región puede no tener capacidad
> para MySQL (`No available SKUs in this location`); si ocurre, prueba otra
> de la lista. Para consultar las permitidas:
>
> ```powershell
> az policy assignment show --name sys.regionrestriction `
>   --query "parameters.listOfAllowedLocations.value" -o tsv
> ```

### 3.1 Iniciar sesión

```powershell
az login
az account show --output table
# Si tienes varias suscripciones:
# az account set --subscription "<id-o-nombre>"
```

### 3.2 Grupo de recursos

```powershell
az group create --name $RG --location $LOC
```

### 3.3 MySQL Flexible Server

```powershell
az mysql flexible-server create `
  --resource-group $RG `
  --name $MYSQL `
  --location $LOC `
  --admin-user $DBADMIN `
  --admin-password $DBPASS `
  --version 8.0.21 `
  --tier Burstable `
  --sku-name Standard_B1ms `
  --storage-size 32 `
  --public-access 0.0.0.0
```

> `--public-access 0.0.0.0` permite conexiones desde servicios de Azure
> (App Service) y **no** desde Internet en general. La conexión va cifrada
> porque la app usa `sslMode=REQUIRED`.

Crea la base de datos:

```powershell
az mysql flexible-server db create `
  --resource-group $RG `
  --server-name $MYSQL `
  --database-name HospitalDB
```

Si vas a importar datos **desde tu PC**, agrega temporalmente tu IP pública:

```powershell
$miIp = (Invoke-RestMethod https://api.ipify.org)
az mysql flexible-server firewall-rule create `
  --resource-group $RG --name $MYSQL `
  --rule-name MiIP --start-ip-address $miIp --end-ip-address $miIp
```

Al terminar la importación puedes borrar la regla:

```powershell
az mysql flexible-server firewall-rule delete `
  --resource-group $RG --name $MYSQL --rule-name MiIP --yes
```

---

## 4. Importar la base de datos

### Opción A — Instalación nueva (crea tablas y usuario admin)

Usa el script del proyecto. Crea la base, las tablas y un usuario
**admin / Admin123**:

```powershell
$MYSQL_BIN = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$HOST = "$MYSQL.mysql.database.azure.com"
$SQL  = "src\java\modelo\BD.sql"

& $MYSQL_BIN -h $HOST -u $DBADMIN -p --ssl-mode=REQUIRED --default-character-set=utf8mb4 `
  -e "source $((Resolve-Path $SQL).Path.Replace('\','/'))"
```

### Opción B — Llevar tus datos actuales (recomendada si ya registraste pacientes)

1. Exporta tu base local:

```powershell
$DUMP_BIN = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"
& $DUMP_BIN -u root -p --databases HospitalDB --single-transaction `
  --routines --triggers --set-gtid-purged=OFF --default-character-set=utf8mb4 `
  > novamed-dump.sql
```

2. Impórtala en Azure:

```powershell
& $MYSQL_BIN -h $HOST -u $DBADMIN -p --ssl-mode=REQUIRED --default-character-set=utf8mb4 `
  -e "source $((Resolve-Path .\novamed-dump.sql).Path.Replace('\','/'))"
```

3. Crea las tablas clínicas que falten (seguro e idempotente, no borra datos):

```powershell
& $MYSQL_BIN -h $HOST -u $DBADMIN -p --ssl-mode=REQUIRED --default-character-set=utf8mb4 `
  -e "source $((Resolve-Path .\src\java\modelo\migracion_clinicas.sql).Path.Replace('\','/'))"
```

4. Crea el usuario de la aplicación (permisos mínimos):

```powershell
$sql = "CREATE USER IF NOT EXISTS '$APPUSER'@'%' IDENTIFIED BY '$APPPASS'; " +
       "GRANT SELECT, INSERT, UPDATE, DELETE ON HospitalDB.* TO '$APPUSER'@'%'; " +
       "FLUSH PRIVILEGES;"
& $MYSQL_BIN -h $HOST -u $DBADMIN -p --ssl-mode=REQUIRED -e $sql
```

> El script `deploy\desplegar-azure.ps1` ya hace los pasos 3 y 4
> automáticamente. Si no creas las tablas clínicas, el dashboard mostrará “—”
> en esas tarjetas (los datos existentes no se pierden).

---

## 5. Crear el App Service con Tomcat

Comprueba los runtimes disponibles:

```powershell
az webapp list-runtimes --os linux | Select-String "TOMCAT"
```

Valor recomendado (coincide con el Tomcat usado para compilar):

```text
TOMCAT:11.0-java17
```

Crea el plan y la aplicación web:

```powershell
az appservice plan create `
  --resource-group $RG --name "plan-novamed" `
  --is-linux --sku B1

az webapp create `
  --resource-group $RG --plan "plan-novamed" --name $APP `
  --runtime "TOMCAT:11.0-java17"
```

> Alternativas válidas: `TOMCAT:10.1-java21` o `TOMCAT:10.1-java17`. El WAR
> está compilado con `--release 17`, así que funciona en Java 17 o superior.

### 5.1 Configurar la conexión (variables de entorno)

```powershell
az webapp config appsettings set `
  --resource-group $RG --name $APP `
  --settings `
    NOVAMED_DB_HOST="$MYSQL.mysql.database.azure.com:3306" `
    NOVAMED_DB_NAME="HospitalDB" `
    NOVAMED_DB_USER="$APPUSER" `
    NOVAMED_DB_PASS="$APPPASS"
```

Alternativa con URL completa:

```powershell
az webapp config appsettings set -g $RG -n $APP --settings `
  NOVAMED_DB_URL="jdbc:mysql://$MYSQL.mysql.database.azure.com:3306/HospitalDB?sslMode=REQUIRED&serverTimezone=UTC&characterEncoding=UTF-8" `
  NOVAMED_DB_USER="$APPUSER" `
  NOVAMED_DB_PASS="$APPPASS"
```

> Importante: en PowerShell, si la URL contiene `&`, va entre comillas dobles
> (como arriba) para que no se interprete como fin de comando.

---

## 6. Desplegar el WAR

> **Importante:** en App Service (Tomcat en Linux) el WAR debe llamarse
> `ROOT.war`. Si subes `ProyectoFina8semestre.war`, el archivo queda en
> `/home/site/wwwroot` pero Tomcat sigue sirviendo el `ROOT.war` anterior.

```powershell
# 1) compilar
powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1 `
  -TomcatHome "C:\Program Files\Apache Software Foundation\Tomcat 11.0"

# 2) publicar como ROOT.war
Copy-Item dist\ProyectoFina8semestre.war "$env:TEMP\ROOT.war" -Force
az webapp deploy `
  --resource-group $RG --name $APP `
  --src-path "$env:TEMP\ROOT.war" `
  --type war
```

Espera 1–3 minutos y abre:

```text
https://<tu-app>.azurewebsites.net/
```

La primera carga compila los JSP y puede tardar unos segundos.

### Carpetas persistentes y variables de entorno

Además de las variables de conexión (`NOVAMED_DB_*`), la aplicación entiende:

| Variable | Valor recomendado en Azure | Para qué |
|---|---|---|
| `NOVAMED_LOG_DIR` | `/home/LogFiles` | Carpeta de `novamed-error.log` (persistente). |
| `NOVAMED_UPLOAD_DIR` | `/home/data/documentos` | Carpeta de los documentos subidos. |

```powershell
az webapp config appsettings set -g $RG -n $APP --settings `
  NOVAMED_LOG_DIR="/home/LogFiles" `
  NOVAMED_UPLOAD_DIR="/home/data/documentos"
```

Sin esas variables la app usa `{catalina.base}/logs` y
`{catalina.base}/novamed-documentos`, con respaldo en `{HOME}` y en la carpeta
temporal. En Azure el sistema de archivos del contenedor es de solo lectura
salvo `/home`, por eso conviene fijarlas.

### Correo para "Olvidé mi contraseña"

La recuperación genera un enlace de un solo uso que vence en 30 minutos. Para
que el correo se envíe de verdad, configura un servidor SMTP:

| Variable | Ejemplo (Gmail) |
|---|---|
| `NOVAMED_SMTP_HOST` | `smtp.gmail.com` |
| `NOVAMED_SMTP_PORT` | `587` |
| `NOVAMED_SMTP_USER` | `tucorreo@gmail.com` |
| `NOVAMED_SMTP_PASS` | clave de aplicación de 16 caracteres |
| `NOVAMED_SMTP_FROM` | `tucorreo@gmail.com` |
| `NOVAMED_SMTP_SSL` | `false` (usa `true` con el puerto 465) |

```powershell
az webapp config appsettings set -g $RG -n $APP --settings `
  NOVAMED_SMTP_HOST="smtp.gmail.com" `
  NOVAMED_SMTP_PORT="587" `
  NOVAMED_SMTP_USER="tucorreo@gmail.com" `
  NOVAMED_SMTP_PASS="<clave-de-aplicacion>" `
  NOVAMED_SMTP_FROM="tucorreo@gmail.com" `
  NOVAMED_SMTP_SSL="false"
```

Si no se configuran, el enlace se escribe en `novamed-error.log` (modo
desarrollo) y el flujo sigue funcionando. El enlace se envía al correo guardado
en `usuario.email`, así que ese dato debe ser un buzón real: el usuario `admin`
del dump tiene un correo ficticio (`admin@hospital.com`).

### Verificar que quedó bien

```powershell
# Estado y URL
az webapp show -g $RG -n $APP --query "{estado:state, url:defaultHostName, runtime:siteConfig.linuxFxVersion}" -o table

# Logs en vivo (Ctrl+C para salir)
az webapp log tail -g $RG -n $APP

# Descargar los logs (incluye /home/LogFiles)
az webapp log download -g $RG -n $APP --log-file logs.zip
```

Los errores propios de la app se escriben en `novamed-error.log` dentro de
`/home/LogFiles` (o en la carpeta que indique `NOVAMED_LOG_DIR`).

---

## 7. Actualizar la aplicación

Cada vez que cambies código:

```powershell
powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1 `
  -TomcatHome "C:\Program Files\Apache Software Foundation\Tomcat 11.0"

Copy-Item dist\ProyectoFina8semestre.war "$env:TEMP\ROOT.war" -Force
az webapp deploy -g $RG -n $APP --src-path "$env:TEMP\ROOT.war" --type war
```

### 7.1 Actualizar una base que ya existe

Cuando la base ya tiene datos (por ejemplo, los 5.547 pacientes), **no** vuelvas
a importar el respaldo. Aplica las migraciones idempotentes:

```powershell
mysql -h <servidor>.mysql.database.azure.com -P 3306 -u novamedadmin -p `
  --ssl-mode=REQUIRED --default-character-set=utf8mb4 `
  -e "source C:/ruta/al/proyecto/src/java/modelo/migracion_mejoras.sql"
```

`migracion_mejoras.sql` crea `configuracion`, `usuario_actividad` y
`documentos`, agrega las actividades nuevas y normaliza las contraseñas que no
sean BCrypt. Es seguro ejecutarla varias veces.

Si vas a usar el asistente virtual, aplica también su migración (no sobrescribe
lo que ya hayas configurado):

```powershell
mysql -h <servidor>.mysql.database.azure.com -P 3306 -u novamedadmin -p `
  --ssl-mode=REQUIRED --default-character-set=utf8mb4 `
  -e "source C:/ruta/al/proyecto/src/java/modelo/migracion_asistente.sql"
```

Luego entra a **Configuración → Asistente virtual (Retell AI)** y guarda la
public key y el agent ID. El detalle está en `ASISTENTE_RETELL.md`.

Las cuentas demo migradas usan la clave temporal `Temporal#2026`. La cuenta
`admin` existente **conserva** su clave; si no la recuerdas, usa una cuenta
administradora de prueba o el flujo “Olvidé mi contraseña”.

### 7.2 Firewall de MySQL para probar desde tu equipo

```powershell
# alta temporal (tu IP actual)
az mysql flexible-server firewall-rule create `
  -g $RG --name $MYSQL --rule-name AllowMiIp `
  --start-ip-address <tu-ip> --end-ip-address <tu-ip>

# baja al terminar
az mysql flexible-server firewall-rule delete `
  -g $RG --name $MYSQL --rule-name AllowMiIp
```

La app desplegada no necesita esta regla: App Service entra por las reglas de
servicios de Azure. La regla solo es para aplicar migraciones o revisar datos
desde tu equipo.

Si el navegador muestra la versión anterior:

```powershell
az webapp restart -g $RG -n $APP
```

---

## 8. Costos aproximados (USD/mes, región chilecentral)

| Recurso | Configuración | Aprox. |
|---|---|---|
| App Service Plan | B1 Linux (1 núcleo, 1.75 GB) | ~13 |
| App Service Plan | F1 Linux (gratis, 60 min CPU/día) | 0 |
| MySQL Flexible | Burstable B1ms + 32 GB | ~16 |
| **Total** | B1 + MySQL | **~29** |
| **Total** | F1 + MySQL | **~16** |

- **Azure for Students** incluye 100 USD de crédito: alcanza para varios meses.
- Para una demo puedes usar **F1** en App Service y mantener MySQL B1ms.
- Los precios cambian por región y por convenio; confírmalos en el portal.
- Apaga o elimina los recursos cuando no los uses:

```powershell
az group delete --name $RG --yes --no-wait
```

---

## 9. Alternativas si no quieres pagar Azure completo

| Combinación | Ventaja | Limitación |
|---|---|---|
| App Service **F1** + MySQL gratuito externo (Aiven, Clever Cloud, Railway) | Casi 0 USD | Límite de CPU diario; latencia |
| **Docker** (incluido) en Render / Railway / Fly.io | Despliegue simple | Suele requerir MySQL externo |
| VM gratuita de Oracle Cloud + Tomcat + MySQL | Gratis permanente | Administras el servidor |
| Solo local con Ngrok/Cloudflare Tunnel | 0 USD, rápido | Tu PC debe estar encendida |

El proyecto incluye un `Dockerfile` listo (Tomcat 11 + Java 17):

```powershell
docker build -t novamed .
docker run --rm -p 8080:8080 `
  -e NOVAMED_DB_HOST="host:3306" `
  -e NOVAMED_DB_NAME="HospitalDB" `
  -e NOVAMED_DB_USER="usuario" `
  -e NOVAMED_DB_PASS="clave" `
  novamed
```

Abre `http://localhost:8080/ProyectoFina8semestre/`.

---

## 10. Seguridad mínima antes de publicar

1. **Cambia la contraseña del usuario `admin`.**
   La instalación nueva trae `admin / Admin123`.
2. Usa un usuario de base de datos distinto de `novamedadmin`, con permisos
   solo sobre `HospitalDB` (el script de la sección 4 lo crea así).
3. Fuerza HTTPS:

```powershell
az webapp update -g $RG -n $APP --https-only true
```

4. Desactiva FTP:

```powershell
az webapp config set -g $RG -n $APP --ftps-state Disabled
```

5. Elimina la regla de firewall de tu IP cuando termines de importar.
6. No subas contraseñas al repositorio: van solo en *App Settings*.
7. La recuperación de contraseña **no envía correo real** (solo escribe en el
   log). Está documentado en `CAMBIOS_SEGURIDAD.md`.

---

## 11. Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `404` en `/ProyectoFina8semestre/` | El WAR se publicó en la raíz | Abre `https://<tu-app>.azurewebsites.net/` |
| `404` en `/` | El WAR no se desplegó | Revisa `az webapp log tail`; vuelve a desplegar |
| El login dice "servicio no disponible" | La app no conecta a MySQL | Revisa `NOVAMED_DB_HOST` (debe incluir `:3306`) y las reglas del servidor MySQL |
| `500` al abrir el dashboard | Faltan tablas clínicas | Importa `BD.sql` completo o crea las tablas |
| `Communications link failure` | Firewall o host incorrecto | Verifica `NOVAMED_DB_HOST` y las reglas del servidor MySQL |
| `SSLConnectionRequired` / error TLS | Falta SSL | Usa `sslMode=REQUIRED` o deja que la app lo agregue |
| `Access denied for user` | Usuario/clave o grants | Revisa `NOVAMED_DB_USER/PASS` y `GRANT` |
| `Public Key Retrieval is not allowed` | Conexión local sin SSL | En local la app ya usa `allowPublicKeyRetrieval=true` |
| Fechas corridas | Zona horaria | La URL usa `serverTimezone=UTC`; ajusta si necesitas otra |
| `502/503` al iniciar | Runtime incompatible o app caída | Usa `TOMCAT:11.0-java17` y revisa logs |
| La sesión se cierra sola | Varias instancias sin afinidad | Mantén 1 instancia o activa *ARR affinity* |
| Un módulo del menú abre en blanco | El enlace en `actividades.enlace` es una URL absoluta (`http://localhost:8080/...`) y el navegador intenta abrir tu PC | Ya se corrige al pintar el menú (`Util.enlaceMenu`). Para limpiar la base: `UPDATE actividades SET enlace = SUBSTRING_INDEX(enlace,'/',-1) WHERE enlace LIKE 'http://localhost:8080/%';` |
| Un listado tarda ~50 s y se corta | El JSP consulta la base una vez por cada fila (N+1); con MySQL remoto cada conexión paga TLS | Junta los datos en una sola consulta o carga las listas auxiliares una vez en un `Map` (como `listaUsuarios.jsp`) |
| `403 - No tienes permisos` en Usuarios/Perfiles/Auditoría | El perfil de la cuenta no es Administrador | Es intencional (`FiltroSesion.SOLO_ADMIN`); entra con una cuenta Administrador |
| Cambios que no aparecen | Caché de Tomcat | `az webapp restart` y recarga forzada |
| `Incorrect value for --version` | Azure CLI nuevo exige versión exacta | Usa `--version 8.0.21` |
| `ResourceGroupNotFound` y el script se detiene | `$ErrorActionPreference = "Stop"` convierte el `stderr` de `az` en error fatal | Usa `deploy\desplegar-azure.ps1` (ya lo maneja) o ejecuta `az` sin `$ErrorActionPreference = "Stop"` |
| `az` no se reconoce tras instalarlo | `PATH` sin actualizar en la sesión | Cierra y reabre PowerShell, o usa `C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd` |
| `MissingSubscriptionRegistration` | Suscripción nueva sin proveedores registrados | `az provider register --namespace Microsoft.DBforMySQL --wait` (el script ya lo hace para MySQL, Web, Storage e Insights) |

---

## 12. Resumen de comandos

```powershell
# 1. WAR
powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1 `
  -TomcatHome "C:\Program Files\Apache Software Foundation\Tomcat 11.0"

# 2. Login
az login

# 3. Grupo
az group create -n rg-novamed -l chilecentral

# 4. MySQL
az mysql flexible-server create -g rg-novamed -n novamed-mysql-12345 -l chilecentral `
  --admin-user novamedadmin --admin-password "Clave!2026" `
  --version 8.0.21 --tier Burstable --sku-name Standard_B1ms --storage-size 32 `
  --public-access 0.0.0.0

az mysql flexible-server db create -g rg-novamed -s novamed-mysql-12345 -d HospitalDB

# 5. App Service
az appservice plan create -g rg-novamed -n plan-novamed --is-linux --sku B1
az webapp create -g rg-novamed -p plan-novamed -n novamed-app-12345 `
  --runtime "TOMCAT:11.0-java17"

# 6. Variables de entorno
az webapp config appsettings set -g rg-novamed -n novamed-app-12345 --settings `
  NOVAMED_DB_HOST="novamed-mysql-12345.mysql.database.azure.com:3306" `
  NOVAMED_DB_NAME="HospitalDB" `
  NOVAMED_DB_USER="novamed" `
  NOVAMED_DB_PASS="OtraClave!2026" `
  NOVAMED_LOG_DIR="/home/LogFiles" `
  NOVAMED_UPLOAD_DIR="/home/data/documentos"

# 7. Desplegar (siempre como ROOT.war)
Copy-Item dist\ProyectoFina8semestre.war "$env:TEMP\ROOT.war" -Force
az webapp deploy -g rg-novamed -n novamed-app-12345 `
  --src-path "$env:TEMP\ROOT.war" --type war

# 8. Ver logs
az webapp log tail -g rg-novamed -n novamed-app-12345
```

URL final:

```text
https://novamed-app-12345.azurewebsites.net/
```
