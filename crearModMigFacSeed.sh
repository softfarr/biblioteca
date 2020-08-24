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
export FORANEAS="permiso_rol:permiso,rol usuario_rol:usuario,rol libro_usuario:libro,usuario"
export PROYECTO=
export ES_TABLA_EXCLUIDA=
export ES_TABLA_CON_FORANEAS=

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
        -f) shift
            FORANEAS=${1}
            ;;
        *)  echo "${1} Opcion invalida"
            ;;
    esac
    shift
done

if [ -z "${PROYECTO}" -o -z "${TABLAS}" -o -z "${EXCEPCIONES}" ]; then
    echo "SINTAXIS"
    echo "`basename ${0}` <ARGS>"
    echo "ARGS: -p nombreProyecto                               Nombre del proyecto Laravel = Nombre base de datos"
    echo "      -t \"tabla1 tabla2 tabla3 tabla4 ...\"          Tablas de la base de datos que se van a procesar"
    echo "      -e \"tabla2 tabla4 ...\">                       Tablas de la base de datos que solo se procesaran para migraciones"
    echo "      -f \"tabla2:tabla1,tabla3 tabla4:tabla1 ...\">  Tablas de la base de datos con llaves foráneas"
    exit
fi

if false;then
    cd ${WWW}
    if [ -d "${PROYECTO}" ]; then
        rm -rf ${WWW}/${PROYECTO}
    fi
    git clone https://github.com/softfarr/${PROYECTO}.git

    cd ${WWW}/${PROYECTO}
    composer install
fi

cd ${WWW}/${PROYECTO}

php artisan migrate:reset

echo "DROP SCHEMA IF EXISTS \`"${PROYECTO}"\` ; CREATE SCHEMA IF NOT EXISTS \`"${PROYECTO}"\` DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci;" | mysql -u root -p

for TABLA in ${TABLAS}
do
    ES_TABLA_EXCLUIDA=false
    for EXCEPCION in ${EXCEPCIONES}
    do
        if [ ${TABLA} == ${EXCEPCION} ]; then
            ES_TABLA_EXCLUIDA=true
            break
        fi
    done
    ES_TABLA_CON_FORANEAS=false
    for FORANEA in ${FORANEAS}
    do
        SOLO_TAB_FORANEAS=`echo ${FORANEA} | awk 'BEGIN{FS=":"}{print $1}'`
        LAS_TAB_FORANEAS=`echo ${FORANEA} | awk 'BEGIN{FS=":"}{print $2}'`
        for TABLA_EVALUADA in ${SOLO_TAB_FORANEAS}
        do
            if [ ${TABLA} == ${TABLA_EVALUADA} ]; then
                ES_TABLA_CON_FORANEAS=true
                TABLA1=`echo ${LAS_TAB_FORANEAS} | awk 'BEGIN{FS=","}{print $1}'`
                TABLA2=`echo ${LAS_TAB_FORANEAS} | awk 'BEGIN{FS=","}{print $2}'`
                break
            fi
        done
    done
    TABLACAP=`echo ${TABLA} | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2,length($0)-1))}'`

    if ! ${ES_TABLA_EXCLUIDA} ; then
        rm -f database/seeds/Tabla${TABLACAP}Seeder.php
        rm -f database/factories/${TABLACAP}Factory.php
        rm -f app/Models/${TABLACAP}.php
    fi
    rm -f database/migrations/*${TABLA}.php

    echo "Migración de tabla ${TABLA}."
    echo "Busque la migración en database/migrations/AAAA_MM_DD_hhmmss_"${TABLA}".php"
    php artisan make:migration crear_tabla_${TABLA} --create=${TABLA}
    if ${ES_TABLA_CON_FORANEAS} ; then
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
        MIGRACION_CON_FORANEAS=`ls database/migrations/*_${TABLA}.php`
        cat ${MIGRACION_CON_FORANEAS} | awk -v p="'" -v tabla1=${TABLA1} -v tabla2=${TABLA2} '
        index($0,"$table->bigIncrements(" p "id" p ");")>0{
            print $0
            print "\t\t\t" "//Inicio llaves foráneas"
            print "\t\t\t" "$tabla1=" p tabla1 p ";"
            print "\t\t\t" "$tabla2=" p tabla2 p ";"
            print "\t\t\t" "$campo1=$tabla1." p "_id" p ";"
            print "\t\t\t" "$fk_name1=" p "fk_" p ".$tabla1.$tabla2." p "_" p ".$tabla1;"
            print "\t\t\t" "$campo2=$tabla2." p "_id" p ";"
            print "\t\t\t" "$fk_name2=" p "fk_" p ".$tabla1.$tabla2." p "_" p ".$tabla2;"
            print "\t\t\t" "$table->unsignedBigInteger($campo1);"
            print "\t\t\t" "$table->foreign($campo1,$fk_name1)->references(" p "id" p ")->on($tabla1)->onDelete(" p "restrict" p ")->onUpdate(" p "restrict" p ");"
            print "\t\t\t" "$table->unsignedBigInteger($campo2);"
            print "\t\t\t" "$table->foreign($campo2,$fk_name2)->references(" p "id" p ")->on($tabla2)->onDelete(" p "restrict" p ")->onUpdate(" p "restrict" p ");"
            print "\t\t\t" "//Fin llaves foráneas"
        }
        index($0,"$table->bigIncrements(" p "id" p ");")==0{print $0}
        ' > ${MIGRACION_CON_FORANEAS}1
        mv ${MIGRACION_CON_FORANEAS}1 ${MIGRACION_CON_FORANEAS}
    fi
    echo
    if ${ES_TABLA_EXCLUIDA} ; then
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
    cat database/seeds/DatabaseSeeder.php | awk -v tabla=${TABLACAP} 'index($0,"// $this->call(UsersTableSeeder::class);")>0{print $0; print "\t \t" "$this->call(Tabla" tabla "Seeder::class);"};index($0,"// $this->call(UsersTableSeeder::class);")==0{print $0}' > database/seeds/DatabaseSeeder.php1
    mv database/seeds/DatabaseSeeder.php1 database/seeds/DatabaseSeeder.php
    echo
done

php artisan migrate #--seed

exit 
