package Interfaces;

import modelo.ItemInventario;

public interface inventarioCRUD {
    public int agregarItem(ItemInventario i);
    public int actualizarItem(ItemInventario i);
    public int eliminarItem(int id);
    public ItemInventario listadoItem_Id(int id);
}
