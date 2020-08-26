<div class="form-group">
    <label for="nombre" class="col-sm-2 control-label requerido">Nombre</label>

    <div class="col-sm-10">
    <input type="text" name="nombre" id="nombre" class="form-control" value="{{old('nombre')}}" placeholder="Nombre"/>
    </div>
</div>

<div class="form-group">
    <label for="url" class="col-sm-2 control-label requerido">URL</label>

    <div class="col-sm-10">
        <input type="text" name="url" id="url" class="form-control" value="{{old('url')}}" placeholder="URL"/>
    </div>
</div>

<div class="form-group">
    <label for="icono" class="col-sm-2 control-label">Icono</label>

    <div class="col-sm-10">
        <input type="text" name="icono" id="icono" class="form-control" value="{{old('icono')}}" placeholder="Icono"/>
    </div>
</div>
