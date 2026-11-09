<%@page import="modelo.*"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Consultas y Reportes</title>
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
    
        .badge-activa{ background:#28a745; } .badge-egresada{ background:#6c757d; }
        .cards{ display:flex; gap:15px; max-width:900px; margin:0 auto 20px; }
        .card{ flex:1; background:white; border-radius:12px; padding:14px; text-align:center; box-shadow:0 5px 15px rgba(0,0,0,0.2); }
        .card b{ display:block; font-size:26px; color:#1e3c72; } .card span{ font-size:12px; color:#556077; }
</style>
</head>

<body>

<h2>📊 Consultas y Reportes</h2>

<%
    String tipo = request.getParameter("tipo") == null ? "ocupacion" : request.getParameter("tipo");
    String desde = request.getParameter("desde");
    String hasta = request.getParameter("hasta");
    if (desde == null || desde.isEmpty()) desde = java.time.LocalDate.now().minusMonths(1).toString();
    if (hasta == null || hasta.isEmpty()) hasta = java.time.LocalDate.now().toString();
    ReporteDAO dao = new ReporteDAO();
    int[] r = dao.resumen();
    String[][] tipos = {{"ocupacion","Ocupación de camas"},{"hospitalizados","Pacientes hospitalizados"},{"tratamientos","Tratamientos activos"},{"inventario","Inventario de medicamentos"}};
%>

<div class="cards">
    <div class="card"><b><%=r[0]%></b><span>Pacientes hospitalizados</span></div>
    <div class="card"><b><%=r[1]%> / <%=r[2]%></b><span>Camas ocupadas</span></div>
    <div class="card"><b><%=r[3]%></b><span>Tratamientos en curso</span></div>
    <div class="card"><b><%=r[4]%></b><span>Medicamentos agotados</span></div>
</div>

<div class="form-container">
    <form method="get" action="reportes.jsp">
        <div class="fila">
            <div class="input-group">
                <label>Tipo de reporte</label>
                <select name="tipo">
<% for (String[] t : tipos) { %>
                    <option value="<%=t[0]%>" <%=t[0].equals(tipo) ? "selected" : ""%>><%=t[1]%></option>
<% } %>
                </select>
            </div>
            <div class="input-group">
                <label>Desde (solo pacientes hospitalizados)</label>
                <input type="date" name="desde" value="<%=Util.esc(desde)%>">
            </div>
            <div class="input-group">
                <label>Hasta</label>
                <input type="date" name="hasta" value="<%=Util.esc(hasta)%>">
            </div>
        </div>
        <input type="submit" value="Generar Reporte" class="btn">
    </form>
</div>

<%
    ReporteDAO.Resultado res = dao.generar(tipo, desde, hasta);
%>
<table>
    <tr>
<% for (String h : res.encabezados) { %>
        <th><%=h%></th>
<% } %>
    </tr>
<% for (String[] fila : res.filas) { %>
    <tr>
<%   for (String v : fila) {
         boolean estado = "Ocupada".equals(v) || "Disponible".equals(v) || "Mantenimiento".equals(v) || "Activa".equals(v)
                 || "Egresada".equals(v) || "En curso".equals(v) || "Agotado".equals(v);
         String clase = "Ocupada".equals(v) ? "badge-ocupada" : "Disponible".equals(v) ? "badge-disponible"
                 : "Mantenimiento".equals(v) ? "badge-mantenimiento" : "Activa".equals(v) || "En curso".equals(v) ? "badge-activa"
                 : "Agotado".equals(v) ? "badge-ocupada" : "badge-egresada";
         if (estado) { %>
        <td><span class="badge <%=clase%>"><%=Util.esc(v)%></span></td>
<%       } else { %>
        <td><%=Util.esc(v)%></td>
<%       }
     } %>
    </tr>
<% } %>
</table>

</body>
</html>
