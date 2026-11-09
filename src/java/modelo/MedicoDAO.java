package modelo;

import Interfaces.medicoCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MedicoDAO implements medicoCRUD {

    @Override
    public int agregarMedico(Medico m) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO medicos (documento, nombre, apellido, telefono, correo, id_especialidad, estado) "
               + "VALUES (?,?,?,?,?,?,?)")) {
            ps.setString(1, m.getDocumento());
            ps.setString(2, m.getNombre());
            ps.setString(3, m.getApellido());
            ps.setString(4, m.getTelefono());
            ps.setString(5, m.getCorreo());
            if (m.getId_especialidad() != null) {
                ps.setInt(6, m.getId_especialidad());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            ps.setString(7, m.getEstado());
            estatus = ps.executeUpdate();
            System.out.println("MEDICO GUARDADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR MEDICO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarMedico(Medico m) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE medicos SET documento=?, nombre=?, apellido=?, telefono=?, correo=?, "
               + "id_especialidad=?, estado=? WHERE id_medico=?")) {
            ps.setString(1, m.getDocumento());
            ps.setString(2, m.getNombre());
            ps.setString(3, m.getApellido());
            ps.setString(4, m.getTelefono());
            ps.setString(5, m.getCorreo());
            if (m.getId_especialidad() != null) {
                ps.setInt(6, m.getId_especialidad());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            ps.setString(7, m.getEstado());
            ps.setInt(8, m.getId_medico());
            estatus = ps.executeUpdate();
            System.out.println("MEDICO ACTUALIZADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR MEDICO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarMedico(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM medicos WHERE id_medico=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            System.out.println("MEDICO ELIMINADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR MEDICO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Medico listadoMedico_Id(int id) {
        Conexion cn = new Conexion();
        Medico m = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM medicos WHERE id_medico=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m = mapearMedico(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR MEDICO: " + ex.getMessage());
        }
        return m;
    }

    /** Listado con el nombre de la especialidad ya resuelto (JOIN), para mostrar en la tabla. */
    public List<Medico> listadoMedicos() {
        List<Medico> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        String sql = "SELECT med.*, esp.nombre AS nombre_especialidad "
                   + "FROM medicos med LEFT JOIN especialidades esp "
                   + "ON med.id_especialidad = esp.id_especialidad "
                   + "ORDER BY med.id_medico";
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Medico m = mapearMedico(rs);
                m.setNombreEspecialidad(rs.getString("nombre_especialidad"));
                lista.add(m);
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR MEDICOS: " + ex.getMessage());
        }
        return lista;
    }

    private Medico mapearMedico(ResultSet rs) throws SQLException {
        Medico m = new Medico();
        m.setId_medico(rs.getInt("id_medico"));
        m.setDocumento(rs.getString("documento"));
        m.setNombre(rs.getString("nombre"));
        m.setApellido(rs.getString("apellido"));
        m.setTelefono(rs.getString("telefono"));
        m.setCorreo(rs.getString("correo"));
        int idEsp = rs.getInt("id_especialidad");
        m.setId_especialidad(rs.wasNull() ? null : idEsp);
        m.setEstado(rs.getString("estado"));
        return m;
    }
}
