<?php

namespace App\Models\Admin;

use Illuminate\Database\Eloquent\Model;

class Menu extends Model
{
    protected $table='menu'; // Nombre de la tabla de la base de datos
    protected $fillable=['nombre','url', 'orden', 'icono'];  // Nombre de las columnas de la tabla que van a ser "llenables"
    protected $guarded='id';  // Nombre de las columnas de la tabla que NO van a ser "llenables"
    //public $timestamps=true; // Le dice a Laravel si los campos created_at y updated_at se van a usar
}
