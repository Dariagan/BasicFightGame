PROGRAM Administrador;
//grupo 14:
//Autor 1: Stefano Tomasini Hoefner

//grado:Ingeniería del Software
//Objetivo del programa: Ser el programa de administrador
//Datos de entrada: cadenas de entrada por consola, archivoCuentas.bin
//Datos de salida: modificaciones sobre archivoCuentas.bin


USES sysutils, cuentas_personajes_caras;
//TYPE

var archivoCuentas:tFicheroCuentas;
archivoCaras:text;
respuesta:string;
salirPrograma:boolean;

PROCEDURE menuPrincipal;
 BEGIN writeln;
  writeln('*************** ZONA DE ADMINISTRADOR *************');
  writeln('1) Ver todas las cuentas y sus respectivos personajes');
  writeln('2) Ver el numero total de partidas de cada jugador');
  writeln('3) Crear/modificar personajes de una cuenta');
  writeln('4) Salir');
  writeln('***********************************************************');
  write('Elija una opcion: ');
 END;


PROCEDURE verCuentasPersonajes(var archivoCuentas:tFicheroCuentas); //esto imprime todas las cuentas creadas junto a sus respectivos personajes (1 jugador=1 cuenta, con varios personajes)
var bufferCuenta:tCuenta;//cuenta de lectura
seEncontroCuenta:boolean;
i:integer;
BEGIN
   seEncontroCuenta:=FALSE;
   {$I-}
   Reset(archivoCuentas);//control de errores
   {$I+}
   if (IOResult = 0) then//si esta el fichero entonces...
    begin
     while (not eof(archivoCuentas)) do
      begin
       read(archivoCuentas, bufferCuenta);//lee una cuenta del fichero en el registro buffercuenta
       write(slinebreak,'Usuario: ',bufferCuenta.usuario,' Personajes: ');
       for i:=1 to 8 do
           if bufferCuenta.personajes[i].nombre<>'NO_CREADO' then write(bufferCuenta.personajes[i].nombre, ' ');
       seEncontroCuenta:=TRUE;
      end;
      close(archivoCuentas);
      if (not seEncontroCuenta) then writeln('No hay ninguna cuenta creada.');
     end
   else writeln('No se encontro el fichero "archivoCuentas.bin".');//si no encuentra el fichero
   writeln; writeln;
   writeln('Pulsa enter para volver al menu principal');
   readln;
END;





FUNCTION contarPartidasCuenta(cuenta:tCuenta):integer;
var i:integer;
begin
    contarPartidasCuenta:=0;
    for i:=1 to 8 do
         if cuenta.personajes[i].nombre<>'NO_CREADO' then contarPartidasCuenta+=cuenta.personajes[i].nCombates;
end;

PROCEDURE verTotalPartidas(var archivoCuentas:tFicheroCuentas); //esto, dentro de cada cuenta, debería sumar los nCombates de todos los 8 personajes que tiene cada cuenta
var bufferCuenta:tCuenta;//cuenta de lectura
seEncontroCuenta:boolean;
BEGIN
   seEncontroCuenta:=FALSE;
   {$I-}
   Reset(archivoCuentas);//control de errores
   {$I+}
   if (IOResult = 0) then//si esta el fichero entonces...
    begin
     while (not eof(archivoCuentas)) do//si no llego al final del fichero...
      begin
       read(archivoCuentas, bufferCuenta);//lee una cuenta del fichero en el registro buffercuenta
       writeln('Usuario: ',bufferCuenta.usuario,' Numero de partidas: ', contarPartidasCuenta(bufferCuenta));
       seEncontroCuenta:=TRUE;
      end;
      close(archivoCuentas);
      if (not seEncontroCuenta) then writeln('No hay ninguna cuenta creada.');
     end
   else writeln('No se encontro el fichero "archivoCuentas.bin".');//si no encuentra el fichero
writeln;
writeln('Pulse enter para volver al menu principal');
readln;
END;

PROCEDURE editarCuenta(var archivoCuentas:tFicheroCuentas;var archivoCaras:text; var salirPrograma:boolean);
var
caras:tArrCaras;
eleccion:string;
cuentaIntroducida:tCuenta;
cuentaIniciada:tCuenta;
resultadoBusqueda:integer;

  BEGIN
   write('Escriba el nombre de usuario de la cuenta a modificar: '); readln(cuentaIntroducida.usuario);
   buscarRegistroCuenta(archivoCuentas,cuentaIniciada,cuentaIntroducida,'adminBuscarUsuario',resultadoBusqueda);
   case resultadoBusqueda of
   1:writeln('Se cargaron los datos de la cuenta ', cuentaIniciada.usuario);
   0:writeln('No se encontro ninguna cuenta registrada bajo el nombre de usuario "', cuentaIntroducida.usuario,'".');
   -1:writeln('No se encontro el fichero "archivoCuentas.bin"');
   end;
    if (resultadoBusqueda=1) then
      begin
        cargarCaras(archivoCaras,caras);
        repeat
        imprimirPantallaGestionPJs(cuentaIniciada,true);
        readln(eleccion);
        case eleccion of
             '1':
              begin
                imprimirPantallaSelPJ('crear');
                readln(eleccion);
                if (eleccionPosible(eleccion)) then
                  begin
                    crearPersonaje(archivoCuentas,cuentaIniciada,StrToInt(eleccion),caras);
                    eleccion:='0';
                  end
                else writeln('Creacion de personaje cancelada por el usuario.');
              end;

             '2':
              begin
                imprimirPantallaSelPJ('info');
                readln(eleccion);
                if (eleccionPosible(eleccion)) then
                  begin
                    if (cuentaIniciada.personajes[StrToInt(eleccion)].nombre<>'NO_CREADO') then
                       verPersonaje(cuentaIniciada,StrToInt(eleccion))
                    else
                      begin
                       writeln('No se puede ver la informacion de un personaje no creado.');
                       readln();
                      end;
                    eleccion:='0';
                  end
                else writeln('Vista de personaje cancelada por el usuario.');
              end;

             '3':
              begin
                 imprimirPantallaSelPJ('modificar');
                 readln(eleccion);
                 if (eleccionPosible(eleccion)) then
                  begin
                   if (cuentaIniciada.personajes[StrToInt(eleccion)].nombre<>'NO_CREADO') then
                        begin
                          editarPersonaje(archivoCuentas,caras,cuentaIniciada,StrToInt(eleccion),true);
                        end
                      else
                        begin
                           writeln('No se puede modificar un personaje no creado.');
                           readln();
                        end;
                    eleccion:='0';
                  end
                else writeln('Edicion de texto de personaje cancelada por el usuario.');
              end;
            //'4':volver a la pantalla anterior
             '5':salirPrograma:=true;
        end;
        until (eleccion='4') or (eleccion='5');


 end;
END;


BEGIN //Programa principal
assignfile(archivoCuentas,'archivoCuentas.bin');
assignfile(archivoCaras,'archivoCaras.txt');
salirPrograma:=false;
 REPEAT
  writeln('*************** ZONA DE ADMINISTRADOR *************');
  write('Introduce la contrasena para continuar: '); readln(respuesta);
 UNTIL (respuesta='admin');
 REPEAT
 menuPrincipal(); readln(respuesta);
  CASE respuesta OF
  '1': verCuentasPersonajes(archivoCuentas);
  '2': verTotalPartidas(archivoCuentas);
  '3': editarCuenta(archivoCuentas,archivoCaras,salirPrograma);
  '4': salirPrograma:=true;
  end;

 UNTIL (salirPrograma);

writeln('Cerrando...');
readln;
END.

