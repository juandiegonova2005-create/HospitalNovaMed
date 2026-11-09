<%@page import="modelo.Medico"%>
<%@page import="modelo.MedicoDAO"%>
<%@page import="modelo.Especialidad"%>
<%@page import="modelo.EspecialidadDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Médico</title>
    <style>
        body{ margin:0; font-family: Arial, Helvetica, sans-serif; background:#f4f6f9;
            display:flex; justify-content:center; align-items:center; min-height:100vh; padding:20px; box-sizing:border-box; }
        .container{ background:white; padding:30px; border-radius:15px; box-shadow:0px 10px 25px rgba(0,0,0,0.2); width:420px; }
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
    MedicoDAO mdao = new MedicoDAO();
    Medico m = mdao.listadoMedico_Id(id);

    EspecialidadDAO edao = new EspecialidadDAO();
    List<Especialidad> especialidades = edao.listadoEspecialidades();
%>

<div class="container">
    <h2>👨‍⚕️ Editar Médico</h2>
    <form method="post" action="CtrolMedico">
        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_medico" value="<%=m.getId_medico()%>"/>

        <div class="input-group">
            <label>Documento</label>
            <input type="text" name="cdocumento" value="<%=m.getDocumento()%>" required>
        </div>

        <div class="input-group">
            <label>Nombre</label>
            <input type="text" name="cnombre" value="<%=m.getNombre()%>" required>
        </div>

        <div class="input-group">
            <label>Apellido</label>
            <input type="text" name="capellido" value="<%=m.getApellido()%>" required>
        </div>

        <div class="input-group">
            <label>Teléfono</label>
            <input type="text" name="ctelefono" value="<%=m.getTelefono() != null ? m.getTelefono() : ""%>">
        </div>

        <div class="input-group">
            <label>Correo</label>
            <input type="email" name="ccorreo" value="<%=m.getCorreo() != null ? m.getCorreo() : ""%>">
        </div>

        <div class="input-group">
            <label>Especialidad</label>
            <select name="cid_especialidad">
                <option value="">-- Ninguna --</option>
<%
    for (Especialidad esp : especialidades) {
        boolean sel = m.getId_especialidad() != null && m.getId_especialidad() == esp.getId_especialidad();
%>
                <option value="<%=esp.getId_especialidad()%>" <%=sel ? "selected" : ""%>><%=esp.getNombre()%></option>
<%
    }
%>
            </select>
        </div>

        <div class="input-group">
            <label>Estado</label>
            <select name="cestado">
                <option value="Activo" <%="Activo".equalsIgnoreCase(m.getEstado()) ? "selected" : ""%>>Activo</option>
                <option value="Inactivo" <%="Inactivo".equalsIgnoreCase(m.getEstado()) ? "selected" : ""%>>Inactivo</option>
            </select>
        </div>

        <input type="submit" value="Actualizar" class="btn">
    </form>
    <div class="volver"><a href="javascript:history.back()">← Volver</a></div>
</div>

</body>
</html>
