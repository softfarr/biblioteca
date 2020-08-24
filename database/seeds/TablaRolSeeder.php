<?php

use App\Models\Rol;
use Illuminate\Support\Str;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class TablaRolSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        //DB::table('rol')->insert([
        //    'nombre' => Str::random(10),
        //    'created_at' => Carbon::now()->format('Y-m-d h:i:s')
        //]);

        factory(Rol::class)->times(50)->create();
    }
}
