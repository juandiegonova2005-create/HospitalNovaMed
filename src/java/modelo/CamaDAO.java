package modelo;

import Interfaces.camaCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CamaDAO implements camaCRUD {

    @Override
    public int agregarCama(Cama c) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO camas (numero, tipo, estado) VALUES (?,?,?)")) {
            ps.setString(1, c.getNumero());
            ps.setString(2, c.getTipo());
            ps.setString(3, c.getEstado());
            estatus = ps.executeUpdate();
            System.out.println("CAMA GUARDADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR CAMA: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarCama(Cama c) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE camas SET numero=?, tipo=?, estado=? WHERE id_cama=?")) {
            ps.setString(1, c.getNumero());
            ps.setString(2, c.getTipo());
            ps.setString(3, c.getEstado());
            ps.setInt(4, c.getId_cama());
            estatus = ps.executeUpdate();
            System.out.println("CAMA ACTUALIZADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR CAMA: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarCama(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM camas WHERE id_cama=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            System.out.println("CAMA ELIMINADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR CAMA (verifique que no tenga pacientes asignados): " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Cama listadoCama_Id(int id) {
        Conexion cn = new Conexion();
        Cama c = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM camas WHERE id_cama=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    c = mapearCama(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR CAMA: " + ex.getMessage());
        }
        return c;
    }

    public List<Cama> listadoCamas() {
        List<Cama> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM camas ORDER BY id_cama");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearCama(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR CAMAS: " + ex.getMessage());
        }
        return lista;
    }

    private Cama mapearCama(ResultSet rs) throws SQLException {
        Cama c = new Cama();
        c.setId_cama(rs.getInt("id_cama"));
        c.setNumero(rs.getString("numero"));
        c.setTipo(rs.getString("tipo"));
        c.setEstado(rs.getString("estado"));
        return c;
    }
}
