<%@page import="modelo.Medicamento"%>
<%@page import="modelo.MedicamentoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Medicamento</title>
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
    MedicamentoDAO mdao = new MedicamentoDAO();
    Medicamento m = mdao.listadoMedicamento_Id(id);
%>

<div class="container">
    <h2>💊 Editar Medicamento</h2>
    <form method="post" action="CtrolMedicamento">
        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_medicamento" value="<%=m.getId_medicamento()%>"/>

        <div class="input-group">
            <label>Nombre</label>
            <input type="text" name="cnombre" value="<%=m.getNombre()%>" required>
        </div>

        <div class="input-group">
            <label>Descripción</label>
            <input type="text" name="cdescripcion" value="<%=m.getDescripcion() != null ? m.getDescripcion() : ""%>">
        </div>

        <div class="input-group">
            <label>Stock</label>
            <input type="number" name="cstock" min="0" value="<%=m.getStock()%>" required>
        </div>

        <div class="input-group">
            <label>Precio</label>
            <input type="number" step="0.01" min="0" name="cprecio" value="<%=m.getPrecio()%>">
        </div>

        <div class="input-group">
            <label>Estado</label>
            <select name="cestado">
                <option value="Disponible" <%="Disponible".equalsIgnoreCase(m.getEstado()) ? "selected" : ""%>>Disponible</option>
                <option value="Agotado" <%="Agotado".equalsIgnoreCase(m.getEstado()) ? "selected" : ""%>>Agotado</option>
            </select>
        </div>

        <input type="submit" value="Actualizar" class="btn">
    </form>
    <div class="volver"><a href="javascript:history.back()">← Volver</a></div>
</div>

</body>
</html>
