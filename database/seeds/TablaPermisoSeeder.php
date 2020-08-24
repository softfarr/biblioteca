<?php

use App\Models\Permiso;
use Illuminate\Support\Str;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class TablaPermisoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        //DB::table('permiso')->insert([
        //    'nombre' => Str::random(10),
        //    'slug' => Str::random(10),
        //    'created_at' => Carbon::now()->format('Y-m-d h:i:s')
        //]);

        factory(Permiso::class)->times(50)->create();
    }
}
