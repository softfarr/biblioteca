@extends("theme.$theme.layout")

@section('titulo')
Menus
@endsection

@section('contenido')
    <!-- Ini row -->
    <div class="row">
        <div class="col-lg-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">Crear Menú</h3>
                </div>
                <!-- /.box-header -->
                <div class="box-body table-responsive no-padding">
                    <table class="table table-hover table-bordered table-striped">
                        <form action="{{route('menu_guardar')}}" method="POST" id="form-general" class="form-horizontal">
                            @csrf
                            <div class="box-body">
                                @include('admin.menu.form')
                            </div>
                            <!-- /.box-body -->
                            <div class="box-footer">
                                @include('includes.boton-form-crear')
                            </div>
                            <!-- /.box-footer -->
                        </form>
                    </table>
                </div>
                <!-- /.box-body -->
            </div>
            <!-- /.box -->
            @include('admin.menu.form-error')
            @include('admin.menu.form-mensaje')
        </div>
    </div>
    <!-- Fin row -->
@endsection