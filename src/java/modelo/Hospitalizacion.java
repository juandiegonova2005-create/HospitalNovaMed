package modelo;

public class Hospitalizacion {

    int id_hospitalizacion;
    int id_paciente;
    int id_cama;
    int id_medico;
    String fecha_ingreso;
    String estado;
    String motivo;
    String paciente;
    String cama_num;
    String medico;

    public Hospitalizacion() {
    }

    public int getId_hospitalizacion() {
        return id_hospitalizacion;
    }

    public void setId_hospitalizacion(int id_hospitalizacion) {
        this.id_hospitalizacion = id_hospitalizacion;
    }

    public int getId_paciente() {
        return id_paciente;
    }

    public void setId_paciente(int id_paciente) {
        this.id_paciente = id_paciente;
    }

    public int getId_cama() {
        return id_cama;
    }

    public void setId_cama(int id_cama) {
        this.id_cama = id_cama;
    }

    public int getId_medico() {
        return id_medico;
    }

    public void setId_medico(int id_medico) {
        this.id_medico = id_medico;
    }

    public String getFecha_ingreso() {
        return fecha_ingreso;
    }

    public void setFecha_ingreso(String fecha_ingreso) {
        this.fecha_ingreso = fecha_ingreso;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    public String getPaciente() {
        return paciente;
    }

    public void setPaciente(String paciente) {
        this.paciente = paciente;
    }

    public String getCama_num() {
        return cama_num;
    }

    public void setCama_num(String cama_num) {
        this.cama_num = cama_num;
    }

    public String getMedico() {
        return medico;
    }

    public void setMedico(String medico) {
        this.medico = medico;
    }
}
