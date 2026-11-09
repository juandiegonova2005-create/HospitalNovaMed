package modelo;

import Interfaces.tratamientoCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TratamientoDAO implements tratamientoCRUD {

    private static final String SELECT =
        "SELECT t.*, CONCAT(p.nombre,' ',p.apellido) AS paciente, d.codigo_cie10 AS codigo, md.nombre AS medicamento FROM tratamientos t LEFT JOIN diagnosticos d ON d.id_diagnostico=t.id_diagnostico LEFT JOIN historias_clinicas h ON h.id_historia=d.id_historia LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente LEFT JOIN medicamentos md ON md.id_medicamento=t.id_medicamento ";

    @Override
    public int agregarTratamiento(Tratamiento o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO tratamientos (id_diagnostico,id_medicamento,dosis,duracion_dias,estado) VALUES (?,?,?,?,?)")) {
            ps.setInt(1, o.getId_diagnostico());
            ps.setInt(2, o.getId_medicamento());
            ps.setString(3, o.getDosis());
            ps.setInt(4, o.getDuracion_dias());
            ps.setString(5, o.getEstado());
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR TRATAMIENTO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarTratamiento(Tratamiento o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE tratamientos SET id_diagnostico=?,id_medicamento=?,dosis=?,duracion_dias=?,estado=? WHERE id_tratamiento=?")) {
            ps.setInt(1, o.getId_diagnostico());
            ps.setInt(2, o.getId_medicamento());
            ps.setString(3, o.getDosis());
            ps.setInt(4, o.getDuracion_dias());
            ps.setString(5, o.getEstado());
            ps.setInt(6, o.getId_tratamiento());
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR TRATAMIENTO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarTratamiento(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM tratamientos WHERE id_tratamiento=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR TRATAMIENTO (verifique registros relacionados): " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Tratamiento listadoTratamiento_Id(int id) {
        Conexion cn = new Conexion();
        Tratamiento o = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "WHERE t.id_tratamiento=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    o = mapear(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR TRATAMIENTO: " + ex.getMessage());
        }
        return o;
    }

    public List<Tratamiento> listado() {
        List<Tratamiento> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "ORDER BY t.id_tratamiento DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR TRATAMIENTO: " + ex.getMessage());
        }
        return lista;
    }

    private Tratamiento mapear(ResultSet rs) throws SQLException {
        Tratamiento o = new Tratamiento();
        o.setId_tratamiento(rs.getInt("id_tratamiento"));
        o.setId_diagnostico(rs.getInt("id_diagnostico"));
        o.setId_medicamento(rs.getInt("id_medicamento"));
        o.setDosis(rs.getString("dosis"));
        o.setDuracion_dias(rs.getInt("duracion_dias"));
        o.setEstado(rs.getString("estado"));
        o.setPaciente(rs.getString("paciente"));
        o.setCodigo(rs.getString("codigo"));
        o.setMedicamento(rs.getString("medicamento"));
        return o;
    }
}
