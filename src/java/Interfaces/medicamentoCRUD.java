package Interfaces;

import modelo.Medicamento;

public interface medicamentoCRUD {
    public int agregarMedicamento(Medicamento m);
    public int actualizarMedicamento(Medicamento m);
    public int eliminarMedicamento(int id);
    public Medicamento listadoMedicamento_Id(int id);
}
