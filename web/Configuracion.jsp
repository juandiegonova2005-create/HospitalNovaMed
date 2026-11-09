<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.ConfiguracionDAO, modelo.Util"%>
<%
    int minutosSesion = ConfiguracionDAO.minutosSesion();
    int maxIntentos = ConfiguracionDAO.maxIntentos();
    int minutosBloqueo = ConfiguracionDAO.minutosBloqueo();
    boolean retellHabilitado = ConfiguracionDAO.retellHabilitado();
    String retellPublicKey = ConfiguracionDAO.retellPublicKey();
    String retellAgentId = ConfiguracionDAO.retellAgentId();
    String retellVoiceKey = ConfiguracionDAO.retellVoicePublicKey();
    String retellVoiceAgentId = ConfiguracionDAO.retellVoiceAgentId();
    boolean retellListo = ConfiguracionDAO.asistenteConfigurado();
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Configuración de seguridad - NovaMed</title>
<style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;padding:24px;color:#1e293b}
    .wrap{max-width:760px;margin:0 auto}
    h1{color:#0f4c5c;font-size:1.4rem;margin-bottom:4px}
    p.sub{color:#64748b;font-size:.9rem;margin-bottom:20px}
    .card{background:#fff;border-radius:14px;box-shadow:0 6px 24px rgba(0,0,0,.07);
          padding:26px;margin-bottom:18px}
    .grid{display:grid;grid-template-columns:1fr 1fr;gap:18px}
    @media(max-width:620px){.grid{grid-template-columns:1fr}}
    label{display:block;font-size:.85rem;font-weight:bold;color:#334155;margin-bottom:6px}
    input{width:100%;padding:11px 12px;border:1px solid #cbd5e1;border-radius:8px;font-size:.95rem}
    input:focus{outline:none;border-color:#0f766e}
    .hint{font-size:.78rem;color:#64748b;margin-top:6px}
    .btn{display:inline-block;margin-top:20px;padding:12px 20px;border:0;border-radius:8px;
         background:#0f766e;color:#fff;font-size:.95rem;cursor:pointer;text-decoration:none}
    .btn:hover{background:#115e59}
    .btn-outline{background:#fff;border:1px solid #cbd5e1;color:#334155}
    .btn-outline:hover{background:#f1f5f9}
    .alert-ok{background:#dcfce7;border:1px solid #86efac;color:#166534;border-radius:8px;
              padding:10px 14px;margin-bottom:16px;font-size:.88rem;font-weight:bold}
    .alert-error{background:#fee2e2;border:1px solid #fca5a5;color:#991b1b;border-radius:8px;
                 padding:10px 14px;margin-bottom:16px;font-size:.88rem;font-weight:bold}
    h3{color:#0f4c5c;font-size:1rem;margin-bottom:10px}
    ul{list-style:disc;padding-left:22px;color:#475569;font-size:.87rem;line-height:1.7}
    .log{background:#0f172a;color:#e2e8f0;border-radius:8px;padding:12px 14px;
         font-family:Consolas,monospace;font-size:.8rem;margin-top:10px;word-break:break-all}
    code{background:#f1f5f9;border-radius:5px;padding:2px 6px;font-size:.82rem}
    .acciones{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
    .check{display:flex;align-items:center;gap:10px;font-size:.9rem;color:#334155;
           margin-bottom:18px;font-weight:bold}
    .check input{width:18px;height:18px;margin:0}
    .chip{display:inline-block;border-radius:999px;padding:3px 10px;font-size:.75rem;
          font-weight:bold;margin-left:8px;vertical-align:middle}
    .chip-ok{background:#dcfce7;color:#166534}
    .chip-warn{background:#fef3c7;color:#92400e}
    .chip-off{background:#e2e8f0;color:#475569}
</style>
</head>
<body>
<div class="wrap">
    <h1>⚙ Configuración de seguridad</h1>
    <p class="sub">Estos valores se guardan en la base de datos y se aplican sin reiniciar el servidor.</p>

    <% if ("ok".equals(msg)) { %>
        <div class="alert-ok">✓ Configuración guardada.</div>
    <% } else if ("sesion".equals(msg)) { %>
        <div class="alert-error">✗ El tiempo de sesión debe estar entre 1 y 1440 minutos.</div>
    <% } else if ("intentos".equals(msg)) { %>
        <div class="alert-error">✗ Los intentos permitidos deben estar entre 3 y 20.</div>
    <% } else if ("bloqueo".equals(msg)) { %>
        <div class="alert-error">✗ El tiempo de bloqueo debe estar entre 1 y 1440 minutos.</div>
    <% } else if ("secreta".equals(msg)) { %>
        <div class="alert-error">✗ Esa es la <strong>API key secreta</strong> (empieza por <code>key_</code>). Usa la <strong>Public Key</strong>, que empieza por <code>public_key_</code>.</div>
    <% } else if ("formato".equals(msg)) { %>
        <div class="alert-error">✗ La public key debe empezar por <code>public_key_</code> y el agent ID por <code>agent_</code>.</div>
    <% } else if ("pareja".equals(msg)) { %>
        <div class="alert-error">✗ Cada canal necesita su public key y su agent ID. No dejes uno sin el otro.</div>
    <% } else if ("sinconfig".equals(msg)) { %>
        <div class="alert-error">✗ Para activar el asistente configura al menos el chat o la voz.</div>
    <% } else if ("error".equals(msg)) { %>
        <div class="alert-error">✗ No se pudo guardar. Revisa el registro de errores.</div>
    <% } %>

    <div class="card">
        <form method="post" action="Configuracion">
            <input type="hidden" name="seccion" value="seguridad">
            <div class="grid">
                <div>
                    <label for="sesion">Tiempo de expiración por inactividad (minutos)</label>
                    <input type="number" id="sesion" name="sesion_minutos" min="1" max="1440"
                           value="<%=minutosSesion%>" required>
                    <div class="hint">Redúcelo a 1–2 para la prueba de expiración; súbelo a 60 para la prueba contraria.</div>
                </div>
                <div>
                    <label for="intentos">Intentos fallidos antes de bloquear</label>
                    <input type="number" id="intentos" name="max_intentos" min="3" max="20"
                           value="<%=maxIntentos%>" required>
                    <div class="hint">Por defecto 5 intentos.</div>
                </div>
                <div>
                    <label for="bloqueo">Duración del bloqueo (minutos)</label>
                    <input type="number" id="bloqueo" name="minutos_bloqueo" min="1" max="1440"
                           value="<%=minutosBloqueo%>" required>
                    <div class="hint">Tiempo que la cuenta permanece bloqueada.</div>
                </div>
                <div>
                    <label>Duración efectiva actual</label>
                    <input type="text" value="<%=minutosSesion%> min de inactividad" readonly>
                    <div class="hint">Cambia al instante al guardar.</div>
                </div>
            </div>
            <button type="submit" class="btn">Guardar configuración</button>
        </form>
    </div>

    <div class="card">
        <h3>🤖 Asistente virtual (Retell AI)
            <% if (retellHabilitado && retellListo) { %>
                <span class="chip chip-ok">Activo</span>
            <% } else if (retellHabilitado) { %>
                <span class="chip chip-warn">Falta configurar</span>
            <% } else { %>
                <span class="chip chip-off">Desactivado</span>
            <% } %>
        </h3>
        <p style="color:#475569;font-size:.87rem;line-height:1.6;margin-bottom:16px">
            El asistente aparece como botón flotante en todo el sitio: páginas públicas,
            login y panel interno. Responde preguntas frecuentes del hospital y también
            puede orientar a los usuarios dentro del sistema. Se activa o desactiva sin
            reiniciar el servidor.
        </p>
        <form method="post" action="Configuracion">
            <input type="hidden" name="seccion" value="asistente">
            <label class="check">
                <input type="checkbox" name="retell_habilitado" value="1" <%=retellHabilitado ? "checked" : ""%>>
                Mostrar el asistente en el sitio
            </label>
            <div class="grid">
                <div>
                    <label for="retell-pub">Public key del chat</label>
                    <input type="text" id="retell-pub" name="retell_public_key"
                           value="<%=Util.esc(retellPublicKey)%>" placeholder="public_key_..."
                           autocomplete="off" spellcheck="false">
                    <div class="hint">Empieza por <code>public_key_</code>. No pegues la API key secreta (empieza por <code>key_</code>).</div>
                </div>
                <div>
                    <label for="retell-agent">Agent ID del chat</label>
                    <input type="text" id="retell-agent" name="retell_agent_id"
                           value="<%=Util.esc(retellAgentId)%>" placeholder="agent_..."
                           autocomplete="off" spellcheck="false">
                    <div class="hint">Agente de texto creado en Retell (pestaña Chat).</div>
                </div>
                <div>
                    <label for="retell-vpub">Public key de voz (opcional)</label>
                    <input type="text" id="retell-vpub" name="retell_voice_public_key"
                           value="<%=Util.esc(retellVoiceKey)%>" placeholder="public_key_..."
                           autocomplete="off" spellcheck="false">
                    <div class="hint">Solo si quieres llamadas de voz desde el navegador.</div>
                </div>
                <div>
                    <label for="retell-vagent">Agent ID de voz (opcional)</label>
                    <input type="text" id="retell-vagent" name="retell_voice_agent_id"
                           value="<%=Util.esc(retellVoiceAgentId)%>" placeholder="agent_..."
                           autocomplete="off" spellcheck="false">
                    <div class="hint">El widget de voz no usa la public key del chat: requiere la suya.</div>
                </div>
            </div>
            <div class="acciones">
                <button type="submit" class="btn">Guardar asistente</button>
                <a class="btn btn-outline" href="https://www.retellai.com/" target="_blank" rel="noopener">Abrir Retell AI</a>
            </div>
        </form>
    </div>

    <div class="card">
        <h3>🧪 Registro de errores</h3>
        <p style="color:#475569;font-size:.87rem;line-height:1.6">
            El botón siguiente provoca una excepción controlada. La aplicación la captura,
            muestra la página de error y escribe el evento en <code>novamed-error.log</code>,
            dentro de la carpeta <code>logs</code> de Tomcat. En Azure se descarga con
            <code>az webapp log download</code>.
        </p>
        <div class="acciones">
            <a class="btn btn-outline" href="SimularError" target="_blank">Simular error y revisar el log</a>
            <a class="btn btn-outline" href="listaAuditoria.jsp" target="marco">Ver auditoría</a>
        </div>
    </div>

    <div class="card">
        <h3>📋 Cómo cumplir las pruebas</h3>
        <ul>
            <li><strong>Expiración:</strong> baja el tiempo a 1 minuto, inicia sesión y espera sin hacer clic; la siguiente acción te envía al login.</li>
            <li><strong>Ampliación:</strong> sube el tiempo a 60 minutos y repite; la sesión se mantiene activa.</li>
            <li><strong>Bloqueo:</strong> con 5 intentos (valor por defecto) falla la contraseña 5 veces seguidas.</li>
            <li><strong>Desbloqueo:</strong> desde el listado de usuarios puedes liberar la cuenta sin cambiar la clave.</li>
        </ul>
    </div>
</div>
</body>
</html>
