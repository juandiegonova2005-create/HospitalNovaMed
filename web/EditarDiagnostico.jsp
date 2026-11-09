<%@page import="modelo.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Diagnóstico</title>
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
    DiagnosticoDAO dao = new DiagnosticoDAO();
    Diagnostico o = dao.listadoDiagnostico_Id(id);
    if (o == null) {
        response.sendRedirect("listaDiagnosticos.jsp");
        return;
    }
%>

<div class="container">
    <h2>🩺 Editar Diagnóstico</h2>

    <form method="post" action="CtrolDiagnostico">
        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_diagnostico" value="<%=o.getId_diagnostico()%>"/>

        <div class="input-group">
                <label>Historia clínica</label>
                <select name="cid_historia" required>
<%
    for (String[] op : Opciones.listar("historias")) {
%>
                    <option value="<%=op[0]%>" <%=String.valueOf(o.getId_historia()).equals(op[0]) ? "selected" : ""%>><%=Util.esc(op[1])%></option>
<%
    }
%>
                </select>
        </div>
        <div class="input-group">
                <label>Código CIE-10</label>
                <input type="text" name="ccodigo_cie10" value="<%=Util.esc(o.getCodigo_cie10())%>" required>
        </div>
        <div class="input-group">
                <label>Fecha</label>
                <input type="date" name="cfecha" value="<%=Util.esc(o.getFecha())%>" required>
        </div>
        <div class="input-group" style="flex:1 1 100%">
                <label>Descripción del diagnóstico</label>
                <textarea name="cdescripcion" required><%=Util.esc(o.getDescripcion())%></textarea>
        </div>

        <input type="submit" value="Actualizar" class="btn">
    </form>

    <div class="volver"><a href="javascript:history.back()">← Volver</a></div>
</div>

</body>
</html>
