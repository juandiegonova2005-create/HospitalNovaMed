<%@page import="modelo.Paciente"%>
<%@page import="modelo.PacienteDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Pacientes</title>

    <style>

        body{
            margin:0;
            font-family: Arial, Helvetica, sans-serif;
            background:#f4f6f9;
            padding:20px;
        }

        h2{
            text-align:center;
            color:#1e3c72;
        }

        /* FORM */
        .form-container{
            background:white;
            padding:20px;
            border-radius:12px;
            box-shadow:0px 5px 15px rgba(0,0,0,0.2);
            max-width:700px;
            margin:auto;
            margin-bottom:20px;
        }

        .fila{
            display:flex;
            flex-wrap:wrap;
            gap:15px;
        }

        .input-group{
            margin-bottom:15px;
            flex:1 1 200px;
        }

        label{
            font-size:14px;
        }

        input, select{
            width:100%;
            padding:10px;
            margin-top:5px;
            border-radius:8px;
            border:1px solid #ccc;
            box-sizing:border-box;
        }

        input:focus, select:focus{
            border-color:#4facfe;
            outline:none;
        }

        .btn{
            width:100%;
            padding:12px;
            border:none;
            border-radius:8px;
            background:#28a745;
            color:white;
            font-size:15px;
            cursor:pointer;
        }

        .btn:hover{
            background:#218838;
        }

        /* BUSCADOR */
        .search-container{
            max-width:700px;
            margin:auto;
            margin-bottom:20px;
            display:flex;
            gap:10px;
        }

        .search-container input{
            flex:1;
            padding:10px;
            border-radius:8px;
            border:1px solid #ccc;
        }

        .btn-buscar{
            padding:10px 20px;
            border:none;
            border-radius:8px;
            background:#1e3c72;
            color:white;
            cursor:pointer;
        }

        .btn-buscar:hover{
            background:#16325c;
        }

        .btn-limpiar{
            padding:10px 15px;
            border:none;
            border-radius:8px;
            background:#6c757d;
            color:white;
            cursor:pointer;
            text-decoration:none;
            display:flex;
            align-items:center;
        }

        .btn-limpiar:hover{
            background:#5a6268;
        }

        /* ALERTA */
        .alerta{
            max-width:700px;
            margin:auto;
            margin-bottom:20px;
            background:#f8d7da;
            color:#721c24;
            padding:12px;
            border-radius:8px;
            text-align:center;
        }

        /* TABLA */
        table{
            width:100%;
            border-collapse:collapse;
            background:white;
            box-shadow:0px 5px 15px rgba(0,0,0,0.2);
        }

        th{
            background:#1e3c72;
            color:white;
            padding:10px;
            font-size:13px;
        }

        td{
            padding:10px;
            text-align:center;
            font-size:13px;
        }

        tr:nth-child(even){
            background:#f2f2f2;
        }

        tr:hover{
            background:#dfe9f3;
        }

        a.accion{
            text-decoration:none;
            padding:6px 10px;
            border-radius:6px;
            color:white;
            font-size:13px;
            display:inline-block;
            margin:2px;
        }

        .editar{
            background:#007bff;
        }

        .eliminar{
            background:#dc3545;
        }

        .editar:hover{
            background:#0069d9;
        }

        .eliminar:hover{
            background:#c82333;
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

    </style>
</head>

<body>

<h2>🧑‍⚕️ Gestión de Pacientes</h2>

<%
    String error = (String) request.getAttribute("error");
    if (error != null) {
%>
    <div class="alerta"><%=error%></div>
<%
    }
%>

<!-- BUSCADOR -->
<div class="search-container">
    <form method="post" action="CtrolPaciente" style="display:flex; flex:1; gap:10px;">
        <input type="hidden" name="accion" value="buscar"/>
        <input type="text" name="texto" placeholder="Buscar por documento, nombre o apellido...">
        <input type="submit" value="🔍 Buscar" class="btn-buscar">
    </form>
    <a href="listaPacientes.jsp" class="btn-limpiar">✖ Limpiar</a>
</div>

<!-- FORMULARIO DE REGISTRO -->
<div class="form-container">
    <form method="post" action="CtrolPaciente"
          onsubmit="return confirm('¿Registrar paciente?');">

        <input type="hidden" name="accion" value="agregar"/>

        <div class="fila">
            <div class="input-group">
                <label>Documento</label>
                <input type="text" name="cdocumento" required>
            </div>
            <div class="input-group">
                <label>Nombre</label>
                <input type="text" name="cnombre" required>
            </div>
            <div class="input-group">
                <label>Apellido</label>
                <input type="text" name="capellido" required>
            </div>
        </div>

        <div class="fila">
            <div class="input-group">
                <label>Fecha de nacimiento</label>
                <input type="date" name="cfecha_nacimiento">
            </div>
            <div class="input-group">
                <label>Teléfono</label>
                <input type="text" name="ctelefono">
            </div>
            <div class="input-group">
                <label>Correo</label>
                <input type="email" name="ccorreo">
            </div>
        </div>

        <div class="fila">
            <div class="input-group">
                <label>Dirección</label>
                <input type="text" name="cdireccion">
            </div>
            <div class="input-group">
                <label>Estado</label>
                <select name="cestado">
                    <option value="Activo">Activo</option>
                    <option value="Inactivo">Inactivo</option>
                </select>
            </div>
            <div class="input-group">
                <label>ID Cama (opcional)</label>
                <input type="number" name="cid_cama" min="1">
            </div>
        </div>

        <input type="submit" value="Registrar Paciente" class="btn">
    </form>
</div>

<!-- TABLA -->
<table>
    <tr>
        <th>ID</th>
        <th>Documento</th>
        <th>Nombre</th>
        <th>Apellido</th>
        <th>Fecha Nac.</th>
        <th>Teléfono</th>
        <th>Correo</th>
        <th>Cama</th>
        <th>Estado</th>
        <th>Acciones</th>
    </tr>

<%
    List<Paciente> lista = (List<Paciente>) request.getAttribute("pacientes");
    if (lista == null) {
        PacienteDAO pdao = new PacienteDAO();
        lista = pdao.listadoPacientes();
    }

    for (Paciente p : lista) {
        String claseBadge = "Activo".equalsIgnoreCase(p.getEstado()) ? "badge-activo" : "badge-inactivo";
%>

    <tr>
        <td><%=p.getId_paciente()%></td>
        <td><%=p.getDocumento()%></td>
        <td><%=p.getNombre()%></td>
        <td><%=p.getApellido()%></td>
        <td><%=p.getFecha_nacimiento() != null ? p.getFecha_nacimiento() : "-"%></td>
        <td><%=p.getTelefono() != null ? p.getTelefono() : "-"%></td>
        <td><%=p.getCorreo() != null ? p.getCorreo() : "-"%></td>
        <td><%=p.getId_cama() != null ? p.getId_cama() : "-"%></td>
        <td><span class="badge <%=claseBadge%>"><%=p.getEstado()%></span></td>
        <td>

            <a class="accion editar"
               href="EditarPaciente.jsp?id=<%=p.getId_paciente()%>" target="marco">
               ✏ Editar
            </a>

            <a class="accion eliminar"
               href="CtrolPaciente?accion=eliminar&id=<%=p.getId_paciente()%>"
               onclick="return confirm('¿Eliminar este paciente?')">
               🗑️ Eliminar
            </a>

        </td>
    </tr>

<%
    }
%>

</table>

</body>
</html>
