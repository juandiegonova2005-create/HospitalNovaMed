package modelo;

import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Datos agregados para el dashboard. Cada consulta es independiente: si una
 * tabla no existe todavia, esa tarjeta muestra "—" y el resto sigue funcionando.
 */
public class DashboardDAO {

    public static class Datos {
        public int pacientes = -1;
        public int pacientesActivos = -1;
        public int medicosTotales = -1;
        public int medicosActivos = -1;
        public int camasTotales = -1;
        public int camasDisponibles = -1;
        public int camasOcupadas = -1;
        public int camasMantenimiento = -1;
        public int hospitalizados = -1;
        public int historias = -1;
        public int diagnosticos = -1;
        public int tratamientosCurso = -1;
        public int tratamientosFinalizados = -1;
        public int medicamentosTotales = -1;
        public int medicamentosDisponibles = -1;
        public int medicamentosAgotados = -1;
        public int stockCritico = -1;
        public int inventario = -1;
        public int usuarios = -1;
        public int eventos = -1;
        public int eventosHoy = -1;
        public String actualizado = "";

        public List<String[]> stock = new ArrayList<>();          // nombre, stock, estado
        public List<String[]> hospitalizaciones = new ArrayList<>(); // paciente, cama, medico, ingreso
        public List<String[]> actividad = new ArrayList<>();      // fecha, actor, accion, detalle
    }

    /** Ejecuta un COUNT. Devuelve -1 si la tabla/consulta no esta disponible. */
    private static int cuenta(Connection con, String sql) {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            Log.error("DASHBOARD (consulta): " + e.getMessage());
            return -1;
        }
    }

    /** Ejecuta una consulta de filas y las devuelve como texto. */
    private static List<String[]> filas(Connection con, String sql) {
        List<String[]> lista = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int n = rs.getMetaData().getColumnCount();
            while (rs.next()) {
                String[] fila = new String[n];
                for (int i = 0; i < n; i++) {
                    String v = rs.getString(i + 1);
                    fila[i] = v == null ? "—" : v;
                }
                lista.add(fila);
            }
        } catch (SQLException e) {
            Log.error("DASHBOARD (listado): " + e.getMessage());
        }
        return lista;
    }

    public Datos cargar() {
        Datos d = new Datos();
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return d;
            }

            d.pacientes = cuenta(con, "SELECT COUNT(*) FROM pacientes");
            d.pacientesActivos = cuenta(con, "SELECT COUNT(*) FROM pacientes WHERE estado='Activo'");
            d.medicosTotales = cuenta(con, "SELECT COUNT(*) FROM medicos");
            d.medicosActivos = cuenta(con, "SELECT COUNT(*) FROM medicos WHERE estado='Activo'");

            d.camasTotales = cuenta(con, "SELECT COUNT(*) FROM camas");
            d.camasDisponibles = cuenta(con, "SELECT COUNT(*) FROM camas WHERE estado='Disponible'");
            d.camasOcupadas = cuenta(con, "SELECT COUNT(*) FROM camas WHERE estado='Ocupada'");
            d.camasMantenimiento = cuenta(con, "SELECT COUNT(*) FROM camas WHERE estado='Mantenimiento'");

            d.hospitalizados = cuenta(con, "SELECT COUNT(*) FROM hospitalizaciones WHERE estado='Activa'");
            d.historias = cuenta(con, "SELECT COUNT(*) FROM historias_clinicas");
            d.diagnosticos = cuenta(con, "SELECT COUNT(*) FROM diagnosticos");
            d.tratamientosCurso = cuenta(con, "SELECT COUNT(*) FROM tratamientos WHERE estado='En curso'");
            d.tratamientosFinalizados = cuenta(con, "SELECT COUNT(*) FROM tratamientos WHERE estado='Finalizado'");

            d.medicamentosTotales = cuenta(con, "SELECT COUNT(*) FROM medicamentos");
            d.medicamentosDisponibles = cuenta(con, "SELECT COUNT(*) FROM medicamentos WHERE estado='Disponible' AND stock > 0");
            d.medicamentosAgotados = cuenta(con, "SELECT COUNT(*) FROM medicamentos WHERE stock <= 0 OR estado='Agotado'");
            d.stockCritico = cuenta(con, "SELECT COUNT(*) FROM medicamentos WHERE stock <= 5 OR estado='Agotado'");

            d.inventario = cuenta(con, "SELECT COUNT(*) FROM inventario");
            d.usuarios = cuenta(con, "SELECT COUNT(*) FROM Usuario");
            d.eventos = cuenta(con, "SELECT COUNT(*) FROM auditoria");
            d.eventosHoy = cuenta(con, "SELECT COUNT(*) FROM auditoria WHERE DATE(fecha)=CURDATE()");

            d.stock = filas(con,
                    "SELECT nombre, stock, estado FROM medicamentos "
                    + "WHERE stock <= 5 OR estado='Agotado' ORDER BY stock ASC, nombre LIMIT 6");

            d.hospitalizaciones = filas(con,
                    "SELECT CONCAT(p.nombre,' ',p.apellido), c.numero, "
                    + "CONCAT(m.nombre,' ',m.apellido), DATE_FORMAT(h.fecha_ingreso,'%d/%m/%Y') "
                    + "FROM hospitalizaciones h "
                    + "LEFT JOIN pacientes p ON p.id_paciente=h.id_paciente "
                    + "LEFT JOIN camas c ON c.id_cama=h.id_cama "
                    + "LEFT JOIN medicos m ON m.id_medico=h.id_medico "
                    + "WHERE h.estado='Activa' ORDER BY h.fecha_ingreso DESC, h.id_hospitalizacion DESC LIMIT 5");

            d.actividad = filas(con,
                    "SELECT DATE_FORMAT(fecha,'%d/%m %H:%i'), actor, accion, detalle "
                    + "FROM auditoria ORDER BY id DESC LIMIT 8");

            d.actualizado = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
        } catch (Exception e) {
            Log.error("DASHBOARD (conexion): " + e.getMessage(), e);
        }
        return d;
    }
}
