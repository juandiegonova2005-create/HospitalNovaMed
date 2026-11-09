package modelo;

import Interfaces.diagnosticoCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DiagnosticoDAO implements diagnosticoCRUD {

    private static final String SELECT =
        "SELECT t.*, CONCAT(p.nombre,' ',p.apellido) AS paciente, CONCAT(m.nombre,' ',m.apellido) AS medico FROM diagnosticos t LEFT JOIN historias_clinicas h ON h.id_historia=t.id_historia LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente LEFT JOIN medicos m ON m.id_medico=h.id_medico ";

    @Override
    public int agregarDiagnostico(Diagnostico o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO diagnosticos (id_historia,codigo_cie10,fecha,descripcion) VALUES (?,?,?,?)")) {
            ps.setInt(1, o.getId_historia());
            ps.setString(2, o.getCodigo_cie10());
            ps.setString(3, o.getFecha() == null || o.getFecha().isEmpty() ? null : o.getFecha());
            ps.setString(4, o.getDescripcion());
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR DIAGNOSTICO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarDiagnostico(Diagnostico o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE diagnosticos SET id_historia=?,codigo_cie10=?,fecha=?,descripcion=? WHERE id_diagnostico=?")) {
            ps.setInt(1, o.getId_historia());
            ps.setString(2, o.getCodigo_cie10());
            ps.setString(3, o.getFecha() == null || o.getFecha().isEmpty() ? null : o.getFecha());
            ps.setString(4, o.getDescripcion());
            ps.setInt(5, o.getId_diagnostico());
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR DIAGNOSTICO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarDiagnostico(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM diagnosticos WHERE id_diagnostico=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR DIAGNOSTICO (verifique registros relacionados): " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Diagnostico listadoDiagnostico_Id(int id) {
        Conexion cn = new Conexion();
        Diagnostico o = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "WHERE t.id_diagnostico=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    o = mapear(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR DIAGNOSTICO: " + ex.getMessage());
        }
        return o;
    }

    public List<Diagnostico> listado() {
        List<Diagnostico> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "ORDER BY t.id_diagnostico DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR DIAGNOSTICO: " + ex.getMessage());
        }
        return lista;
    }

    private Diagnostico mapear(ResultSet rs) throws SQLException {
        Diagnostico o = new Diagnostico();
        o.setId_diagnostico(rs.getInt("id_diagnostico"));
        o.setId_historia(rs.getInt("id_historia"));
        o.setCodigo_cie10(rs.getString("codigo_cie10"));
        o.setFecha(rs.getString("fecha"));
        o.setDescripcion(rs.getString("descripcion"));
        o.setPaciente(rs.getString("paciente"));
        o.setMedico(rs.getString("medico"));
        return o;
    }
}
