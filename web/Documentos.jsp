<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, modelo.Documento, modelo.DocumentoDAO, modelo.UsuarioDAO, modelo.Util"%>
<%
    String idSesion = (String) session.getAttribute("idUsuario");
    String actor = String.valueOf(session.getAttribute("nUsuario"));
    boolean admin = new UsuarioDAO().esAdministrador(idSesion);
    List<Documento> lista = new DocumentoDAO().listar(idSesion, admin);
    String msg = request.getParameter("msg");
    String detalle = request.getParameter("detalle");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Documentos - NovaMed</title>
<style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:Arial,Helvetica,sans-serif;background:#f4f6f9;padding:24px;color:#1e293b}
    .wrap{max-width:1000px;margin:0 auto}
    h1{color:#0f4c5c;font-size:1.4rem;margin-bottom:4px}
    p.sub{color:#64748b;font-size:.88rem;margin-bottom:18px}
    .card{background:#fff;border-radius:14px;box-shadow:0 6px 24px rgba(0,0,0,.07);
          padding:24px;margin-bottom:18px}
    h3{color:#0f4c5c;font-size:1rem;margin-bottom:12px}
    label{display:block;font-size:.84rem;font-weight:bold;color:#334155;margin:12px 0 6px}
    input[type=text],input[type=file]{width:100%;padding:10px 12px;border:1px solid #cbd5e1;
         border-radius:8px;font-size:.9rem;background:#fff}
    input:focus{outline:none;border-color:#0f766e}
    .hint{font-size:.78rem;color:#64748b;margin-top:6px}
    .btn{display:inline-block;margin-top:16px;padding:11px 18px;border:0;border-radius:8px;
         background:#0f766e;color:#fff;font-size:.92rem;cursor:pointer;text-decoration:none}
    .btn:hover{background:#115e59}
    .btn-danger{background:#fff;border:1px solid #fca5a5;color:#b91c1c;padding:5px 10px;
         font-size:.76rem;margin:0}
    .btn-danger:hover{background:#fef2f2}
    table{width:100%;border-collapse:collapse;margin-top:6px}
    th{background:#0f4c5c;color:#fff;text-align:left;padding:9px;font-size:.78rem}
    td{padding:9px;border-bottom:1px solid #eef2f7;font-size:.83rem;vertical-align:top}
    .alert-ok{background:#dcfce7;border:1px solid #86efac;color:#166534;border-radius:8px;
              padding:10px 14px;margin-bottom:14px;font-size:.87rem;font-weight:bold}
    .alert-error{background:#fee2e2;border:1px solid #fca5a5;color:#991b1b;border-radius:8px;
                 padding:10px 14px;margin-bottom:14px;font-size:.87rem}
    a.dl{color:#0f766e;font-weight:bold;text-decoration:none}
    a.dl:hover{text-decoration:underline}
    .empty{color:#64748b;font-size:.88rem;padding:14px 0}
    code{background:#f1f5f9;border-radius:5px;padding:2px 6px;font-size:.8rem}
</style>
</head>
<body>
<div class="wrap">
    <h1>📎 Documentos adjuntos</h1>
    <p class="sub">Carga segura de archivos con validación de extensión y de contenido real.</p>

    <% if ("ok".equals(msg)) { %>
        <div class="alert-ok">✓ Archivo cargado correctamente.</div>
    <% } else if ("eliminado".equals(msg)) { %>
        <div class="alert-ok">✓ Archivo eliminado.</div>
    <% } else if ("invalido".equals(msg)) { %>
        <div class="alert-error">✗ <strong>Archivo rechazado:</strong>
            <%=Util.esc(detalle == null ? "El contenido no coincide con la extensión." : detalle)%>
        </div>
    <% } else if ("tamano".equals(msg)) { %>
        <div class="alert-error">✗ El archivo supera el máximo permitido de 5 MB.</div>
    <% } else if ("vacio".equals(msg)) { %>
        <div class="alert-error">✗ Selecciona un archivo antes de enviar.</div>
    <% } else if ("error".equals(msg)) { %>
        <div class="alert-error">✗ No se pudo completar la operación. Revisa el registro de errores.</div>
    <% } %>

    <div class="card">
        <h3>Subir un documento</h3>
        <form method="post" action="SubirDocumento" enctype="multipart/form-data">
            <label for="archivo">Archivo (máximo 5 MB)</label>
            <input type="file" id="archivo" name="archivo" required
                   accept=".pdf,.jpg,.jpeg,.png,.gif,.txt,.doc,.docx,.xls,.xlsx,.rtf">
            <div class="hint">
                Formatos aceptados: PDF, JPG, PNG, GIF, TXT, DOC, DOCX, XLS, XLSX y RTF.
                El servidor verifica la firma del archivo, así que un ejecutable renombrado
                a <code>.pdf</code> será rechazado.
            </div>

            <label for="descripcion">Descripción (opcional)</label>
            <input type="text" id="descripcion" name="descripcion" maxlength="250"
                   placeholder="Ej.: Resultado de laboratorio del paciente">

            <button type="submit" class="btn">Subir documento</button>
        </form>
    </div>

    <div class="card">
        <h3><%= admin ? "Todos los documentos" : "Mis documentos" %> (<%=lista.size()%>)</h3>
        <% if (lista.isEmpty()) { %>
            <div class="empty">Todavía no hay documentos cargados.</div>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Archivo</th>
                    <th>Descripción</th>
                    <% if (admin) { %><th>Usuario</th><% } %>
                    <th>Tamaño</th>
                    <th>Fecha</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <% for (Documento d : lista) { %>
                <tr>
                    <td>
                        <a class="dl" href="DescargarDocumento?id=<%=d.getId()%>">
                            <%=Util.esc(d.getNombreOriginal())%>
                        </a>
                    </td>
                    <td><%=Util.esc(d.getDescripcion())%></td>
                    <% if (admin) { %><td>@<%=Util.esc(d.getUsuario())%></td><% } %>
                    <td><%=d.getTamanoLegible()%></td>
                    <td><%=d.getFecha() == null ? "" : new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(d.getFecha())%></td>
                    <td>
                        <form method="post" action="EliminarDocumento" style="margin:0"
                              onsubmit="return confirm('¿Eliminar este archivo?');">
                            <input type="hidden" name="id" value="<%=d.getId()%>">
                            <button type="submit" class="btn btn-danger">Eliminar</button>
                        </form>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>
</div>
</body>
</html>
