# Asistente virtual con Retell AI – Hospital NovaMed

Integración del asistente virtual (chat y, opcionalmente, voz) en todo el sitio:
páginas públicas, login y panel interno. El widget se activa o desactiva desde
**Configuración de seguridad** sin recompilar ni reiniciar el servidor.

> La integración ya está en el proyecto. Solo falta crear el agente en Retell,
> copiar la **public key** y el **agent ID**, y guardarlos en la pantalla
> **Configuración**. Las claves secretas de Retell (`API key`) **no** se usan en
> el navegador ni se guardan en la base de datos.

---

## 1. Qué se agregó

| Archivo | Función |
|---|---|
| `src/java/filtros/FiltroAsistente.java` | Inserta el widget en las respuestas HTML. No lo duplica dentro del iframe del panel y no toca PDF, imágenes, CSS ni JS. |
| `src/java/modelo/ConfiguracionDAO.java` | Lee y guarda los parámetros del asistente en `configuracion`, con caché de 10 s. |
| `src/java/modelo/AsistenteDAO.java` | Calcula totales agregados (pacientes, camas, médicos, stock, etc.) y los envía al agente. No expone datos personales. |
| `src/java/controlador/Configuracion.java` | Valida y guarda la configuración del asistente. |
| `web/Configuracion.jsp` | Nueva tarjeta **Asistente virtual (Retell AI)** con estado y campos. |
| `web/WEB-INF/web.xml` | Registra `FiltroAsistente` después de los filtros de errores y sesión. |
| `src/java/modelo/Usuario.java`, `LoginDAO.java`, `CtrolValidar.java` | Guardan nombre y perfil en la sesión para que el agente salude con contexto. |
| `src/java/modelo/migracion_asistente.sql` | Crea los parámetros `retell_*` (idempotente). |
| `src/java/modelo/BD.sql`, `migracion_mejoras.sql` | Incluyen los parámetros para instalaciones y migraciones nuevas. |

El widget se muestra como botón flotante abajo a la derecha. Si configuras chat
y voz, el visitante elige **Chat Assistant** o **Voice Assistant**. Si solo
configuras uno, abre directamente ese canal.

### Variables que recibe el agente

El filtro envía `data-dynamic` con estas variables. Las de datos solo se envían
cuando hay sesión iniciada y son **totales agregados**: no incluyen nombres,
documentos, correos ni datos clínicos.

| Variable | Ejemplo | Uso sugerido en el prompt |
|---|---|---|
| `{{hospital}}` | `Hospital NovaMed` | Presentación. |
| `{{pagina}}` | `/cpanel.jsp` | Saber desde dónde escribe el usuario. |
| `{{logueado}}` | `si` / `no` | Elegir entre ayuda pública o ayuda interna. |
| `{{usuario}}` | `usr2000` | Identificar al usuario sin pedir la clave. |
| `{{nombre}}` | `Juan` | Saludo personalizado. |
| `{{perfil}}` | `Administrador` | Ajustar la ayuda al rol. |
| `{{datos_pacientes}}` | `5547` | Total de pacientes. |
| `{{datos_pacientes_activos}}` | `4208` | Pacientes activos. |
| `{{datos_medicos}}` | `200` | Total de médicos. |
| `{{datos_medicos_activos}}` | `181` | Médicos activos. |
| `{{datos_camas}}` | `1004` | Total de camas. |
| `{{datos_camas_disponibles}}` | `543` | Camas disponibles. |
| `{{datos_camas_ocupadas}}` | `408` | Camas ocupadas. |
| `{{datos_camas_mantenimiento}}` | `53` | Camas en mantenimiento. |
| `{{datos_especialidades}}` | `53` | Especialidades. |
| `{{datos_medicamentos}}` | `200` | Medicamentos. |
| `{{datos_stock_critico}}` | `14` | Stock crítico o agotado. |
| `{{datos_inventario}}` | `500` | Artículos de inventario. |
| `{{datos_historias}}` | `0` | Historias clínicas. |
| `{{datos_hospitalizados}}` | `0` | Hospitalizaciones activas. |
| `{{datos_usuarios}}` | `458` | Usuarios del sistema. |
| `{{datos_auditoria}}` | `233` | Eventos de auditoría. |
| `{{datos_auditoria_hoy}}` | `164` | Eventos de auditoría de hoy. |
| `{{datos_actualizado}}` | `04/11/2026 21:29` | Fecha y hora del corte. |

Los totales se cachean 60 segundos. Si la base no responde, el agente no recibe
las variables `datos_*` y el prompt le indica que no invente cifras.

---

## 2. Crear el agente en Retell AI

1. Entra a <https://www.retellai.com/> y abre el panel.
2. Abre **Agents** y pulsa **Create an Agent → Chat Agent**.
3. Elige **Single prompt** (para preguntas libres) y asigna un nombre, por
   ejemplo `NovaMed Asistente`.
4. Pega el contenido completo de
   [`PROMPT_AGENTE_RETELL.txt`](PROMPT_AGENTE_RETELL.txt) en el prompt.
   Reemplaza `[HORARIO]`, `[DIRECCIÓN]`, `[TELÉFONO]`, `[CANAL DE CITAS]`,
   `[TELÉFONO DE URGENCIAS]`, `[CANAL DE SOPORTE]`, `[SITIO WEB]` y `[CORREO]`.
5. En **Welcome Message** elige **AI speaks first** y un saludo como:
   `Hola, soy Nova, el asistente virtual de Hospital NovaMed. ¿En qué te puedo ayudar?`
6. **Publica** el agente (no lo dejes en borrador).
7. Copia el **Agent ID** del chat (empieza por `agent_`).

### Si ya tienes un agente de voz

No necesitas crearlo de nuevo:

1. Abre el agente de voz.
2. En la esquina superior derecha, abre **More options**.
3. Elige **Convert to Chat Agent** y confirma.
4. Retell crea un **chat agent nuevo** y conserva el agente de voz original.
5. Copia el Agent ID del agente nuevo y publícalo.

> El Agent ID de voz (`agent_979...`) no sirve para el chat. Si el widget
> responde `422 Cannot start a chat session with selected agent`, el ID
> configurado no es un chat agent publicado.

### Public key

1. En **API Keys → Public Keys**, crea o abre la public key.
2. Agrega los dominios permitidos (sin `https://` ni rutas):
   - `localhost` (pruebas locales)
   - `novamed-app-88257.azurewebsites.net` (Azure)
3. Copia la **public key** (empieza por `public_key_`). La **API key** secreta
   empieza por `key_` y **no** se usa en el navegador.

Si quieres voz, crea además un **Voice Agent** con su propia public key y su
propio agent ID. El widget de voz no reutiliza la public key del chat.

> El widget de voz **no** reutiliza la public key del chat. Si ofreces voz,
> configura también `retell_voice_public_key`.

---

## 3. Crear los parámetros en la base de datos

### Local

```powershell
mysql -u root -p --default-character-set=utf8mb4 `
  -e "source C:/Users/JUAN DIEGO/OneDrive/Documentos/NetBeansProjects/ProyectoFina8semestre/src/java/modelo/migracion_asistente.sql"
```

### Azure

```powershell
# La clave del administrador NO se guarda en el repositorio.
# Usa la que tengas en deploy/azure-deploy.json (ese archivo está excluido por .gitignore).
$env:MYSQL_PWD = "<clave-del-administrador-de-la-base>"
mysql -h <servidor>.mysql.database.azure.com -P 3306 `
  -u <usuario-administrador> --ssl-mode=REQUIRED --default-character-set=utf8mb4 `
  -e "source src/java/modelo/migracion_asistente.sql"
$env:MYSQL_PWD = $null
```

El script no sobrescribe valores existentes: se puede ejecutar varias veces.

---

## 4. Configurar desde el panel

1. Inicia sesión con un usuario **Administrador** (`usr2000` / `Temporal#2026`).
2. Abre **Configuración de seguridad**.
3. En la tarjeta **Asistente virtual (Retell AI)**:
   - Marca **Mostrar el asistente en el sitio**.
   - Pega la **public key** y el **agent ID** del chat.
   - Opcional: public key y agent ID de voz.
4. Guarda. El estado debe cambiar a **Activo**.
5. Abre otra pestaña en `login.jsp` o en el panel y verifica el botón flotante.

Si dejas la casilla desmarcada, el widget no se inyecta en ninguna página.

### Validaciones de la pantalla

- La public key debe empezar por `public_key_` y el agent ID por `agent_`.
  Si pegas una clave que empieza por `key_`, la pantalla la rechaza porque es la
  **API key secreta**.
- Cada canal exige su clave y su agente; no se permite media pareja.
- Para activar el asistente debe haber al menos un canal completo.
- Cada cambio queda en **Auditoría** como `CONFIGURACION_ASISTENTE`.

---

## 5. Prompt del agente

El prompt completo y actualizado está en:

```text
PROMPT_AGENTE_RETELL.txt
```

Incluye:

- Identidad, tono y públicos (visitante y usuario del sistema).
- Uso obligatorio de las variables `datos_*` para dar cifras concretas.
- Mapa de preguntas frecuentes a variables (pacientes, camas, médicos, stock…).
- Módulos, rutas y procedimientos del sistema.
- Reglas de seguridad: no pedir contraseñas, no revelar datos de pacientes, no
  dar diagnósticos, no inventar cifras.
- Plantillas de respuesta y límites del agente.

Después de pegarlo en Retell, reemplaza los datos entre corchetes y **publica**
el agente para que el widget use la versión nueva.

---

## 6. Probar

### Local

```powershell
# 1. compilar y publicar en Tomcat
powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1 `
  -TomcatHome "C:\Program Files\Apache Software Foundation\Tomcat 11.0"

# 2. abrir
start http://localhost:8080/ProyectoFina8semestre/login.jsp
```

Abre la consola del navegador (`F12`). Si el widget no aparece, busca mensajes
que empiecen por `Retell Widget`.

### Azure

```powershell
powershell -ExecutionPolicy Bypass -File deploy\build-war.ps1 `
  -TomcatHome "C:\Program Files\Apache Software Foundation\Tomcat 11.0"

Copy-Item dist\ProyectoFina8semestre.war "$env:TEMP\ROOT.war" -Force
az webapp deploy -g rg-novamed -n novamed-app-88257 `
  --src-path "$env:TEMP\ROOT.war" --type war
```

Luego configura las claves desde el panel de Azure y prueba en:
`https://novamed-app-88257.azurewebsites.net/`

---

## 7. Seguridad y límites

- La **public key** está diseñada para ir en el navegador. No es un secreto.
- La **API key** de Retell es secreta: no la pongas en `Configuracion.jsp`, en la
  base de datos ni en el repositorio.
- El widget no recibe datos clínicos ni datos personales. Solo recibe nombre,
  usuario, perfil, página, si hay sesión y **totales agregados** (por ejemplo,
  cantidad de pacientes o camas disponibles).
- Si activas reCAPTCHA en Retell, agrega también `data-recaptcha-key` al script
  (hoy no está incluido).
- El agente es un apoyo informativo: no reemplaza al personal de salud ni el
  proceso oficial de citas.
- El script de Retell se carga desde `dashboard.retellai.com`; si tu red bloquea
  dominios externos, el widget no cargará.

---

## 8. Costos de Azure

El detalle de dónde ver la base de datos, la configuración, el costo diario y
cómo reducir el gasto está en [`COSTOS_AZURE.md`](COSTOS_AZURE.md).

---

## 9. Solución de problemas

| Síntoma | Revisión |
|---|---|
| No aparece el botón | Verifica que el estado diga **Activo** y que la public key/agent ID sean correctos. |
| Error de dominio | Agrega el dominio exacto (`localhost` o el de Azure) en la public key de Retell. |
| Aparece en el panel pero no en módulos | Es intencional: el widget vive en el marco principal, no dentro del iframe. |
| El chat no abre y Retell responde `422 Cannot start a chat session` | El Agent ID no es de un **Chat Agent** publicado. Convierte el agente de voz con **More options → Convert to Chat Agent** o crea uno nuevo, publica y actualiza el ID. |
| El chat abre pero responde “no tengo acceso” a las cifras | Falta pegar y publicar el prompt de `PROMPT_AGENTE_RETELL.txt`, o el agente no está recibiendo las variables `datos_*`. Revisa `data-dynamic` en el HTML y el prompt. |
| El chat no responde | Revisa que el agente sea de tipo **Chat** y que esté publicado. |
| La voz falla | Configura `retell_voice_public_key` y `retell_voice_agent_id`; la clave del chat no sirve para voz. |
| Cambié las claves y sigue igual | Espera 10 s (caché) y recarga con `Ctrl+Shift+R`. |
| Quiero ocultarlo sin borrar las claves | Desmarca **Mostrar el asistente** y guarda. |
