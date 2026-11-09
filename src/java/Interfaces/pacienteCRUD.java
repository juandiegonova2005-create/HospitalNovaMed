package Interfaces;

import modelo.Paciente;

public interface pacienteCRUD {
    public int agregarPaciente(Paciente p);
    public int actualizarPaciente(Paciente p);
    public int eliminarPaciente(int id);
    public Paciente listadoPaciente_Id(int id);
}