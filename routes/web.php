<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', 'InicioController@index');
Route::group(['prefix'=>'admin', 'namespace'=>'Admin'], function(){
    Route::get('permiso','PermisoController@index')->name('permiso');
    Route::get('permiso/crear','PermisoController@crear')->name('permiso_crear');
    Route::get('permiso/guardar','PermisoController@guardar')->name('permiso_guardar');
    Route::get('permiso/mostrar','PermisoController@mostrar')->name('permiso_mostrar');
    Route::get('permiso/editar','PermisoController@editar')->name('permiso_editar');
    Route::get('permiso/actualizar','PermisoController@actualizar')->name('permiso_actualizar');
    Route::get('permiso/eliminar','PermisoController@eliminar')->name('permiso_eliminar');
});

