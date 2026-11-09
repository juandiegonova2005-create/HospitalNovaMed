/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import modelo.GesActividad;

public interface gesActividadCRUD {
    public int agregarGesActividad(GesActividad g);
    public int actualizarGesActividad(GesActividad g);
    public int eliminarGesActividad(int id);
    public GesActividad listadoGesActividad_Id(int id);
}
