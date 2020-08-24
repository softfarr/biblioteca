<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;
use phpDocumentor\Reflection\Types\Boolean;

class CrearTablaUsuarioRol extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('usuario_rol', function (Blueprint $table) {
            $table->bigIncrements('id');
            //inicio Llaves foráneas
            $tabla1='usuario';
            $tabla2='rol';
            $campo1=$tabla1.'_id';
            $fk_name1='fk_'.$tabla1.$tabla2.'_'.$tabla1;
            $campo2=$tabla2.'_id';
            $fk_name2='fk_'.$tabla1.$tabla2.'_'.$tabla2;
            $table->unsignedBigInteger($campo1);
            $table->foreign($campo1,$fk_name1)->references('id')->on($tabla1)->onDelete('restrict')->onUpdate('restrict');
            $table->unsignedBigInteger($campo2);
            $table->foreign($campo2,$fk_name2)->references('id')->on($tabla2)->onDelete('restrict')->onUpdate('restrict');
            //fin Llaves foráneas
            $table->Boolean('estado');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('usuario_rol');
    }
}
