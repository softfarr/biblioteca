#!/bin/bash

#Este script crea las migraciones modelos, factories y seeds para las
#tablas en TABLAS en el directorio /var/www/html/PROYECTO y los
#acondiciona agregando las lineas de namespace que hagan falta, según
#el tipo de archivo que este creando.
#Solo falta complementar los archivos de migracion con los detalles de las
#columnas, las migraciones y seeders con lo mismo que las migraciones, 
#segun sea el caso.

export WWW=/var/www/html
export TABLAS="permiso rol usuario libro permiso_rol usuario_rol libro_usuario"
export EXCEPCIONES="permiso_rol usuario_rol libro_usuario"
export PROYECTO=
export TABLA_EXCLUIDA=

clear

while [ ! -z "${*}" ]
do
    case ${1} in
        -p) shift
            PROYECTO=${1}
            ;;
        -t) shift
            TABLAS=${1}
            ;;
        -e) shift
            EXCEPCIONES=${1}
            ;;
        *)  echo "${1} Opcion invalida"
            ;;
    esac
    shift
done

if [ -z "${PROYECTO}" -o -z "${TAREAS}" -o -z "${EXCEPCIONES}" ]; then
    echo "SINTAXIS"
    echo "`basename ${0}` <ARGS>"
    echo "ARGS: -p nombreProyecto                        Nombre del proyecto Laravel = Nombre base de datos"
    echo "      -t \"tabla1 tabla2 tabla3 tabla4 ...\"     Tablas de la base de datos que se van a procesar"
    echo "      -e \"tabla2 tabla4 ...\">                  Tablas de la base de datos que solo se procesaran para migraciones"
    exit
fi

cd ${WWW}
git clone git clone https://github.com/softfarr/${PROYECTO}.git

cd ${WWW}/${PROYECTO}
composer install

php artisan migrate:reset

echo "DROP SCHEMA IF EXISTS \`"${PROYECTO}"\` ; CREATE SCHEMA IF NOT EXISTS \`"${PROYECTO}"\` DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci;" | mysql -u root -p

for TABLA in ${TABLAS}
do
    for EXCEPCION in ${EXCEPCIONES}
    do
        if [ ${TABLA} == ${EXCEPCION} ]; then
            TABLA_EXCLUIDA=true
            break
        else
            TABLA_EXCLUIDA=false
        fi
    done
    TABLACAP=`echo ${TABLA} | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2,length($0)-1))}'`

    if [ ! ${TABLA_EXCLUIDA} ]; then
        rm -f database/seeds/*${TABLACAP}*.php
        rm -f database/factories/${TABLACAP}*.php
        rm -f app/Models/${TABLACAP}.php
    fi
    rm -f database/migrations/*${TABLA}.php

    echo "Migración de tabla ${TABLA}."
    echo "Busque la migración en database/migrations/AAAA_MM_DD_hhmmss_"${TABLA}".php"
    echo "No olvide agregar las instrucciones de las columnas. Ejemplo:"
    echo "\$table->string('nombre',50)->unique();"
    echo "Si la tabla tiene llaves foráneas, agregue el siguiente código después de la instrucción:"
    echo "\$table->bigIncrements('id');"
    echo "Reemplace nombreTabla1 y nombreTabla2 por los nombres de las tablas correspondientes:"
    echo "//Inicio llaves foráneas"
    echo "\$tabla1='nombreTabla1';"
    echo "\$tabla2='nombreTabla2';"
    echo "\$campo1=\$tabla1.'_id';"
    echo "\$fk_name1='fk_'.\$tabla1.\$tabla2.'_'.\$tabla1;"
    echo "\$campo2=\$tabla2.'_id';"
    echo "\$fk_name2='fk_'.\$tabla1.\$tabla2.'_'.\$tabla2;"
    echo "\$table->unsignedBigInteger(\$campo1);"
    echo "\$table->foreign(\$campo1,\$fk_name1)->references('id')->on(\$tabla1)->onDelete('restrict')->onUpdate('restrict');"
    echo "\$table->unsignedBigInteger(\$campo2);"
    echo "\$table->foreign(\$campo2,\$fk_name2)->references('id')->on(\$tabla2)->onDelete('restrict')->onUpdate('restrict');"
    echo "//Fin llaves foráneas"
    php artisan make:migration crear_tabla_${TABLA} --create=${TABLA}
    echo
    if ${TABLA_EXCLUIDA} ; then
        continue
    fi
    echo "Modelo de tabla ${TABLA}."
    echo "Busque el modelo en app/Models/"${TABLACAP}".php"
    echo "No olvide agregar la instruccion:"
    echo "protected \$table='"${TABLA}"';"
    php artisan make:model Models/${TABLACAP}
    cat app/Models/${TABLACAP}.php | awk -v tabla=${TABLA} 'index($0,"//")>0{print "\tprotected $table=\"" tabla "\";"};index($0,"//")==0{print $0}' > app/Models/${TABLACAP}.php1
    mv app/Models/${TABLACAP}.php1 app/Models/${TABLACAP}.php
    echo
    echo "Factory de tabla ${TABLA}"
    echo "Busque el factory en app/database/factories/"${TABLACAP}"Factory.php"
    echo "No olvide agregar las instrucciones del factory. Ejemplo:"
    echo "\$factory->define("${TABLACAP}"::class, function (Faker \$faker) {"
    echo "    return ["
    echo "        'name' => \$faker->name,"
    echo "        'email' => \$faker->unique()->safeEmail,"
    echo "        'email_verified_at' => now(),"
    echo "        'password' => '\$2y\$10\$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77UdFm', // secret"
    echo "        'remember_token' => Str::random(10),"
    echo "    ];"
    echo "});"
    php artisan make:factory ${TABLACAP}Factory
    cat database/factories/${TABLACAP}Factory.php | awk -v tabla=${TABLACAP} 'index($0,"use App\\Model;")>0{print $0;print "use App\\Models\\" tabla ";";next};index($0,"Model::class")>0{sub("Model",tabla,$0);print $0;next};index($0,"Model::class")==0{print $0}' > database/factories/${TABLACAP}Factory.php1
    mv database/factories/${TABLACAP}Factory.php1 database/factories/${TABLACAP}Factory.php
    echo
    echo "Seeder de tabla ${TABLA}."
    echo "Busque el seeder en database/seeds/Tabla"${TABLACAP}"Seeder.php"
    echo "No olvide agregar las instrucciones:"
    echo "//DB::table('permiso')->insert(["
    echo "//'nombre' => Str::random(10),"
    echo "//'slug' => Str::random(10),"
    echo "//'created_at' => Carbon::now()->format('Y-m-d h:i:s')"
    echo "//]);"
    echo "factory(Permiso::class)->times(50)->create();"
    echo "Busque el seeder en app/database/seeds/DatabaseSeeder.php"
    echo "No olvide agregar las instrucciones:"
    echo "\$this->call(["
    echo "    Tabla"${TABLACAP}"Seeder::class"
    echo "]);"
    php artisan make:seeder Tabla${TABLACAP}Seeder
    cat database/seeds/Tabla${TABLACAP}Seeder.php | awk -v tabla=${TABLACAP} 'NR==3{print "use App\\Models\\" tabla ";";print $0;next};index($0,"//")>0{print "\t \t" "factory(" tabla "::class)->times(50)->create();"};index($0,"//")==0&&NR!=3{print $0}' > database/seeds/Tabla${TABLACAP}Seeder.php1
    mv database/seeds/Tabla${TABLACAP}Seeder.php1 database/seeds/Tabla${TABLACAP}Seeder.php
    echo
done

php artisan migrate #--seed

exit 
