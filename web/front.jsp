<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio - Hospital NovaMed</title>
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
            --shadow:  rgba(15,27,46,0.14);
        }

        body {
            font-family: 'Manrope', sans-serif;
            background-color: var(--mist);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            overflow: hidden;
        }

        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background:
                radial-gradient(ellipse 70% 60% at 10% 10%, #dfe9f2 0%, transparent 55%),
                radial-gradient(ellipse 60% 50% at 90% 90%, #dff0ec 0%, transparent 55%);
            pointer-events: none;
            z-index: 0;
        }

        .container {
            position: relative;
            z-index: 1;
            background: var(--panel);
            padding: 48px 44px;
            border-radius: 20px;
            box-shadow: 0 16px 50px var(--shadow);
            text-align: center;
            width: min(440px, 92vw);
            animation: aparecer 0.55s ease both;
        }

        @keyframes aparecer {
            from { opacity: 0; transform: translateY(24px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .icon-wrap {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(160deg, var(--care), var(--indigo));
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 22px;
            font-size: 2.2rem;
            position: relative;
        }

        .icon-wrap::after {
            content: '✦';
            position: absolute;
            top: -4px;
            right: -4px;
            color: var(--nova);
            font-size: 1.1rem;
        }

        .form-tag {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: var(--light-bg);
            color: var(--care);
            font-size: 0.7rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            padding: 4px 12px;
            border-radius: 20px;
            margin-bottom: 12px;
        }

        h2 {
            font-family: 'Fraunces', serif;
            font-size: 1.7rem;
            color: var(--deep);
            font-weight: 600;
            margin-bottom: 10px;
            line-height: 1.2;
        }

        p {
            color: var(--muted);
            font-size: 0.88rem;
            line-height: 1.65;
            margin-bottom: 28px;
        }

        .divider {
            width: 48px;
            height: 2px;
            background: var(--pale);
            border-radius: 2px;
            margin: 0 auto 28px;
        }

        .tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            justify-content: center;
        }

        .tag {
            background: var(--light-bg);
            color: var(--muted);
            font-size: 0.75rem;
            font-weight: 500;
            padding: 5px 14px;
            border-radius: 20px;
            border: 1px solid var(--pale);
        }

        .cta {
            display: inline-block;
            margin-top: 22px;
            padding: 11px 22px;
            border-radius: 10px;
            background: var(--indigo);
            color: #fff;
            text-decoration: none;
            font-size: 0.85rem;
            font-weight: 700;
            transition: background 0.2s ease;
        }

        .cta:hover { background: var(--care); }
    </style>
</head>
<body>

<div class="container">
    <div class="icon-wrap">✚</div>
    <div class="form-tag">✦ Panel activo</div>
    <h2>Bienvenido a Hospital NovaMed</h2>
    <p>Selecciona una opción del menú lateral para comenzar a gestionar tus pacientes e historias clínicas.</p>
    <div class="divider"></div>
    <div class="tags">
        <span class="tag">🩺 Clínico</span>
        <span class="tag">📋 Historias</span>
        <span class="tag">🔒 Seguro</span>
    </div>
    <a class="cta" href="dashboard.jsp">Ver dashboard →</a>
</div>

</body>
</html>
