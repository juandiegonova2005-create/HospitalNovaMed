package Interfaces;

import modelo.Tratamiento;

public interface tratamientoCRUD {
    public int agregarTratamiento(Tratamiento o);
    public int actualizarTratamiento(Tratamiento o);
    public int eliminarTratamiento(int id);
    public Tratamiento listadoTratamiento_Id(int id);
}
