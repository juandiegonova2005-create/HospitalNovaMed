/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import modelo.Actividades;

/**
 *
 * @author sebas
 */
public interface actividadesCRUD {
    public int agregarActividad(Actividades A);
    public int actualizarActividad(Actividades A);
    public int eliminarActividad(int id);
    public Actividades listadoDatos_Id(int id);
}
