package modelo;

import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// Entrega listas {id, texto} para llenar los <select> de los formularios
public class Opciones {

    public static List<String[]> listar(String tipo) {
        String sql;
        switch (tipo) {
            case "pacientes":
                sql = "SELECT id_paciente, CONCAT(nombre,' ',apellido) FROM pacientes ORDER BY nombre";
                break;
            case "camas":
                sql = "SELECT id_cama, CONCAT(numero,' - ',tipo) FROM camas ORDER BY numero";
                break;
            case "camas_disp":
                sql = "SELECT id_cama, CONCAT(numero,' - ',tipo) FROM camas WHERE estado='Disponible' ORDER BY numero";
                break;
            case "medicos":
                sql = "SELECT id_medico, CONCAT(nombre,' ',apellido) FROM medicos ORDER BY nombre";
                break;
            case "medicamentos":
                sql = "SELECT id_medicamento, nombre FROM medicamentos ORDER BY nombre";
                break;
            case "historias":
                sql = "SELECT h.id_historia, CONCAT('HC-',LPAD(h.id_historia,4,'0'),' ',p.nombre,' ',p.apellido) "
                    + "FROM historias_clinicas h LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente ORDER BY h.id_historia";
                break;
            case "diagnosticos":
                sql = "SELECT d.id_diagnostico, CONCAT(d.codigo_cie10,' - ',p.nombre,' ',p.apellido) FROM diagnosticos d "
                    + "LEFT JOIN historias_clinicas h ON h.id_historia=d.id_historia "
                    + "LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente ORDER BY d.id_diagnostico";
                break;
            default:
                return new ArrayList<>();
        }
        List<String[]> lista = new ArrayList<>();
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new String[]{rs.getString(1), rs.getString(2)});
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL CARGAR OPCIONES (" + tipo + "): " + ex.getMessage());
        }
        return lista;
    }
}
