package modelo;

public class Cama {

    int id_cama;
    String numero;
    String tipo;
    String estado;

    public Cama() {
    }

    public Cama(int id_cama, String numero, String tipo, String estado) {
        this.id_cama = id_cama;
        this.numero = numero;
        this.tipo = tipo;
        this.estado = estado;
    }

    public int getId_cama() {
        return id_cama;
    }

    public void setId_cama(int id_cama) {
        this.id_cama = id_cama;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}
