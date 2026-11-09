<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital NovaMed - Registro Exitoso</title>
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,700&family=Manrope:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --night:    #0f1b2e;
            --indigo:   #1f3a5f;
            --nova:     #e2a33d;
            --care:     #2f7566;
            --mist:     #eef2f7;
            --panel:    #ffffff;
            --muted:    #556077;
            --deep:     #10192b;
            --pale:     #c7d8e6;
            --light-bg: #e7f0f2;
            --shadow:   rgba(15,27,46,0.16);
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

        .wrapper {
            position: relative;
            z-index: 1;
            background: var(--panel);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px var(--shadow);
            width: min(400px, 92vw);
            animation: fadeUp 0.55s ease both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ─── TOP BAND ─── */
        .top-band {
            background: linear-gradient(160deg, var(--care) 0%, var(--indigo) 100%);
            padding: 2.2rem 2rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            text-align: center;
            position: relative;
        }

        .top-band::before {
            content: '✦';
            position: absolute;
            top: 18px;
            right: 22px;
            color: var(--nova);
            font-size: 1.3rem;
            opacity: 0.85;
        }

        .check-circle {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: rgba(255,255,255,0.18);
            color: var(--panel);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
        }

        .form-tag {
            background: rgba(255,255,255,0.18);
            color: var(--panel);
            font-size: 0.68rem;
            font-weight: 700;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            padding: 4px 12px;
            border-radius: 20px;
        }

        .top-band h1 {
            font-family: 'Fraunces', serif;
            font-size: 1.5rem;
            color: var(--panel);
            font-weight: 600;
            line-height: 1.2;
        }

        /* ─── BODY ─── */
        .card-body {
            padding: 2rem 2.2rem;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .card-body p {
            font-size: 0.88rem;
            color: var(--muted);
            text-align: center;
            line-height: 1.6;
        }

        .divider-line {
            width: 100%;
            height: 1px;
            background: var(--pale);
        }

        /* ─── BUTTONS ─── */
        .btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 10px;
            font-family: 'Manrope', sans-serif;
            font-size: 0.92rem;
            font-weight: 600;
            letter-spacing: 0.03em;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.25s, transform 0.2s;
        }

        .btn-primary {
            background: var(--indigo);
            color: var(--panel);
        }

        .btn-primary:hover {
            background: var(--night);
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: transparent;
            border: 1.5px solid var(--pale);
            color: var(--indigo);
        }

        .btn-secondary:hover {
            background: var(--light-bg);
        }

        .actions {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
    </style>
</head>
<body>

    <div class="wrapper">

        <div class="top-band">
            <div class="check-circle">✓</div>
            <div class="form-tag">✦ Operación completada</div>
            <h1>¡Registro exitoso!</h1>
        </div>

        <div class="card-body">
            <p>La información fue guardada correctamente en el sistema. Ya puedes iniciar sesión con tu nueva cuenta.</p>

            <div class="divider-line"></div>

            <div class="actions">
                <a href="login.jsp" class="btn btn-primary">→ Iniciar sesión</a>
                <a href="Register.jsp" class="btn btn-secondary">+ Registrar otro usuario</a>
            </div>
        </div>

    </div>

</body>
</html>