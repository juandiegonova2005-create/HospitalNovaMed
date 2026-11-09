package modelo;

import Interfaces.especialidadCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EspecialidadDAO implements especialidadCRUD {

    @Override
    public int agregarEspecialidad(Especialidad e) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO especialidades (nombre, descripcion) VALUES (?,?)")) {
            ps.setString(1, e.getNombre());
            ps.setString(2, e.getDescripcion());
            estatus = ps.executeUpdate();
            System.out.println("ESPECIALIDAD GUARDADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR ESPECIALIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarEspecialidad(Especialidad e) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE especialidades SET nombre=?, descripcion=? WHERE id_especialidad=?")) {
            ps.setString(1, e.getNombre());
            ps.setString(2, e.getDescripcion());
            ps.setInt(3, e.getId_especialidad());
            estatus = ps.executeUpdate();
            System.out.println("ESPECIALIDAD ACTUALIZADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR ESPECIALIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarEspecialidad(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM especialidades WHERE id_especialidad=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            System.out.println("ESPECIALIDAD ELIMINADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR ESPECIALIDAD (verifique que no tenga médicos asociados): " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Especialidad listadoEspecialidad_Id(int id) {
        Conexion cn = new Conexion();
        Especialidad e = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM especialidades WHERE id_especialidad=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    e = mapearEspecialidad(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR ESPECIALIDAD: " + ex.getMessage());
        }
        return e;
    }

    public List<Especialidad> listadoEspecialidades() {
        List<Especialidad> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM especialidades ORDER BY id_especialidad");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearEspecialidad(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR ESPECIALIDADES: " + ex.getMessage());
        }
        return lista;
    }

    private Especialidad mapearEspecialidad(ResultSet rs) throws SQLException {
        Especialidad e = new Especialidad();
        e.setId_especialidad(rs.getInt("id_especialidad"));
        e.setNombre(rs.getString("nombre"));
        e.setDescripcion(rs.getString("descripcion"));
        return e;
    }
}
