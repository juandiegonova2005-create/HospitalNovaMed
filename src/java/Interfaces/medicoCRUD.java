package Interfaces;

import modelo.Medico;

public interface medicoCRUD {
    public int agregarMedico(Medico m);
    public int actualizarMedico(Medico m);
    public int eliminarMedico(int id);
    public Medico listadoMedico_Id(int id);
}
