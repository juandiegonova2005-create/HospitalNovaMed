package modelo;

public class Medico {

    int id_medico;
    String documento;
    String nombre;
    String apellido;
    String telefono;
    String correo;
    Integer id_especialidad;
    String nombreEspecialidad; // solo lectura, para mostrar en listados (JOIN)
    String estado;

    public Medico() {
    }

    public int getId_medico() {
        return id_medico;
    }

    public void setId_medico(int id_medico) {
        this.id_medico = id_medico;
    }

    public String getDocumento() {
        return documento;
    }

    public void setDocumento(String documento) {
        this.documento = documento;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public Integer getId_especialidad() {
        return id_especialidad;
    }

    public void setId_especialidad(Integer id_especialidad) {
        this.id_especialidad = id_especialidad;
    }

    public String getNombreEspecialidad() {
        return nombreEspecialidad;
    }

    public void setNombreEspecialidad(String nombreEspecialidad) {
        this.nombreEspecialidad = nombreEspecialidad;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}
