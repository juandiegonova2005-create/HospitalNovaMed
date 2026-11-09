package Interfaces;

import modelo.Diagnostico;

public interface diagnosticoCRUD {
    public int agregarDiagnostico(Diagnostico o);
    public int actualizarDiagnostico(Diagnostico o);
    public int eliminarDiagnostico(int id);
    public Diagnostico listadoDiagnostico_Id(int id);
}
