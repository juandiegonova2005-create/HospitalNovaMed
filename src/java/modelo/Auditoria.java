package modelo;

import java.sql.Timestamp;

public class Auditoria {

    private long id;
    private Timestamp fecha;
    private String actor;
    private String accion;
    private String detalle;
    private String ip;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public Timestamp getFecha() { return fecha; }
    public void setFecha(Timestamp fecha) { this.fecha = fecha; }
    public String getActor() { return actor; }
    public void setActor(String actor) { this.actor = actor; }
    public String getAccion() { return accion; }
    public void setAccion(String accion) { this.accion = accion; }
    public String getDetalle() { return detalle; }
    public void setDetalle(String detalle) { this.detalle = detalle; }
    public String getIp() { return ip; }
    public void setIp(String ip) { this.ip = ip; }
}
