<%@page import="modelo.Cama"%>
<%@page import="modelo.CamaDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Cama</title>
    <style>
        body{ margin:0; font-family: Arial, Helvetica, sans-serif; background:#f4f6f9;
            display:flex; justify-content:center; align-items:center; min-height:100vh;
            padding:20px; box-sizing:border-box; }
        .container{ background:white; padding:30px; border-radius:15px;
            box-shadow:0px 10px 25px rgba(0,0,0,0.2); width:380px; }
        h2{ text-align:center; color:#1e3c72; margin-bottom:20px; }
        .input-group{ margin-bottom:15px; }
        label{ font-size:14px; color:#333; }
        input, select{ width:100%; padding:10px; margin-top:5px; border-radius:8px;
            border:1px solid #ccc; outline:none; box-sizing:border-box; }
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
    CamaDAO cdao = new CamaDAO();
    Cama c = cdao.listadoCama_Id(id);
%>

<div class="container">
    <h2>🛏️ Editar Cama</h2>

    <form method="post" action="CtrolCama">
        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_cama" value="<%=c.getId_cama()%>"/>

        <div class="input-group">
            <label>Número</label>
            <input type="text" name="cnumero" value="<%=c.getNumero()%>" required>
        </div>

        <div class="input-group">
            <label>Tipo</label>
            <select name="ctipo">
                <option value="General" <%="General".equalsIgnoreCase(c.getTipo()) ? "selected" : ""%>>General</option>
                <option value="UCI" <%="UCI".equalsIgnoreCase(c.getTipo()) ? "selected" : ""%>>UCI</option>
                <option value="Pediatría" <%="Pediatría".equalsIgnoreCase(c.getTipo()) ? "selected" : ""%>>Pediatría</option>
                <option value="Aislamiento" <%="Aislamiento".equalsIgnoreCase(c.getTipo()) ? "selected" : ""%>>Aislamiento</option>
            </select>
        </div>

        <div class="input-group">
            <label>Estado</label>
            <select name="cestado">
                <option value="Disponible" <%="Disponible".equalsIgnoreCase(c.getEstado()) ? "selected" : ""%>>Disponible</option>
                <option value="Ocupada" <%="Ocupada".equalsIgnoreCase(c.getEstado()) ? "selected" : ""%>>Ocupada</option>
                <option value="Mantenimiento" <%="Mantenimiento".equalsIgnoreCase(c.getEstado()) ? "selected" : ""%>>Mantenimiento</option>
            </select>
        </div>

        <input type="submit" value="Actualizar" class="btn">
    </form>

    <div class="volver"><a href="javascript:history.back()">← Volver</a></div>
</div>

</body>
</html>
