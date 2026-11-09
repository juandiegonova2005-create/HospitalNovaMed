<%@page import="modelo.ItemInventario"%>
<%@page import="modelo.InventarioDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Item de Inventario</title>
    <style>
        body{ margin:0; font-family: Arial, Helvetica, sans-serif; background:#f4f6f9;
            display:flex; justify-content:center; align-items:center; min-height:100vh; padding:20px; box-sizing:border-box; }
        .container{ background:white; padding:30px; border-radius:15px; box-shadow:0px 10px 25px rgba(0,0,0,0.2); width:400px; }
        h2{ text-align:center; color:#1e3c72; margin-bottom:20px; }
        .input-group{ margin-bottom:15px; }
        label{ font-size:14px; color:#333; }
        input, select{ width:100%; padding:10px; margin-top:5px; border-radius:8px; border:1px solid #ccc; box-sizing:border-box; }
        .btn{ width:100%; padding:12px; border:none; border-radius:8px; background:#1e3c72; color:white; font-size:15px; cursor:pointer; margin-top:10px; }
        .btn:hover{ background:#16325c; }
        .volver{ text-align:center; margin-top:15px; }
        .volver a{ text-decoration:none; color:#1e3c72; font-size:14px; }
        .volver a:hover{ text-decoration:underline; }
    </style>
</head>
<body>

<%
    int id = Integer.parseInt(request.getParameter("id"));
    InventarioDAO idao = new InventarioDAO();
    ItemInventario i = idao.listadoItem_Id(id);
%>

<div class="container">
    <h2>📦 Editar Item</h2>
    <form method="post" action="CtrolInventario">
        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_item" value="<%=i.getId_item()%>"/>

        <div class="input-group">
            <label>Nombre</label>
            <input type="text" name="cnombre" value="<%=i.getNombre()%>" required>
        </div>

        <div class="input-group">
            <label>Categoría</label>
            <input type="text" name="ccategoria" value="<%=i.getCategoria() != null ? i.getCategoria() : ""%>">
        </div>

        <div class="input-group">
            <label>Cantidad</label>
            <input type="number" name="ccantidad" min="0" value="<%=i.getCantidad()%>" required>
        </div>

        <div class="input-group">
            <label>Ubicación</label>
            <input type="text" name="cubicacion" value="<%=i.getUbicacion() != null ? i.getUbicacion() : ""%>">
        </div>

        <div class="input-group">
            <label>Estado</label>
            <select name="cestado">
                <option value="Disponible" <%="Disponible".equalsIgnoreCase(i.getEstado()) ? "selected" : ""%>>Disponible</option>
                <option value="Agotado" <%="Agotado".equalsIgnoreCase(i.getEstado()) ? "selected" : ""%>>Agotado</option>
                <option value="Mantenimiento" <%="Mantenimiento".equalsIgnoreCase(i.getEstado()) ? "selected" : ""%>>Mantenimiento</option>
            </select>
        </div>

        <input type="submit" value="Actualizar" class="btn">
    </form>
    <div class="volver"><a href="javascript:history.back()">← Volver</a></div>
</div>

</body>
</html>
