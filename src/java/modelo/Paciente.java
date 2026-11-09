package modelo;

import java.sql.Date;

/**
 *
 * @author sebas
 */
public class Paciente {

    int id_paciente;
    String documento;
    String nombre;
    String apellido;
    Date fecha_nacimiento;
    String telefono;
    String direccion;
    String correo;
    String estado;
    Integer id_cama; // puede ser null si el paciente no tiene cama asignada

    public Paciente() {
    }

    public Paciente(int id_paciente, String documento, String nombre, String apellido, Date fecha_nacimiento,
                     String telefono, String direccion, String correo, String estado, Integer id_cama) {
        this.id_paciente = id_paciente;
        this.documento = documento;
        this.nombre = nombre;
        this.apellido = apellido;
        this.fecha_nacimiento = fecha_nacimiento;
        this.telefono = telefono;
        this.direccion = direccion;
        this.correo = correo;
        this.estado = estado;
        this.id_cama = id_cama;
    }

    public int getId_paciente() {
        return id_paciente;
    }

    public void setId_paciente(int id_paciente) {
        this.id_paciente = id_paciente;
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

    public Date getFecha_nacimiento() {
        return fecha_nacimiento;
    }

    public void setFecha_nacimiento(Date fecha_nacimiento) {
        this.fecha_nacimiento = fecha_nacimiento;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public Integer getId_cama() {
        return id_cama;
    }

    public void setId_cama(Integer id_cama) {
        this.id_cama = id_cama;
    }
}
