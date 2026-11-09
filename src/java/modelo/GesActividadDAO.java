package modelo;

import Interfaces.gesActividadCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GesActividadDAO implements gesActividadCRUD {

    @Override
    public int agregarGesActividad(GesActividad g) {
        Conexion cn = new Conexion();
        Connection con;
        PreparedStatement ps;
        int estatus = 0;
        try {
            con = cn.crearConexion();
            String q = "INSERT INTO gesActividad (id_perfil, id_actividad) VALUES (?,?)";
            ps = con.prepareStatement(q);
            ps.setInt(1, g.getId_perfil());
            ps.setInt(2, g.getId_actividad());
            estatus = ps.executeUpdate();
            System.out.println("GESACTIVIDAD GUARDADA");
            con.close();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR GESACTIVIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarGesActividad(GesActividad g) {
        Conexion cn = new Conexion();
        Connection con;
        PreparedStatement ps;
        int estatus = 0;
        try {
            con = cn.crearConexion();
            String q = "UPDATE gesActividad SET id_perfil=?, id_actividad=? WHERE idgesActividad=?";
            ps = con.prepareStatement(q);
            ps.setInt(1, g.getId_perfil());
            ps.setInt(2, g.getId_actividad());
            ps.setInt(3, g.getIdgesActividad());
            estatus = ps.executeUpdate();
            System.out.println("GESACTIVIDAD ACTUALIZADA");
            con.close();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR GESACTIVIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int eliminarGesActividad(int id) {
        Conexion cn = new Conexion();
        Connection con;
        PreparedStatement ps;
        int estatus = 0;
        try {
            con = cn.crearConexion();
            String q = "DELETE FROM gesActividad WHERE idgesActividad=?";
            ps = con.prepareStatement(q);
            ps.setInt(1, id);
            estatus = ps.executeUpdate();
            System.out.println("GESACTIVIDAD ELIMINADA");
            con.close();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ELIMINAR GESACTIVIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public GesActividad listadoGesActividad_Id(int id) {
        Conexion cn = new Conexion();
        GesActividad g = null;
        Connection con;
        PreparedStatement ps;
        ResultSet rs;
        try {
            con = cn.crearConexion();
            String q = "SELECT * FROM gesActividad WHERE idgesActividad=?";
            ps = con.prepareStatement(q);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                g = new GesActividad();
                g.setIdgesActividad(rs.getInt("idgesActividad"));
                g.setId_perfil(rs.getInt("id_perfil"));
                g.setId_actividad(rs.getInt("id_actividad"));
            }
            con.close();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR GESACTIVIDAD: " + ex.getMessage());
        }
        return g;
    }

    public List<GesActividad> listadoGesActividades() {
        List<GesActividad> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        Connection con;
        PreparedStatement ps;
        ResultSet rs;
        try {
            con = cn.crearConexion();
            ps = con.prepareStatement("SELECT * FROM gesActividad ORDER BY idgesActividad");
            rs = ps.executeQuery();
            while (rs.next()) {
                GesActividad g = new GesActividad();
                g.setIdgesActividad(rs.getInt("idgesActividad"));
                g.setId_perfil(rs.getInt("id_perfil"));
                g.setId_actividad(rs.getInt("id_actividad"));
                lista.add(g);
            }
            con.close();
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR GESACTIVIDADES: " + ex.getMessage());
        }
        return lista;
    }
}
