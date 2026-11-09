<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hospital NovaMed - Servicios</title>
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
    --sidebar-border: rgba(199,216,230,0.12);
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
}

.section-title {
    text-align: center;
    margin-bottom: 40px;
}

.section-title .form-tag {
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

/* ── CARDS ── */
.servicios {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 24px;
}

.card {
    background: var(--panel);
    width: 260px;
    padding: 30px 24px;
    border-radius: 18px;
    text-align: center;
    box-shadow: 0 6px 24px var(--shadow);
    border: 1px solid var(--pale);
    transition: transform 0.25s, box-shadow 0.25s;
}

.card:hover {
    transform: translateY(-6px);
    box-shadow: 0 16px 40px var(--shadow);
}

.card-icon {
    width: 64px;
    height: 64px;
    border-radius: 50%;
    background: linear-gradient(160deg, var(--care), var(--indigo));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.8rem;
    margin: 0 auto 16px;
}

.card h3 {
    font-family: 'Fraunces', serif;
    font-size: 1rem;
    color: var(--deep);
    font-weight: 600;
    margin-bottom: 10px;
}

.card p {
    color: var(--muted);
    font-size: 0.84rem;
    line-height: 1.65;
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
    <div class="header-tag">✦ Sistema clínico</div>
    <h1>Hospital NovaMed</h1>
    <p>Gestiona pacientes, hospitalizaciones, historias clínicas y tratamientos de forma fácil y segura</p>
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
        <div class="form-tag">✦ Lo que ofrecemos</div>
        <h2>Módulos del sistema</h2>
        <div class="divider"></div>
    </div>

    <div class="servicios">
        <div class="card">
            <div class="card-icon">📋</div>
            <h3>Gestión de Pacientes</h3>
            <p>Registra, busca y actualiza los datos personales y clínicos de cada paciente.</p>
        </div>
        <div class="card">
            <div class="card-icon">🗂️</div>
            <h3>Historias Clínicas</h3>
            <p>Consulta antecedentes, diagnósticos y evolución clínica de cada paciente.</p>
        </div>
        <div class="card">
            <div class="card-icon">🛏️</div>
            <h3>Hospitalización</h3>
            <p>Controla ingresos, egresos, asignación de camas y médicos responsables.</p>
        </div>
        <div class="card">
            <div class="card-icon">🩺</div>
            <h3>Diagnósticos y Tratamientos</h3>
            <p>Registra diagnósticos CIE-10 y los medicamentos y dosis asociados.</p>
        </div>
        <div class="card">
            <div class="card-icon">💊</div>
            <h3>Medicamentos e Inventario</h3>
            <p>Administra stock, precios, categorías y disponibilidad de los insumos.</p>
        </div>
        <div class="card">
            <div class="card-icon">📊</div>
            <h3>Reportes y Auditoría</h3>
            <p>Consulta indicadores de ocupación, tratamientos y actividad del sistema.</p>
        </div>
    </div>
</div>

<footer>
    <span>Hospital NovaMed</span> — Sistema de Gestión Hospitalaria
</footer>

</body>
</html>
