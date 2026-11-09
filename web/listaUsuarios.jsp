<%@page import="java.util.List"%>
<%@page import="modelo.Usuario"%>
<%@page import="modelo.UsuarioDAO"%>
<%@page import="modelo.Perfil"%>
<%@page import="modelo.PerfilDAO"%>
<%@page import="modelo.Util"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listado de Usuarios</title>

    <style>

        body{
            margin:0;
            font-family: Arial, Helvetica, sans-serif;
            background:#f4f6f9;
            padding:20px;
        }

        h2{
            text-align:center;
            color:#1e3c72;
        }

        table{
            width:100%;
            border-collapse:collapse;
            background:white;
            box-shadow:0px 5px 15px rgba(0,0,0,0.2);
        }

        th{
            background:#1e3c72;
            color:white;
            padding:10px;
        }

        td{
            padding:10px;
            text-align:center;
        }

        tr:nth-child(even){
            background:#f2f2f2;
        }

        tr:hover{
            background:#dfe9f3;
        }

        a{
            text-decoration:none;
            padding:6px 10px;
            border-radius:6px;
            color:white;
            font-size:13px;
        }

        .editar{
            background:#007bff;
        }

        .editar:hover{
            background:#0069d9;
        }

        .perfil{
            background:#7e22ce;
        }

        .perfil:hover{
            background:#6b21a8;
        }

        .eliminar{
            background:#dc3545;
        }

        .eliminar:hover{
            background:#c82333;
        }

        .permisos{
            background:#0f766e;
        }

        .permisos:hover{
            background:#115e59;
        }

        .desbloquear{
            background:#d97706;
            border:none;
            cursor:pointer;
            font-size:13px;
            padding:6px 10px;
            border-radius:6px;
            color:white;
            margin:2px;
        }

        .desbloquear:hover{
            background:#b45309;
        }

        .estado-on{
            background:#dcfce7;
            color:#166534;
            padding:3px 9px;
            border-radius:999px;
            font-size:12px;
            font-weight:bold;
        }

        .estado-off{
            background:#fee2e2;
            color:#991b1b;
            padding:3px 9px;
            border-radius:999px;
            font-size:12px;
            font-weight:bold;
        }

        .alerta{
            max-width:700px;
            margin:0 auto 16px auto;
            padding:10px 14px;
            border-radius:8px;
            font-size:14px;
            font-weight:bold;
        }

        .alerta-ok{ background:#dcfce7; border:1px solid #86efac; color:#166534; }
        .alerta-error{ background:#fee2e2; border:1px solid #fca5a5; color:#991b1b; }

    </style>
</head>

<body>

<h2>👤 Listado de Usuarios</h2>

<%
    String msg = request.getParameter("msg");
    if ("desbloqueado".equals(msg)) {
%>
    <div class="alerta alerta-ok">✓ Cuenta desbloqueada. El usuario ya puede iniciar sesión.</div>
<%
    } else if ("error".equals(msg) || "id".equals(msg)) {
%>
    <div class="alerta alerta-error">✗ No se pudo completar la operación.</div>
<%
    }
%>
<!-- BUSCADOR -->
<style>
    .buscador-tabla{ max-width:700px; margin:0 auto 20px auto; display:flex; gap:10px; }
    .buscador-tabla input{ flex:1; padding:10px; border-radius:8px; border:1px solid #ccc; }
    .buscador-tabla button{ padding:10px 15px; border:none; border-radius:8px; background:#6c757d; color:white; cursor:pointer; }
    .buscador-tabla button:hover{ background:#5a6268; }
    #sinResultados{ display:none; text-align:center; color:#666; margin:10px 0; }
</style>

<div class="buscador-tabla">
    <input type="text" id="buscador" placeholder="🔍 Buscar..." oninput="filtrarTabla()" autocomplete="off">
    <button type="button" onclick="limpiarBusqueda()">✖ Limpiar</button>
</div>
<p id="sinResultados">No se encontraron resultados.</p>

<script>
    function normalizar(t) {
        return t.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    function filtrarTabla() {
        var buscado = normalizar(document.getElementById('buscador').value.trim());
        var filas = document.querySelectorAll('table tr');
        var visibles = 0;

        for (var i = 1; i < filas.length; i++) {           // la fila 0 es el encabezado
            var celdas = filas[i].cells;
            var texto = '';
            for (var c = 0; c < celdas.length - 1; c++) {  // se omite la ultima columna (Acciones)
                texto += ' ' + celdas[c].textContent;
            }
            var coincide = normalizar(texto).indexOf(buscado) !== -1;
            filas[i].style.display = coincide ? '' : 'none';
            if (coincide) visibles++;
        }
        document.getElementById('sinResultados').style.display =
                (visibles === 0 && filas.length > 1) ? 'block' : 'none';
    }

    function limpiarBusqueda() {
        document.getElementById('buscador').value = '';
        filtrarTabla();
        document.getElementById('buscador').focus();
    }
</script>
<table>
    <tr>
        <th>ID</th>
        <th>Nombres</th>
        <th>Apellidos</th>
        <th>Email</th>
        <th>Usuario</th>
        <th>Contraseña</th>
        <th>Perfil</th>
        <th>Estado</th>
        <th>Acciones</th>
    </tr>

<%
    UsuarioDAO udao = new UsuarioDAO();
    PerfilDAO  pdao = new PerfilDAO();
    List<Usuario> lista = udao.listadoDatos();

    // Los perfiles se leen UNA sola vez. Antes se hacia una consulta por cada
    // usuario: con 458 usuarios y MySQL en la nube la pagina tardaba ~35s.
    java.util.Map<Integer, String> nombresPerfil = new java.util.HashMap<>();
    for (Perfil p : pdao.listadoPerfiles()) {
        nombresPerfil.put(p.getId_perfil(), p.getPerfil());
    }

    for (Usuario a : lista) {
        String nomPerfil = nombresPerfil.getOrDefault(a.getIdperfil(), "Sin perfil");
        boolean bloqueado = a.isBloqueada();
%>

    <tr>
        <td><%=Util.esc(a.getIdentificacion())%></td>
        <td><%=Util.esc(a.getNombre())%></td>
        <td><%=Util.esc(a.getApellido())%></td>
        <td><%=Util.esc(a.getEmail())%></td>
        <td><%=Util.esc(a.getUsuario())%></td>
        <td>******</td>
        <td><%=Util.esc(nomPerfil)%></td>
        <td>
            <% if (bloqueado) { %>
                <span class="estado-off">Bloqueado</span>
            <% } else { %>
                <span class="estado-on">Activo</span>
            <% } %>
        </td>
        <td>

            <a class="editar"
               href="EditarUsuario.jsp?id=<%=Util.esc(a.getIdentificacion())%>" target="marco">
               ✏ Editar
            </a>

            <a class="perfil"
               href="PermisosUsuario.jsp?id=<%=Util.esc(a.getIdentificacion())%>" target="marco">
               🔐 Roles y permisos
            </a>

            <% if (bloqueado) { %>
            <form method="post" action="DesbloquearUsuario" style="display:inline"
                  onsubmit="return confirm('¿Desbloquear esta cuenta?');">
                <input type="hidden" name="id" value="<%=Util.esc(a.getIdentificacion())%>">
                <button type="submit" class="desbloquear">🔓 Desbloquear</button>
            </form>
            <% } %>

            <a class="eliminar"
               href="EliminarUsuario?id=<%=Util.esc(a.getIdentificacion())%>"
               onclick="return confirm('¿Eliminar este usuario?')">
               🗑️ Eliminar
            </a>

        </td>
    </tr>

<%
    }
%>

</table>

</body>
</html>
