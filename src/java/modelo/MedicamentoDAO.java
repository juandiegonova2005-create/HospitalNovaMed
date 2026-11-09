package modelo;

import Interfaces.medicamentoCRUD;
import config.Conexion;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MedicamentoDAO implements medicamentoCRUD {

    @Override
    public int agregarMedicamento(Medicamento m) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO medicamentos (nombre, descripcion, stock, precio, estado) VALUES (?,?,?,?,?)")) {
            ps.setString(1, m.getNombre());
            ps.setString(2, m.getDescripcion());
            ps.setInt(3, m.getStock());
            ps.setBigDecimal(4, m.getPrecio());
            ps.setString(5, m.getEstado());
            estatus = ps.executeUpdate();
            System.out.println("MEDICAMENTO GUARDADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR MEDICAMENTO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarMedicamento(Medicamento m) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE medicamentos SET nombre=?, descripcion=?, stock=?, precio=?, estado=? WHERE id_medicamento=?")) {
            ps.setString(1, m.getNombre());
            ps.setString(2, m.getDescripcion());
            ps.setInt(3, m.getStock());
            ps.setBigDecimal(4, m.getPrecio());
            ps.setString(5, m.getEstado());
            ps.setInt(6, m.getId_medicamento());
            estatus = ps.executeUpdate();
            System.out.println("MEDICAMENTO ACTUALIZADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR MEDICAMENTO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarMedicamento(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM medicamentos WHERE id_medicamento=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            System.out.println("MEDICAMENTO ELIMINADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR MEDICAMENTO: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Medicamento listadoMedicamento_Id(int id) {
        Conexion cn = new Conexion();
        Medicamento m = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM medicamentos WHERE id_medicamento=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m = mapearMedicamento(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR MEDICAMENTO: " + ex.getMessage());
        }
        return m;
    }

    public List<Medicamento> listadoMedicamentos() {
        List<Medicamento> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM medicamentos ORDER BY id_medicamento");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearMedicamento(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR MEDICAMENTOS: " + ex.getMessage());
        }
        return lista;
    }

    private Medicamento mapearMedicamento(ResultSet rs) throws SQLException {
        Medicamento m = new Medicamento();
        m.setId_medicamento(rs.getInt("id_medicamento"));
        m.setNombre(rs.getString("nombre"));
        m.setDescripcion(rs.getString("descripcion"));
        m.setStock(rs.getInt("stock"));
        BigDecimal precio = rs.getBigDecimal("precio");
        m.setPrecio(precio != null ? precio : BigDecimal.ZERO);
        m.setEstado(rs.getString("estado"));
        return m;
    }
}
