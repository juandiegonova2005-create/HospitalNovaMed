package modelo;

import Interfaces.pacienteCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PacienteDAO implements pacienteCRUD {

    @Override
    public int agregarPaciente(Paciente p) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO pacientes (documento, nombre, apellido, fecha_nacimiento, telefono, direccion, correo, estado, id_cama) "
               + "VALUES (?,?,?,?,?,?,?,?,?)")) {

            ps.setString(1, p.getDocumento());
            ps.setString(2, p.getNombre());
            ps.setString(3, p.getApellido());
            ps.setDate(4, p.getFecha_nacimiento());
            ps.setString(5, p.getTelefono());
            ps.setString(6, p.getDireccion());
            ps.setString(7, p.getCorreo());
            ps.setString(8, p.getEstado());
            if (p.getId_cama() != null) {
                ps.setInt(9, p.getId_cama());
            } else {
                ps.setNull(9, Types.INTEGER);
            }

            estatus = ps.executeUpdate();
            System.out.println("PACIENTE GUARDADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR PACIENTE: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarPaciente(Paciente p) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE pacientes SET documento=?, nombre=?, apellido=?, fecha_nacimiento=?, telefono=?, "
               + "direccion=?, correo=?, estado=?, id_cama=? WHERE id_paciente=?")) {

            ps.setString(1, p.getDocumento());
            ps.setString(2, p.getNombre());
            ps.setString(3, p.getApellido());
            ps.setDate(4, p.getFecha_nacimiento());
            ps.setString(5, p.getTelefono());
            ps.setString(6, p.getDireccion());
            ps.setString(7, p.getCorreo());
            ps.setString(8, p.getEstado());
            if (p.getId_cama() != null) {
                ps.setInt(9, p.getId_cama());
            } else {
                ps.setNull(9, Types.INTEGER);
            }
            ps.setInt(10, p.getId_paciente());

            estatus = ps.executeUpdate();
            System.out.println("PACIENTE ACTUALIZADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR PACIENTE: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarPaciente(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM pacientes WHERE id_paciente=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            System.out.println("PACIENTE ELIMINADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR PACIENTE: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Paciente listadoPaciente_Id(int id) {
        Conexion cn = new Conexion();
        Paciente p = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM pacientes WHERE id_paciente=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = mapearPaciente(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR PACIENTE: " + ex.getMessage());
        }
        return p;
    }

    public List<Paciente> listadoPacientes() {
        List<Paciente> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM pacientes ORDER BY id_paciente DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearPaciente(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR PACIENTES: " + ex.getMessage());
        }
        return lista;
    }

    // Búsqueda por documento, nombre o apellido (función "Buscar paciente" del módulo)
    public List<Paciente> buscarPacientes(String texto) {
        List<Paciente> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM pacientes WHERE documento LIKE ? OR nombre LIKE ? OR apellido LIKE ? "
               + "ORDER BY id_paciente DESC")) {
            String like = "%" + texto + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapearPaciente(rs));
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR PACIENTES: " + ex.getMessage());
        }
        return lista;
    }

    private Paciente mapearPaciente(ResultSet rs) throws SQLException {
        Paciente p = new Paciente();
        p.setId_paciente(rs.getInt("id_paciente"));
        p.setDocumento(rs.getString("documento"));
        p.setNombre(rs.getString("nombre"));
        p.setApellido(rs.getString("apellido"));
        p.setFecha_nacimiento(rs.getDate("fecha_nacimiento"));
        p.setTelefono(rs.getString("telefono"));
        p.setDireccion(rs.getString("direccion"));
        p.setCorreo(rs.getString("correo"));
        p.setEstado(rs.getString("estado"));
        int idCama = rs.getInt("id_cama");
        p.setId_cama(rs.wasNull() ? null : idCama);
        return p;
    }
}
