<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" %>
<%@ page import="config.Conexion" %>

<%
    HttpSession sesion_cli = request.getSession(true);
    String nUsuario = (String) sesion_cli.getAttribute("nUsuario");

    Connection con = null;
    Statement sentencia = null;
    ResultSet resultado = null;

    String nombre   = "";
    String apellido = "";
    String usu      = "";
    String perfil   = "";
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hospital NovaMed - Panel de Control</title>
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
    --shadow:   rgba(15,27,46,0.14);
    --sidebar-bg: #0d1524;
    --sidebar-hover: #17263e;
    --sidebar-border: rgba(199,216,230,0.12);
}

body {
    font-family: 'Manrope', sans-serif;
    display: flex;
    background-color: var(--mist);
    height: 100vh;
    overflow: hidden;
}

/* ── SIDEBAR ── */
.sidebar {
    width: 260px;
    background: var(--sidebar-bg);
    color: var(--panel);
    height: 100vh;
    display: flex;
    flex-direction: column;
    flex-shrink: 0;
}

.sidebar-header {
    padding: 24px 18px 18px;
    border-bottom: 1px solid var(--sidebar-border);
}

.brand {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
}

.brand-icon {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    background: linear-gradient(160deg, var(--care), var(--indigo));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    flex-shrink: 0;
}

.brand-name {
    font-family: 'Fraunces', serif;
    font-size: 1.1rem;
    color: var(--panel);
    font-weight: 600;
}

/* Tarjeta perfil */
.perfil-card {
    background: rgba(199,216,230,0.08);
    border: 1px solid var(--sidebar-border);
    border-radius: 12px;
    padding: 12px 14px;
}

.perfil-card .avatar {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: linear-gradient(160deg, var(--care), var(--indigo));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 9px;
    color: var(--panel);
}

.perfil-card .user-name {
    font-size: 13px;
    font-weight: 600;
    color: var(--panel);
    margin-bottom: 3px;
}

.perfil-card .user-at {
    font-size: 11px;
    color: var(--pale);
    margin-bottom: 9px;
}

.badge-perfil {
    display: inline-block;
    background: rgba(31,58,95,0.45);
    color: var(--pale);
    font-size: 11px;
    font-weight: 600;
    padding: 3px 10px;
    border-radius: 20px;
    border: 1px solid rgba(199,216,230,0.25);
}

/* Menú */
.sidebar-menu {
    flex: 1;
    padding: 16px 12px;
    overflow-y: auto;
}

.menu-label {
    font-size: 10px;
    font-weight: 600;
    color: rgba(255,255,255,0.35);
    text-transform: uppercase;
    letter-spacing: 0.1em;
    padding: 0 6px;
    margin-bottom: 8px;
}

.sidebar a {
    display: flex;
    align-items: center;
    gap: 8px;
    color: rgba(255,255,255,0.78);
    text-decoration: none;
    padding: 10px 12px;
    margin-bottom: 3px;
    border-radius: 9px;
    font-size: 13.5px;
    transition: background 0.2s, color 0.2s;
}

.sidebar a:hover {
    background: var(--sidebar-hover);
    color: var(--panel);
}

/* ── MAIN ── */
.main {
    flex: 1;
    background: var(--mist);
    display: flex;
    flex-direction: column;
    min-width: 0;
}

/* ── HEADER ── */
.header {
    background: linear-gradient(160deg, var(--care) 0%, var(--indigo) 100%);
    color: var(--panel);
    padding: 14px 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-shrink: 0;
}

.header-left {
    display: flex;
    flex-direction: column;
    gap: 3px;
}

.header-left .bienvenida {
    font-family: 'Fraunces', serif;
    font-size: 1rem;
    font-weight: 600;
    color: var(--panel);
}

.header-left .perfil-header {
    font-size: 12px;
    color: rgba(255,255,255,0.85);
    display: flex;
    align-items: center;
    gap: 6px;
}

.header-left .perfil-header span {
    background: rgba(255,255,255,0.2);
    padding: 2px 10px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 11px;
}

.logout {
    background: rgba(15,27,46,0.35);
    border: 1px solid rgba(255,255,255,0.25);
    padding: 8px 16px;
    border-radius: 9px;
    color: var(--panel);
    text-decoration: none;
    font-size: 13px;
    font-weight: 600;
    transition: background 0.2s;
}

.logout:hover {
    background: rgba(15,27,46,0.6);
}

/* ── CONTENT / IFRAME ── */
.content {
    flex: 1;
    padding: 20px;
    overflow: hidden;
}

iframe {
    width: 100%;
    height: calc(100vh - 100px);
    border: none;
    border-radius: 14px;
    background: var(--panel);
    box-shadow: 0 4px 20px var(--shadow);
}

</style>

</head>
<body>

<%
    try {
        Conexion cn = new Conexion();
        con = cn.crearConexion();

        PreparedStatement psDatos = con.prepareStatement(
            "SELECT u.identificacion, u.nombre, u.apellido, u.usuario, p.perfil " +
            "FROM Usuario u " +
            "JOIN Perfil p ON u.id_perfil = p.id_perfil " +
            "WHERE u.usuario = ?"
        );
        psDatos.setString(1, nUsuario);
        resultado = psDatos.executeQuery();

        String idLogueado = null;
        if (resultado.next()) {
            idLogueado = resultado.getString("identificacion");
            nombre   = resultado.getString("nombre");
            apellido = resultado.getString("apellido");
            usu      = resultado.getString("usuario");
            perfil   = resultado.getString("perfil");
        }

        // Perfiles adicionales (si los tiene) se muestran junto al principal
        if (idLogueado != null) {
            PreparedStatement psExtra = con.prepareStatement(
                "SELECT p.perfil FROM usuario_perfil up JOIN Perfil p ON p.id_perfil = up.id_perfil " +
                "WHERE up.identificacion = ? ORDER BY p.perfil");
            psExtra.setString(1, idLogueado);
            ResultSet rsExtra = psExtra.executeQuery();
            while (rsExtra.next()) {
                perfil += " + " + rsExtra.getString("perfil");
            }
        }

        con.close();

    } catch (Exception e) {
        modelo.Log.error("ERROR cpanel datos: " + e.getMessage());
    }

    String iniciales = "";
    if (nombre   != null && nombre.length()   > 0) iniciales += nombre.charAt(0);
    if (apellido != null && apellido.length() > 0) iniciales += apellido.charAt(0);
%>

<!-- ── SIDEBAR ── -->
<div class="sidebar">

    <div class="sidebar-header">
        <div class="brand">
            <div class="brand-icon">✚</div>
            <span class="brand-name">Hospital NovaMed</span>
        </div>

        <div class="perfil-card">
            <div class="avatar"><%=iniciales.toUpperCase()%></div>
            <div class="user-name"><%=modelo.Util.esc(nombre)%> <%=modelo.Util.esc(apellido)%></div>
            <div class="user-at">@<%=modelo.Util.esc(usu)%></div>
            <span class="badge-perfil">✦ <%=modelo.Util.esc(perfil)%></span>
        </div>
    </div>

    <div class="sidebar-menu">
        <div class="menu-label">Actividades</div>

<%
    // El menu se arma con los permisos efectivos: perfil principal + perfiles
    // adicionales + concesiones puntuales - denegaciones (tabla usuario_actividad).
    String idLogueadoMenu = (String) sesion_cli.getAttribute("idUsuario");
    java.util.List<modelo.Actividades> menu = modelo.PermisosDAO.listarActividades(idLogueadoMenu);
    for (modelo.Actividades act : menu) {
%>
        <a href="<%=modelo.Util.esc(modelo.Util.enlaceMenu(act.getEnlace()))%>" target="marco">
            ▸ <%=modelo.Util.esc(act.getNom_actividad())%>
        </a>
<%
    }
    boolean esAdmin = new modelo.UsuarioDAO().esAdministrador(idLogueadoMenu);
%>
        <a href="Documentos.jsp" target="marco">▸ Documentos</a>

        <% if (esAdmin) { %>
        <div class="menu-label" style="margin-top:14px">Administración</div>
        <a href="Configuracion.jsp" target="marco">▸ Configuración de seguridad</a>
        <a href="listaUsuarios.jsp" target="marco">▸ Usuarios y permisos</a>
        <a href="listaAuditoria.jsp" target="marco">▸ Auditoría</a>
        <% } %>

        <div class="menu-label" style="margin-top:14px">Mi cuenta</div>
        <a href="MiPerfil.jsp" target="marco">▸ Mi perfil (correo y contraseña)</a>
    </div>
</div>

<!-- ── MAIN ── -->
<div class="main">

    <div class="header">
        <div class="header-left">
            <div class="bienvenida"><%=modelo.Util.esc(nombre)%> <%=modelo.Util.esc(apellido)%></div>
            <div class="perfil-header">
                Perfil: <span><%=modelo.Util.esc(perfil)%></span>
            </div>
        </div>
        <a href="CerrarSesion" class="logout">← Cerrar sesión</a>
    </div>

    <div class="content">
        <iframe name="marco" src="front.jsp"></iframe>
    </div>

</div>

</body>
</html>
