<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.RecuperacionDAO, modelo.Util"%>
<%
    String token = request.getParameter("token");
    boolean formato = token != null && token.matches("[0-9a-f]{64}");
    boolean valido = formato && new RecuperacionDAO().validarToken(token) != null;
    String err = request.getParameter("err");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="referrer" content="no-referrer">
<title>Nueva contraseña - Hospital NovaMed</title>
<style>*{box-sizing:border-box;margin:0;padding:0}body{font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:#fff;border-radius:14px;box-shadow:0 6px 24px rgba(0,0,0,.08);padding:32px;width:100%;max-width:420px}h2{color:#0f4c5c;margin-bottom:6px}p.sub{color:#64748b;font-size:.9rem;margin-bottom:20px}label{display:block;font-size:.85rem;font-weight:bold;color:#334155;margin:14px 0 6px}input{width:100%;padding:11px 12px;border:1px solid #cbd5e1;border-radius:8px;font-size:.95rem}input:focus{outline:none;border-color:#0f766e}button{width:100%;margin-top:20px;padding:12px;border:0;border-radius:8px;background:#0f766e;color:#fff;font-size:1rem;cursor:pointer}button:hover{background:#115e59}.ok{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534;padding:10px 14px;border-radius:8px;font-size:.85rem;margin-bottom:14px}.err{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;padding:10px 14px;border-radius:8px;font-size:.85rem;margin-bottom:14px}a.back{display:block;text-align:center;margin-top:18px;color:#0f766e;font-size:.9rem;text-decoration:none}small{color:#64748b;font-size:.78rem}</style>
</head>
<body>
<div class="card">
<% if (!valido) { %>
    <h2>Enlace no válido</h2>
    <p class="sub">El enlace es incorrecto, ya fue usado o venció. Solicita uno nuevo.</p>
    <a class="back" href="olvide.jsp">Solicitar nuevo enlace</a>
<% } else { %>
    <h2>Crea tu nueva contraseña</h2>
    <p class="sub">Entre 8 y 72 caracteres, con mayúscula, minúscula, número y símbolo. Sin secuencias como 123456789012345.</p>

    <% if ("segura".equals(err)) { %><div class="err">La contraseña no cumple los requisitos.</div><% } %>
    <% if ("igual".equals(err)) { %><div class="err">Las contraseñas no coinciden.</div><% } %>
    <% if ("bd".equals(err)) { %><div class="err">No se pudo guardar. Intenta de nuevo.</div><% } %>

    <form method="post" action="RestablecerClave" autocomplete="off">
        <input type="hidden" name="token" value="<%=Util.esc(token)%>">
        <label for="cclave">Nueva contraseña</label>
        <input type="password" id="cclave" name="cclave" required minlength="8" maxlength="72" autocomplete="new-password">
        <label for="cclave2">Repite la contraseña</label>
        <input type="password" id="cclave2" name="cclave2" required minlength="8" maxlength="72" autocomplete="new-password">
        <button type="submit">Guardar contraseña</button>
    </form>
<% } %>
</div>
</body>
</html>
