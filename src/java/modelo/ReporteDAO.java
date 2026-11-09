package modelo;

import config.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReporteDAO {

    // Resultado de un reporte: encabezados + filas
    public static class Resultado {
        public String[] encabezados = new String[0];
        public List<String[]> filas = new ArrayList<>();
    }

    // Tarjetas del resumen: hospitalizados activos, camas ocupadas, camas totales, tratamientos en curso, medicamentos agotados
    public int[] resumen() {
        String[] sqls = {
            "SELECT COUNT(*) FROM hospitalizaciones WHERE estado='Activa'",
            "SELECT COUNT(*) FROM camas WHERE estado='Ocupada'",
            "SELECT COUNT(*) FROM camas",
            "SELECT COUNT(*) FROM tratamientos WHERE estado='En curso'",
            "SELECT COUNT(*) FROM medicamentos WHERE stock<=0 OR estado='Agotado'"
        };
        int[] r = new int[sqls.length];
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion()) {
            for (int i = 0; i < sqls.length; i++) {
                try (PreparedStatement ps = con.prepareStatement(sqls[i]); ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        r[i] = rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR EN RESUMEN: " + ex.getMessage());
        }
        return r;
    }

    public Resultado generar(String tipo, String desde, String hasta) {
        Resultado res = new Resultado();
        String sql;
        boolean usaFechas = false;
        switch (tipo) {
            case "hospitalizados":
                res.encabezados = new String[]{"ID", "Paciente", "Documento", "Cama", "Médico", "Ingreso", "Estado"};
                sql = "SELECT h.id_hospitalizacion, CONCAT(p.nombre,' ',p.apellido), CONCAT('***',RIGHT(p.documento,4)), c.numero, "
                    + "CONCAT(m.nombre,' ',m.apellido), h.fecha_ingreso, h.estado FROM hospitalizaciones h "
                    + "LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente LEFT JOIN camas c ON c.id_cama=h.id_cama "
                    + "LEFT JOIN medicos m ON m.id_medico=h.id_medico WHERE h.fecha_ingreso BETWEEN ? AND ? ORDER BY h.fecha_ingreso DESC";
                usaFechas = true;
                break;
            case "tratamientos":
                res.encabezados = new String[]{"Paciente", "CIE-10", "Medicamento", "Dosis", "Días", "Estado"};
                sql = "SELECT CONCAT(p.nombre,' ',p.apellido), d.codigo_cie10, md.nombre, t.dosis, t.duracion_dias, t.estado "
                    + "FROM tratamientos t LEFT JOIN diagnosticos d ON d.id_diagnostico=t.id_diagnostico "
                    + "LEFT JOIN historias_clinicas h ON h.id_historia=d.id_historia LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente "
                    + "LEFT JOIN medicamentos md ON md.id_medicamento=t.id_medicamento WHERE t.estado='En curso' ORDER BY t.id_tratamiento";
                break;
            case "inventario":
                res.encabezados = new String[]{"Medicamento", "Stock", "Precio", "Estado"};
                sql = "SELECT nombre, stock, precio, estado FROM medicamentos ORDER BY stock";
                break;
            default: // ocupacion
                res.encabezados = new String[]{"Cama", "Tipo", "Estado", "Paciente", "Médico", "Ingreso"};
                sql = "SELECT c.numero, c.tipo, c.estado, CONCAT(p.nombre,' ',p.apellido), CONCAT(m.nombre,' ',m.apellido), h.fecha_ingreso "
                    + "FROM camas c LEFT JOIN hospitalizaciones h ON h.id_cama=c.id_cama AND h.estado='Activa' "
                    + "LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente LEFT JOIN medicos m ON m.id_medico=h.id_medico ORDER BY c.numero";
        }
        Conexion cn = new Conexion();
        try (Connection con = cn.crearConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            if (usaFechas) {
                ps.setString(1, desde);
                ps.setString(2, hasta);
            }
            try (ResultSet rs = ps.executeQuery()) {
                int n = res.encabezados.length;
                while (rs.next()) {
                    String[] fila = new String[n];
                    for (int i = 0; i < n; i++) {
                        String v = rs.getString(i + 1);
                        fila[i] = v == null ? "—" : v;
                    }
                    res.filas.add(fila);
                }
            }
        } catch (SQLException ex) {
            modelo.Log.error("ERROR AL GENERAR REPORTE: " + ex.getMessage());
        }
        return res;
    }
}
