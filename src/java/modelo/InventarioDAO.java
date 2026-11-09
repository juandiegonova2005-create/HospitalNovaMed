package modelo;

import Interfaces.inventarioCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventarioDAO implements inventarioCRUD {

    @Override
    public int agregarItem(ItemInventario i) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO inventario (nombre, categoria, cantidad, ubicacion, estado) VALUES (?,?,?,?,?)")) {
            ps.setString(1, i.getNombre());
            ps.setString(2, i.getCategoria());
            ps.setInt(3, i.getCantidad());
            ps.setString(4, i.getUbicacion());
            ps.setString(5, i.getEstado());
            estatus = ps.executeUpdate();
            System.out.println("ITEM DE INVENTARIO GUARDADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR ITEM: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarItem(ItemInventario i) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE inventario SET nombre=?, categoria=?, cantidad=?, ubicacion=?, estado=? WHERE id_item=?")) {
            ps.setString(1, i.getNombre());
            ps.setString(2, i.getCategoria());
            ps.setInt(3, i.getCantidad());
            ps.setString(4, i.getUbicacion());
            ps.setString(5, i.getEstado());
            ps.setInt(6, i.getId_item());
            estatus = ps.executeUpdate();
            System.out.println("ITEM DE INVENTARIO ACTUALIZADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR ITEM: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarItem(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM inventario WHERE id_item=?")) {
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            System.out.println("ITEM DE INVENTARIO ELIMINADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR ITEM: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public ItemInventario listadoItem_Id(int id) {
        Conexion cn = new Conexion();
        ItemInventario i = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM inventario WHERE id_item=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    i = mapearItem(rs);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR ITEM: " + ex.getMessage());
        }
        return i;
    }

    public List<ItemInventario> listadoInventario() {
        List<ItemInventario> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM inventario ORDER BY id_item");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearItem(rs));
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR INVENTARIO: " + ex.getMessage());
        }
        return lista;
    }

    private ItemInventario mapearItem(ResultSet rs) throws SQLException {
        ItemInventario i = new ItemInventario();
        i.setId_item(rs.getInt("id_item"));
        i.setNombre(rs.getString("nombre"));
        i.setCategoria(rs.getString("categoria"));
        i.setCantidad(rs.getInt("cantidad"));
        i.setUbicacion(rs.getString("ubicacion"));
        i.setEstado(rs.getString("estado"));
        return i;
    }
}
