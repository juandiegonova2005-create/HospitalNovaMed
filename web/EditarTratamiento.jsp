<%@page import="modelo.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Tratamiento</title>
    <style>
        body{ margin:0; font-family: Arial, Helvetica, sans-serif; background:#f4f6f9;
            display:flex; justify-content:center; align-items:center; min-height:100vh;
            padding:20px; box-sizing:border-box; }
        .container{ background:white; padding:30px; border-radius:15px;
            box-shadow:0px 10px 25px rgba(0,0,0,0.2); width:380px; }
        h2{ text-align:center; color:#1e3c72; margin-bottom:20px; }
        .input-group{ margin-bottom:15px; }
        label{ font-size:14px; color:#333; }
        input, select, textarea{ width:100%; padding:10px; margin-top:5px; border-radius:8px;
            border:1px solid #ccc; outline:none; box-sizing:border-box; font-family:inherit; }
        .btn{ width:100%; padding:12px; border:none; border-radius:8px; background:#1e3c72;
            color:white; font-size:15px; cursor:pointer; margin-top:10px; }
        .btn:hover{ background:#16325c; }
        .volver{ text-align:center; margin-top:15px; }
        .volver a{ text-decoration:none; color:#1e3c72; font-size:14px; }
        .volver a:hover{ text-decoration:underline; }
    </style>
</head>
<body>

<%
    int id = Integer.parseInt(request.getParameter("id"));
    TratamientoDAO dao = new TratamientoDAO();
    Tratamiento o = dao.listadoTratamiento_Id(id);
    if (o == null) {
        response.sendRedirect("listaTratamientos.jsp");
        return;
    }
%>

<div class="container">
    <h2>💊 Editar Tratamiento</h2>

    <form method="post" action="CtrolTratamiento">
        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_tratamiento" value="<%=o.getId_tratamiento()%>"/>

        <div class="input-group">
                <label>Diagnóstico</label>
                <select name="cid_diagnostico" required>
<%
    for (String[] op : Opciones.listar("diagnosticos")) {
%>
                    <option value="<%=op[0]%>" <%=String.valueOf(o.getId_diagnostico()).equals(op[0]) ? "selected" : ""%>><%=Util.esc(op[1])%></option>
<%
    }
%>
                </select>
        </div>
        <div class="input-group">
                <label>Medicamento</label>
                <select name="cid_medicamento" required>
<%
    for (String[] op : Opciones.listar("medicamentos")) {
%>
                    <option value="<%=op[0]%>" <%=String.valueOf(o.getId_medicamento()).equals(op[0]) ? "selected" : ""%>><%=Util.esc(op[1])%></option>
<%
    }
%>
                </select>
        </div>
        <div class="input-group">
                <label>Dosis</label>
                <input type="text" name="cdosis" value="<%=Util.esc(o.getDosis())%>" required>
        </div>
        <div class="input-group">
                <label>Duración (días)</label>
                <input type="number" name="cduracion_dias" value="<%=o.getDuracion_dias()%>" min="1" required>
        </div>
        <div class="input-group">
                <label>Estado</label>
                <select name="cestado">
                    <option value="En curso" <%="En curso".equals(o.getEstado()) ? "selected" : ""%>>En curso</option>
                    <option value="Finalizado" <%="Finalizado".equals(o.getEstado()) ? "selected" : ""%>>Finalizado</option>
                </select>
        </div>

        <input type="submit" value="Actualizar" class="btn">
    </form>

    <div class="volver"><a href="javascript:history.back()">← Volver</a></div>
</div>

</body>
</html>
