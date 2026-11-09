/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import Interfaces.actividadesCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ActividadesDAO implements actividadesCRUD {

    @Override
    public int agregarActividad(Actividades a) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO actividades (nom_actividad, enlace) VALUES (?,?)")) {
            ps.setString(1, a.getNom_actividad());
            ps.setString(2, a.getEnlace());
            estatus = ps.executeUpdate();
            System.out.println("ACTIVIDAD GUARDADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR ACTIVIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarActividad(Actividades a) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE actividades SET nom_actividad=?, enlace=? WHERE id_actividad=?")) {
            ps.setString(1, a.getNom_actividad());
            ps.setString(2, a.getEnlace());
            ps.setInt(3, a.getId_actividad());
            estatus = ps.executeUpdate();
            System.out.println("ACTIVIDAD ACTUALIZADA");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR ACTIVIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    /**
     * Elimina una actividad. Primero borra sus referencias en gesActividad
     * (tabla que asigna la actividad a los perfiles), porque la FK impide
     * borrar la actividad mientras siga referenciada.
     * Todo en una sola transacción: si algo falla, no queda a medias.
     */
    @Override
    public int eliminarActividad(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps1 = con.prepareStatement(
                        "DELETE FROM gesActividad WHERE id_actividad=?")) {
                    ps1.setInt(1, id);
                    ps1.executeUpdate();
                }

                try (PreparedStatement ps2 = con.prepareStatement(
                        "DELETE FROM actividades WHERE id_actividad=?")) {
                    ps2.setInt(1, id);
                    estatus = ps2.executeUpdate();
                }

                con.commit();
                System.out.println("ACTIVIDAD ELIMINADA");
            } catch (SQLException ex) {
                con.rollback();
                estatus = 0;
                modelo.Log.error("ERROR AL ELIMINAR ACTIVIDAD: " + ex.getMessage());
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR DE CONEXION AL ELIMINAR ACTIVIDAD: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Actividades listadoDatos_Id(int id) {
        Conexion cn = new Conexion();
        Actividades a = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM actividades WHERE id_actividad=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    a = new Actividades();
                    a.setId_actividad(rs.getInt("id_actividad"));
                    a.setNom_actividad(rs.getString("nom_actividad"));
                    a.setEnlace(rs.getString("enlace"));
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR ACTIVIDAD: " + ex.getMessage());
        }
        return a;
    }

    public List<Actividades> listadoActividades() {
        List<Actividades> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM actividades ORDER BY id_actividad");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Actividades a = new Actividades();
                a.setId_actividad(rs.getInt("id_actividad"));
                a.setNom_actividad(rs.getString("nom_actividad"));
                a.setEnlace(rs.getString("enlace"));
                lista.add(a);
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR ACTIVIDADES: " + ex.getMessage());
        }
        return lista;
    }
}
