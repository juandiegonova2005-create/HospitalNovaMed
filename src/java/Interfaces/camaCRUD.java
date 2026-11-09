package Interfaces;

import modelo.Cama;

public interface camaCRUD {
    public int agregarCama(Cama c);
    public int actualizarCama(Cama c);
    public int eliminarCama(int id);
    public Cama listadoCama_Id(int id);
}
