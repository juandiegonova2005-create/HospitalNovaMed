<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, modelo.Usuario, modelo.UsuarioDAO, modelo.Perfil, modelo.PerfilDAO, modelo.Actividades, modelo.PermisosDAO, modelo.Util"%>
<%
    String paramId = request.getParameter("id");
    String msg = request.getParameter("msg");

    UsuarioDAO udao = new UsuarioDAO();
    PerfilDAO pdao = new PerfilDAO();

    Usuario u = null;
    try {
        u = (paramId == null) ? null : udao.listadoDatos_Id(Integer.parseInt(paramId));
    } catch (Exception e) {
        u = null;
    }

    List<Perfil> perfiles = pdao.listadoPerfiles();
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Roles y permisos - NovaMed</title>
<style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;padding:24px;color:#1e293b}
    .wrap{max-width:980px;margin:0 auto}
    h1{color:#0f4c5c;font-size:1.35rem;margin-bottom:4px}
    p.sub{color:#64748b;font-size:.88rem;margin-bottom:18px}
    .card{background:#fff;border-radius:14px;box-shadow:0 6px 24px rgba(0,0,0,.07);
          padding:24px;margin-bottom:18px}
    .info{background:#f0f9ff;border:1px solid #bae6fd;border-radius:10px;
          padding:12px 16px;font-size:.87rem;line-height:1.7;margin-bottom:18px}
    h3{color:#0f4c5c;font-size:1rem;margin-bottom:12px}
    label{font-size:.86rem;font-weight:bold;color:#334155}
    select{width:100%;padding:10px 12px;border:1px solid #cbd5e1;border-radius:8px;margin-top:6px;font-size:.92rem}
    .roles{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:8px}
    @media(max-width:700px){.roles{grid-template-columns:1fr}}
    .check{display:flex;align-items:center;gap:8px;margin:7px 0;font-weight:normal;font-size:.9rem;color:#334155}
    table{width:100%;border-collapse:collapse;margin-top:8px}
    th{background:#0f4c5c;color:#fff;text-align:left;padding:9px;font-size:.78rem}
    td{padding:8px 9px;border-bottom:1px solid #eef2f7;font-size:.83rem;vertical-align:middle}
    .opts{display:flex;gap:12px}
    .opt{display:flex;align-items:center;gap:4px;font-size:.78rem;color:#475569;font-weight:normal}
    .tag{display:inline-block;padding:2px 8px;border-radius:999px;font-size:.72rem;font-weight:bold}
    .on{background:#dcfce7;color:#166534}
    .off{background:#f1f5f9;color:#64748b}
    .btn{display:inline-block;margin-top:18px;padding:12px 20px;border:0;border-radius:8px;
         background:#0f766e;color:#fff;font-size:.95rem;cursor:pointer;text-decoration:none}
    .btn:hover{background:#115e59}
    .btn-volver{background:#fff;border:1px solid #cbd5e1;color:#334155;margin-left:8px}
    .btn-volver:hover{background:#f1f5f9}
    .alert-ok{background:#dcfce7;border:1px solid #86efac;color:#166534;border-radius:8px;
              padding:10px 14px;margin-bottom:16px;font-size:.88rem;font-weight:bold}
    .alert-error{background:#fee2e2;border:1px solid #fca5a5;color:#991b1b;border-radius:8px;
                 padding:10px 14px;margin-bottom:16px;font-size:.88rem;font-weight:bold}
</style>
</head>
<body>
<div class="wrap">
    <h1>🔐 Roles y permisos por usuario</h1>
    <p class="sub">Asigna uno o varios roles y ajusta cada módulo de forma individual.</p>

    <% if ("ok".equals(msg)) { %>
        <div class="alert-ok">✓ Roles y permisos guardados. Los cambios se aplican de inmediato.</div>
    <% } else if ("error".equals(msg)) { %>
        <div class="alert-error">✗ No se pudieron guardar los cambios. Revisa el registro de errores.</div>
    <% } %>

    <% if (u == null) { %>
        <div class="card">
            <div class="alert-error">No se encontró el usuario. Abre esta pantalla desde el listado de usuarios.</div>
            <a class="btn btn-volver" href="listaUsuarios.jsp">← Volver al listado</a>
        </div>
    <% } else {
        Perfil actual = pdao.listadoPerfil_Id(u.getIdperfil());
        List<Integer> extras = udao.perfilesAdicionales(u.getIdentificacion());
        Map<Integer, Integer> overrides = PermisosDAO.overrides(u.getIdentificacion());
        java.util.Set<String> efectivos = PermisosDAO.enlacesPermitidos(u.getIdentificacion());
    %>

    <div class="card">
        <div class="info">
            <strong>Nombre:</strong> <%=Util.esc(u.getNombre())%> <%=Util.esc(u.getApellido())%><br>
            <strong>Identificación:</strong> <%=Util.esc(u.getIdentificacion())%><br>
            <strong>Usuario:</strong> @<%=Util.esc(u.getUsuario())%><br>
            <strong>Rol principal:</strong> <%= actual == null ? "Sin rol" : Util.esc(actual.getPerfil()) %>
        </div>

        <form method="post" action="PermisosUsuario">
            <input type="hidden" name="identificacion" value="<%=Util.esc(u.getIdentificacion())%>">

            <h3>1. Roles asignados</h3>
            <div class="roles">
                <div>
                    <label for="id_perfil">Rol principal</label>
                    <select id="id_perfil" name="id_perfil" required>
                        <% for (Perfil p : perfiles) { %>
                            <option value="<%=p.getId_perfil()%>" <%= p.getId_perfil() == u.getIdperfil() ? "selected" : "" %>>
                                <%=Util.esc(p.getPerfil())%>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div>
                    <label>Roles adicionales (puede marcar varios)</label>
                    <% for (Perfil p : perfiles) { %>
                        <label class="check">
                            <input type="checkbox" name="extras" value="<%=p.getId_perfil()%>"
                                <%= extras.contains(p.getId_perfil()) ? "checked" : "" %>>
                            <%=Util.esc(p.getPerfil())%>
                        </label>
                    <% } %>
                </div>
            </div>

            <h3 style="margin-top:22px">2. Permisos por módulo</h3>
            <p style="color:#64748b;font-size:.8rem;margin-bottom:6px">
                “Heredar” usa lo que dan los roles. “Permitir” concede el módulo aunque el rol no lo tenga.
                “Denegar” lo bloquea siempre.
            </p>
            <table>
                <thead>
                    <tr>
                        <th>Módulo</th>
                        <th>Efectivo hoy</th>
                        <th>Decisión</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Actividades a : PermisosDAO.listarTodas()) {
                       Integer ov = overrides.get(a.getId_actividad());
                       boolean activo = a.getEnlace() != null && efectivos.contains(a.getEnlace());
                %>
                    <tr>
                        <td><strong><%=Util.esc(a.getNom_actividad())%></strong><br>
                            <span style="color:#94a3b8;font-size:.74rem"><%=Util.esc(a.getEnlace())%></span></td>
                        <td>
                            <span class="tag <%= activo ? "on" : "off" %>"><%= activo ? "Permitido" : "Bloqueado" %></span>
                        </td>
                        <td>
                            <div class="opts">
                                <label class="opt">
                                    <input type="radio" name="perm_<%=a.getId_actividad()%>" value=""
                                        <%= ov == null ? "checked" : "" %>> Heredar
                                </label>
                                <label class="opt">
                                    <input type="radio" name="perm_<%=a.getId_actividad()%>" value="1"
                                        <%= (ov != null && ov == 1) ? "checked" : "" %>> Permitir
                                </label>
                                <label class="opt">
                                    <input type="radio" name="perm_<%=a.getId_actividad()%>" value="0"
                                        <%= (ov != null && ov == 0) ? "checked" : "" %>> Denegar
                                </label>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>

            <button type="submit" class="btn">Guardar roles y permisos</button>
            <a class="btn btn-volver" href="listaUsuarios.jsp">← Volver al listado</a>
        </form>
    </div>

    <% } %>
</div>
</body>
</html>
