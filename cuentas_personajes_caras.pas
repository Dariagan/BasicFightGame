unit cuentas_personajes_caras;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;

CONST MAXIMO_tArrCaras = 100;

type
  tPersonaje = RECORD
  nombre:string[30];
  descripcion:string[200];
  cara:string[7];
  nivel:integer;
  vida:integer;
  danio:integer;
  nCombates:integer;
  nCombatesGanados:integer;
  pos:byte;
 END;

  tArrayPersonajes = array [1..30] of tPersonaje;

  tCuenta = RECORD
   usuario:string[30];
   contrasenia:string[100];
   personajes:tArrayPersonajes;
  END;

  tFicheroCuentas = FILE of tCuenta;
  tArrCaras = array[1..MAXIMO_tArrCaras] of string[7];

PROCEDURE grabarRegistroCuenta(VAR archivoCuentas:tFicheroCuentas; registroCuenta:tCuenta);
PROCEDURE buscarRegistroCuenta (VAR archivoCuentas:tFicheroCuentas;var cuentaIniciada:tCuenta; var cuentaBuscada:tCuenta;modo:string;var resultadoBusqueda:integer);
PROCEDURE grabarPersonaje (var archivoCuentas:tFicheroCuentas;var cuentaIniciada:tCuenta;personaje:tPersonaje;var resultadoGrabado:integer);
PROCEDURE cargarCaras(var archivoCaras:text; var caras:tArrCaras);
PROCEDURE elegirCara (caras:tArrCaras;var caraElegida:shortstring);
PROCEDURE imprimirPantallaGestionPJs(cuentaIniciada:tCuenta;modoAdmin:boolean);
PROCEDURE crearPersonaje (var archivoCuentas:tFicheroCuentas; var cuentaIniciada:tCuenta; pos:byte; caras:tArrCaras);
PROCEDURE verPersonaje(cuentaIniciada:tCuenta;pos:byte);
PROCEDURE subirNivel(var pjJugador:tPersonaje;pjEnemigo:tPersonaje);
PROCEDURE editarPersonaje (var archivoCuentas:tFicheroCuentas;caras:tArrCaras;var cuentaIniciada:tCuenta;pos:byte;modoAdmin:boolean);
PROCEDURE imprimirPantallaSelPJ(modo:string);
FUNCTION darCara(caras:tArrCaras):shortstring;
FUNCTION eleccionPosible(cadena:string):boolean;

implementation

PROCEDURE imprimirPantallaSelPJ(modo:string);
 begin
     case modo of
     'crear':
      begin
       writeln('En que posicion (de 1 a 8) quiere poner su nuevo personaje?. Nota: si ya esta ocupada esa posicion, se sobreescribira el personaje preexistente.');
       writeln('Escriba algo distinto a una posicion si quiere cancelar la creacion de un nuevo personaje');
      end;
     'info':
      begin
       writeln('A que personaje (de 1 a 8) quiere revisarle su informacion?');
       writeln('Escriba algo distinto a una posicion para cancelar.');
      end;
     'editarTexto':
      begin
       writeln('A que personaje (de 1 a 8) quiere editarle su texto?');
       writeln('Escriba algo distinto a una posicion para cancelar.');
      end;
     'modificar':
      begin
       writeln('Que personaje (de 1 a 8) quiere modificar?');
       writeln('Escriba algo distinto a una posicion para cancelar.');
      end;
     'jugar':
      begin
       writeln('Con que personaje (de 1 a 8) quiere jugar?');
       writeln('Escriba algo distinto a una posicion para cancelar.');
      end;
     end;
 end;

PROCEDURE grabarRegistroCuenta(VAR archivoCuentas:tFicheroCuentas; registroCuenta:tCuenta);
BEGIN
 {$I-}
 reset(archivoCuentas);
 {$I+}
 if (IOResult = 0) then
   SEEK(archivoCuentas,FILESIZE(archivoCuentas))
 else
   Rewrite(archivoCuentas);

 write(archivoCuentas,registroCuenta);
 close(archivoCuentas);
END;

PROCEDURE buscarRegistroCuenta (VAR archivoCuentas:tFicheroCuentas;var cuentaIniciada:tCuenta; var cuentaBuscada:tCuenta;modo:string;var resultadoBusqueda:integer);

var bufferCuenta:tCuenta;
seEncontroCuenta:boolean;

BEGIN
   seEncontroCuenta:=FALSE;
   {$I-}
   Reset(archivoCuentas);
   {$I+}
   if (IOResult = 0) then
    begin
     while ((not eof(archivoCuentas)) and (seEncontroCuenta=FALSE)) do
//no se puede poner un repeat en este caso porque no se puede saltar la comprobación anterior a la iteración 1ª de si se llego al end of file
//antes de intentar leer el fichero. Si en la 1ª iteración se intenta leer el fichero cuando ya terminó el fichero, el programa va a lanzar una excepción.
//Ya que no puedo usar un repeat en este caso, es necesario anteriormente forzar que seEncontroCuenta sea falso, sino puede que el valor basura sea un TRUE,
//y se salte la lectura totalmente.
      begin
       read(archivoCuentas, bufferCuenta);
       if (((modo='buscarUsuario')or(modo='adminBuscarUsuario')) and (cuentaBuscada.usuario=bufferCuenta.usuario)) then
         begin
          seEncontroCuenta:=TRUE;
          if(modo='adminBuscarUsuario') then cuentaIniciada:=bufferCuenta;
         end
       else if ((modo='buscarCredenciales') and (cuentaBuscada.usuario=bufferCuenta.usuario) and (cuentaBuscada.contrasenia=bufferCuenta.contrasenia)) then
         begin
           cuentaIniciada:= bufferCuenta;
           seEncontroCuenta:=TRUE;
         end;
      end;
      close(archivoCuentas);
      if (seEncontroCuenta) then resultadoBusqueda:=1
      else resultadoBusqueda:=0;
     end
   else resultadoBusqueda:=-1;
END;

PROCEDURE imprimirPantallaGestionPJs(cuentaIniciada:tCuenta;modoAdmin:boolean);
var i:integer;
 BEGIN
  writeln('****************************');
  writeln('*************** PERSONAJES (',cuentaIniciada.usuario,') ***************');
  for i:=1 to 8 do
      begin
       writeln('Personaje ',i,':');
       if (cuentaIniciada.personajes[i].nombre<>'NO_CREADO') then
         begin
          writeln(cuentaIniciada.personajes[i].nombre,' ',cuentaIniciada.personajes[i].cara);
          writeln('Nivel ',cuentaIniciada.personajes[i].nivel,slinebreak);
         end
       else
         writeln('POSICION LIBRE',slinebreak);
      end;

  writeln('Que desea hacer?');
  writeln('1) Crear personaje nuevo');
  writeln('2) Ver informacion completa de un personaje');
  if(not modoAdmin) then
     begin
      writeln('3) Editar nombre y/o descripcion y/o cara de un personaje');
      writeln('4) Cargar personaje y jugar');
      writeln('5) Volver a la pantalla anterior');
      writeln('6) Salir del programa');
     end
  else
    begin
      writeln('3) Modificar personaje');
      writeln('4) Volver a la pantalla anterior');
      writeln('5) Salir del programa');
    end

  end;


PROCEDURE grabarPersonaje (var archivoCuentas:tFicheroCuentas;var cuentaIniciada:tCuenta;personaje:tPersonaje;var resultadoGrabado:integer);
var seEncontroCuenta:boolean;
bufferCuenta:tCuenta;
puntero_cuenta:Longint;
begin
   seEncontroCuenta:=FALSE;
   {$I-}
   Reset(archivoCuentas);
   {$I+}
   if (IOResult = 0) then//comprobacion de si está el archivo
    begin
     while ((not eof(archivoCuentas)) and (seEncontroCuenta=FALSE)) do
      begin
       read(archivoCuentas, bufferCuenta);
       if (cuentaIniciada.usuario=bufferCuenta.usuario) then
         begin
           seEncontroCuenta:=TRUE;
           puntero_cuenta:=filepos(archivoCuentas)-1;
         end;
      end;

      if(seEncontroCuenta) then
        begin
          bufferCuenta.personajes[personaje.pos]:=personaje;
          seek(archivoCuentas,puntero_cuenta);
          write(archivoCuentas,bufferCuenta);
          resultadoGrabado:=1;
        end
      else resultadoGrabado:=0;

      close(archivoCuentas);
    end
   else
     resultadoGrabado:=-1;
end;

PROCEDURE cargarCaras(var archivoCaras:text; var caras:tArrCaras);
var i:integer;
 BEGIN
    i:=1;
    {$I-}
    reset(archivoCaras);
    {$I+}
    if (IOResult = 0) then
     begin
      while not eof(archivoCaras) do
      begin
       readLn(archivoCaras, caras[i]);
       i+=1;
      end;
      for i:=i to MAXIMO_tArrCaras do
          caras[i]:='---';
      close(archivoCaras);
     end
    else
     begin
       writeln('No se encontro el fichero "archivoCaras.txt", la unica cara disponible sera: :-)');
       for i:=1 to MAXIMO_tArrCaras do
           caras[i]:=':-)';
     end;
END;

PROCEDURE elegirCara (caras:tArrCaras;var caraElegida:shortstring);
var
i:integer;
eleccion:string;
BEGIN

    repeat//no puedo usar la función darCara porque también necesito el índice.
    randomize;
     i:=(random(MAXIMO_tArrCaras)+1);
    until (caras[i]<>'---');

    writeln(slinebreak,'ELIJA LA CARA DE SU PERSONAJE.',slinebreak,'Escriba "si" para elegir la cara mostrada',slinebreak,'Escriba cualquier otra cadena para ver la siguiente cara disponible.',slinebreak,'Escriba "ret" para retroceder a la cara anterior.');
    repeat
      write(slinebreak,caras[i],' ');readln(eleccion);
      if ((eleccion<>'si') and (eleccion<>'Si') and (eleccion<>'SI')) then
          if (eleccion<>'ret') then
            begin
             i+=1;
             if ((i>MAXIMO_tArrCaras) or (caras[i]='---')) then i:=1;
            end
          else
            begin
               i-=1;
               if (i<1) then
                begin
                 i:=MAXIMO_tArrCaras;
                  while (caras[i]='---') do
                    i-=1;
                end;
            end;
    until (eleccion='si')or(eleccion='Si')or(eleccion='SI');
    caraElegida:=caras[i];
END;

FUNCTION darCara(caras:tArrCaras):shortstring;
var i:integer;
BEGIN
    repeat
     randomize;
     i:=(random(MAXIMO_tArrCaras)+1);
    until (caras[i]<>'---');
    darCara:=caras[i];
END;

PROCEDURE verPersonaje(cuentaIniciada:tCuenta;pos:byte);
 BEGIN
      begin
       if (cuentaIniciada.personajes[pos].nombre<>'NO_CREADO') then
         begin
          writeln(cuentaIniciada.personajes[pos].cara);
          writeln('Nombre: ', cuentaIniciada.personajes[pos].nombre);
          writeln('Descripcion:', cuentaIniciada.personajes[pos].descripcion);
          writeln('Nivel: ',cuentaIniciada.personajes[pos].nivel);
          writeln('Vida: ',cuentaIniciada.personajes[pos].vida,'HP');
          writeln('Danio: ',cuentaIniciada.personajes[pos].danio,'ATK');
          writeln('Combates peleados: ',cuentaIniciada.personajes[pos].nCombates);
          writeln('Combates ganados: ',cuentaIniciada.personajes[pos].nCombatesGanados);
          writeln('Pulsa enter para volver ');
          readln();
         end
       else
         writeln('El personaje elegido no fue creado todavia.',slinebreak);
      end;
 END;

PROCEDURE crearPersonaje (var archivoCuentas:tFicheroCuentas; var cuentaIniciada:tCuenta; pos:byte; caras:tArrCaras);
var personajeNuevo:tPersonaje;
resultadoGrabado:integer;
BEGIN

    personajeNuevo.nivel:=0;
    personajeNuevo.vida:=100;
    personajeNuevo.danio:=10;
    personajeNuevo.nCombates:=0;
    personajeNuevo.nCombatesGanados:=0;
    personajeNuevo.pos:=pos;

    write('Escriba el nombre de su personaje: ');
    readLn(personajeNuevo.nombre);
    write(slinebreak,'Escriba la descripcion de su personaje: ');
    readLn(personajeNuevo.descripcion);

    elegirCara(caras,personajeNuevo.cara);
    grabarPersonaje(archivoCuentas,cuentaIniciada,personajeNuevo,resultadoGrabado);

    case resultadoGrabado of
    1:begin
     writeln('El personaje se grabo exitosamente.');
     cuentaIniciada.personajes[pos]:=personajeNuevo;
     end;
    0:begin
     writeln('No se encontro la cuenta con la que se inicio sesion. No se pudo grabar el personaje.');
     end;
    -1:begin
     writeln('No se encuentra el fichero "archivoCuentas.bin". No se pudo grabar el personaje.');
     end;
   end;
END;

PROCEDURE subirNivel(var pjJugador:tPersonaje;pjEnemigo:tPersonaje);
var
n1,n2:real;
BEGIN
     write(slinebreak,'Tu personaje, ', pjJugador.nombre,' ',pjJugador.cara,' ha subido un nivel! ');
     pjJugador.nivel+=1;

      n1:=sqr(pjEnemigo.danio/pjJugador.danio)*3;
      n2:=sqr(pjEnemigo.vida/pjJugador.vida)*20;
//esto es para que el aumento sea más o menos proporcional a la dificultad que tuvo el combate. si fue facil, se gana menos. si fue dificil, se gana mas.

     if(round(n1)>0) then write('+',round(n1),'ATK, ');
     if(round(n2)>0) then write('+',round(n2),'HP!');
     pjJugador.danio+=round(n1);
     pjJugador.vida+=round(n2);
END;

FUNCTION eleccionPosible(cadena:string):boolean;
BEGIN
    if((cadena='1')or(cadena='2')or(cadena='3')or(cadena='4')or(cadena='5')or(cadena='6')or(cadena='7')or(cadena='8')) then
        eleccionPosible:=true
    else eleccionPosible:=false;
END;

PROCEDURE editarPersonaje (var archivoCuentas:tFicheroCuentas;caras:tArrCaras;var cuentaIniciada:tCuenta;pos:byte;modoAdmin:boolean);
var
resultadoGrabado:integer;
respuesta:string;
respuestaNum:integer;
i,nivelesSubidos:integer;
cambioAlgo:boolean;
BEGIN
   cambioAlgo:=false;
   writeln(slinebreak,'Nombre personaje: ',cuentaIniciada.personajes[pos].nombre);
   write(slinebreak,'Escriba el nuevo nombre de su personaje, o escriba "no" para no cambiarlo: '); readln(respuesta);
   if (respuesta<>'no') then
     begin
      cambioAlgo:=true;
      cuentaIniciada.personajes[pos].nombre:=respuesta;
     end;
   writeln(slinebreak,'Descripcion personaje: ',cuentaIniciada.personajes[pos].descripcion);
   write('Escriba la nuevo descripcion de su personaje, o escriba "no" para no cambiarla: '); readln(respuesta);
   if (respuesta<>'no') then
    begin
      cambioAlgo:=true;
      cuentaIniciada.personajes[pos].descripcion:=respuesta;
     end;
   writeln(slinebreak,'Cara personaje: ',cuentaIniciada.personajes[pos].cara);
   write('Escriba "si" si quiere cambiarle la cara a su personaje: ');readln(respuesta);
   if (respuesta='si') then
    begin
     cambioAlgo:=true;
     elegirCara(caras,cuentaIniciada.personajes[pos].cara);
    end;
   if (modoAdmin) then
   begin
        writeln(slinebreak,'SECCION ADMIN. EN ESTA SECCION DE MODIFICACION DEL PERSONAJE, INTRODUCIR CADENAS DE TEXTO EN VEZ DE NUMEROS ENTEROS LANZA UNA EXCEPCION');

      writeln(slinebreak,'Nivel personaje: ',cuentaIniciada.personajes[pos].nivel);
      write('Designe el nuevo nivel de su personaje (numero entero no negativo), o introduzca un numero negativo para no modificarlo: ');
      readln(respuestaNum);
      if (respuestaNum>=0) then
        begin
         cambioAlgo:=true;
         nivelesSubidos:=respuestaNum-cuentaIniciada.personajes[pos].nivel;
         for i:=1 to nivelesSubidos do
             subirNivel(cuentaIniciada.personajes[pos],cuentaIniciada.personajes[pos]);
        end;

      writeln(slinebreak,'Vida personaje: ',cuentaIniciada.personajes[pos].vida);
      write('Designe los nuevos puntos de vida de su personaje (numero natural), o introduzca un numero entero no positivo para no modificarlo: ');
      readln(respuestaNum);
      if (respuestaNum>0) then
        begin
         cambioAlgo:=true;
         cuentaIniciada.personajes[pos].vida:=respuestaNum;
        end;

      writeln(slinebreak,'Danio personaje: ',cuentaIniciada.personajes[pos].danio);
      write('Designe el nuevo danio de su personaje (numero natural), o introduzca un numero entero no positivo para no modificarlo: ');
      readln(respuestaNum);
      if (respuestaNum>0) then
        begin
         cambioAlgo:=true;
         cuentaIniciada.personajes[pos].danio:=respuestaNum;
        end;

    end;

    if (cambioAlgo) then
     begin
      grabarPersonaje(archivoCuentas,cuentaIniciada,cuentaIniciada.personajes[pos],resultadoGrabado);
      case resultadoGrabado of
        1:begin
         writeln('El personaje editado se grabo exitosamente.');
       //cuentaIniciada.personajes[pos]:=;
         end;
        0:begin
         writeln('No se encontro la cuenta con la que se inicio sesion. No se pudo grabar la edicion del personaje.');
         end;
        -1:begin
         writeln('No se encuentra el fichero "archivoCuentas.bin". No se pudo grabar la edicion del personaje.');
         end;
      end;
     end;

END;

end.

