<%@page import="modelo.Actividades"%>
<%@page import="modelo.ActividadesDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Actividad</title>

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
            animation: aparecer 0.5s ease;
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

        input{
            width:100%;
            padding:10px;
            margin-top:5px;
            border-radius:8px;
            border:1px solid #ccc;
            outline:none;
            transition:0.3s;
        }

        input:focus{
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

        @keyframes aparecer{
            from{opacity:0; transform:translateY(20px);}
            to{opacity:1; transform:translateY(0);}
        }

    </style>
</head>

<body>

<%
    int id = Integer.parseInt(request.getParameter("id"));
    ActividadesDAO adao = new ActividadesDAO();
    Actividades a = adao.listadoDatos_Id(id);
%>

<div class="container">

    <h2>✏️ Editar Actividad</h2>

    <form method="post" action="CtrolActividades"
          onsubmit="return confirm('¿Actualizar actividad?');">

        <input type="hidden" name="accion" value="editar"/>
        <input type="hidden" name="cid_actividad" value="<%=a.getId_actividad()%>"/>

        <div class="input-group">
            <label>Nombre de la Actividad</label>
            <input type="text" name="cnom_actividad"
                   value="<%=a.getNom_actividad()%>" required>
        </div>

        <div class="input-group">
            <label>Enlace (URL)</label>
            <input type="url" name="cenlace"
                   value="<%=a.getEnlace()%>" required>
        </div>

        <input type="submit" value="Actualizar" class="btn">

    </form>

    <div class="volver">
        <a href="javascript:history.back()">? Volver</a>
    </div>

</div>

</body>
</html>