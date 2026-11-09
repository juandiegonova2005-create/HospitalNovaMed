<%@page import="modelo.ItemInventario"%>
<%@page import="modelo.InventarioDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Inventario</title>
    <style>
        body{ margin:0; font-family: Arial, Helvetica, sans-serif; background:#f4f6f9; padding:20px; }
        h2{ text-align:center; color:#1e3c72; }
        .form-container{ background:white; padding:20px; border-radius:12px;
            box-shadow:0px 5px 15px rgba(0,0,0,0.2); max-width:700px; margin:auto; margin-bottom:20px; }
        .fila{ display:flex; flex-wrap:wrap; gap:15px; }
        .input-group{ margin-bottom:15px; flex:1 1 150px; }
        label{ font-size:14px; }
        input, select{ width:100%; padding:10px; margin-top:5px; border-radius:8px; border:1px solid #ccc; box-sizing:border-box; }
        input:focus, select:focus{ border-color:#4facfe; outline:none; }
        .btn{ width:100%; padding:12px; border:none; border-radius:8px; background:#28a745; color:white; font-size:15px; cursor:pointer; }
        .btn:hover{ background:#218838; }
        .alerta{ max-width:700px; margin:auto; margin-bottom:20px; background:#f8d7da; color:#721c24; padding:12px; border-radius:8px; text-align:center; }
        table{ width:100%; border-collapse:collapse; background:white; box-shadow:0px 5px 15px rgba(0,0,0,0.2); }
        th{ background:#1e3c72; color:white; padding:10px; font-size:13px; }
        td{ padding:10px; text-align:center; font-size:13px; }
        tr:nth-child(even){ background:#f2f2f2; }
        tr:hover{ background:#dfe9f3; }
        a.accion{ text-decoration:none; padding:6px 10px; border-radius:6px; color:white; font-size:13px; display:inline-block; margin:2px; }
        .editar{ background:#007bff; } .eliminar{ background:#dc3545; }
        .editar:hover{ background:#0069d9; } .eliminar:hover{ background:#c82333; }
        .badge{ padding:4px 10px; border-radius:12px; font-size:12px; color:white; }
        .badge-disponible{ background:#28a745; }
        .badge-agotado{ background:#dc3545; }
        .badge-mantenimiento{ background:#e2a33d; }
    </style>
</head>
<body>

<h2>📦 Gestión de Inventario</h2>

<%
    String error = (String) request.getAttribute("error");
    if (error != null) {
%>
    <div class="alerta"><%=error%></div>
<%
    }
%>

<div class="form-container">
    <form method="post" action="CtrolInventario" onsubmit="return confirm('¿Registrar item?');">
        <input type="hidden" name="accion" value="agregar"/>
        <div class="fila">
            <div class="input-group">
                <label>Nombre</label>
                <input type="text" name="cnombre" required>
            </div>
            <div class="input-group">
                <label>Categoría</label>
                <input type="text" name="ccategoria" placeholder="Equipo, insumo, mobiliario...">
            </div>
        </div>
        <div class="fila">
            <div class="input-group">
                <label>Cantidad</label>
                <input type="number" name="ccantidad" min="0" value="0" required>
            </div>
            <div class="input-group">
                <label>Ubicación</label>
                <input type="text" name="cubicacion" placeholder="Bodega, piso 2...">
            </div>
            <div class="input-group">
                <label>Estado</label>
                <select name="cestado">
                    <option value="Disponible">Disponible</option>
                    <option value="Agotado">Agotado</option>
                    <option value="Mantenimiento">Mantenimiento</option>
                </select>
            </div>
        </div>
        <input type="submit" value="Registrar Item" class="btn">
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
        <th>Nombre</th>
        <th>Categoría</th>
        <th>Cantidad</th>
        <th>Ubicación</th>
        <th>Estado</th>
        <th>Acciones</th>
    </tr>
<%
    InventarioDAO idao = new InventarioDAO();
    List<ItemInventario> lista = idao.listadoInventario();
    for (ItemInventario i : lista) {
        String claseBadge;
        String est = i.getEstado() == null ? "" : i.getEstado();
        if ("Disponible".equalsIgnoreCase(est)) {
            claseBadge = "badge-disponible";
        } else if ("Agotado".equalsIgnoreCase(est)) {
            claseBadge = "badge-agotado";
        } else {
            claseBadge = "badge-mantenimiento";
        }
%>
    <tr>
        <td><%=i.getId_item()%></td>
        <td><%=i.getNombre()%></td>
        <td><%=i.getCategoria() != null ? i.getCategoria() : "-"%></td>
        <td><%=i.getCantidad()%></td>
        <td><%=i.getUbicacion() != null ? i.getUbicacion() : "-"%></td>
        <td><span class="badge <%=claseBadge%>"><%=i.getEstado()%></span></td>
        <td>
            <a class="accion editar" href="EditarInventario.jsp?id=<%=i.getId_item()%>" target="marco">✏ Editar</a>
            <a class="accion eliminar" href="CtrolInventario?accion=eliminar&id=<%=i.getId_item()%>"
               onclick="return confirm('¿Eliminar este item?')">🗑️ Eliminar</a>
        </td>
    </tr>
<%
    }
%>
</table>

</body>
</html>
