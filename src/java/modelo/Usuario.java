/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

/**
 *
 * @author sebas
 */
public class Usuario {

    int iddato;
    String identificacion;
    String nombre;
    String apellido;
    String email;
    String telefono;
    String usuario;
    String clave;
    int idperfil;
    String perfil;
    int intentosFallidos;
    java.sql.Timestamp bloqueadoHasta;

    public Usuario() {
    }

    public Usuario(int iddato, String identificacion, String nombre, String apellido, String email, String telefono,
                   String usuario, String clave, int idperfil) {
        this.iddato = iddato;
        this.identificacion = identificacion;
        this.nombre = nombre;
        this.apellido = apellido;
        this.email = email;
        this.telefono = telefono;
        this.usuario = usuario;
        this.clave = clave;
        this.idperfil = idperfil;
    }

    public int getIddato() {
        return iddato;
    }

    public void setIddato(int iddato) {
        this.iddato = iddato;
    }

    public String getIdentificacion() {
        return identificacion;
    }

    public void setIdentificacion(String identificacion) {
        this.identificacion = identificacion;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getClave() {
        return clave;
    }

    public void setClave(String clave) {
        this.clave = clave;
    }

    public int getIdperfil() {
        return idperfil;
    }

    public void setIdperfil(int idperfil) {
        this.idperfil = idperfil;
    }

    /** Nombre del perfil principal (Administrador, Usuario, Medico...). */
    public String getPerfil() {
        return perfil;
    }

    public void setPerfil(String perfil) {
        this.perfil = perfil;
    }

    public int getIntentosFallidos() {
        return intentosFallidos;
    }

    public void setIntentosFallidos(int intentosFallidos) {
        this.intentosFallidos = intentosFallidos;
    }

    public java.sql.Timestamp getBloqueadoHasta() {
        return bloqueadoHasta;
    }

    public void setBloqueadoHasta(java.sql.Timestamp bloqueadoHasta) {
        this.bloqueadoHasta = bloqueadoHasta;
    }

    /** true si la cuenta esta bloqueada en este momento. */
    public boolean isBloqueada() {
        return bloqueadoHasta != null && bloqueadoHasta.getTime() > System.currentTimeMillis();
    }
}
