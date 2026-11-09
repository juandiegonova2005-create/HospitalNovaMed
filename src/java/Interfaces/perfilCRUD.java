/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package Interfaces;

import modelo.Perfil;

public interface perfilCRUD {
    public int agregarPerfil(Perfil p);
    public int actualizarPerfil(Perfil p);
    public int eliminarPerfil(int id);
    public Perfil listadoPerfil_Id(int id);
}
