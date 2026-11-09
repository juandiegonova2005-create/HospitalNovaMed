<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.Usuario, modelo.UsuarioDAO, modelo.Util"%>
<%
    String id = (String) session.getAttribute("idUsuario");
    Usuario u = null;
    try {
        u = (id == null) ? null : new UsuarioDAO().listadoDatos_Id(Integer.parseInt(id));
    } catch (Exception e) {
        u = null;
    }
    String msg = request.getParameter("msg");
    String detalle = request.getParameter("detalle");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mi perfil</title>
<style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;min-height:100vh;
         display:flex;align-items:flex-start;justify-content:center;padding:24px}
    .card{background:#fff;border-radius:14px;box-shadow:0 6px 24px rgba(0,0,0,.08);
          padding:32px;width:100%;max-width:520px}
    h2{color:#0f4c5c;margin-bottom:6px}
    p.sub{color:#64748b;font-size:.9rem;margin-bottom:20px}
    label{display:block;font-size:.85rem;font-weight:bold;color:#334155;margin:14px 0 6px}
    input{width:100%;padding:11px 12px;border:1px solid #cbd5e1;border-radius:8px;font-size:.95rem}
    input:focus{outline:none;border-color:#0f766e}
    button{width:100%;margin-top:20px;padding:12px;border:0;border-radius:8px;
           background:#0f766e;color:#fff;font-size:1rem;cursor:pointer}
    button:hover{background:#115e59}
    .ok{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534;padding:10px 14px;
        border-radius:8px;font-size:.85rem;margin-bottom:14px}
    .err{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;padding:10px 14px;
         border-radius:8px;font-size:.85rem;margin-bottom:14px}
    a.back{display:block;text-align:center;margin-top:18px;color:#0f766e;font-size:.9rem;text-decoration:none}
    small{color:#64748b;font-size:.78rem}
    .dato{background:#f1f5f9;border-radius:8px;padding:10px 12px;font-size:.9rem;
          color:#334155;margin-bottom:6px}
    hr{border:0;border-top:1px solid #e2e8f0;margin:22px 0 4px}
    .hint{font-size:.78rem;color:#64748b;margin-top:5px}
    .fuerza{height:6px;border-radius:99px;background:#e2e8f0;margin-top:8px;overflow:hidden}
    .fuerza span{display:block;height:100%;width:0;transition:width .2s,background .2s}
</style>
</head>
<body>
<div class="card">
<% if (u == null) { %>
    <div class="err">No se encontró tu información. Inicia sesión de nuevo.</div>
<% } else { %>
    <h2>Mi perfil</h2>
    <p class="sub">Actualiza tu correo y/o tu contraseña. Te pediremos tu contraseña actual por seguridad.</p>

    <div class="dato"><b>Nombre:</b> <%=Util.esc(u.getNombre())%> <%=Util.esc(u.getApellido())%></div>
    <div class="dato"><b>Usuario:</b> @<%=Util.esc(u.getUsuario())%></div>

    <% if ("ok".equals(msg)) { %><div class="ok" style="margin-top:14px">✓ Tus datos fueron actualizados.</div><% } %>
    <% if ("clave_actual".equals(msg)) { %><div class="err" style="margin-top:14px">La contraseña actual es incorrecta.</div><% } %>
    <% if ("email_invalido".equals(msg)) { %><div class="err" style="margin-top:14px">El correo no es válido.</div><% } %>
    <% if ("email_duplicado".equals(msg)) { %><div class="err" style="margin-top:14px">Ese correo ya está registrado por otro usuario.</div><% } %>
    <% if ("clave_debil".equals(msg)) { %>
        <div class="err" style="margin-top:14px">
            <%=Util.esc(detalle == null
                ? "La nueva contraseña no cumple la política de seguridad."
                : detalle)%>
        </div>
    <% } %>
    <% if ("clave_distinta".equals(msg)) { %><div class="err" style="margin-top:14px">Las contraseñas nuevas no coinciden.</div><% } %>
    <% if ("sin_cambios".equals(msg)) { %><div class="err" style="margin-top:14px">No hiciste ningún cambio.</div><% } %>
    <% if ("error".equals(msg)) { %><div class="err" style="margin-top:14px">No se pudo guardar. Intenta de nuevo.</div><% } %>

    <form method="post" action="ActualizarMiPerfil" autocomplete="off" id="formPerfil">
        <label for="cmail">Correo electrónico</label>
        <input type="email" id="cmail" name="cmail" required maxlength="60"
               value="<%=Util.esc(u.getEmail())%>">

        <hr>
        <label for="cclave_nueva">Nueva contraseña <small>(déjala vacía si no quieres cambiarla)</small></label>
        <input type="password" id="cclave_nueva" name="cclave_nueva" maxlength="72"
               autocomplete="new-password" oninput="medirFuerza()">
        <div class="fuerza"><span id="barra"></span></div>
        <div class="hint" id="msgClave">Mínimo 8 caracteres, mayúscula, minúscula, número y símbolo.</div>

        <label for="cclave_nueva2">Repite la nueva contraseña</label>
        <input type="password" id="cclave_nueva2" name="cclave_nueva2" maxlength="72"
               autocomplete="new-password">

        <hr>
        <label for="cclave_actual">Contraseña actual <small>(obligatoria para guardar cambios)</small></label>
        <input type="password" id="cclave_actual" name="cclave_actual" required
               autocomplete="current-password">

        <button type="submit">Guardar cambios</button>
    </form>

    <a class="back" href="cpanel.jsp">← Volver al panel</a>
<% } %>
</div>

<script>
    function medirFuerza() {
        var v = document.getElementById('cclave_nueva').value;
        var barra = document.getElementById('barra');
        var msg = document.getElementById('msgClave');
        var puntos = 0;
        if (v.length >= 8) puntos++;
        if (/[A-Z]/.test(v)) puntos++;
        if (/[a-z]/.test(v)) puntos++;
        if (/[0-9]/.test(v)) puntos++;
        if (/[!@#$%^&*()\-_=+\[\]{};:,.?\/|~]/.test(v)) puntos++;

        var colores = ['#e2e8f0', '#dc2626', '#f59e0b', '#f59e0b', '#16a34a', '#16a34a'];
        barra.style.width = (v.length === 0 ? 0 : (puntos / 5) * 100) + '%';
        barra.style.background = colores[puntos];

        if (v.length === 0) {
            msg.style.color = '#64748b';
            msg.textContent = 'Mínimo 8 caracteres, mayúscula, minúscula, número y símbolo.';
        } else if (puntos === 5 && !/012345|123456|234567|345678|456789|567890|abcdef|qwerty/i.test(v)) {
            msg.style.color = '#16a34a';
            msg.textContent = '✔ Contraseña válida';
        } else {
            msg.style.color = '#dc2626';
            msg.textContent = 'Aún falta cumplir algún requisito o hay una secuencia fácil de adivinar.';
        }
    }

    document.getElementById('formPerfil').addEventListener('submit', function (e) {
        var n1 = document.getElementById('cclave_nueva').value;
        var n2 = document.getElementById('cclave_nueva2').value;
        if (n1 !== n2) {
            e.preventDefault();
            alert('Las contraseñas nuevas no coinciden.');
        }
    });

    // Las claves no se pueden copiar (prueba de valor enmascarado)
    document.addEventListener('copy', function (e) {
        if (e.target && e.target.type === 'password') {
            e.preventDefault();
        }
    });
</script>
</body>
</html>
