<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="modelo.Perfil"%>
<%@page import="modelo.PerfilDAO"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaMed - Registro de Cuenta</title>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,700&family=Manrope:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">

    <style>
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --cream:    #eef2f7;
            --blush:    #c7d8e6;
            --rose:     #1f3a5f;
            --deep:     #0f1b2e;
            --muted:    #556077;
            --white:    #ffffff;
            --light-bg: #e7f0f2;
            --shadow:   rgba(15,27,46,0.16);
            --care:     #2f7566;
            --nova:     #e2a33d;
        }

        body {
            font-family: 'Manrope', sans-serif;
            background-color: var(--cream);
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
            padding: 2rem 1rem;
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

        .wrap {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 560px;
            animation: fadeUp 0.55s ease both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ─── CARD ─── */
        .card {
            background: var(--white);
            border-radius: 22px;
            overflow: hidden;
            box-shadow: 0 20px 60px var(--shadow);
        }

        /* ─── CARD TOP ─── */
        .card-top {
            background: linear-gradient(160deg, var(--care) 0%, var(--rose) 100%);
            padding: 2rem 2.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .icon-circle {
            width: 54px;
            height: 54px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.22);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .icon-circle i {
            font-size: 26px;
            color: var(--white);
        }

        .card-top-text .form-tag {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: rgba(255, 255, 255, 0.2);
            color: var(--white);
            font-size: 0.68rem;
            font-weight: 600;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            padding: 3px 10px;
            border-radius: 20px;
            margin-bottom: 6px;
        }

        .card-top-text h2 {
            font-family: 'Fraunces', serif;
            font-size: 1.5rem;
            color: var(--white);
            font-weight: 600;
            line-height: 1.2;
        }

        .card-top-text p {
            font-size: 0.82rem;
            color: rgba(255, 255, 255, 0.85);
            margin-top: 3px;
        }

        /* ─── CARD BODY ─── */
        .card-body {
            padding: 2rem 2.5rem;
        }

        /* ─── SECTION LABEL ─── */
        .section-label {
            font-family: 'Fraunces', serif;
            font-size: 1rem;
            color: var(--deep);
            font-weight: 600;
            margin: 1.5rem 0 1rem;
            padding-bottom: 8px;
            border-bottom: 1.5px solid var(--blush);
        }

        .section-label:first-child {
            margin-top: 0;
        }

        /* ─── FIELDS ─── */
        .field {
            margin-bottom: 1rem;
        }

        label {
            display: block;
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--deep);
            letter-spacing: 0.05em;
            text-transform: uppercase;
            margin-bottom: 5px;
        }

        .input-wrap {
            position: relative;
        }

        input, select {
            width: 100%;
            padding: 11px 14px 11px 38px;
            border: 1.5px solid var(--blush);
            border-radius: 10px;
            font-family: 'Manrope', sans-serif;
            font-size: 0.92rem;
            color: var(--deep);
            background: var(--cream);
            outline: none;
            transition: border-color 0.25s, box-shadow 0.25s;
            appearance: none;
        }

        select {
            padding-left: 14px;
        }

        input::placeholder {
            color: #9aa7bc;
            font-weight: 300;
        }

        input:focus, select:focus {
            border-color: var(--rose);
            box-shadow: 0 0 0 3px rgba(31, 58, 95, 0.15);
            background: var(--white);
        }

        input.invalido, select.invalido {
            border-color: #ef4444 !important;
            box-shadow: 0 0 0 3px rgba(239, 68, 68, .1) !important;
        }

        input.valido {
            border-color: #22c55e !important;
            box-shadow: 0 0 0 3px rgba(34, 197, 94, .1) !important;
        }

        .input-icon {
            position: absolute;
            left: 11px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 15px;
            color: var(--rose);
            pointer-events: none;
        }

        .pass-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 16px;
            color: var(--rose);
            cursor: pointer;
            background: none;
            border: none;
            padding: 2px;
        }

        .pass-toggle:hover {
            color: var(--deep);
        }

        /* ─── ERROR MESSAGES ─── */
        .error-msg {
            color: #ef4444;
            font-size: 11px;
            margin-top: 4px;
            display: none;
            align-items: center;
            gap: 4px;
        }

        .error-msg i {
            font-size: 12px;
        }

        /* ─── STRENGTH BAR ─── */
        .strength-wrap {
            margin-top: 8px;
        }

        .strength-track {
            height: 4px;
            border-radius: 2px;
            background: var(--light-bg);
            overflow: hidden;
            margin-bottom: 4px;
        }

        .strength-bar {
            height: 100%;
            width: 0%;
            transition: width .3s, background .3s;
            border-radius: 2px;
        }

        .strength-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .strength-label {
            font-size: 11px;
            font-weight: 600;
        }

        .pass-hint {
            font-size: 11px;
            color: var(--muted);
        }

        /* ─── TWO COL ─── */
        .two-col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        /* ─── BUTTONS ─── */
        .actions {
            margin-top: 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .btn-primary {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 10px;
            font-family: 'Manrope', sans-serif;
            font-size: 0.92rem;
            font-weight: 600;
            letter-spacing: 0.06em;
            cursor: pointer;
            background: var(--rose);
            color: var(--white);
            transition: background 0.25s, transform 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-primary:hover {
            background: var(--deep);
            transform: translateY(-2px);
        }

        .btn-secondary {
            width: 100%;
            padding: 13px;
            border: 1.5px solid var(--blush);
            border-radius: 10px;
            font-family: 'Manrope', sans-serif;
            font-size: 0.92rem;
            font-weight: 600;
            cursor: pointer;
            background: transparent;
            color: var(--muted);
            transition: background 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-secondary:hover {
            background: var(--light-bg);
        }

        /* ─── DIVIDER & FOOTER ─── */
        .divider-line {
            width: 100%;
            height: 1px;
            background: var(--blush);
            margin: 1.25rem 0;
        }

        .footer-link {
            text-align: center;
            font-size: 0.82rem;
            color: var(--muted);
        }

        .footer-link a {
            color: var(--rose);
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .footer-link a:hover {
            text-decoration: underline;
        }

        /* ─── RESPONSIVE ─── */
        @media (max-width: 600px) {
            .card-top { padding: 1.5rem; }
            .card-body { padding: 1.5rem; }
            .two-col { grid-template-columns: 1fr; }
        }
    </style>
</head>

<body>
<div class="wrap">
  <div class="card">

    <!-- ENCABEZADO -->
    <div class="card-top">
      <div class="icon-circle">
        <i class="ti ti-user-plus"></i>
      </div>
      <div class="card-top-text">
        <div class="form-tag">✦ Nuevo usuario</div>
        <h2>Registro de cuenta</h2>
        <p>Crea tu cuenta para acceder a Hospital NovaMed</p>
      </div>
    </div>

    <!-- FORMULARIO -->
    <div class="card-body">
      <form method="post" action="ControladorUsuario" onsubmit="return validarRegistro()" id="formRegistro">

        <div class="section-label">Información personal</div>

        <%-- Identificación --%>
        <div class="field">
          <label for="cidentificacion">Identificación</label>
          <div class="input-wrap">
            <i class="ti ti-id-badge input-icon"></i>
            <input type="text" name="cidentificacion" id="cidentificacion"
                   required maxlength="15" placeholder="Ej: 1234567890"
                   oninput="validarCampo(this,/^\d{6,15}$/,'erridentificacion','Solo números, entre 6 y 15 dígitos.')">
          </div>
          <div class="error-msg" id="erridentificacion"><i class="ti ti-alert-circle"></i><span></span></div>
        </div>

        <%-- Nombre y Apellido --%>
        <div class="two-col">
          <div class="field">
            <label for="cnombre">Nombre</label>
            <div class="input-wrap">
              <input type="text" name="cnombre" id="cnombre"
                     required minlength="2" maxlength="30" placeholder="Ej: Juan"
                     style="padding-left:14px"
                     oninput="validarCampo(this,/^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ' -]{2,30}$/,'errnombre','Solo letras, espacios, apóstrofo o guion (2 a 30).')">
            </div>
            <div class="error-msg" id="errnombre"><i class="ti ti-alert-circle"></i><span></span></div>
          </div>
          <div class="field">
            <label for="capellido">Apellido</label>
            <div class="input-wrap">
              <input type="text" name="capellido" id="capellido"
                     required minlength="2" maxlength="30" placeholder="Ej: Pérez"
                     style="padding-left:14px"
                     oninput="validarCampo(this,/^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ' -]{2,30}$/,'errapellido','Solo letras, espacios, apóstrofo o guion (2 a 30).')">
            </div>
            <div class="error-msg" id="errapellido"><i class="ti ti-alert-circle"></i><span></span></div>
          </div>
        </div>

        <%-- Email y Teléfono --%>
        <div class="two-col">
          <div class="field">
            <label for="cmail">Correo electrónico</label>
            <div class="input-wrap">
              <i class="ti ti-mail input-icon"></i>
              <input type="email" name="cmail" id="cmail"
                     required maxlength="60" placeholder="juan@correo.com"
                     oninput="validarCampo(this,/^[^\s@]+@[^\s@]+\.[^\s@]+$/,'erremail','Ingresa un correo válido.')">
            </div>
            <div class="error-msg" id="erremail"><i class="ti ti-alert-circle"></i><span></span></div>
          </div>
          <div class="field">
            <label for="ctelefono">Teléfono</label>
            <div class="input-wrap">
              <i class="ti ti-phone input-icon"></i>
              <input type="text" name="ctelefono" id="ctelefono"
                     maxlength="15" placeholder="3001234567"
                     oninput="validarCampo(this,/^\d{7,15}$/,'errtelefono','Solo números, entre 7 y 15 dígitos.')">
            </div>
            <div class="error-msg" id="errtelefono"><i class="ti ti-alert-circle"></i><span></span></div>
          </div>
        </div>

        <div class="section-label">Acceso a la cuenta</div>

        <%-- Usuario --%>
        <div class="field">
          <label for="cusuario">Nombre de usuario</label>
          <div class="input-wrap">
            <i class="ti ti-at input-icon"></i>
            <input type="text" name="cusuario" id="cusuario"
                   required minlength="4" maxlength="20" placeholder="Mínimo 4 caracteres"
                   oninput="validarCampo(this,/^[a-zA-Z0-9._-]{4,20}$/,'errusuario','Entre 4 y 20 caracteres. Letras, números, punto, guion o guion bajo.')">
          </div>
          <div class="error-msg" id="errusuario"><i class="ti ti-alert-circle"></i><span></span></div>
        </div>

        <%-- Contraseña --%>
        <div class="field">
          <label for="cclave">Contraseña</label>
          <div class="input-wrap">
            <i class="ti ti-lock input-icon"></i>
            <input type="password" name="cclave" id="cclave"
                   required minlength="8" maxlength="72" placeholder="Mínimo 8 caracteres"
                   style="padding-right:36px"
                   autocomplete="new-password"
                   oninput="evaluarFortaleza(this.value)">
            <button type="button" class="pass-toggle" onclick="togglePassword()" aria-label="Mostrar u ocultar contraseña">
              <i class="ti ti-eye" id="eyeIcon"></i>
            </button>
          </div>
          <div class="strength-wrap" id="strengthWrap" style="display:none">
            <div class="strength-track"><div class="strength-bar" id="fortalezaBar"></div></div>
            <div class="strength-row">
              <span class="strength-label" id="fortalezaLabel"></span>
              <span class="pass-hint">Mayúscula · minúscula · número · símbolo</span>
            </div>
          </div>
          <div class="error-msg" id="errclave"><i class="ti ti-alert-circle"></i><span></span></div>
        </div>

        <%-- Perfil --%>
        <div class="field">
          <label for="cidperfil">Perfil</label>
          <div class="input-wrap">
            <select name="cidperfil" id="cidperfil" required>
              <option value="">-- Seleccione un perfil --</option>
              <%
                PerfilDAO pdao = new PerfilDAO();
                List<Perfil> perfiles = pdao.listadoPerfiles();
                for (Perfil p : perfiles) {
                  // El perfil Administrador no puede auto-registrarse
                  if ("Administrador".equalsIgnoreCase(p.getPerfil())) continue;
              %>
              <option value="<%=p.getId_perfil()%>"><%=p.getPerfil()%></option>
              <% } %>
            </select>
          </div>
          <div class="error-msg" id="errperfil"><i class="ti ti-alert-circle"></i><span></span></div>
        </div>

        <div class="actions">
          <button type="submit" class="btn-primary">
            <i class="ti ti-check"></i> Crear cuenta
          </button>
          <button type="reset" class="btn-secondary" onclick="limpiarValidaciones()">
            <i class="ti ti-trash"></i> Limpiar formulario
          </button>
        </div>

      </form>

      <div class="divider-line"></div>

      <div class="footer-link">
        <a href="login.jsp"><i class="ti ti-arrow-left"></i> Volver al inicio de sesión</a>
      </div>
    </div>

  </div>
</div>

<script>
    function validarCampo(input, patron, idError, mensaje) {
        const wrap = document.getElementById(idError);
        const span = wrap ? wrap.querySelector('span') : null;
        const valor = input.value.trim();

        if (!input.required && valor === '') {
            input.classList.remove('invalido', 'valido');
            if (wrap) wrap.style.display = 'none';
            return true;
        }

        if (patron.test(valor)) {
            input.classList.remove('invalido');
            input.classList.add('valido');
            if (wrap) wrap.style.display = 'none';
            return true;
        } else {
            input.classList.remove('valido');
            input.classList.add('invalido');
            if (span) span.textContent = mensaje;
            if (wrap) wrap.style.display = 'flex';
            return false;
        }
    }

    function evaluarFortaleza(clave) {
        const bar   = document.getElementById('fortalezaBar');
        const label = document.getElementById('fortalezaLabel');
        const wrap  = document.getElementById('strengthWrap');
        const errWrap = document.getElementById('errclave');
        const errSpan = errWrap ? errWrap.querySelector('span') : null;
        const input = document.getElementById('cclave');

        if (clave.length === 0) { wrap.style.display = 'none'; return; }
        wrap.style.display = 'block';

        let puntos = 0;
        if (clave.length >= 8)                  puntos++;
        if (/[A-Z]/.test(clave))                puntos++;
        if (/[a-z]/.test(clave))                puntos++;
        if (/[0-9]/.test(clave))                puntos++;
        if (/[!@#$%^&*()\-_=+\[\]{};:,.?\/|~]/.test(clave)) puntos++;

        const niveles = [
            { w: '0%',   c: 'transparent', t: '' },
            { w: '20%',  c: '#ef4444',     t: '🔴 Muy débil'  },
            { w: '40%',  c: '#f97316',     t: '🟠 Débil'      },
            { w: '60%',  c: '#eab308',     t: '🟡 Aceptable'  },
            { w: '80%',  c: '#84cc16',     t: '🟢 Buena'      },
            { w: '100%', c: '#22c55e',     t: '🟢 Fuerte'     },
        ];

        const n = niveles[puntos];
        bar.style.width      = n.w;
        bar.style.background = n.c;
        label.textContent    = n.t;
        label.style.color    = n.c;

        if (puntos === 5 && !/012345|123456|234567|345678|456789|567890|abcdef|qwerty|asdfgh|zxcvbn/i.test(clave)) {
            input.classList.remove('invalido'); input.classList.add('valido');
            if (errWrap) errWrap.style.display = 'none';
        } else if (clave.length > 0) {
            input.classList.remove('valido'); input.classList.add('invalido');
        }
    }

    function togglePassword() {
        const input = document.getElementById('cclave');
        const icon  = document.getElementById('eyeIcon');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'ti ti-eye-off';
        } else {
            input.type = 'password';
            icon.className = 'ti ti-eye';
        }
    }

    function sanitizar(valor) {
        return /[<>"%\\]/.test(valor);
    }

    function validarRegistro() {
        let valido = true;

        const campos = [
            { id: 'cidentificacion', patron: /^\d{6,15}$/,                          err: 'erridentificacion', msg: 'Identificación inválida.' },
            { id: 'cnombre',         patron: /^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ' -]{2,30}$/,  err: 'errnombre',         msg: 'Nombre inválido.'         },
            { id: 'capellido',       patron: /^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ' -]{2,30}$/,  err: 'errapellido',       msg: 'Apellido inválido.'        },
            { id: 'cmail',           patron: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,           err: 'erremail',          msg: 'Email inválido.'           },
            { id: 'cusuario',        patron: /^[a-zA-Z0-9._-]{4,20}$/,               err: 'errusuario',        msg: 'Usuario inválido.'         },
        ];

        campos.forEach(c => {
            const input = document.getElementById(c.id);
            if (!validarCampo(input, c.patron, c.err, c.msg)) valido = false;
            if (sanitizar(input.value)) {
                mostrarError(c.err, 'Contiene caracteres no permitidos: < > " \' % ; ( )');
                input.classList.add('invalido');
                valido = false;
            }
        });

        const clave = document.getElementById('cclave').value;
        const fuerte = /^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()\-_=+\[\]{};:,.?\/|~]).{8,72}$/;
        const secuencia = /012345|123456|234567|345678|456789|567890|abcdef|qwerty|asdfgh|zxcvbn/i;
        if (!fuerte.test(clave)) {
            mostrarError('errclave', 'La clave debe tener entre 8 y 72 caracteres, con mayúscula, minúscula, número y símbolo.');
            document.getElementById('cclave').classList.add('invalido');
            valido = false;
        } else if (secuencia.test(clave)) {
            mostrarError('errclave', 'La clave no puede contener secuencias como 123456789012345 o abcdef.');
            document.getElementById('cclave').classList.add('invalido');
            valido = false;
        }

        const perfil = document.getElementById('cidperfil');
        if (perfil.value === '') {
            perfil.classList.add('invalido');
            mostrarError('errperfil', 'Selecciona un perfil.');
            valido = false;
        }

        if (!valido) {
            const primerError = document.querySelector('.invalido');
            if (primerError) primerError.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }

        return valido;
    }

    function mostrarError(idError, mensaje) {
        const wrap = document.getElementById(idError);
        const span = wrap ? wrap.querySelector('span') : null;
        if (span) span.textContent = mensaje;
        if (wrap) wrap.style.display = 'flex';
    }

    function limpiarValidaciones() {
        document.querySelectorAll('.error-msg').forEach(e => {
            e.style.display = 'none';
            const s = e.querySelector('span');
            if (s) s.textContent = '';
        });
        document.querySelectorAll('input, select').forEach(e => e.classList.remove('invalido', 'valido'));
        const bar   = document.getElementById('fortalezaBar');
        const label = document.getElementById('fortalezaLabel');
        const wrap  = document.getElementById('strengthWrap');
        if (bar)   { bar.style.width = '0%'; bar.style.background = 'transparent'; }
        if (label) label.textContent = '';
        if (wrap)  wrap.style.display = 'none';
    }

    // La contrasena no se puede copiar mientras esta enmascarada
    document.addEventListener('copy', function (e) {
        if (e.target && e.target.type === 'password') {
            e.preventDefault();
        }
    });
    document.addEventListener('cut', function (e) {
        if (e.target && e.target.type === 'password') {
            e.preventDefault();
        }
    });
</script>

</body>
</html>