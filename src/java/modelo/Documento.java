package modelo;

/** Documento adjunto subido por un usuario (tabla documentos). */
public class Documento {

    private int id;
    private String identificacion;
    private String nombreOriginal;
    private String nombreGuardado;
    private String tipo;
    private long tamano;
    private String descripcion;
    private java.sql.Timestamp fecha;
    private String usuario;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getIdentificacion() {
        return identificacion;
    }

    public void setIdentificacion(String identificacion) {
        this.identificacion = identificacion;
    }

    public String getNombreOriginal() {
        return nombreOriginal;
    }

    public void setNombreOriginal(String nombreOriginal) {
        this.nombreOriginal = nombreOriginal;
    }

    public String getNombreGuardado() {
        return nombreGuardado;
    }

    public void setNombreGuardado(String nombreGuardado) {
        this.nombreGuardado = nombreGuardado;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public long getTamano() {
        return tamano;
    }

    public void setTamano(long tamano) {
        this.tamano = tamano;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public java.sql.Timestamp getFecha() {
        return fecha;
    }

    public void setFecha(java.sql.Timestamp fecha) {
        this.fecha = fecha;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    /** Tamano legible para la tabla. */
    public String getTamanoLegible() {
        if (tamano < 1024) {
            return tamano + " B";
        }
        if (tamano < 1024 * 1024) {
            return String.format(java.util.Locale.ROOT, "%.1f KB", tamano / 1024.0);
        }
        return String.format(java.util.Locale.ROOT, "%.1f MB", tamano / (1024.0 * 1024.0));
    }
}
