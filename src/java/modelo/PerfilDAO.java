package modelo;

import Interfaces.perfilCRUD;
import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PerfilDAO implements perfilCRUD {

    @Override
    public int agregarPerfil(Perfil p) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO Perfil (perfil) VALUES (?)")) {
            ps.setString(1, p.getPerfil());
            estatus = ps.executeUpdate();
            System.out.println("PERFIL GUARDADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL AGREGAR PERFIL: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public int actualizarPerfil(Perfil p) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE Perfil SET perfil=? WHERE id_perfil=?")) {
            ps.setString(1, p.getPerfil());
            ps.setInt(2, p.getId_perfil());
            estatus = ps.executeUpdate();
            System.out.println("PERFIL ACTUALIZADO");
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL ACTUALIZAR PERFIL: " + ex.getMessage());
        }
        return estatus;
    }

    /**
     * Elimina un perfil.
     * - Si hay usuarios con ese perfil, NO se borra nada: se devuelve -1
     *   para que el controlador avise que primero hay que reasignar esos usuarios.
     * - Si no hay usuarios, se limpian primero las referencias en gesActividad
     *   (son solo permisos, es seguro borrarlas) y luego se borra el perfil.
     * Todo en una transacción.
     *
     * @return >0 si se eliminó, -1 si hay usuarios asignados (no se puede), 0 si falló por otra razón.
     */
    @Override
    public int eliminarPerfil(int id) {
        Conexion cn = new Conexion();
        int estatus = 0;
        try (Connection con = cn.crearConexion()) {

            // 1. Verificar si hay usuarios con este perfil
            try (PreparedStatement chk = con.prepareStatement(
                    "SELECT COUNT(*) FROM Usuario WHERE id_perfil = ?")) {
                chk.setInt(1, id);
                try (ResultSet rs = chk.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return -1; // hay usuarios asignados, no se puede borrar
                    }
                }
            }

            con.setAutoCommit(false);
            try {
                // 2. Limpiar permisos asociados en gesActividad (seguro)
                try (PreparedStatement ps1 = con.prepareStatement(
                        "DELETE FROM gesActividad WHERE id_perfil=?")) {
                    ps1.setInt(1, id);
                    ps1.executeUpdate();
                }

                // 3. Borrar el perfil
                try (PreparedStatement ps2 = con.prepareStatement(
                        "DELETE FROM Perfil WHERE id_perfil=?")) {
                    ps2.setInt(1, id);
                    estatus = ps2.executeUpdate();
                }

                con.commit();
                System.out.println("PERFIL ELIMINADO");
            } catch (SQLException ex) {
                con.rollback();
                estatus = 0;
                modelo.Log.error("ERROR AL ELIMINAR PERFIL: " + ex.getMessage());
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR DE CONEXION AL ELIMINAR PERFIL: " + ex.getMessage());
        }
        return estatus;
    }

    @Override
    public Perfil listadoPerfil_Id(int id) {
        Conexion cn = new Conexion();
        Perfil p = null;
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM Perfil WHERE id_perfil=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Perfil();
                    p.setId_perfil(rs.getInt("id_perfil"));
                    p.setPerfil(rs.getString("perfil"));
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL BUSCAR PERFIL: " + ex.getMessage());
        }
        return p;
    }

    public List<Perfil> listadoPerfiles() {
        List<Perfil> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT * FROM Perfil ORDER BY id_perfil");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Perfil p = new Perfil();
                p.setId_perfil(rs.getInt("id_perfil"));
                p.setPerfil(rs.getString("perfil"));
                lista.add(p);
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL LISTAR PERFILES: " + ex.getMessage());
        }
        return lista;
    }
}