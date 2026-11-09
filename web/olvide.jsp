<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Recuperar contraseña - Hospital NovaMed</title>
<style>*{box-sizing:border-box;margin:0;padding:0}body{font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:#fff;border-radius:14px;box-shadow:0 6px 24px rgba(0,0,0,.08);padding:32px;width:100%;max-width:420px}h2{color:#0f4c5c;margin-bottom:6px}p.sub{color:#64748b;font-size:.9rem;margin-bottom:20px}label{display:block;font-size:.85rem;font-weight:bold;color:#334155;margin:14px 0 6px}input{width:100%;padding:11px 12px;border:1px solid #cbd5e1;border-radius:8px;font-size:.95rem}input:focus{outline:none;border-color:#0f766e}button{width:100%;margin-top:20px;padding:12px;border:0;border-radius:8px;background:#0f766e;color:#fff;font-size:1rem;cursor:pointer}button:hover{background:#115e59}.ok{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534;padding:10px 14px;border-radius:8px;font-size:.85rem;margin-bottom:14px}.err{background:#fef2f2;border:1px solid #fecaca;color:#dc2626;padding:10px 14px;border-radius:8px;font-size:.85rem;margin-bottom:14px}a.back{display:block;text-align:center;margin-top:18px;color:#0f766e;font-size:.9rem;text-decoration:none}small{color:#64748b;font-size:.78rem}</style>
</head>
<body>
<div class="card">
    <h2>¿Olvidaste tu contraseña?</h2>
    <p class="sub">Escribe el correo con el que te registraste y te enviaremos un enlace para crear una nueva.</p>

    <% if ("1".equals(request.getParameter("enviado"))) { %>
        <div class="ok">Si el correo está registrado, recibirás un enlace para restablecer tu contraseña. El enlace vence en 30 minutos.</div>
    <% } %>

    <form method="post" action="RecuperarClave">
        <label for="cmail">Correo electrónico</label>
        <input type="email" id="cmail" name="cmail" required maxlength="60" placeholder="tucorreo@ejemplo.com">
        <button type="submit">Enviar enlace</button>
    </form>
    <a class="back" href="login.jsp">← Volver al inicio de sesión</a>
</div>
</body>
</html>
