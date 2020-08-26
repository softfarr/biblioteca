<?php

namespace App\Models\Admin;

use Illuminate\Database\Eloquent\Model;

class Menu_rol extends Model
{
    protected $table='menu_rol'; // Nombre de la tabla de la base de datos
    public $timestamps=false; // Le dice a Laravel si los campos created_at y updated_at se van a usar
}
