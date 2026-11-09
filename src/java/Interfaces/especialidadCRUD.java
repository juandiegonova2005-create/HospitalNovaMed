package Interfaces;

import modelo.Especialidad;

public interface especialidadCRUD {
    public int agregarEspecialidad(Especialidad e);
    public int actualizarEspecialidad(Especialidad e);
    public int eliminarEspecialidad(int id);
    public Especialidad listadoEspecialidad_Id(int id);
}
