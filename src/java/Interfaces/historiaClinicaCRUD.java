package Interfaces;

import modelo.HistoriaClinica;

public interface historiaClinicaCRUD {
    public int agregarHistoriaClinica(HistoriaClinica o);
    public int actualizarHistoriaClinica(HistoriaClinica o);
    public int eliminarHistoriaClinica(int id);
    public HistoriaClinica listadoHistoriaClinica_Id(int id);
}
