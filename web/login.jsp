<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hospital NovaMed - Acceso</title>
  <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,700&family=Manrope:wght@300;400;500;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    :root {
      --night:   #0f1b2e;
      --indigo:  #1f3a5f;
      --nova:    #e2a33d;
      --care:    #2f7566;
      --mist:    #eef2f7;
      --panel:   #ffffff;
      --muted:   #556077;
      --deep:    #10192b;
      --pale:    #c7d8e6;
      --light-bg:#e7f0f2;
      --shadow:  rgba(15,27,46,0.16);
    }

    body {
      font-family: 'Manrope', sans-serif;
      background-color: var(--mist);
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      overflow: hidden;
    }

    body::before {
      content: '';
      position: fixed;
      inset: 0;
      background:
        radial-gradient(ellipse 80% 60% at 5% 0%, #dfe9f2 0%, transparent 55%),
        radial-gradient(ellipse 70% 60% at 95% 100%, #dff0ec 0%, transparent 55%);
      pointer-events: none;
      z-index: 0;
    }

    .login-wrapper {
      position: relative;
      z-index: 1;
      display: grid;
      grid-template-columns: 300px 380px;
      border-radius: 20px;
      overflow: hidden;
      box-shadow: 0 20px 60px var(--shadow);
      animation: fadeUp 0.55s ease both;
    }

    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(30px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .login-side {
      background: linear-gradient(160deg, var(--care) 0%, var(--indigo) 100%);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 48px 32px;
      gap: 20px;
      text-align: center;
      position: relative;
    }

    .login-side::before {
      content: '✦';
      position: absolute;
      top: 22px;
      right: 26px;
      color: var(--nova);
      font-size: 1.4rem;
      opacity: 0.85;
    }

    .login-side img {
      width: 100px;
      filter: brightness(0) invert(1);
      opacity: 0.92;
    }

    .login-side h2 {
      font-family: 'Fraunces', serif;
      font-size: 1.55rem;
      color: var(--panel);
      line-height: 1.2;
    }

    .login-side p {
      font-size: 0.82rem;
      color: rgba(255,255,255,0.85);
      line-height: 1.65;
    }

    .side-divider {
      width: 40px;
      height: 2px;
      background: rgba(255,255,255,0.5);
      border-radius: 2px;
    }

    .side-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      justify-content: center;
    }

    .side-tag {
      background: rgba(255,255,255,0.18);
      color: var(--panel);
      font-size: 0.72rem;
      letter-spacing: 0.02em;
      padding: 4px 12px;
      border-radius: 20px;
    }

    .login-form-panel {
      background: var(--panel);
      padding: 52px 44px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 22px;
    }

    .form-header {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    .form-tag {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      background: var(--light-bg);
      color: var(--care);
      font-size: 0.72rem;
      font-weight: 600;
      letter-spacing: 0.04em;
      padding: 4px 12px;
      border-radius: 20px;
      width: fit-content;
    }

    .form-header h3 {
      font-family: 'Fraunces', serif;
      font-size: 1.7rem;
      color: var(--deep);
      line-height: 1.15;
    }

    .form-header p {
      font-size: 0.85rem;
      color: var(--muted);
      line-height: 1.55;
    }

    .intentos-box {
      margin: -12px 0 18px;
      padding: 10px 14px;
      border-radius: 10px;
      background: #fff7ed;
      border: 1px solid #fed7aa;
      color: #9a3412;
      font-size: 0.85rem;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .intentos-box small { color: #c2410c; }
    .intentos-dots { display: flex; gap: 6px; }
    .intentos-dots .dot { width: 12px; height: 12px; border-radius: 50%; background: #fde4cc; }
    .intentos-dots .dot.on { background: #dc2626; }
    .error-box {
      background: #fef2f2;
      border: 1px solid #fecaca;
      border-radius: 10px;
      padding: 10px 14px;
      font-size: 0.83rem;
      color: #dc2626;
    }

    .input-group {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    .input-group label {
      font-size: 0.8rem;
      font-weight: 600;
      color: var(--deep);
      letter-spacing: 0.03em;
    }

    .input-wrap {
      position: relative;
    }

    .input-wrap .input-icon {
      position: absolute;
      left: 14px;
      top: 50%;
      transform: translateY(-50%);
      font-size: 1rem;
      pointer-events: none;
    }

    .input-group input {
      width: 100%;
      padding: 12px 14px 12px 40px;
      border: 1.5px solid var(--pale);
      border-radius: 10px;
      font-family: 'Manrope', sans-serif;
      font-size: 0.92rem;
      color: var(--deep);
      background: var(--mist);
      outline: none;
      transition: border-color 0.25s, box-shadow 0.25s;
    }

    .input-group input:focus {
      border-color: var(--care);
      box-shadow: 0 0 0 3px rgba(47,117,102,0.15);
      background: var(--panel);
    }

    .input-group input::placeholder {
      color: #9aa7bc;
      font-weight: 300;
    }

    .btn {
      width: 100%;
      padding: 13px;
      border: none;
      border-radius: 10px;
      background: var(--indigo);
      color: var(--panel);
      font-family: 'Manrope', sans-serif;
      font-size: 0.92rem;
      font-weight: 600;
      letter-spacing: 0.03em;
      cursor: pointer;
      transition: background 0.25s, transform 0.2s;
      margin-top: 4px;
    }

    .btn:hover {
      background: var(--night);
      transform: translateY(-2px);
    }

    .form-links {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
    }

    .form-links a {
      text-decoration: none;
      color: var(--muted);
      font-size: 0.82rem;
      transition: color 0.2s;
    }

    .form-links a:hover {
      color: var(--care);
      text-decoration: underline;
    }

    .form-links .register-link {
      color: var(--care);
      font-weight: 600;
    }

    .divider-line {
      width: 100%;
      height: 1px;
      background: var(--pale);
      border-radius: 1px;
    }

    @media (max-width: 720px) {
      .login-wrapper {
        grid-template-columns: 1fr;
        width: min(400px, 92vw);
      }
      .login-side { padding: 32px 24px; }
      .login-side img { width: 76px; }
      .login-form-panel { padding: 36px 28px; }
    }
  </style>
</head>
<body>

  <div class="login-wrapper">

    <div class="login-side">
           <img src="img/medicina.svg" alt="cruz médica con latido">
      <div class="side-divider"></div>
      <h2>Bienvenido a Hospital NovaMed</h2>
      <p>Gestiona el registro y consulta de historias clínicas de forma segura y sencilla.</p>
      <div class="side-tags">
        <span class="side-tag">🩺 Clínico</span>
        <span class="side-tag">📋 Historias</span>
        <span class="side-tag">🔒 Seguro</span>
      </div>
    </div>

    <div class="login-form-panel">
      <div class="form-header">
        <div class="form-tag">✦ Acceso al sistema</div>
        <h3>Iniciar sesión</h3>
        <p>Ingresa tus credenciales para acceder a tu panel de gestión hospitalaria.</p>
      </div>

      <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
      %>
        <div class="error-box">⚠️ <%= modelo.Util.esc(error) %></div>
        <%
          Integer intentos = (Integer) request.getAttribute("intentos");
          Integer maxIntentos = (Integer) request.getAttribute("maxIntentos");
          if (intentos != null && maxIntentos != null) {
        %>
        <div class="intentos-box">
          <strong>Intentos fallidos: <%= intentos %> de <%= maxIntentos %></strong>
          <span class="intentos-dots">
            <% for (int i = 1; i <= maxIntentos; i++) { %><span class="dot<%= i <= intentos ? " on" : "" %>"></span><% } %>
          </span>
          <% if (intentos < maxIntentos) { %>
            <small>Te quedan <%= maxIntentos - intentos %> intento(s) antes de que la cuenta se bloquee.</small>
          <% } %>
        </div>
        <% } %>
      <% } %>

      <% if ("reset".equals(request.getParameter("msg"))) { %>
      <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:10px;padding:10px 14px;font-size:0.83rem;color:#166534;margin-bottom:14px;">
        ✓ Tu contraseña fue restablecida. Ya puedes iniciar sesión.
      </div>
      <% } %>

      <% if ("expirada".equals(request.getParameter("msg"))) { %>
      <div style="background:#fff7ed;border:1px solid #fed7aa;border-radius:10px;padding:10px 14px;font-size:0.83rem;color:#9a3412;margin-bottom:14px;">
        Tu sesión expiró por inactividad. Vuelve a iniciar sesión.
      </div>
      <% } %>

      <form method="post" action="CtrolValidar" autocomplete="off">
        <div class="input-group" style="margin-bottom: 16px;">
          <label>Usuario o correo</label>
          <div class="input-wrap">
            <span class="input-icon">👤</span>
            <input type="text" name="cusuario" id="cusuario" placeholder="Tu usuario o correo"
                   maxlength="100" autocomplete="username" required>
          </div>
        </div>

        <div class="input-group" style="margin-bottom: 8px;">
          <label>Contraseña</label>
          <div class="input-wrap">
            <span class="input-icon">🔑</span>
            <input type="password" name="cclave" id="cclave" placeholder="••••••••"
                   maxlength="100" autocomplete="current-password" required>
          </div>
        </div>
        <p style="font-size:0.75rem;color:#64748b;margin-bottom:18px">
          El campo está enmascarado y su contenido no se puede copiar.
        </p>

        <input type="submit" name="accion" value="Ingresar" class="btn">
      </form>

      <div class="divider-line"></div>

      <div class="form-links">
        <a href="olvide.jsp">¿Olvidaste tu contraseña?</a>
        <a href="Register.jsp" class="register-link">¿No tienes cuenta? Regístrate</a>
        <a href="index.jsp">← Volver al inicio</a>
      </div>
    </div>

  </div>

  <script src="js/seguridad.js"></script>
  <script>
    // Refuerzo: el campo de contrasena siempre queda enmascarado
    document.getElementById('cclave').setAttribute('autocomplete', 'current-password');
  </script>

</body>
</html>
