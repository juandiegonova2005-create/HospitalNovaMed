<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hospital NovaMed - Quiénes Somos</title>
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
  }

  body {
    font-family: 'Manrope', sans-serif;
    background-color: var(--mist);
    color: var(--deep);
    min-height: 100vh;
    overflow-x: hidden;
  }

  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background:
      radial-gradient(ellipse 80% 50% at 10% 0%, #dfe9f2 0%, transparent 60%),
      radial-gradient(ellipse 60% 60% at 90% 100%, #dff0ec 0%, transparent 55%);
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

  nav a:hover { color: var(--care); }
  nav a:hover::after { transform: translateX(-50%) scaleX(1); }

  nav a.active {
    color: var(--care);
  }
  nav a.active::after {
    transform: translateX(-50%) scaleX(1);
  }

  /* ─── CONTAINER ─── */
  .container {
    position: relative;
    z-index: 1;
    padding: 60px 24px 80px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 36px;
  }

  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(28px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  /* ─── PAGE HEADER ─── */
  .page-header {
    text-align: center;
    animation: fadeUp 0.5s ease both;
  }

  .page-tag {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: var(--light-bg);
    color: var(--care);
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.05em;
    padding: 5px 14px;
    border-radius: 20px;
    margin-bottom: 14px;
  }

  .page-header h2 {
    font-family: 'Fraunces', serif;
    font-size: 2.4rem;
    color: var(--deep);
    line-height: 1.2;
  }

  .page-header h2 em {
    color: var(--care);
    font-style: normal;
  }

  .page-header p {
    color: var(--muted);
    font-size: 0.95rem;
    margin-top: 10px;
    max-width: 520px;
    margin-inline: auto;
    line-height: 1.7;
  }

  /* ─── MISSION CARD ─── */
  .mission-card {
    background: var(--panel);
    width: min(860px, 100%);
    border-radius: 18px;
    box-shadow: 0 8px 40px var(--shadow);
    overflow: hidden;
    display: grid;
    grid-template-columns: 1fr 260px;
    animation: fadeUp 0.5s 0.1s ease both;
  }

  .mission-content {
    padding: 44px 44px;
    display: flex;
    flex-direction: column;
    gap: 16px;
    justify-content: center;
  }

  .mission-content h3 {
    font-family: 'Fraunces', serif;
    font-size: 1.4rem;
    color: var(--deep);
  }

  .mission-content p {
    font-size: 0.92rem;
    line-height: 1.75;
    color: var(--muted);
  }

  .mission-visual {
    background: linear-gradient(160deg, var(--care) 0%, var(--indigo) 100%);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 32px 20px;
    gap: 14px;
    position: relative;
  }

  .mission-visual::before {
    content: '✦';
    position: absolute;
    top: 18px;
    right: 20px;
    color: var(--nova);
    font-size: 1.2rem;
    opacity: 0.85;
  }

  .mission-visual img {
    width: 110px;
    filter: brightness(0) invert(1);
    opacity: 0.92;
  }

  .mission-visual-label {
    color: var(--panel);
    font-size: 0.78rem;
    font-weight: 500;
    letter-spacing: 0.06em;
    text-align: center;
    opacity: 0.9;
  }

  /* ─── VALUES ROW ─── */
  .values-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    width: min(860px, 100%);
    animation: fadeUp 0.5s 0.18s ease both;
  }

  .value-card {
    background: var(--panel);
    border-radius: 14px;
    padding: 26px 22px;
    box-shadow: 0 4px 16px var(--shadow);
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    border-top: 3px solid var(--pale);
    transition: border-color 0.25s, transform 0.22s;
  }

  .value-card:hover {
    border-color: var(--nova);
    transform: translateY(-4px);
  }

  .value-card .v-icon {
    font-size: 1.8rem;
  }

  .value-card h4 {
    font-family: 'Fraunces', serif;
    font-size: 1rem;
    color: var(--deep);
  }

  .value-card p {
    font-size: 0.82rem;
    color: var(--muted);
    line-height: 1.6;
  }

  /* ─── TEAM SECTION ─── */
  .section-title {
    font-family: 'Fraunces', serif;
    font-size: 1.5rem;
    color: var(--deep);
    text-align: center;
    width: min(860px, 100%);
    animation: fadeUp 0.5s 0.24s ease both;
  }

  .section-title span { color: var(--care); }

  .team-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    width: min(860px, 100%);
    animation: fadeUp 0.5s 0.3s ease both;
  }

  .team-card {
    background: var(--panel);
    border-radius: 16px;
    padding: 32px 20px 26px;
    box-shadow: 0 4px 20px var(--shadow);
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    transition: transform 0.22s, box-shadow 0.22s;
  }

  .team-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 14px 36px var(--shadow);
  }

  .team-avatar {
    width: 72px;
    height: 72px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--care), var(--indigo));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    margin-bottom: 4px;
  }

  .team-card h4 {
    font-family: 'Fraunces', serif;
    font-size: 1.05rem;
    color: var(--deep);
  }

  .team-card .role {
    font-size: 0.76rem;
    color: var(--care);
    font-weight: 600;
    letter-spacing: 0.04em;
    background: var(--light-bg);
    padding: 3px 12px;
    border-radius: 20px;
  }

  .team-card p {
    font-size: 0.82rem;
    color: var(--muted);
    line-height: 1.55;
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
    .mission-card { grid-template-columns: 1fr; }
    .mission-visual { padding: 28px; min-height: 160px; }
    .mission-visual img { width: 84px; }
    .mission-content { padding: 28px 24px; }
    .values-row { grid-template-columns: 1fr 1fr; }
    .team-grid { grid-template-columns: 1fr 1fr; }
    .page-header h2 { font-size: 1.8rem; }
  }

  @media (max-width: 480px) {
    .values-row { grid-template-columns: 1fr; }
    .team-grid { grid-template-columns: 1fr; }
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
  <a href="index.jsp"><span>🏠</span> Inicio</a>
  <a href="login.jsp"><span>🔒</span> Acceso</a>
  <a href="quienesSomos.jsp" class="active"><span>👥</span> Quiénes Somos</a>
  <a href="productos.jsp"><span>🩺</span> Servicios</a>
  <a href="contactanos.jsp"><span>📞</span> Contáctanos</a>
</nav>

<!-- ─── CONTENIDO ─── -->
<div class="container">

  <!-- PAGE HEADER -->
  <div class="page-header">
    <div class="page-tag">✦ Conócenos</div>
    <h2>Quiénes <em>somos</em></h2>
    <p>Un equipo comprometido con el desarrollo de soluciones digitales para la gestión hospitalaria.</p>
  </div>

  <!-- MISIÓN CARD -->
  <div class="mission-card">
    <div class="mission-content">
      <h3>Nuestra misión</h3>
      <p>
        Somos estudiantes de la Universidad San Buenaventura que desarrollamos
        este proyecto como parte de nuestro proceso de aprendizaje en el área
        de desarrollo web, utilizando tecnologías como JSP, HTML y CSS.
      </p>
      <p>
        Nuestro objetivo es crear una aplicación que permita registrar
        pacientes, gestionar hospitalizaciones, diagnósticos y tratamientos,
        y consultar su historial clínico de manera fácil, rápida y accesible.
      </p>
      <p>
        Este proyecto busca aplicar los conocimientos adquiridos durante nuestra
        formación, fortaleciendo habilidades en programación, diseño de interfaces
        y desarrollo de aplicaciones web orientadas al sector de la salud.
      </p>
    </div>
    <div class="mission-visual">
           <img src="img/medicina.svg" alt="equipo clínico">
      <div class="mission-visual-label">Equipo<br>Clínico</div>
    </div>
  </div>

  <!-- VALORES -->
  <div class="values-row">
    <div class="value-card">
      <div class="v-icon">🎯</div>
      <h4>Compromiso</h4>
      <p>Dedicados a entregar soluciones de calidad que respondan a necesidades reales del sector de la salud.</p>
    </div>
    <div class="value-card">
      <div class="v-icon">🔒</div>
      <h4>Seguridad</h4>
      <p>Protegemos los datos de los pacientes aplicando buenas prácticas de desarrollo seguro.</p>
    </div>
    <div class="value-card">
      <div class="v-icon">💡</div>
      <h4>Innovación</h4>
      <p>Buscamos soluciones modernas y accesibles que mejoren la gestión hospitalaria.</p>
    </div>
  </div>

  <!-- EQUIPO -->
  <div class="section-title">Nuestro <span>equipo de desarrollo</span></div>

  <div class="team-grid">
    <div class="team-card">
      <div class="team-avatar">👨‍💻</div>
      <h4>Juan Diego Nova</h4>
      <div class="role">Desarrollador</div>
      <p>Desarrollo backend con JSP y lógica de gestión de pacientes e historias clínicas.</p>
    </div>
    <div class="team-card">
      <div class="team-avatar">👨‍🎨</div>
      <h4>Juan Felipe Pérez</h4>
      <div class="role">Desarrollador</div>
      <p>Diseño de interfaces y experiencia de usuario para el sistema hospitalario.</p>
    </div>
    <div class="team-card">
      <div class="team-avatar">👩‍💻</div>
      <h4>Sebastian Rodríguez</h4>
      <div class="role">Desarrollador</div>
      <p>Integración de componentes y aseguramiento de calidad del sistema.</p>
    </div>
  </div>

</div>

<!-- ─── FOOTER ─── -->
<footer>
  <strong>Hospital NovaMed</strong> &mdash; Sistema de Gestión Hospitalaria &mdash; Todos los derechos reservados
</footer>

</body>
</html>
