package modelo;

import Interfaces.historiaClinicaCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HistoriaClinicaDAO implements historiaClinicaCRUD {

    private static final String SELECT =
        "SELECT t.*, CONCAT(p.nombre,' ',p.apellido) AS paciente, CONCAT(m.nombre,' ',m.apellido) AS medico FROM historias_clinicas t LEFT JOIN pacientes p ON p.id_paciente=t.id_paciente LEFT JOIN medicos m ON m.id_medico=t.id_medico ";

    @Override
    public int agregarHistoriaClinica(HistoriaClinica o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO historias_clinicas (id_paciente,id_medico,fecha,antecedentes,motivo) VALUES (?,?,?,?,?)")) {
            ps.setInt(1, o.getId_paciente());
            ps.setInt(2, o.getId_medico());
            ps.setString(3, o.getFecha() == null || o.getFecha().isEmpty() ? null : o.getFecha());
            ps.setString(4, o.getAntecedentes());
            ps.setString(5, o.getMotivo());
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR HISTORIACLINICA: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarHistoriaClinica(HistoriaClinica o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE historias_clinicas SET id_paciente=?,id_medico=?,fecha=?,antecedentes=?,motivo=? WHERE id_historia=?")) {
            ps.setInt(1, o.getId_paciente());
            ps.setInt(2, o.getId_medico());
            ps.setString(3, o.getFecha() == null || o.getFecha().isEmpty() ? null : o.getFecha());
            ps.setString(4, o.getAntecedentes());
            ps.setString(5, o.getMotivo());
            ps.setInt(6, o.getId_historia());
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR HISTORIACLINICA: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarHistoriaClinica(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM historias_clinicas WHERE id_historia=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR HISTORIACLINICA (verifique registros relacionados): " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public HistoriaClinica listadoHistoriaClinica_Id(int id) {
        Conexion cn = new Conexion();
        HistoriaClinica o = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "WHERE t.id_historia=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    o = mapear(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR HISTORIACLINICA: " + ex.getMessage());
        }
        return o;
    }

    public List<HistoriaClinica> listado() {
        List<HistoriaClinica> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "ORDER BY t.id_historia DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR HISTORIACLINICA: " + ex.getMessage());
        }
        return lista;
    }

    private HistoriaClinica mapear(ResultSet rs) throws SQLException {
        HistoriaClinica o = new HistoriaClinica();
        o.setId_historia(rs.getInt("id_historia"));
        o.setId_paciente(rs.getInt("id_paciente"));
        o.setId_medico(rs.getInt("id_medico"));
        o.setFecha(rs.getString("fecha"));
        o.setAntecedentes(rs.getString("antecedentes"));
        o.setMotivo(rs.getString("motivo"));
        o.setPaciente(rs.getString("paciente"));
        o.setMedico(rs.getString("medico"));
        return o;
    }
}
