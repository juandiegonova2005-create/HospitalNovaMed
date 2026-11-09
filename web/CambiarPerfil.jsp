<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.Usuario"%>
<%@ page import="modelo.UsuarioDAO"%>
<%@ page import="modelo.Perfil"%>
<%@ page import="modelo.PerfilDAO"%>
<%@ page import="java.util.List"%>
<%@ page import="modelo.Util"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cambiar Perfil</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f4f6f9;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 2rem;
        }
        .card {
            background: white;
            border-radius: 15px;
            box-shadow: 0px 10px 25px rgba(0,0,0,0.15);
            padding: 2rem;
            width: 100%;
            max-width: 450px;
        }
        h2 {
            text-align: center;
            color: #1e3c72;
            margin-bottom: 1.5rem;
            font-size: 20px;
        }
        .info-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 1.5rem;
            font-size: 14px;
            color: #334155;
            line-height: 2;
        }
        .info-box strong { color: #1e3c72; }
        .badge {
            display: inline-block;
            background: #dbeafe;
            color: #1d4ed8;
            font-size: 12px;
            font-weight: bold;
            padding: 3px 10px;
            border-radius: 20px;
        }
        label {
            display: block;
            font-size: 13px;
            font-weight: bold;
            color: #475569;
            margin-bottom: 6px;
        }
        select {
            width: 100%;
            padding: 10px 12px;
            border: 1.5px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 1rem;
            outline: none;
        }
        select:focus { border-color: #3b82f6; }
        .btn-guardar {
            width: 100%;
            padding: 11px;
            background: #1e3c72;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
            margin-bottom: 8px;
        }
        .btn-guardar:hover { background: #16325c; }
        .btn-volver {
            display: block;
            text-align: center;
            padding: 10px;
            border: 1.5px solid #cbd5e1;
            border-radius: 8px;
            color: #64748b;
            text-decoration: none;
            font-size: 14px;
        }
        .btn-volver:hover { background: #f1f5f9; }
        .alert-ok {
            background: #dcfce7;
            border: 1px solid #86efac;
            color: #166534;
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 1rem;
            font-size: 13px;
            font-weight: bold;
        }
        .alert-error {
            background: #fee2e2;
            border: 1px solid #fca5a5;
            color: #991b1b;
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 1rem;
            font-size: 13px;
            font-weight: bold;
        }
    </style>
</head>
<body>

<%
    String paramId = request.getParameter("id");
    String msg     = request.getParameter("msg");

    UsuarioDAO udao = new UsuarioDAO();
    PerfilDAO  pdao = new PerfilDAO();
    List<Perfil> perfiles = pdao.listadoPerfiles();

    Usuario u = null;
    if (paramId != null && !paramId.isEmpty()) {
        try {
            u = udao.listadoDatos_Id(Integer.parseInt(paramId));
        } catch (NumberFormatException e) { }
    }
%>

<div class="card">
    <h2>&#128100; Cambiar perfil de usuario</h2>

    <% if ("ok".equals(msg)) { %>
        <div class="alert-ok">&#10003; Perfil actualizado correctamente.</div>
    <% } else if ("error".equals(msg)) { %>
        <div class="alert-error">&#10007; Ocurrio un error. Intenta de nuevo.</div>
    <% } %>

    <% if (u != null) {
        Perfil perfilActual = pdao.listadoPerfil_Id(u.getIdperfil());
        String nomPerfil = (perfilActual != null) ? perfilActual.getPerfil() : "Sin perfil";
    %>

    <div class="info-box">
        <strong>Nombre:</strong> <%=Util.esc(u.getNombre())%> <%=Util.esc(u.getApellido())%><br>
        <strong>Identificacion:</strong> <%=Util.esc(u.getIdentificacion())%><br>
        <strong>Usuario:</strong> @<%=Util.esc(u.getUsuario())%><br>
        <strong>Perfil actual:</strong> <span class="badge"><%=Util.esc(nomPerfil)%></span>
    </div>

    <form method="post" action="CambiarPerfil">
        <input type="hidden" name="identificacion" value="<%=Util.esc(u.getIdentificacion())%>">

        <label>Selecciona el nuevo perfil:</label>
        <select name="nuevo_perfil" required>
            <option value="">-- Selecciona un perfil --</option>
            <% for (Perfil p : perfiles) { %>
                <option value="<%=p.getId_perfil()%>"
                    <%= (p.getId_perfil() == u.getIdperfil()) ? "selected" : "" %>>
                    <%=Util.esc(p.getPerfil())%>
                </option>
            <% } %>
        </select>

        <label style="margin-top:14px">Perfiles adicionales (opcional):</label>
        <% List<Integer> extrasUsu = udao.perfilesAdicionales(u.getIdentificacion());
           for (Perfil p : perfiles) { %>
            <div style="margin:4px 0;font-size:.9rem">
                <label style="display:inline;font-weight:normal">
                    <input type="checkbox" name="extras" value="<%=p.getId_perfil()%>"
                        <%= extrasUsu.contains(p.getId_perfil()) ? "checked" : "" %>>
                    <%=Util.esc(p.getPerfil())%>
                </label>
            </div>
        <% } %>
        <small style="color:#64748b">El usuario obtiene los permisos del perfil principal más los de los adicionales marcados.</small>
        <button type="submit" class="btn-guardar">Aplicar cambio de perfil</button>
    </form>

    <% } else { %>
        <div class="alert-error">No se encontro el usuario.</div>
    <% } %>

    <a href="listaUsuarios.jsp" class="btn-volver">&#8592; Volver al listado</a>
</div>

</body>
</html>