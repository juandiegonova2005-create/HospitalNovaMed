<%@page import="modelo.GesActividad"%>
<%@page import="modelo.GesActividadDAO"%>
<%@page import="modelo.Perfil"%>
<%@page import="modelo.PerfilDAO"%>
<%@page import="modelo.Actividades"%>
<%@page import="modelo.ActividadesDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión Actividades por Perfil</title>

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

        /* FORM */
        .form-container{
            background:white;
            padding:20px;
            border-radius:12px;
            box-shadow:0px 5px 15px rgba(0,0,0,0.2);
            max-width:500px;
            margin:auto;
            margin-bottom:30px;
        }

        .input-group{
            margin-bottom:15px;
        }

        label{
            font-size:14px;
        }

        select{
            width:100%;
            padding:10px;
            margin-top:5px;
            border-radius:8px;
            border:1px solid #ccc;
        }

        select:focus{
            border-color:#4facfe;
            outline:none;
        }

        .btn{
            width:100%;
            padding:12px;
            border:none;
            border-radius:8px;
            background:#28a745;
            color:white;
            font-size:15px;
            cursor:pointer;
        }

        .btn:hover{
            background:#218838;
        }

        /* TABLA */
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

        .eliminar{
            background:#dc3545;
        }

        .editar:hover{
            background:#0069d9;
        }

        .eliminar:hover{
            background:#c82333;
        }

    </style>
</head>

<body>

<h2>🔗 Gestión de Actividades por Perfil</h2>

<%
    PerfilDAO pdao = new PerfilDAO();
    List<Perfil> listaPerfiles = pdao.listadoPerfiles();

    ActividadesDAO adao = new ActividadesDAO();
    List<Actividades> listaActs = adao.listadoActividades();
%>

<!-- FORMULARIO -->
<div class="form-container">
    <form method="post" action="CtrolGesActividad"
          onsubmit="return confirm('¿Asignar actividad?');">

        <input type="hidden" name="accion" value="agregar"/>

        <div class="input-group">
            <label>Perfil</label>
            <select name="cid_perfil" required>
                <option value="">-- Seleccione --</option>
                <% for (Perfil p : listaPerfiles) { %>
                <option value="<%=p.getId_perfil()%>">
                    <%=p.getPerfil()%>
                </option>
                <% } %>
            </select>
        </div>

        <div class="input-group">
            <label>Actividad</label>
            <select name="cid_actividad" required>
                <option value="">-- Seleccione --</option>
                <% for (Actividades a : listaActs) { %>
                <option value="<%=a.getId_actividad()%>">
                    <%=a.getNom_actividad()%>
                </option>
                <% } %>
            </select>

        </div>

        <input type="submit" value="Asignar" class="btn">

    </form>
</div>
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
        <th>Perfil</th>
        <th>Actividad</th>
        <th>Acciones</th>
    </tr>

<%
    GesActividadDAO gdao = new GesActividadDAO();
    List<GesActividad> lista = gdao.listadoGesActividades();

    for (GesActividad g : lista) {
%>

    <tr>
        <td><%=g.getIdgesActividad()%></td>
        <td><%=g.getId_perfil()%></td>
        <td><%=g.getId_actividad()%></td>
        <td>
            <a class="editar"
               href="EditarGesActividad.jsp?id=<%=g.getIdgesActividad()%>" target="marco">
               Editar
            </a>

            <a class="eliminar"
               href="CtrolGesActividad?accion=eliminar&id=<%=g.getIdgesActividad()%>"
               onclick="return confirm('¿Eliminar asignación?')">
               Eliminar
            </a>
        </td>
    </tr>

<%
    }
%>

</table>

</body>
</html>