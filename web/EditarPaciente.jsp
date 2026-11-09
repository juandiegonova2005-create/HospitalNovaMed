<%@page import="modelo.Paciente"%>
<%@page import="modelo.PacienteDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Paciente</title>

    <style>

        body{
            margin:0;
            font-family: Arial, Helvetica, sans-serif;
            background:#f4f6f9;
            display:flex;
            justify-content:center;
            align-items:center;
            min-height:100vh;
            padding:20px;
            box-sizing:border-box;
        }

        .container{
            background:white;
            padding:30px;
            border-radius:15px;
            box-shadow:0px 10px 25px rgba(0,0,0,0.2);
            width:420px;
        }

        h2{
            text-align:center;
            color:#1e3c72;
            margin-bottom:20px;
        }

        .input-group{
            margin-bottom:15px;
        }

        label{
            font-size:14px;
            color:#333;
        }

        input, select{
            width:100%;
            padding:10px;
            margin-top:5px;
            border-radius:8px;
            border:1px solid #ccc;
            outline:none;
            transition:0.3s;
            box-sizing:border-box;
        }

        input:focus, select:focus{
            border-color:#4facfe;
            box-shadow:0 0 5px rgba(79,172,254,0.5);
        }

        .btn{
            width:100%;
            padding:12px;
            border:none;
            border-radius:8px;
            background:#1e3c72;
            color:white;
            font-size:15px;
            cursor:pointer;
            margin-top:10px;
            transition:0.3s;
        }

        .btn:hover{
            background:#16325c;
        }

        .volver{
            text-align:center;
            margin-top:15px;
        }

        .volver a{
            text-decoration:none;
            color:#1e3c72;
            font-size:14px;
        }

        .volver a:hover{
            text-decoration:underline;
        }

    </style>
</head>

<body>

<%
    int id = Integer.parseInt(request.getParameter("id"));
    PacienteDAO pdao = new PacienteDAO();
    Paciente p = pdao.listadoPaciente_Id(id);
%>

<div class="container">

    <h2>🧑‍⚕️ Editar Paciente</h2>

    <form method="post" action="CtrolPaciente">

        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_paciente" value="<%=p.getId_paciente()%>"/>

        <div class="input-group">
            <label>Documento</label>
            <input type="text" name="cdocumento" value="<%=p.getDocumento()%>" required>
        </div>

        <div class="input-group">
            <label>Nombre</label>
            <input type="text" name="cnombre" value="<%=p.getNombre()%>" required>
        </div>

        <div class="input-group">
            <label>Apellido</label>
            <input type="text" name="capellido" value="<%=p.getApellido()%>" required>
        </div>

        <div class="input-group">
            <label>Fecha de nacimiento</label>
            <input type="date" name="cfecha_nacimiento"
                   value="<%=p.getFecha_nacimiento() != null ? p.getFecha_nacimiento().toString() : ""%>">
        </div>

        <div class="input-group">
            <label>Teléfono</label>
            <input type="text" name="ctelefono" value="<%=p.getTelefono() != null ? p.getTelefono() : ""%>">
        </div>

        <div class="input-group">
            <label>Correo</label>
            <input type="email" name="ccorreo" value="<%=p.getCorreo() != null ? p.getCorreo() : ""%>">
        </div>

        <div class="input-group">
            <label>Dirección</label>
            <input type="text" name="cdireccion" value="<%=p.getDireccion() != null ? p.getDireccion() : ""%>">
        </div>

        <div class="input-group">
            <label>Estado</label>
            <select name="cestado">
                <option value="Activo" <%="Activo".equalsIgnoreCase(p.getEstado()) ? "selected" : ""%>>Activo</option>
                <option value="Inactivo" <%="Inactivo".equalsIgnoreCase(p.getEstado()) ? "selected" : ""%>>Inactivo</option>
            </select>
        </div>

        <div class="input-group">
            <label>ID Cama (opcional)</label>
            <input type="number" name="cid_cama" min="1"
                   value="<%=p.getId_cama() != null ? p.getId_cama() : ""%>">
        </div>

        <input type="submit" value="Actualizar" class="btn">

    </form>

    <div class="volver">
        <a href="javascript:history.back()">← Volver</a>
    </div>

</div>

</body>
</html>
