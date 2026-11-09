<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, modelo.Auditoria, modelo.AuditoriaDAO, modelo.Util"%>
<%
    String q = request.getParameter("q");
    List<Auditoria> filas = new AuditoriaDAO().listar(q, 300);
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Auditoría</title>
<style>
body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;padding:20px}
h2{color:#0f4c5c;margin-bottom:12px}
form{margin-bottom:14px}
input[type=text]{padding:9px 12px;border:1px solid #cbd5e1;border-radius:8px;width:280px}
button,a.lim{padding:9px 14px;border:0;border-radius:8px;background:#0f766e;color:#fff;cursor:pointer;text-decoration:none;font-size:.9rem}
a.lim{background:#64748b}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 2px 10px rgba(0,0,0,.06)}
th{background:#0f4c5c;color:#fff;text-align:left;padding:10px;font-size:.82rem}
td{padding:9px 10px;border-bottom:1px solid #eef2f7;font-size:.82rem;color:#334155;vertical-align:top}
.tag{display:inline-block;padding:2px 8px;border-radius:999px;background:#e0f2f1;color:#0f766e;font-weight:bold;font-size:.75rem}
.mal{background:#fee2e2;color:#b91c1c}
small{color:#64748b}
</style>
</head>
<body>
<h2>🧾 Bitácora de auditoría</h2>
<form method="get" action="listaAuditoria.jsp">
    <input type="text" name="q" placeholder="Filtrar por usuario, acción o detalle" value="<%=Util.esc(q)%>">
    <button type="submit">Buscar</button>
    <a class="lim" href="listaAuditoria.jsp">Limpiar</a>
</form>
<small>Mostrando los últimos <%=filas.size()%> eventos (máx. 300).</small>
<table>
<tr><th>#</th><th>Fecha</th><th>Usuario</th><th>Acción</th><th>Detalle</th><th>IP</th></tr>
<% for (Auditoria a : filas) {
       boolean malo = a.getAccion() != null && (a.getAccion().contains("FALLIDO") || a.getAccion().contains("BLOQUE") || a.getAccion().contains("DENEGADO") || a.getAccion().contains("INCORRECTA")); %>
<tr>
    <td><%=a.getId()%></td>
    <td><%=a.getFecha()%></td>
    <td><%=Util.esc(a.getActor())%></td>
    <td><span class="tag <%= malo ? "mal" : "" %>"><%=Util.esc(a.getAccion())%></span></td>
    <td><%=Util.esc(a.getDetalle())%></td>
    <td><%=Util.esc(a.getIp())%></td>
</tr>
<% } %>
<% if (filas.isEmpty()) { %><tr><td colspan="6" style="text-align:center;color:#64748b">Sin eventos registrados.</td></tr><% } %>
</table>
</body>
</html>
