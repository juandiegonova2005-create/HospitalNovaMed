<%@page import="modelo.GesActividad"%>
<%@page import="modelo.GesActividadDAO"%>
<%@page import="modelo.Perfil"%>
<%@page import="modelo.PerfilDAO"%>
<%@page import="modelo.Actividades"%>
<%@page import="modelo.ActividadesDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Asignación</title>

    <style>

        body{
            margin:0;
            font-family: Arial, Helvetica, sans-serif;
            background:#f4f6f9;
            display:flex;
            justify-content:center;
            align-items:center;
            height:100vh;
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

        select{
            width:100%;
            padding:10px;
            margin-top:5px;
            border-radius:8px;
            border:1px solid #ccc;
            outline:none;
            transition:0.3s;
        }

        select:focus{
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

    GesActividadDAO gdao = new GesActividadDAO();
    GesActividad g = gdao.listadoGesActividad_Id(id);

    PerfilDAO pdao = new PerfilDAO();
    List<Perfil> listaPerfiles = pdao.listadoPerfiles();

    ActividadesDAO adao = new ActividadesDAO();
    List<Actividades> listaActs = adao.listadoActividades();
%>

<div class="container">

    <h2>🔗 Editar Asignación</h2>

    <form method="post" action="CtrolGesActividad">

        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cidgesActividad" value="<%=g.getIdgesActividad()%>"/>

        <!-- Perfil -->
        <div class="input-group">
            <label>Perfil</label>
            <select name="cid_perfil" required>
                <% for (Perfil p : listaPerfiles) { %>
                <option value="<%=p.getId_perfil()%>"
                    <%=p.getId_perfil() == g.getId_perfil() ? "selected" : ""%>>
                    <%=p.getPerfil()%>
                </option>
                <% } %>
            </select>
        </div>

        <!-- Actividad -->
        <div class="input-group">
            <label>Actividad</label>
            <select name="cid_actividad" required>
                <% for (Actividades a : listaActs) { %>
                <option value="<%=a.getId_actividad()%>"
                    <%=a.getId_actividad() == g.getId_actividad() ? "selected" : ""%>>
                    <%=a.getNom_actividad()%>
                </option>
                <% } %>
            </select>
        </div>

        <input type="submit" value="Actualizar" class="btn">

    </form>

    <div class="volver">
        <a href="javascript:history.back()">? Volver</a>
    </div>

</div>

</body>
</html>