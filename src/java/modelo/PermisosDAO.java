package modelo;

import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Permisos por actividad.
 *
 * Un usuario recibe las actividades de su perfil principal y de sus perfiles
 * adicionales (tabla usuario_perfil). Sobre eso, el administrador puede
 * conceder o denegar actividades puntuales por usuario (tabla usuario_actividad).
 * Una denegacion siempre gana.
 */
public class PermisosDAO {

    /**
     * Traduce la ruta interna (JSP o servlet) a la actividad del menu que la
     * controla. Las rutas que no aparecen aqui solo exigen estar autenticado.
     */
    private static final Map<String, String> RUTAS;
    static {
        Map<String, String> m = new LinkedHashMap<>();
        // Usuarios y seguridad
        for (String r : new String[]{"/listaUsuarios.jsp", "/EditarUsuario.jsp", "/EditarUsuario",
            "/EliminarUsuario", "/PermisosUsuario.jsp", "/PermisosUsuario", "/DesbloquearUsuario"}) {
            m.put(r, "listaUsuarios.jsp");
        }
        // Perfiles
        for (String r : new String[]{"/listaPerfiles.jsp", "/EditarPerfil.jsp", "/CtrolPerfil"}) {
            m.put(r, "listaPerfiles.jsp");
        }
        // Actividades
        for (String r : new String[]{"/listaActividades.jsp", "/EditarActividad.jsp", "/CtrolActividades"}) {
            m.put(r, "listaActividades.jsp");
        }
        // Permisos por perfil
        for (String r : new String[]{"/listaGesActividad.jsp", "/EditarGesActividad.jsp", "/CtrolGesActividad"}) {
            m.put(r, "listaGesActividad.jsp");
        }
        // Pacientes
        for (String r : new String[]{"/listaPacientes.jsp", "/EditarPaciente.jsp", "/VerPaciente.jsp", "/CtrolPaciente"}) {
            m.put(r, "listaPacientes.jsp");
        }
        // Camas
        for (String r : new String[]{"/listaCamas.jsp", "/EditarCamas.jsp", "/CtrolCama"}) {
            m.put(r, "listaCamas.jsp");
        }
        // Medicos
        for (String r : new String[]{"/listaMedicos.jsp", "/EditarMedico.jsp", "/CtrolMedico"}) {
            m.put(r, "listaMedicos.jsp");
        }
        // Especialidades
        for (String r : new String[]{"/listaEspecialidades.jsp", "/EditarEspecialidad.jsp", "/CtrolEspecialidad"}) {
            m.put(r, "listaEspecialidades.jsp");
        }
        // Inventario
        for (String r : new String[]{"/listaInventario.jsp", "/EditarInventario.jsp", "/CtrolInventario"}) {
            m.put(r, "listaInventario.jsp");
        }
        // Medicamentos
        for (String r : new String[]{"/listaMedicamentos.jsp", "/EditarMedicamento.jsp", "/CtrolMedicamento"}) {
            m.put(r, "listaMedicamentos.jsp");
        }
        // Hospitalizaciones
        for (String r : new String[]{"/listaHospitalizaciones.jsp", "/EditarHospitalizacion.jsp", "/CtrolHospitalizacion"}) {
            m.put(r, "listaHospitalizaciones.jsp");
        }
        // Historias clinicas
        for (String r : new String[]{"/listaHistoriasClinicas.jsp", "/EditarHistoriaClinica.jsp", "/CtrolHistoriaClinica"}) {
            m.put(r, "listaHistoriasClinicas.jsp");
        }
        // Diagnosticos
        for (String r : new String[]{"/listaDiagnosticos.jsp", "/EditarDiagnostico.jsp", "/CtrolDiagnostico"}) {
            m.put(r, "listaDiagnosticos.jsp");
        }
        // Tratamientos
        for (String r : new String[]{"/listaTratamientos.jsp", "/EditarTratamiento.jsp", "/CtrolTratamiento"}) {
            m.put(r, "listaTratamientos.jsp");
        }
        m.put("/reportes.jsp", "reportes.jsp");
        m.put("/dashboard.jsp", "dashboard.jsp");
        m.put("/listaAuditoria.jsp", "listaAuditoria.jsp");
        // Documentos adjuntos
        for (String r : new String[]{"/Documentos.jsp", "/SubirDocumento", "/DescargarDocumento"}) {
            m.put(r, "Documentos.jsp");
        }
        RUTAS = m;
    }

    public static String actividadDe(String ruta) {
        return RUTAS.get(ruta);
    }

    /** Actividades efectivas del usuario (perfiles + concesiones - denegaciones). */
    public static List<Actividades> listarActividades(String identificacion) {
        List<Actividades> lista = new ArrayList<>();
        if (identificacion == null) {
            return lista;
        }
        String sql = "SELECT a.id_actividad, a.nom_actividad, a.enlace FROM actividades a "
                + "WHERE a.id_actividad IN ("
                + "  SELECT g.id_actividad FROM gesActividad g WHERE g.id_perfil IN ("
                + "     SELECT id_perfil FROM Usuario WHERE identificacion = ? "
                + "     UNION SELECT id_perfil FROM usuario_perfil WHERE identificacion = ?) "
                + "  UNION SELECT ua.id_actividad FROM usuario_actividad ua "
                + "     WHERE ua.identificacion = ? AND ua.permitido = 1) "
                + "AND NOT EXISTS (SELECT 1 FROM usuario_actividad ua2 "
                + "     WHERE ua2.identificacion = ? AND ua2.id_actividad = a.id_actividad "
                + "       AND ua2.permitido = 0) "
                + "ORDER BY CASE WHEN a.enlace = 'dashboard.jsp' THEN 0 ELSE 1 END, a.id_actividad";
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return lista;
            }
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                for (int i = 1; i <= 4; i++) {
                    ps.setString(i, identificacion);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Actividades a = new Actividades();
                        a.setId_actividad(rs.getInt("id_actividad"));
                        a.setNom_actividad(rs.getString("nom_actividad"));
                        a.setEnlace(rs.getString("enlace"));
                        lista.add(a);
                    }
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL LISTAR PERMISOS DEL USUARIO: " + e.getMessage(), e);
        }
        return lista;
    }

    /** Conjunto de enlaces permitidos; null si hubo un error de base de datos. */
    public static Set<String> enlacesPermitidos(String identificacion) {
        List<Actividades> lista = listarActividades(identificacion);
        Set<String> set = new HashSet<>();
        for (Actividades a : lista) {
            if (a.getEnlace() != null && !a.getEnlace().isEmpty()) {
                set.add(a.getEnlace());
            }
        }
        return set;
    }

    /** true si el usuario puede abrir la ruta indicada. */
    public static boolean puede(String identificacion, String ruta) {
        if (identificacion == null || ruta == null) {
            return false;
        }
        String actividad = RUTAS.get(ruta);
        if (actividad == null) {
            return true; // ruta compartida (Mi perfil, panel, etc.)
        }
        // El administrador siempre puede entrar a los modulos.
        if (new UsuarioDAO().esAdministrador(identificacion)) {
            return true;
        }
        // Si la actividad no esta dada de alta, no se puede exigir permiso.
        if (!existeActividad(actividad)) {
            return true;
        }
        return enlacesPermitidos(identificacion).contains(actividad);
    }

    private static boolean existeActividad(String enlace) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return false;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT 1 FROM actividades WHERE enlace = ? LIMIT 1")) {
                ps.setString(1, enlace);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL VERIFICAR ACTIVIDAD: " + e.getMessage(), e);
            return false;
        }
    }

    /** Todas las actividades, para la pantalla de permisos por usuario. */
    public static List<Actividades> listarTodas() {
        List<Actividades> lista = new ArrayList<>();
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return lista;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id_actividad, nom_actividad, enlace FROM actividades ORDER BY id_actividad");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Actividades a = new Actividades();
                    a.setId_actividad(rs.getInt("id_actividad"));
                    a.setNom_actividad(rs.getString("nom_actividad"));
                    a.setEnlace(rs.getString("enlace"));
                    lista.add(a);
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL LISTAR ACTIVIDADES: " + e.getMessage(), e);
        }
        return lista;
    }

    /** 1 = permitir, 0 = denegar. Las actividades sin fila heredan del rol. */
    public static Map<Integer, Integer> overrides(String identificacion) {
        Map<Integer, Integer> mapa = new HashMap<>();
        if (identificacion == null) {
            return mapa;
        }
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return mapa;
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id_actividad, permitido FROM usuario_actividad WHERE identificacion = ?")) {
                ps.setString(1, identificacion);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        mapa.put(rs.getInt("id_actividad"), rs.getInt("permitido"));
                    }
                }
            }
        } catch (Exception e) {
            Log.error("ERROR AL LEER PERMISOS PUNTUALES: " + e.getMessage(), e);
        }
        return mapa;
    }

    /** Reemplaza los permisos puntuales del usuario. */
    public static boolean guardarOverrides(String identificacion, Map<Integer, Integer> valores) {
        try (Connection con = new Conexion().crearConexion()) {
            if (con == null) {
                return false;
            }
            con.setAutoCommit(false);
            try {
                try (PreparedStatement del = con.prepareStatement(
                        "DELETE FROM usuario_actividad WHERE identificacion = ?")) {
                    del.setString(1, identificacion);
                    del.executeUpdate();
                }
                try (PreparedStatement ins = con.prepareStatement(
                        "INSERT INTO usuario_actividad (identificacion, id_actividad, permitido) VALUES (?,?,?)")) {
                    for (Map.Entry<Integer, Integer> e : valores.entrySet()) {
                        if (e.getValue() == null || (e.getValue() != 0 && e.getValue() != 1)) {
                            continue;
                        }
                        ins.setString(1, identificacion);
                        ins.setInt(2, e.getKey());
                        ins.setInt(3, e.getValue());
                        ins.addBatch();
                    }
                    ins.executeBatch();
                }
                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            }
        } catch (Exception e) {
            Log.error("ERROR AL GUARDAR PERMISOS PUNTUALES: " + e.getMessage(), e);
            return false;
        }
    }
}
