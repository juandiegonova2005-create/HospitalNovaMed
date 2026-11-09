/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import Interfaces.CRUD;
import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt; // ← IMPORT BCRYPT

/**
 *
 * @author sebas
 */
public class UsuarioDAO implements CRUD {

    @Override
    public int agregarUsuario(Usuario u) {

        Conexion cn = new Conexion();
        Connection con;
        PreparedStatement ps;
        int estatus = 0;

        try {
            con = cn.crearConexion();

            // ✅ Encriptar clave antes de guardar en BD
            String claveEncriptada = BCrypt.hashpw(u.getClave(), BCrypt.gensalt(12));

            String q = "INSERT INTO Usuario (identificacion, nombre, apellido, email, telefono, usuario, clave, id_perfil) VALUES (?,?,?,?,?,?,?,?)";

            ps = con.prepareStatement(q);

            ps.setString(1, u.getIdentificacion());
            ps.setString(2, u.getNombre());
            ps.setString(3, u.getApellido());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getTelefono());
            ps.setString(6, u.getUsuario());
            ps.setString(7, claveEncriptada); // ← hash, NO clave plana
            ps.setInt(8, u.getIdperfil());

            estatus = ps.executeUpdate();

            System.out.println("REGISTRO GUARDADO CORRECTAMENTE");

            con.close();

        } catch (SQLException ex) {
            if ("23000".equals(ex.getSQLState())) {
                modelo.Log.error("REGISTRO DUPLICADO: " + ex.getMessage());
                return -2; // correo, usuario o identificacion repetidos
            }
            modelo.Log.error("ERROR AL REGISTRAR: " + ex.getMessage(), ex);
        }

        return estatus;
    }

    @Override
    public int actualizarDatos(Usuario u) {

        Conexion cn = new Conexion();
        Connection con;
        PreparedStatement ps;
        int estatus = 0;

        try {
            con = cn.crearConexion();

            // ✅ Si viene clave nueva la encripta, si no, conserva la actual
            String claveAGuardar;
            boolean cambiaClave = u.getClave() != null && !u.getClave().isEmpty();
            if (cambiaClave) {
                claveAGuardar = BCrypt.hashpw(u.getClave(), BCrypt.gensalt(12));
            } else {
                Usuario uActual = listadoDatos_Id(Integer.parseInt(u.getIdentificacion()));
                if (uActual == null) {
                    return 0;
                }
                claveAGuardar = uActual.getClave(); // conserva el hash existente
            }

            String q = cambiaClave
                    ? "UPDATE Usuario SET nombre=?, apellido=?, email=?, telefono=?, usuario=?, clave=?, "
                    + "id_perfil=?, intentos_fallidos=0, bloqueado_hasta=NULL WHERE identificacion=?"
                    : "UPDATE Usuario SET nombre=?, apellido=?, email=?, telefono=?, usuario=?, clave=?, "
                    + "id_perfil=? WHERE identificacion=?";

            ps = con.prepareStatement(q);

            ps.setString(1, u.getNombre());
            ps.setString(2, u.getApellido());
            ps.setString(3, u.getEmail());
            ps.setString(4, u.getTelefono());
            ps.setString(5, u.getUsuario());
            ps.setString(6, claveAGuardar); // ← hash nuevo o el existente
            ps.setInt(7, u.getIdperfil());
            ps.setString(8, u.getIdentificacion());

            estatus = ps.executeUpdate();

            System.out.println("REGISTRO ACTUALIZADO");

            con.close();

        } catch (SQLException ex) {
            if ("23000".equals(ex.getSQLState())) {
                modelo.Log.error("ACTUALIZACION DUPLICADA: " + ex.getMessage());
                return -2;
            }
            modelo.Log.error("ERROR AL ACTUALIZAR: " + ex.getMessage(), ex);
        }

        return estatus;
    }

    @Override
    public int eliminarDatos(int id) {

        Conexion cn = new Conexion();
        Connection con;
        PreparedStatement ps;
        int estatus = 0;

        try {
            con = cn.crearConexion();

            String q = "DELETE FROM Usuario WHERE identificacion = ?";

            ps = con.prepareStatement(q);
            ps.setInt(1, id);

            estatus = ps.executeUpdate();

            System.out.println("REGISTRO ELIMINADO");

            con.close();

        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR: " + ex.getMessage());
        }

        return estatus;
    }

    @Override
    public Usuario listadoDatos_Id(int id) {

        Conexion cn = new Conexion();
        Usuario u = null;
        Connection con;
        PreparedStatement ps;
        ResultSet rs;

        try {
            con = cn.crearConexion();

            String q = "SELECT * FROM Usuario WHERE identificacion = ?";

            ps = con.prepareStatement(q);
            ps.setInt(1, id);

            rs = ps.executeQuery();

            if (rs.next()) {
                u = new Usuario();
                u.setIdentificacion(rs.getString("identificacion"));
                u.setNombre(rs.getString("nombre"));
                u.setApellido(rs.getString("apellido"));
                u.setEmail(rs.getString("email"));
                u.setTelefono(rs.getString("telefono"));
                u.setUsuario(rs.getString("usuario"));
                u.setClave(rs.getString("clave")); // devuelve el hash
                u.setIdperfil(rs.getInt("id_perfil"));
                u.setIntentosFallidos(rs.getInt("intentos_fallidos"));
                u.setBloqueadoHasta(rs.getTimestamp("bloqueado_hasta"));
            }

            con.close();

        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR: " + ex.getMessage());
        }

        return u;
    }

    public List<Usuario> listadoDatos() {

        List<Usuario> lista = new ArrayList<>();
        Conexion cn = new Conexion();

        Connection con;
        PreparedStatement ps;
        ResultSet rs;

        try {
            con = cn.crearConexion();

            String q = "SELECT * FROM Usuario";

            ps = con.prepareStatement(q);
            rs = ps.executeQuery();

            while (rs.next()) {
                Usuario u = new Usuario();

                u.setIdentificacion(rs.getString("identificacion"));
                u.setNombre(rs.getString("nombre"));
                u.setApellido(rs.getString("apellido"));
                u.setEmail(rs.getString("email"));
                u.setTelefono(rs.getString("telefono"));
                u.setUsuario(rs.getString("usuario"));
                u.setClave(rs.getString("clave")); // muestra el hash (normal)
                u.setIdperfil(rs.getInt("id_perfil"));
                u.setIntentosFallidos(rs.getInt("intentos_fallidos"));
                u.setBloqueadoHasta(rs.getTimestamp("bloqueado_hasta"));

                lista.add(u);
            }

            con.close();

        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR: " + ex.getMessage());
        }

        return lista;
    }
 public int actualizarPerfil(String identificacion, int idPerfil) {

    Conexion cn = new Conexion();
    Connection con;
    PreparedStatement ps;
    int estatus = 0;

    try {
        con = cn.crearConexion();

        // Solo toca id_perfil, la clave nunca se lee ni se reescribe
        String q = "UPDATE Usuario SET id_perfil=? WHERE identificacion=?";

        ps = con.prepareStatement(q);
        ps.setInt(1, idPerfil);
        ps.setString(2, identificacion);

        estatus = ps.executeUpdate();

        System.out.println("PERFIL ACTUALIZADO CORRECTAMENTE");

        con.close();

    } catch (SQLException ex) {
        modelo.Log.error("ERROR AL ACTUALIZAR PERFIL: " + ex.getMessage());
    }

    return estatus;
}

    /** Quita el bloqueo por intentos fallidos sin cambiar la contrasena. */
    public int desbloquear(String identificacion) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE Usuario SET intentos_fallidos = 0, bloqueado_hasta = NULL "
                    + "WHERE identificacion = ?")) {
                ps.setString(1, identificacion);
                return ps.executeUpdate();
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL DESBLOQUEAR USUARIO: " + ex.getMessage(), ex);
            return 0;
        }
    }



    // ------------------------------------------------------------------
    // Validaciones de duplicados (correo y nombre de usuario)
    // ------------------------------------------------------------------
    private boolean existeCampo(String columna, String valor, String excluirId) {
        if (valor == null) {
            return false;
        }
        String sql = "SELECT 1 FROM Usuario WHERE LOWER(" + columna + ") = LOWER(?)"
                + (excluirId != null ? " AND identificacion <> ?" : "") + " LIMIT 1";
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return false;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, valor.trim());
                if (excluirId != null) {
                    ps.setString(2, excluirId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL VERIFICAR DUPLICADO (" + columna + "): " + ex.getMessage(), ex);
            return false;
        }
    }

    /** excluirId = identificacion del propio usuario al editar (null al crear). */
    public boolean existeEmail(String email, String excluirId) {
        return existeCampo("email", email, excluirId);
    }

    public boolean existeUsuario(String usuario, String excluirId) {
        return existeCampo("usuario", usuario, excluirId);
    }

    public boolean existeIdentificacion(String identificacion) {
        try {
            return listadoDatos_Id(Integer.parseInt(identificacion)) != null;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public Usuario buscarPorEmail(String email) {
        if (email == null) {
            return null;
        }
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return null;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT identificacion, nombre, email, usuario FROM Usuario WHERE LOWER(email) = LOWER(?) LIMIT 1")) {
                ps.setString(1, email.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Usuario u = new Usuario();
                        u.setIdentificacion(rs.getString("identificacion"));
                        u.setNombre(rs.getString("nombre"));
                        u.setEmail(rs.getString("email"));
                        u.setUsuario(rs.getString("usuario"));
                        return u;
                    }
                }
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL BUSCAR POR EMAIL: " + ex.getMessage(), ex);
        }
        return null;
    }

    // ------------------------------------------------------------------
    // Roles: un usuario tiene un perfil principal (Usuario.id_perfil) y
    // puede tener perfiles adicionales (tabla usuario_perfil).
    // ------------------------------------------------------------------
    public boolean esAdministrador(String identificacion) {
        if (identificacion == null) {
            return false;
        }
        String sql = "SELECT 1 FROM Usuario u JOIN Perfil p ON p.id_perfil = u.id_perfil "
                + "WHERE u.identificacion = ? AND p.perfil = 'Administrador' "
                + "UNION SELECT 1 FROM usuario_perfil up JOIN Perfil p ON p.id_perfil = up.id_perfil "
                + "WHERE up.identificacion = ? AND p.perfil = 'Administrador'";
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return false;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, identificacion);
                ps.setString(2, identificacion);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL VERIFICAR ADMINISTRADOR: " + ex.getMessage(), ex);
            return false;
        }
    }

    public List<Integer> perfilesAdicionales(String identificacion) {
        List<Integer> lista = new ArrayList<>();
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return lista;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id_perfil FROM usuario_perfil WHERE identificacion = ?")) {
                ps.setString(1, identificacion);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        lista.add(rs.getInt(1));
                    }
                }
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL LISTAR PERFILES ADICIONALES: " + ex.getMessage(), ex);
        }
        return lista;
    }

    /** Reemplaza por completo los perfiles adicionales del usuario. */
    public boolean guardarPerfilesAdicionales(String identificacion, List<Integer> perfiles) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return false;
            }
            con.setAutoCommit(false);
            try {
                try (PreparedStatement del = con.prepareStatement(
                        "DELETE FROM usuario_perfil WHERE identificacion = ?")) {
                    del.setString(1, identificacion);
                    del.executeUpdate();
                }
                try (PreparedStatement ins = con.prepareStatement(
                        "INSERT INTO usuario_perfil (identificacion, id_perfil) VALUES (?, ?)")) {
                    for (Integer idp : perfiles) {
                        ins.setString(1, identificacion);
                        ins.setInt(2, idp);
                        ins.addBatch();
                    }
                    ins.executeBatch();
                }
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL GUARDAR PERFILES ADICIONALES: " + ex.getMessage(), ex);
            return false;
        }
    }

    // ------------------------------------------------------------------
    // Autoservicio y recuperacion de credenciales
    // ------------------------------------------------------------------
    /** Actualiza correo y/o clave del propio usuario. Un parametro null = no cambiarlo. */
    public int actualizarCredenciales(String identificacion, String emailNuevo, String claveNueva) {
        if (emailNuevo == null && claveNueva == null) {
            return 0;
        }
        StringBuilder sql = new StringBuilder("UPDATE Usuario SET ");
        if (emailNuevo != null) {
            sql.append("email = ?");
        }
        if (claveNueva != null) {
            sql.append(emailNuevo != null ? ", " : "").append("clave = ?, intentos_fallidos = 0, bloqueado_hasta = NULL");
        }
        sql.append(" WHERE identificacion = ?");
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                int i = 1;
                if (emailNuevo != null) {
                    ps.setString(i++, emailNuevo.trim());
                }
                if (claveNueva != null) {
                    ps.setString(i++, BCrypt.hashpw(claveNueva, BCrypt.gensalt(12)));
                }
                ps.setString(i, identificacion);
                return ps.executeUpdate();
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL ACTUALIZAR CREDENCIALES: " + ex.getMessage(), ex);
            return 0;
        }
    }

    /** Fija una clave nueva (flujo "olvide mi contraseña") y desbloquea la cuenta. */
    public int restablecerClave(String identificacion, String claveNueva) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE Usuario SET clave = ?, intentos_fallidos = 0, bloqueado_hasta = NULL WHERE identificacion = ?")) {
                ps.setString(1, BCrypt.hashpw(claveNueva, BCrypt.gensalt(12)));
                ps.setString(2, identificacion);
                return ps.executeUpdate();
            }
        } catch (SQLException ex) {
            Log.error("ERROR AL RESTABLECER CLAVE: " + ex.getMessage(), ex);
            return 0;
        }
    }
}
