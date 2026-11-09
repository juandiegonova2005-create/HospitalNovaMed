<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hospital NovaMed - Sistema de Gestión Hospitalaria</title>
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
    color: var(--deep);
    min-height: 100vh;
    overflow-x: hidden;
  }

  /* ─── BACKGROUND TEXTURE ─── */
  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background:
      radial-gradient(ellipse 70% 45% at 8% 0%, #dfe9f2 0%, transparent 58%),
      radial-gradient(ellipse 55% 55% at 92% 100%, #dff0ec 0%, transparent 55%);
    pointer-events: none;
    z-index: 0;
  }

  /* ─── HEADER ─── */
  header {
    position: relative;
    z-index: 10;
    background: var(--night);
    padding: 0 40px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-height: 80px;
    box-shadow: 0 4px 24px var(--shadow);
  }

  .header-brand {
    display: flex;
    align-items: center;
    gap: 14px;
  }

  .header-icon {
    width: 44px;
    height: 44px;
    background: var(--indigo);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
    position: relative;
  }

  .header-icon::after {
    content: '';
    position: absolute;
    inset: -4px;
    border: 1px solid var(--nova);
    border-radius: 50%;
    opacity: 0.55;
  }

  .header-text h1 {
    font-family: 'Fraunces', serif;
    font-size: 1.6rem;
    font-weight: 700;
    color: var(--panel);
    letter-spacing: 0.01em;
    line-height: 1.1;
  }

  .header-text span {
    font-size: 0.78rem;
    color: var(--pale);
    font-weight: 300;
    letter-spacing: 0.1em;
  }

  .header-badge {
    background: var(--nova);
    color: var(--night);
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    padding: 6px 14px;
    border-radius: 20px;
  }

  /* ─── NAV ─── */
  nav {
    position: relative;
    z-index: 10;
    background: var(--panel);
    border-bottom: 2px solid var(--pale);
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 0;
    box-shadow: 0 2px 12px var(--shadow);
  }

  nav a {
    color: var(--muted);
    text-decoration: none;
    padding: 16px 28px;
    font-size: 0.85rem;
    font-weight: 500;
    letter-spacing: 0.02em;
    display: flex;
    align-items: center;
    gap: 7px;
    position: relative;
    transition: color 0.25s;
  }

  nav a::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%) scaleX(0);
    width: 60%;
    height: 2.5px;
    background: var(--care);
    border-radius: 2px;
    transition: transform 0.25s;
  }

  nav a:hover {
    color: var(--care);
  }

  nav a:hover::after {
    transform: translateX(-50%) scaleX(1);
  }

  nav a .nav-icon {
    font-size: 1rem;
  }

  /* ─── MAIN CONTAINER ─── */
  .container {
    position: relative;
    z-index: 1;
    padding: 60px 24px 80px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 40px;
  }

  /* ─── HERO CARD ─── */
  .hero-card {
    background: var(--panel);
    width: min(880px, 100%);
    border-radius: 18px;
    box-shadow: 0 8px 40px var(--shadow);
    overflow: hidden;
    display: grid;
    grid-template-columns: 1fr 280px;
    animation: fadeUp 0.6s ease both;
  }

  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(28px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  .hero-content {
    padding: 48px 44px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 18px;
  }

  .hero-tag {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: var(--light-bg);
    color: var(--care);
    font-size: 0.75rem;
    font-weight: 600;
    letter-spacing: 0.04em;
    padding: 5px 12px;
    border-radius: 20px;
    width: fit-content;
  }

  .hero-content h2 {
    font-family: 'Fraunces', serif;
    font-size: 2.15rem;
    font-weight: 700;
    color: var(--deep);
    line-height: 1.22;
  }

  .hero-content h2 em {
    color: var(--care);
    font-style: normal;
  }

  .hero-content p {
    font-size: 0.95rem;
    line-height: 1.75;
    color: var(--muted);
    max-width: 430px;
  }

  .hero-cta {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--indigo);
    color: var(--panel);
    font-size: 0.85rem;
    font-weight: 600;
    padding: 13px 26px;
    border-radius: 8px;
    text-decoration: none;
    width: fit-content;
    transition: background 0.25s, transform 0.2s;
    margin-top: 4px;
  }

  .hero-cta:hover {
    background: var(--night);
    transform: translateY(-2px);
  }

  .hero-visual {
    background: linear-gradient(160deg, var(--care) 0%, var(--indigo) 100%);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 32px 20px;
    gap: 16px;
    position: relative;
  }

  .hero-visual::before {
    content: '✦';
    position: absolute;
    top: 22px;
    right: 26px;
    color: var(--nova);
    font-size: 1.4rem;
    opacity: 0.85;
  }

  .hero-visual img {
    width: 130px;
    filter: brightness(0) invert(1);
    opacity: 0.92;
  }

  .hero-visual-label {
    color: var(--panel);
    font-size: 0.8rem;
    font-weight: 500;
    letter-spacing: 0.06em;
    text-align: center;
    opacity: 0.9;
  }

  /* ─── STATS ROW ─── */
  .stats-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    width: min(880px, 100%);
    animation: fadeUp 0.6s 0.15s ease both;
  }

  .stat-card {
    background: var(--panel);
    border-radius: 14px;
    padding: 26px 28px;
    box-shadow: 0 4px 20px var(--shadow);
    display: flex;
    align-items: center;
    gap: 18px;
    border-left: 4px solid var(--pale);
    transition: border-color 0.25s, transform 0.2s;
  }

  .stat-card:hover {
    border-color: var(--nova);
    transform: translateY(-3px);
  }

  .stat-icon {
    width: 48px;
    height: 48px;
    background: var(--light-bg);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5rem;
    flex-shrink: 0;
  }

  .stat-info strong {
    display: block;
    font-family: 'Fraunces', serif;
    font-size: 1.6rem;
    color: var(--deep);
    line-height: 1;
  }

  .stat-info span {
    font-size: 0.78rem;
    color: var(--muted);
    font-weight: 400;
    letter-spacing: 0.02em;
  }

  /* ─── SERVICIOS GRID ─── */
  .section-title {
    font-family: 'Fraunces', serif;
    font-size: 1.5rem;
    color: var(--deep);
    text-align: center;
    width: min(880px, 100%);
    animation: fadeUp 0.6s 0.25s ease both;
  }

  .section-title span {
    color: var(--care);
  }

  .services-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    width: min(880px, 100%);
    animation: fadeUp 0.6s 0.3s ease both;
  }

  .service-card {
    background: var(--panel);
    border-radius: 14px;
    padding: 28px 22px;
    box-shadow: 0 4px 16px var(--shadow);
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    transition: transform 0.22s, box-shadow 0.22s;
    cursor: default;
  }

  .service-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 12px 32px var(--shadow);
  }

  .service-card .s-icon {
    width: 56px;
    height: 56px;
    background: var(--light-bg);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.6rem;
  }

  .service-card h3 {
    font-family: 'Fraunces', serif;
    font-size: 1rem;
    color: var(--deep);
  }

  .service-card p {
    font-size: 0.82rem;
    color: var(--muted);
    line-height: 1.6;
  }

  /* ─── FOOTER ─── */
  footer {
    position: relative;
    z-index: 10;
    background: var(--night);
    color: var(--pale);
    text-align: center;
    padding: 22px 24px;
    font-size: 0.82rem;
    letter-spacing: 0.03em;
  }

  footer strong {
    color: var(--panel);
    font-weight: 500;
  }

  /* ─── RESPONSIVE ─── */
  @media (max-width: 700px) {
    header { padding: 0 20px; }
    .header-badge { display: none; }
    .hero-card { grid-template-columns: 1fr; }
    .hero-visual { padding: 28px; min-height: 180px; }
    .hero-visual img { width: 100px; }
    .hero-content { padding: 32px 24px; }
    .stats-row { grid-template-columns: 1fr; }
    .services-grid { grid-template-columns: 1fr 1fr; }
  }

  @media (max-width: 480px) {
    .services-grid { grid-template-columns: 1fr; }
  }
</style>
</head>
<body>

<!-- ─── HEADER ─── -->
<header>
  <div class="header-brand">
    <div class="header-icon">✚</div>
    <div class="header-text">
      <h1>Hospital NovaMed</h1>
      <span>Sistema de Gestión Hospitalaria</span>
    </div>
  </div>
  <div class="header-badge">Sistema Clínico</div>
</header>

<!-- ─── NAV ─── -->
<nav>
  <a href="index.jsp"><span class="nav-icon">🏠</span> Inicio</a>
  <a href="login.jsp"><span class="nav-icon">🔒</span> Acceso</a>
  <a href="quienesSomos.jsp"><span class="nav-icon">👥</span> Quiénes Somos</a>
  <a href="productos.jsp"><span class="nav-icon">🩺</span> Servicios</a>
  <a href="contactanos.jsp"><span class="nav-icon">📞</span> Contáctanos</a>
</nav>

<!-- ─── CONTENIDO PRINCIPAL ─── -->
<div class="container">

  <!-- HERO CARD -->
  <div class="hero-card">
    <div class="hero-content">
      <div class="hero-tag">✦ Bienvenido/a</div>
      <h2>La historia clínica de tus pacientes,<br><em>siempre a la mano</em></h2>
      <p>
        Registra pacientes, gestiona hospitalizaciones, diagnósticos y
        tratamientos, y consulta su historial clínico de forma ágil y segura.
        Administra la información clínica de tu hospital en un solo lugar.
      </p>
      <a href="login.jsp" class="hero-cta">
        🩺 Ingresar al sistema &rarr;
      </a>
    </div>
    <div class="hero-visual">
                  <img src="img/medicina.svg" alt="cruz médica con latido">
      <div class="hero-visual-label">Gestión<br>Hospitalaria</div>
    </div>
  </div>

  <!-- STATS -->
  <div class="stats-row">
    <div class="stat-card">
      <div class="stat-icon">🧩</div>
      <div class="stat-info">
        <strong>16</strong>
        <span>Módulos integrados</span>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">👤</div>
      <div class="stat-info">
        <strong>2</strong>
        <span>Perfiles de acceso</span>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">⏱️</div>
      <div class="stat-info">
        <strong>30 min</strong>
        <span>Cierre por inactividad</span>
      </div>
    </div>
  </div>

  <!-- SERVICIOS -->
  <div class="section-title">Nuestros <span>módulos</span></div>

  <div class="services-grid">
    <div class="service-card">
      <div class="s-icon">📝</div>
      <h3>Registro de Pacientes</h3>
      <p>Registra los datos personales y clínicos básicos de cada paciente.</p>
    </div>
    <div class="service-card">
      <div class="s-icon">🗂️</div>
      <h3>Historias Clínicas</h3>
      <p>Consulta antecedentes, diagnósticos y evolución clínica por paciente.</p>
    </div>
    <div class="service-card">
      <div class="s-icon">🛏️</div>
      <h3>Hospitalizaciones</h3>
      <p>Gestiona ingresos, egresos, camas y médicos responsables.</p>
    </div>
    <div class="service-card">
      <div class="s-icon">🩺</div>
      <h3>Diagnósticos y Tratamientos</h3>
      <p>Registra diagnósticos CIE-10 y los tratamientos asociados.</p>
    </div>
    <div class="service-card">
      <div class="s-icon">💊</div>
      <h3>Medicamentos e Inventario</h3>
      <p>Controla stock, precios, categorías y disponibilidad de insumos.</p>
    </div>
    <div class="service-card">
      <div class="s-icon">📊</div>
      <h3>Reportes y Auditoría</h3>
      <p>Consulta indicadores de ocupación, tratamientos y actividad del sistema.</p>
    </div>
  </div>

</div>

<!-- ─── FOOTER ─── -->
<footer>
  <strong>Hospital NovaMed</strong> &mdash; Sistema de Gestión Hospitalaria &mdash; Todos los derechos reservados
</footer>

</body>
</html>
