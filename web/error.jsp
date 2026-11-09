<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.Util"%>
<%
    String errorId = (String) request.getAttribute("errorId");
    String mensaje = (String) request.getAttribute("errorMensaje");
    if (mensaje == null) {
        Integer codigo = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
        mensaje = (codigo != null && codigo == 404)
                ? "La página que buscas no existe o fue movida."
                : "Ocurrió un error inesperado. Intenta de nuevo en unos segundos.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Error - Hospital NovaMed</title>
<style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;min-height:100vh;
         display:flex;align-items:center;justify-content:center;padding:20px}
    .card{background:#fff;border-radius:14px;box-shadow:0 6px 24px rgba(0,0,0,.08);
          padding:34px;max-width:520px;width:100%;text-align:center}
    .icon{font-size:42px;margin-bottom:12px}
    h2{color:#0f4c5c;margin-bottom:10px}
    p{color:#475569;line-height:1.6;font-size:.95rem}
    .id{margin-top:16px;font-family:monospace;font-size:.8rem;color:#64748b;
        background:#f1f5f9;border-radius:8px;padding:8px 10px}
    a{display:inline-block;margin-top:20px;padding:11px 18px;border-radius:8px;
      background:#0f766e;color:#fff;text-decoration:none;font-size:.9rem}
    a:hover{background:#115e59}
</style>
</head>
<body>
<div class="card">
    <div class="icon">⚠️</div>
    <h2>Algo no salió como esperábamos</h2>
    <p><%=Util.esc(mensaje)%></p>
    <% if (errorId != null) { %>
        <div class="id">Código de referencia: <%=Util.esc(errorId)%></div>
        <p style="margin-top:10px;font-size:.82rem">
            Comparte este código con el administrador para encontrar el evento en el registro de errores.
        </p>
    <% } %>
    <a href="<%=request.getContextPath()%>/index.jsp">Volver al inicio</a>
</div>
</body>
</html>
