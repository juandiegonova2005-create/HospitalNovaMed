# Azure: base de datos, configuración y costos – Hospital NovaMed

Este documento responde tres preguntas:

1. Dónde ver la base de datos y la configuración en Azure.
2. Cuánto crédito consume tener la página corriendo.
3. Cómo revisar el gasto real y cómo reducirlo.

> Precios consultados en la API oficial de precios de Azure (Azure Retail
> Prices), región **Chile Central**, en USD y sin impuestos. Fecha de consulta:
> **5 de noviembre de 2026**. Los precios pueden cambiar.

---

## 1. Dónde ver la base de datos

### Desde el portal

1. Entra a <https://portal.azure.com>.
2. Busca **rg-novamed** y abre el grupo de recursos.
3. Abre **novamed-mysql-88257** (tipo *Azure Database for MySQL flexible
   server*).

Dentro del servidor MySQL:

| Opción del menú | Qué muestra |
|---|---|
| **Información general** | Nombre del servidor, estado, región, versión y cadena de conexión. |
| **Compute + storage** | Plan (Burstable B1ms), vCores, RAM y almacenamiento (32 GB). |
| **Bases de datos** | `hospitaldb`, `mysql`, `information_schema`, `performance_schema`, `sys`. |
| **Redes** | Reglas de firewall. La regla `AllowJuanDiegoDev` permite tu IP actual. |
| **Copia de seguridad y restauración** | Retención y restauración a un punto en el tiempo. |
| **Autenticación** | Usuario administrador del servidor. |
| **Registros de diagnóstico** | Envío de logs a Log Analytics o almacenamiento. |

Los datos de conexión (host, usuario, contraseña y base) están en
`deploy/azure-deploy.json`. **No compartas ese archivo** ni pegues la contraseña
en el chat, en el código o en el repositorio.

### Conexión con MySQL Workbench

- Host: `novamed-mysql-88257.mysql.database.azure.com`
- Puerto: `3306`
- Base de datos: `hospitaldb`
- Usuario administrador: `novamedadmin`
- Usuario de la aplicación: `novamed`
- SSL: **Require** (obligatorio en Azure)
- Contraseña: la que está en `deploy/azure-deploy.json`

### Conexión por consola

```powershell
mysql -h novamed-mysql-88257.mysql.database.azure.com -P 3306 `
  -u novamedadmin -p --ssl-mode=REQUIRED hospitaldb
```

### Desde la CLI de Azure

```powershell
az mysql flexible-server show -g rg-novamed -n novamed-mysql-88257 -o table
az mysql flexible-server db list -g rg-novamed -s novamed-mysql-88257 -o table
az mysql flexible-server firewall-rule list -g rg-novamed -n novamed-mysql-88257 -o table
```

---

## 2. Dónde ver la configuración de la aplicación

### Desde el portal

1. En `rg-novamed`, abre **novamed-app-88257** (App Service).
2. Menú izquierdo:
   - **Información general**: URL pública y estado.
   - **Configuración → Variables de entorno** (en portales nuevos,
     *Environment variables*): aquí están `NOVAMED_DB_HOST`, `NOVAMED_DB_NAME`,
     `NOVAMED_DB_USER`, `NOVAMED_DB_PASS`, `NOVAMED_LOG_DIR` y
     `NOVAMED_UPLOAD_DIR`.
   - **Implementación → Centro de implementación**: historial de despliegues.
   - **Supervisión → Flujo de registro**: logs en vivo de Tomcat.
   - **Herramientas de desarrollo → Herramientas avanzadas (Kudu)**: consola y
     sistema de archivos.
   - **Configuración → Configuración general**: versión de Java/Tomcat,
     Always On, ARR affinity, etc.

### Desde la CLI

```powershell
# Nombres y valores de las variables (los valores son secretos)
az webapp config appsettings list -g rg-novamed -n novamed-app-88257 -o table

# Ver solo los nombres, sin exponer valores
az webapp config appsettings list -g rg-novamed -n novamed-app-88257 `
  --query "[].name" -o table

# Estado y URL
az webapp show -g rg-novamed -n novamed-app-88257 `
  --query "{estado:state,url:defaultHostName,kind:kind}" -o json

# Logs en vivo
az webapp log tail -g rg-novamed -n novamed-app-88257
```

### Configuración interna del sistema

La configuración de seguridad y del asistente se edita dentro de la aplicación:

- **Configuración de seguridad** (`Configuracion.jsp`): duración de sesión,
  intentos permitidos, minutos de bloqueo, public key y agent ID de Retell.
- **Mi perfil** (`MiPerfil.jsp`): correo y contraseña del usuario.
- **Permisos por usuario** (`PermisosUsuario.jsp`): concesiones o denegaciones
  puntuales.
- **Auditoría** (`listaAuditoria.jsp`): eventos del sistema.

---

## 3. Cuánto cuesta tener la página corriendo

### Recursos que se cobran

| Recurso | Configuración actual | Precio unitario | Cálculo | Costo mensual |
|---|---|---|---|---|
| App Service | Plan B1 Linux, 1 instancia, Always On | $0.0238 USD/hora | 730 h × $0.0238 | **$17.37** |
| MySQL Flexible Server | Burstable B1ms, 1 vCore | $0.0238 USD/hora | 730 h × $0.0238 | **$17.37** |
| Almacenamiento MySQL | 32 GB | $0.161 USD/GB-mes | 32 × $0.161 | **$5.15** |
| **Total** | | | | **≈ $39.90 USD/mes** |

### Costo por día

$$
39.90 \div 30.42 \approx 1.31
$$

**≈ $1.31 USD por día** (sin impuestos), con la aplicación y la base de datos
encendidas las 24 horas.

| Periodo | Costo aproximado |
|---|---|
| 1 día | $1.31 |
| 7 días | $9.18 |
| 30 días | $39.35 |
| 1 mes (730 h) | $39.90 |

### Cuánto dura el crédito de Azure for Students

Con **$100 USD** de crédito y un consumo de **$1.31 por día**:

$$
100 \div 1.31 \approx 76 \text{ días}
$$

El crédito alcanza para **unos 2 meses y medio** si es el único proyecto
encendido. Si además usas otros servicios, el crédito dura menos.

> El plan B1 y el MySQL B1ms **se cobran aunque nadie visite la página**. No son
> servicios gratuitos por demanda: el plan de App Service se cobra mientras
> exista, y el servidor MySQL se cobra mientras esté encendido.
>
> El almacenamiento de MySQL se cobra aunque el servidor esté detenido.
>
> Las cifras no incluyen impuestos. En Chile puede aplicarse IVA al momento de
> pagar, pero el crédito de estudiante se consume a precio de lista.

### Costos que normalmente son insignificantes

- **Transferencia de datos de salida**: Azure incluye una franja mensual; el
  sitio es pequeño y no debería acercarse al límite.
- **Backup de MySQL**: dentro del almacenamiento provisionado normalmente no
  genera un cargo aparte; si se excede, se cobra.
- **Nombre de host `*.azurewebsites.net`**: incluido.

---

## 4. Cómo revisar el gasto real y el crédito

### Gasto del proyecto

1. Portal de Azure → **Cost Management + Billing** → **Cost analysis**.
2. Filtra por **Resource group: rg-novamed**.
3. Agrupa por **Service name** o **Resource**.
4. Cambia el periodo a **Month to date** o **Last 30 days**.

El portal muestra el costo real acumulado; puede tardar unas horas en
actualizarse.

### Saldo del crédito de estudiante

1. Entra a <https://www.microsoftazuresponsorships.com/>.
2. Inicia sesión con la cuenta con la que activaste Azure for Students.
3. Revisa **Usage** y **Balance**.

Ahí ves el crédito restante y el consumo por servicio.

### Alertas de presupuesto

En **Cost Management → Budgets** puedes crear un presupuesto mensual (por
ejemplo, $40) y una alerta al 80 %. Así evitas quedarte sin crédito sin darte
cuenta.

---

## 5. Cómo reducir el costo

### Opción A: detener MySQL cuando no se use

```powershell
az mysql flexible-server stop -g rg-novamed -n novamed-mysql-88257
```

- Deja de cobrarse el **compute** de MySQL (≈ $0.57/día).
- El **almacenamiento** de 32 GB se sigue cobrando (≈ $0.17/día).
- El servidor se puede detener hasta **30 días**; después Azure lo enciende
  automáticamente.
- Al detenerlo, la aplicación no puede conectarse a la base: el sitio mostrará
  errores hasta que lo inicies.

Para volver a encenderlo:

```powershell
az mysql flexible-server start -g rg-novamed -n novamed-mysql-88257
```

Ahorro aproximado: **$17.37/mes** si lo dejas detenido la mayor parte del tiempo.

### Opción B: bajar el plan de App Service

El plan B1 Linux se puede cambiar a **F1 (Free)** para una demo:

```powershell
az appservice plan update -g rg-novamed -n plan-novamed --sku F1
```

Ten en cuenta:

- F1 tiene límites de CPU y no permite Always On.
- La aplicación puede tardar en despertar.
- No es recomendable para producción.

Para volver a B1:

```powershell
az appservice plan update -g rg-novamed -n plan-novamed --sku B1
```

### Opción C: apagar la aplicación

```powershell
az webapp stop -g rg-novamed -n novamed-app-88257
```

> **Importante:** detener la web **no detiene el cobro del plan**. El plan de
> App Service se cobra mientras exista. Para dejar de pagarlo hay que cambiar a
> F1 o eliminar el plan.

### Opción D: eliminar los recursos al terminar

Si ya no necesitas la demo:

```powershell
# Exporta la base antes de eliminar
mysqldump -h novamed-mysql-88257.mysql.database.azure.com `
  -u novamedadmin -p --ssl-mode=REQUIRED hospitaldb > hospitaldb.sql

# Elimina todo el grupo (web + base + almacenamiento)
az group delete -n rg-novamed --yes
```

> Eliminar el grupo borra la base de datos y los archivos subidos. Haz el respaldo
> primero.

---

## 6. Seguridad y limpieza

- La regla de firewall `AllowJuanDiegoDev` abre MySQL a tu IP actual. Cuando
  termines de revisar, elimínala:

```powershell
az mysql flexible-server firewall-rule delete -g rg-novamed `
  -n novamed-mysql-88257 --name AllowJuanDiegoDev
```

- No publiques `deploy/azure-deploy.json` ni las variables `NOVAMED_DB_*`.
- Si una contraseña se expone, cámbiala en MySQL y actualiza
  `NOVAMED_DB_PASS` en App Service.
- La **public key** de Retell es pública por diseño; la **API key** que empieza
  por `key_` es secreta y nunca debe pegarse en la aplicación.

---

## 7. Resumen rápido

| Pregunta | Respuesta |
|---|---|
| ¿Dónde veo la base de datos? | Portal → `rg-novamed` → `novamed-mysql-88257`. |
| ¿Dónde veo la configuración? | Portal → `rg-novamed` → `novamed-app-88257` → Configuración → Variables de entorno. |
| ¿Cuánto cuesta por día? | ≈ **$1.31 USD** (sin impuestos), 24/7. |
| ¿Cuánto cuesta al mes? | ≈ **$39.90 USD** (sin impuestos). |
| ¿Cuánto dura $100? | ≈ **76 días** si es el único gasto. |
| ¿Se cobra si nadie entra? | **Sí**: el plan B1 y MySQL se cobran mientras estén encendidos. |
| ¿Cómo ahorro? | Detén MySQL cuando no lo uses y/o baja el plan a F1. |
| ¿Dónde veo el gasto real? | Cost Management → Cost analysis, filtrado por `rg-novamed`. |
| ¿Dónde veo el saldo? | <https://www.microsoftazuresponsorships.com/>. |
