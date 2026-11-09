<%@page import="java.util.List"%>
<%@page import="modelo.Util"%>
<%@page import="modelo.Usuario"%>
<%@page import="modelo.UsuarioDAO"%>
<%@page import="modelo.Perfil"%>
<%@page import="modelo.PerfilDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Usuario</title>

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
        }

        .container{
            background:white;
            padding:30px;
            border-radius:15px;
            box-shadow:0px 10px 25px rgba(0,0,0,0.2);
            width:500px;
            max-width:100%;
        }

        h2{
            text-align:center;
            color:#1e3c72;
            margin-bottom:20px;
        }

        .input-group{ margin-bottom:15px; }

        label{ font-size:14px; color:#333; }

        input, select{
            width:100%;
            padding:10px;
            margin-top:5px;
            border-radius:8px;
            border:1px solid #ccc;
            box-sizing:border-box;
            font-size:14px;
        }

        input[readonly]{ background:#eef1f5; color:#666; }

        .ayuda{ font-size:12px; margin-top:6px; color:#666; }

        .btn{
            width:100%;
            padding:12px;
            border:none;
            border-radius:8px;
            background:#1e3c72;
            color:white;
            font-size:15px;
            cursor:pointer;
        }

        .btn:hover{ background:#16325c; }

        .aviso{
            background:#fef3c7;
            border:1px solid #fcd34d;
            color:#92400e;
            border-radius:8px;
            padding:10px 12px;
            font-size:13px;
            margin-bottom:14px;
        }

        .volver{
            display:block;
            text-align:center;
            margin-top:14px;
            color:#64748b;
            font-size:13px;
            text-decoration:none;
        }
        .volver:hover{ color:#1e3c72; }
    </style>
</head>

<body>

<%
    Usuario a = null;
    try {
        int id = Integer.parseInt(request.getParameter("id"));
        a = new UsuarioDAO().listadoDatos_Id(id);
    } catch (Exception e) {
        a = null;
    }

    List<Perfil> perfiles = new PerfilDAO().listadoPerfiles();
%>

<div class="container">

    <% if (a == null) { %>
        <h2>Usuario no encontrado</h2>
        <a class="volver" href="listaUsuarios.jsp">← Volver al listado</a>
    <% } else { %>

    <h2>✏ Editar Usuario</h2>

    <% if (a.isBloqueada()) { %>
        <div class="aviso">
            Esta cuenta está bloqueada por intentos fallidos. Si defines una nueva
            contraseña, el bloqueo se quita automáticamente.
        </div>
    <% } %>

    <form method="post" action="EditarUsuario" onsubmit="return revisarClave();">

        <input type="hidden" name="cidd" value="<%=Util.esc(a.getIdentificacion())%>"/>

        <div class="input-group">
            <label>Identificación</label>
            <input type="text" value="<%=Util.esc(a.getIdentificacion())%>" readonly>
        </div>

        <div class="input-group">
            <label>Nombres</label>
            <input type="text" name="cnombre" value="<%=Util.esc(a.getNombre())%>"
                   maxlength="30" pattern="[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' \-]{2,30}" required>
        </div>

        <div class="input-group">
            <label>Apellidos</label>
            <input type="text" name="capellido" value="<%=Util.esc(a.getApellido())%>"
                   maxlength="30" pattern="[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' \-]{2,30}" required>
        </div>

        <div class="input-group">
            <label>Email</label>
            <input type="email" name="cmail" value="<%=Util.esc(a.getEmail())%>"
                   maxlength="60" required>
        </div>

        <div class="input-group">
            <label>Usuario</label>
            <input type="text" name="cusuario" value="<%=Util.esc(a.getUsuario())%>"
                   maxlength="20" required pattern="[A-Za-z0-9._\-]{4,20}">
        </div>

        <div class="input-group">
            <label>Nueva clave</label>
            <input type="password" name="cclave" id="cclave"
                   placeholder="Déjala vacía para no cambiarla"
                   autocomplete="new-password" maxlength="72"
                   oninput="revisarClave()">
            <div class="ayuda" id="msgClave">Déjala vacía si no quieres cambiarla.</div>
            <div class="ayuda">
                Mínimo 8 caracteres, con mayúscula, minúscula, número y símbolo.
                No se aceptan secuencias como 123456789012345.
            </div>
        </div>

        <div class="input-group">
            <label>Perfil</label>
            <select name="cperfil" required>
                <% for (Perfil p : perfiles) { %>
                    <option value="<%=p.getId_perfil()%>"
                        <%= p.getId_perfil() == a.getIdperfil() ? "selected" : "" %>>
                        <%=Util.esc(p.getPerfil())%>
                    </option>
                <% } %>
            </select>
            <div class="ayuda">
                Para asignar varios roles y ajustar permisos usa
                <a href="PermisosUsuario.jsp?id=<%=Util.esc(a.getIdentificacion())%>" target="marco">Roles y permisos</a>.
            </div>
        </div>

        <input type="submit" value="Actualizar" class="btn">

    </form>

    <a class="volver" href="listaUsuarios.jsp">← Volver al listado</a>

    <% } %>

</div>

<script>
    function revisarClave() {
        var input = document.getElementById('cclave');
        if (!input) { return true; }
        var v = input.value;
        var msg = document.getElementById('msgClave');

        if (v.length === 0) {
            msg.style.color = '#666';
            msg.textContent = 'Déjala vacía si no quieres cambiarla.';
            return true;
        }

        var errores = [];
        if (v.length < 8) { errores.push('al menos 8 caracteres'); }
        if (!/[A-Z]/.test(v)) { errores.push('una mayúscula'); }
        if (!/[a-z]/.test(v)) { errores.push('una minúscula'); }
        if (!/[0-9]/.test(v)) { errores.push('un número'); }
        if (!/[!@#$%^&*()\-_=+\[\]{};:,.?\/|~]/.test(v)) { errores.push('un símbolo'); }
        if (/012345|123456|234567|345678|456789|567890|abcdef|qwerty|asdfgh|zxcvbn/i.test(v)) {
            errores.push('sin secuencias');
        }
        if (/\s/.test(v)) { errores.push('sin espacios'); }

        if (errores.length === 0) {
            msg.style.color = '#16a34a';
            msg.textContent = '✔ Contraseña válida';
            return true;
        }

        msg.style.color = '#dc2626';
        msg.textContent = 'Falta: ' + errores.join(', ') + '.';
        return false;
    }

    // Bloquea copiar/cortar el contenido de las claves (prueba de enmascarado)
    document.addEventListener('copy', function (e) {
        if (e.target && e.target.type === 'password') {
            e.preventDefault();
        }
    });
</script>

</body>
</html>
