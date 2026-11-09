<%@page import="modelo.*"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    String badge(String e) {
        if (e == null) return "badge-mantenimiento";
        if ("Activa".equals(e) || "En curso".equals(e)) return "badge-activa";
        return "badge-egresada";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Diagnósticos</title>

    <style>
        body{ margin:0; font-family: Arial, Helvetica, sans-serif; background:#f4f6f9; padding:20px; }
        h2{ text-align:center; color:#1e3c72; }

        .form-container{ background:white; padding:20px; border-radius:12px;
            box-shadow:0px 5px 15px rgba(0,0,0,0.2); max-width:700px; margin:auto; margin-bottom:20px; }

        .fila{ display:flex; flex-wrap:wrap; gap:15px; }
        .input-group{ margin-bottom:15px; flex:1 1 150px; }
        label{ font-size:14px; }
        input, select{ width:100%; padding:10px; margin-top:5px; border-radius:8px;
            border:1px solid #ccc; box-sizing:border-box; }
        input:focus, select:focus{ border-color:#4facfe; outline:none; }

        .btn{ width:100%; padding:12px; border:none; border-radius:8px;
            background:#28a745; color:white; font-size:15px; cursor:pointer; }
        .btn:hover{ background:#218838; }

        .alerta{ max-width:700px; margin:auto; margin-bottom:20px; background:#f8d7da;
            color:#721c24; padding:12px; border-radius:8px; text-align:center; }

        table{ width:100%; border-collapse:collapse; background:white; box-shadow:0px 5px 15px rgba(0,0,0,0.2); }
        th{ background:#1e3c72; color:white; padding:10px; font-size:13px; }
        td{ padding:10px; text-align:center; font-size:13px; }
        tr:nth-child(even){ background:#f2f2f2; }
        tr:hover{ background:#dfe9f3; }

        a.accion{ text-decoration:none; padding:6px 10px; border-radius:6px; color:white;
            font-size:13px; display:inline-block; margin:2px; }
        .editar{ background:#007bff; } .eliminar{ background:#dc3545; }
        .editar:hover{ background:#0069d9; } .eliminar:hover{ background:#c82333; }

        .badge{ padding:4px 10px; border-radius:12px; font-size:12px; color:white; }
        .badge-disponible{ background:#28a745; }
        .badge-ocupada{ background:#dc3545; }
        .badge-mantenimiento{ background:#e2a33d; }
    
        textarea{ width:100%; padding:10px; margin-top:5px; border-radius:8px; border:1px solid #ccc; outline:none; box-sizing:border-box; font-family:inherit; min-height:60px; }
        .badge-activa{ background:#28a745; } .badge-egresada{ background:#6c757d; }
        .accion.seg{ background:#6f42c1; } .accion.ver{ background:#2f7566; }
        .cards{ display:flex; gap:15px; max-width:900px; margin:0 auto 20px; }
        .card{ flex:1; background:white; border-radius:12px; padding:14px; text-align:center; box-shadow:0 5px 15px rgba(0,0,0,0.2); }
        .card b{ display:block; font-size:26px; color:#1e3c72; } .card span{ font-size:12px; color:#556077; }
</style>
</head>

<body>

<h2>🩺 Gestión de Diagnósticos</h2>

<%
    String error = (String) request.getAttribute("error");
    if (error != null) {
%>
    <div class="alerta"><%=Util.esc(error)%></div>
<%
    }
%>

<div class="form-container">
    <form method="post" action="CtrolDiagnostico" onsubmit="return confirm('¿Registrar diagnóstico?');">
        <input type="hidden" name="accion" value="agregar"/>
        <div class="fila">
            <div class="input-group">
                <label>Historia clínica</label>
                <select name="cid_historia" required>
<%
    for (String[] op : Opciones.listar("historias")) {
%>
                    <option value="<%=op[0]%>"><%=Util.esc(op[1])%></option>
<%
    }
%>
                </select>
            </div>
            <div class="input-group">
                <label>Código CIE-10</label>
                <input type="text" name="ccodigo_cie10" required>
            </div>
            <div class="input-group">
                <label>Fecha</label>
                <input type="date" name="cfecha" required>
            </div>
            <div class="input-group" style="flex:1 1 100%">
                <label>Descripción del diagnóstico</label>
                <textarea name="cdescripcion" required></textarea>
            </div>
        </div>
        <input type="submit" value="Registrar Diagnóstico" class="btn">
    </form>
</div>

<table>
    <tr>
        <th>ID</th>
        <th>Paciente</th>
        <th>Historia</th>
        <th>CIE-10</th>
        <th>Diagnóstico</th>
        <th>Médico</th>
        <th>Fecha</th>
        <th>Acciones</th>
    </tr>

<%
    DiagnosticoDAO dao = new DiagnosticoDAO();
    List<Diagnostico> lista = dao.listado();
    for (Diagnostico o : lista) {
%>
    <tr>
        <td><%=Util.esc(String.valueOf(o.getId_diagnostico()))%></td>
        <td><%=Util.esc(String.valueOf(o.getPaciente()))%></td>
        <td><%=Util.esc(String.valueOf(o.getId_historia()))%></td>
        <td><%=Util.esc(String.valueOf(o.getCodigo_cie10()))%></td>
        <td><%=Util.esc(String.valueOf(o.getDescripcion()))%></td>
        <td><%=Util.esc(String.valueOf(o.getMedico()))%></td>
        <td><%=Util.esc(String.valueOf(o.getFecha()))%></td>
        <td>
            <a class="accion editar" href="EditarDiagnostico.jsp?id=<%=o.getId_diagnostico()%>" target="marco">✏ Editar</a>
            <a class="accion eliminar" href="CtrolDiagnostico?accion=eliminar&id=<%=o.getId_diagnostico()%>"
               onclick="return confirm('¿Eliminar este registro?')">🗑️ Eliminar</a>
        </td>
    </tr>
<%
    }
%>

</table>

</body>
</html>
