<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hospital NovaMed - Contáctanos</title>
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
    --shadow:   rgba(15,27,46,0.12);
    --sidebar-bg: #0d1524;
    --sidebar-hover: #17263e;
}

body {
    font-family: 'Manrope', sans-serif;
    background-color: var(--mist);
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

/* ── HEADER ── */
header {
    background: linear-gradient(160deg, var(--care) 0%, var(--indigo) 100%);
    color: var(--panel);
    text-align: center;
    padding: 36px 20px 30px;
    position: relative;
}

header::before {
    content: '✦';
    position: absolute;
    top: 22px;
    right: 5%;
    color: var(--nova);
    font-size: 1.4rem;
    opacity: 0.85;
}

.header-tag {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    background: rgba(255,255,255,0.2);
    color: var(--panel);
    font-size: 0.7rem;
    font-weight: 600;
    letter-spacing: 0.05em;
    padding: 4px 12px;
    border-radius: 20px;
    margin-bottom: 12px;
}

header h1 {
    font-family: 'Fraunces', serif;
    font-size: 2rem;
    font-weight: 600;
    color: var(--panel);
    margin-bottom: 8px;
    line-height: 1.2;
}

header p {
    font-size: 0.9rem;
    color: rgba(255,255,255,0.85);
}

/* ── NAV ── */
nav {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    background: var(--sidebar-bg);
    padding: 0 10px;
}

nav a {
    color: rgba(255,255,255,0.75);
    text-decoration: none;
    padding: 14px 20px;
    display: block;
    font-size: 13.5px;
    font-weight: 500;
    transition: color 0.2s, background 0.2s;
    border-bottom: 2px solid transparent;
}

nav a:hover {
    color: var(--panel);
    background: var(--sidebar-hover);
    border-bottom-color: var(--care);
}

/* ── CONTAINER ── */
.container {
    flex: 1;
    padding: 52px 40px;
    text-align: center;
}

.section-title {
    margin-bottom: 40px;
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

.section-title h2 {
    font-family: 'Fraunces', serif;
    font-size: 1.7rem;
    color: var(--deep);
    font-weight: 600;
}

.section-title .divider {
    width: 48px;
    height: 2px;
    background: var(--pale);
    border-radius: 2px;
    margin: 14px auto 0;
}

/* ── INFO CARDS ── */
.info {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 24px;
    margin-bottom: 48px;
}

.card {
    background: var(--panel);
    width: 220px;
    padding: 28px 20px;
    border-radius: 18px;
    box-shadow: 0 6px 24px var(--shadow);
    border: 1px solid var(--pale);
    transition: transform 0.25s, box-shadow 0.25s;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 14px 36px var(--shadow);
}

.card-icon {
    width: 56px;
    height: 56px;
    border-radius: 50%;
    background: linear-gradient(160deg, var(--care), var(--indigo));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5rem;
    margin: 0 auto 14px;
}

.card h3 {
    font-family: 'Fraunces', serif;
    font-size: 0.95rem;
    color: var(--deep);
    font-weight: 600;
    margin-bottom: 8px;
}

.card p {
    color: var(--muted);
    font-size: 0.83rem;
    line-height: 1.6;
}

/* ── FORMULARIO ── */
.formulario {
    background: var(--panel);
    width: min(440px, 100%);
    margin: 0 auto;
    padding: 36px 32px;
    border-radius: 20px;
    box-shadow: 0 10px 36px var(--shadow);
    border: 1px solid var(--pale);
    text-align: left;
}

.formulario h3 {
    font-family: 'Fraunces', serif;
    font-size: 1.2rem;
    color: var(--deep);
    font-weight: 600;
    margin-bottom: 20px;
    text-align: center;
}

.field {
    margin-bottom: 14px;
}

.field label {
    display: block;
    font-size: 0.78rem;
    font-weight: 600;
    color: var(--deep);
    letter-spacing: 0.03em;
    margin-bottom: 5px;
}

.formulario input,
.formulario textarea {
    width: 100%;
    padding: 11px 14px;
    border: 1.5px solid var(--pale);
    border-radius: 10px;
    font-family: 'Manrope', sans-serif;
    font-size: 0.9rem;
    color: var(--deep);
    background: var(--mist);
    outline: none;
    transition: border-color 0.25s, box-shadow 0.25s;
    resize: vertical;
}

.formulario input::placeholder,
.formulario textarea::placeholder {
    color: #9aa7bc;
    font-weight: 300;
}

.formulario input:focus,
.formulario textarea:focus {
    border-color: var(--care);
    box-shadow: 0 0 0 3px rgba(47,117,102,0.15);
    background: var(--panel);
}

.formulario button {
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

.formulario button:hover {
    background: var(--night);
    transform: translateY(-2px);
}

/* ── FOOTER ── */
footer {
    background: var(--sidebar-bg);
    color: rgba(255,255,255,0.5);
    text-align: center;
    padding: 16px;
    font-size: 12.5px;
    margin-top: auto;
}

footer span {
    color: var(--pale);
    font-weight: 500;
}
</style>
</head>
<body>

<header>
    <div class="header-tag">✦ Estamos para ayudarte</div>
    <h1>Hospital NovaMed</h1>
    <p>Gestiona el registro y consulta de historias clínicas de forma fácil y segura</p>
</header>

<nav>
    <a href="index.jsp">Inicio</a>
    <a href="login.jsp">Acceso</a>
    <a href="quienesSomos.jsp">Quiénes Somos</a>
    <a href="productos.jsp">Servicios</a>
    <a href="contactanos.jsp">Contáctanos</a>
</nav>

<div class="container">
    <div class="section-title">
        <div class="form-tag">✦ Comunícate con nosotros</div>
        <h2>Contáctanos</h2>
        <div class="divider"></div>
    </div>

    <div class="info">
        <div class="card">
            <div class="card-icon">📞</div>
            <h3>Teléfono</h3>
            <p>+57 312 458 7690</p>
        </div>
        <div class="card">
            <div class="card-icon">✉️</div>
            <h3>Correo</h3>
            <p>contacto.novamed2026@gmail.com</p>
        </div>
        <div class="card">
            <div class="card-icon">📍</div>
            <h3>Dirección</h3>
            <p>Calle 45 #12-30<br>Bogotá, Colombia</p>
        </div>
    </div>

    <div class="formulario" style="text-align: center;">
        <h3>Escríbenos</h3>
        <p style="font-size: 0.88rem; color: #556077; line-height: 1.6; margin-bottom: 18px;">
            Para consultas sobre el sistema, escríbenos al correo
            <a href="mailto:contacto.novamed2026@gmail.com" style="color: #1f3a5f; font-weight: 600;">contacto.novamed2026@gmail.com</a>.
        </p>
        <a href="mailto:contacto.novamed2026@gmail.com" style="display: inline-block; padding: 12px 22px; border-radius: 10px; background: #1f3a5f; color: #ffffff; text-decoration: none; font-weight: 600;">Abrir correo →</a>
    </div>
</div>

<footer>
    <span>Hospital NovaMed</span> — Sistema de Gestión Hospitalaria
</footer>

</body>
</html>
