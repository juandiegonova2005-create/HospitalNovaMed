<%@page import="modelo.Paciente"%>
<%@page import="modelo.PacienteDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Paciente</title>

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

        .dato{
            display:flex;
            justify-content:space-between;
            padding:10px 0;
            border-bottom:1px solid #eee;
            font-size:14px;
        }

        .dato span:first-child{
            color:#777;
        }

        .dato span:last-child{
            color:#222;
            font-weight:bold;
        }

        .badge{
            padding:4px 10px;
            border-radius:12px;
            font-size:12px;
            color:white;
        }

        .badge-activo{
            background:#28a745;
        }

        .badge-inactivo{
            background:#6c757d;
        }

        .volver{
            text-align:center;
            margin-top:20px;
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
    String claseBadge = "Activo".equalsIgnoreCase(p.getEstado()) ? "badge-activo" : "badge-inactivo";
%>

<div class="container">

    <h2>🧑‍⚕️ Detalle del Paciente</h2>

    <div class="dato"><span>ID</span><span><%=p.getId_paciente()%></span></div>
    <div class="dato"><span>Documento</span><span><%=p.getDocumento()%></span></div>
    <div class="dato"><span>Nombre</span><span><%=p.getNombre()%> <%=p.getApellido()%></span></div>
    <div class="dato"><span>Fecha nacimiento</span><span><%=p.getFecha_nacimiento() != null ? p.getFecha_nacimiento() : "-"%></span></div>
    <div class="dato"><span>Teléfono</span><span><%=p.getTelefono() != null ? p.getTelefono() : "-"%></span></div>
    <div class="dato"><span>Correo</span><span><%=p.getCorreo() != null ? p.getCorreo() : "-"%></span></div>
    <div class="dato"><span>Dirección</span><span><%=p.getDireccion() != null ? p.getDireccion() : "-"%></span></div>
    <div class="dato"><span>Cama asignada</span><span><%=p.getId_cama() != null ? p.getId_cama() : "Sin asignar"%></span></div>
    <div class="dato"><span>Estado</span><span class="badge <%=claseBadge%>"><%=p.getEstado()%></span></div>

    <div class="volver">
        <a href="javascript:history.back()">← Volver</a>
    </div>

</div>

</body>
</html>
