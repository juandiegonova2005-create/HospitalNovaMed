package modelo;

import Interfaces.hospitalizacionCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HospitalizacionDAO implements hospitalizacionCRUD {

    private static final String SELECT =
        "SELECT t.*, CONCAT(p.nombre,' ',p.apellido) AS paciente, c.numero AS cama_num, CONCAT(m.nombre,' ',m.apellido) AS medico FROM hospitalizaciones t LEFT JOIN pacientes p ON p.id_paciente=t.id_paciente LEFT JOIN camas c ON c.id_cama=t.id_cama LEFT JOIN medicos m ON m.id_medico=t.id_medico ";

    @Override
    public int agregarHospitalizacion(Hospitalizacion o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO hospitalizaciones (id_paciente,id_cama,id_medico,fecha_ingreso,estado,motivo) VALUES (?,?,?,?,?,?)")) {
            ps.setInt(1, o.getId_paciente());
            ps.setInt(2, o.getId_cama());
            ps.setInt(3, o.getId_medico());
            ps.setString(4, o.getFecha_ingreso() == null || o.getFecha_ingreso().isEmpty() ? null : o.getFecha_ingreso());
            ps.setString(5, o.getEstado());
            ps.setString(6, o.getMotivo());
            estatus = ps.executeUpdate();
            if ("Activa".equals(o.getEstado())) {
                cambiarEstadoCama(con, o.getId_cama(), "Ocupada");
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR HOSPITALIZACION: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarHospitalizacion(Hospitalizacion o) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE hospitalizaciones SET id_paciente=?,id_cama=?,id_medico=?,fecha_ingreso=?,estado=?,motivo=? WHERE id_hospitalizacion=?")) {
            ps.setInt(1, o.getId_paciente());
            ps.setInt(2, o.getId_cama());
            ps.setInt(3, o.getId_medico());
            ps.setString(4, o.getFecha_ingreso() == null || o.getFecha_ingreso().isEmpty() ? null : o.getFecha_ingreso());
            ps.setString(5, o.getEstado());
            ps.setString(6, o.getMotivo());
            ps.setInt(7, o.getId_hospitalizacion());
            estatus = ps.executeUpdate();
            cambiarEstadoCama(con, o.getId_cama(), "Activa".equals(o.getEstado()) ? "Ocupada" : "Disponible");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR HOSPITALIZACION: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarHospitalizacion(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        Hospitalizacion h = listadoHospitalizacion_Id(id);
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM hospitalizaciones WHERE id_hospitalizacion=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            if (h != null && "Activa".equals(h.getEstado())) {
                cambiarEstadoCama(con, h.getId_cama(), "Disponible");
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR HOSPITALIZACION (verifique registros relacionados): " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Hospitalizacion listadoHospitalizacion_Id(int id) {
        Conexion cn = new Conexion();
        Hospitalizacion o = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "WHERE t.id_hospitalizacion=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    o = mapear(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR HOSPITALIZACION: " + ex.getMessage());
        }
        return o;
    }

    public List<Hospitalizacion> listado() {
        List<Hospitalizacion> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(SELECT + "ORDER BY t.id_hospitalizacion DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR HOSPITALIZACION: " + ex.getMessage());
        }
        return lista;
    }

    // Marca la cama como Ocupada o Disponible segun el estado de la hospitalizacion
    private void cambiarEstadoCama(Connection con, int idCama, String estado) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("UPDATE camas SET estado=? WHERE id_cama=?")) {
            ps.setString(1, estado);
            ps.setInt(2, idCama);
            ps.executeUpdate();
        }
    }

    // Egreso: cierra la hospitalizacion y libera la cama
    public int egresarHospitalizacion(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion()) {
            Hospitalizacion h = listadoHospitalizacion_Id(id);
            if (h == null) {
                return 0;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE hospitalizaciones SET estado='Egresada', fecha_egreso=CURDATE() WHERE id_hospitalizacion=?")) {
                ps.setInt(1, id);
                estatus = ps.executeUpdate();
            }
            cambiarEstadoCama(con, h.getId_cama(), "Disponible");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL REGISTRAR EGRESO: " + ex.getMessage());
        }
        return estatus;
    }

    private Hospitalizacion mapear(ResultSet rs) throws SQLException {
        Hospitalizacion o = new Hospitalizacion();
        o.setId_hospitalizacion(rs.getInt("id_hospitalizacion"));
        o.setId_paciente(rs.getInt("id_paciente"));
        o.setId_cama(rs.getInt("id_cama"));
        o.setId_medico(rs.getInt("id_medico"));
        o.setFecha_ingreso(rs.getString("fecha_ingreso"));
        o.setEstado(rs.getString("estado"));
        o.setMotivo(rs.getString("motivo"));
        o.setPaciente(rs.getString("paciente"));
        o.setCama_num(rs.getString("cama_num"));
        o.setMedico(rs.getString("medico"));
        return o;
    }
}
