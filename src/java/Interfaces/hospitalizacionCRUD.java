package Interfaces;

import modelo.Hospitalizacion;

public interface hospitalizacionCRUD {
    public int agregarHospitalizacion(Hospitalizacion o);
    public int actualizarHospitalizacion(Hospitalizacion o);
    public int eliminarHospitalizacion(int id);
    public Hospitalizacion listadoHospitalizacion_Id(int id);
}
