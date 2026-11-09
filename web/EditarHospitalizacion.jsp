<%@page import="modelo.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Hospitalización</title>
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
    HospitalizacionDAO dao = new HospitalizacionDAO();
    Hospitalizacion o = dao.listadoHospitalizacion_Id(id);
    if (o == null) {
        response.sendRedirect("listaHospitalizaciones.jsp");
        return;
    }
%>

<div class="container">
    <h2>🏥 Editar Hospitalización</h2>

    <form method="post" action="CtrolHospitalizacion">
        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_hospitalizacion" value="<%=o.getId_hospitalizacion()%>"/>

        <div class="input-group">
                <label>Paciente</label>
                <select name="cid_paciente" required>
<%
    for (String[] op : Opciones.listar("pacientes")) {
%>
                    <option value="<%=op[0]%>" <%=String.valueOf(o.getId_paciente()).equals(op[0]) ? "selected" : ""%>><%=Util.esc(op[1])%></option>
<%
    }
%>
                </select>
        </div>
        <div class="input-group">
                <label>Cama</label>
                <select name="cid_cama" required>
<%
    for (String[] op : Opciones.listar("camas")) {
%>
                    <option value="<%=op[0]%>" <%=String.valueOf(o.getId_cama()).equals(op[0]) ? "selected" : ""%>><%=Util.esc(op[1])%></option>
<%
    }
%>
                </select>
        </div>
        <div class="input-group">
                <label>Médico tratante</label>
                <select name="cid_medico" required>
<%
    for (String[] op : Opciones.listar("medicos")) {
%>
                    <option value="<%=op[0]%>" <%=String.valueOf(o.getId_medico()).equals(op[0]) ? "selected" : ""%>><%=Util.esc(op[1])%></option>
<%
    }
%>
                </select>
        </div>
        <div class="input-group">
                <label>Fecha de ingreso</label>
                <input type="date" name="cfecha_ingreso" value="<%=Util.esc(o.getFecha_ingreso())%>" required>
        </div>
        <div class="input-group">
                <label>Estado</label>
                <select name="cestado">
                    <option value="Activa" <%="Activa".equals(o.getEstado()) ? "selected" : ""%>>Activa</option>
                    <option value="Egresada" <%="Egresada".equals(o.getEstado()) ? "selected" : ""%>>Egresada</option>
                </select>
        </div>
        <div class="input-group" style="flex:1 1 100%">
                <label>Motivo de ingreso</label>
                <textarea name="cmotivo" required><%=Util.esc(o.getMotivo())%></textarea>
        </div>

        <input type="submit" value="Actualizar" class="btn">
    </form>

    <div class="volver"><a href="javascript:history.back()">← Volver</a></div>
</div>

</body>
</html>
