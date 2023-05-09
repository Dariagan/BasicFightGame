PROGRAM Jugar;
//Autor 1: Stefano Tomasini Hoefner


//grado:Ingeniería del Software
//Objetivo del programa: Ser un juego básico de combate que tenga un sistema de inicio de sesión.
//Datos de entrada: cadenas de entrada por consola, archivoCuentas.bin, archivoCaras.txt
//Datos de salida: archivoCuentas.bin

USES sysutils, cuentas_personajes_caras;

TYPE
 tPPT = (piedra, papel, tijera);
 tResultado = (empate, derrota, victoria);

VAR
archivoCuentas:tFicheroCuentas;
archivoCaras:text;
caras:tArrCaras;
cuentaIniciada:tcuenta;
salirPrograma,sesionIniciada:boolean;

eleccion:string;//es un string porque así el programa no lanza excepciones porque el jugador haya puesto cualquier cosa.

FUNCTION conversorPPT(cadena:string):tPPT;
BEGIN
   case cadena of
        'piedra','Piedra','PIEDRA':conversorPPT:=piedra;
        'papel','Papel','PAPEL':conversorPPT:=papel;
        'tijera','Tijera','TIJERA':conversorPPT:=tijera;
   end;
END;

PROCEDURE crearCuenta (VAR archivoCuentas:tFicheroCuentas; var cuentaIniciada:tCuenta;var sesionIniciada:boolean);
VAR cuenta:tCuenta;
i,resultadoBusqueda:integer;
 BEGIN
  writeln('*************** Crear cuenta *************');
  write('Escriba su nombre de usuario: '); readln(cuenta.usuario);
  write('Escriba la contrasenia asociada a la cuenta: '); readln(cuenta.contrasenia);

  buscarRegistroCuenta(archivoCuentas, cuentaIniciada, cuenta,'buscarUsuario',resultadoBusqueda);

  if (resultadoBusqueda=1) then
   begin
     writeln('Ese nombre de usuario ya existe. Su cuenta no fue creada.');
     sesionIniciada:=FALSE;
   end
  else
    begin
     for i:=1 to 8 do
         begin
         cuenta.personajes[i].nombre:='NO_CREADO';
         end;
     grabarRegistroCuenta(archivoCuentas,cuenta);
     cuentaIniciada:=cuenta;
     writeln('La cuenta ha sido creada correctamente');
     sesionIniciada:=TRUE;
    end;
END;

PROCEDURE iniciarSesion (var archivoCuentas:tFicheroCuentas; var cuentaIniciada:tCuenta;var sesionIniciada:boolean);
 VAR
  cuentaIntroducida:tCuenta;
  resultadoBusqueda:integer;
 BEGIN
  writeln;
  writeln('*************** Iniciar sesion *************');
  write('Usuario: '); readln(cuentaIntroducida.usuario);
  write('Contrasenia: '); readln(cuentaIntroducida.contrasenia);

  buscarRegistroCuenta(archivoCuentas, cuentaIniciada,cuentaIntroducida,'buscarCredenciales',resultadoBusqueda);

  case resultadoBusqueda of
    1:begin
     writeln('Se inicio sesion exitosamente.');
     sesionIniciada:=TRUE;
    end;
    0:begin
     writeln('Credenciales no encontrados. No se pudo iniciar sesion.');
     sesionIniciada:=FALSE;
     end;
    -1:begin
     writeln('No se encuentra el fichero "archivoCuentas.bin". No se pudo iniciar sesion.');
     sesionIniciada:=FALSE;
     end;
   end;

 END;

PROCEDURE imprimirPantallaInicio();
 BEGIN
  writeln(slinebreak,'*************** Necesita una cuenta para jugar *************');
  writeln('1) Crear cuenta');
  writeln('2) Iniciar sesion');
  writeln('3) Salir');
  writeln('*************************************************************');
  write('Elige una opcion: ');
 END;


PROCEDURE imprimirAccion(tipoAccion:tResultado;pjJugador:tPersonaje;pjEnemigo:tPersonaje;critico:boolean);
var r_num:integer;
BEGIN
     randomize();
     r_num:=random(3);
     case tipoAccion of
        derrota:
         begin
          if (not critico) then
           begin
            case r_num of
             0:writeln(pjEnemigo.nombre, ' le dio un golpe en el coco a ', pjJugador.nombre,'.');
             1:writeln(pjEnemigo.nombre, ' le dio un golpe a la barriga de ',  pjJugador.nombre,'.');
             2:writeln(pjEnemigo.nombre, ' le dio un golpe a la cara de ', pjJugador.nombre,'.');
            end;
            writeln(pjJugador.cara, ' -', pjEnemigo.danio,'HP');
           end
          else
           begin
            case r_num of
             0:writeln('Golpe critico! ',pjEnemigo.nombre, ' le dio un golpe tremendamente fuerte en el coco a ', pjJugador.nombre,'.');
             1:writeln('Golpe critico! ',pjEnemigo.nombre, ' le dio un golpe tan fuerte a la barriga, que deja sin aliento a ',  pjJugador.nombre,'.');
             2:writeln('Golpe critico! ',pjEnemigo.nombre, ' le dio un golpe directo a la cara de ', pjJugador.nombre,'.');
            end;
            writeln(pjJugador.cara, ' -',pjEnemigo.danio*2,'HP');
           end;
         end;
        victoria:
         begin
          if (not critico) then
           begin
            case r_num of
             0:writeln(pjJugador.nombre,' le ha dado un duro golpe en el coco al ', pjEnemigo.nombre,'.');
             1:writeln(pjJugador.nombre, ' golpeo al ', pjEnemigo.nombre, ' en el pecho.');
             2:writeln(pjJugador.nombre, ' le dio un golpe a la cara del ', pjEnemigo.nombre,'.');
            end;
            writeln(pjEnemigo.cara, ' -', pjJugador.danio,'HP');
           end
          else
           begin
            case r_num of
             0:writeln('Golpe critico! Con su gran destreza, ',pjJugador.nombre, ' le dio un golpe tremendamente fuerte en el coco al ', pjEnemigo.nombre,'.');
             1:writeln('Golpe critico! Con toda su furia, ',pjJugador.nombre, ' golpeo al ', pjEnemigo.nombre, ' contundentemente en su pecho.');
             2:writeln('Golpe critico! Con toda su temible fuerza, ',pjJugador.nombre, ' le dio un golpe directo a la cara del ', pjEnemigo.nombre,'.');
            end;
            writeln(pjEnemigo.cara, ' -',pjJugador.danio*2,'HP');
           end;
         end;
        empate:
         case r_num of
          0:writeln(pjJugador.nombre, ' y el ' , pjEnemigo.nombre, ' son tan torpes que, mientras atacaban, ambos se resbalaron y se cayeron.');
          1:writeln(pjJugador.nombre, ' y el ' , pjEnemigo.nombre, ' chocaron sus armas, sin hacerse danio.');
          2:writeln(pjJugador.nombre, ' y el ' , pjEnemigo.nombre, ' esquivaron mutuamente los golpes del otro.');
         end;
     end;
END;

PROCEDURE combatir(pjJugador:tPersonaje;pjEnemigo:tPersonaje;var res_combate:tResultado);
var
PPT_jugador,PPT_enemigo:tPPT;
resPPT:tResultado;
n_random:integer;
respuesta:string;
critico:boolean;
BEGIN
  res_combate:=empate;
  repeat
    writeln(slinebreak,pjJugador.cara,' ',pjJugador.vida,'HP VERSUS ',pjEnemigo.cara,' ',pjEnemigo.vida,'HP');
    randomize();
    n_random:= random(3);
    case n_random of
     0:PPT_enemigo:=piedra;
     1:PPT_enemigo:=papel;
     2:PPT_enemigo:=tijera;
    end;

    repeat
     write(slinebreak,'piedra, papel, o tijera?: ');
     readln(respuesta);
    until((respuesta='piedra')or(respuesta='Piedra')or(respuesta='PIEDRA')or(respuesta='papel')or(respuesta='Papel')or(respuesta='PAPEL')or(respuesta='tijera')or(respuesta='Tijera')or(respuesta='TIJERA'));
    writeln();
    PPT_jugador:=conversorPPT(respuesta);

    case PPT_jugador of
         piedra: case PPT_enemigo of
              piedra:resPPT:=empate;
              papel:resPPT:=derrota;
              tijera:resPPT:=victoria;
              end;
         papel: case PPT_enemigo of
              piedra:resPPT:=victoria;
              papel:resPPT:=empate;
              tijera:resPPT:=derrota;
              end;
         tijera: case PPT_enemigo of
              piedra:resPPT:=derrota;
              papel:resPPT:=victoria;
              tijera:resPPT:=empate;
              end;
    end;

    critico:=false;
    n_random:=random(10)+1;
    if n_random>=8 then
       critico:=true;

    case resPPT of
         empate: imprimirAccion(empate,pjJugador,pjEnemigo,false);

         derrota:
           begin

             imprimirAccion(derrota,pjJugador,pjEnemigo,critico);
             if (not critico) then pjJugador.vida-=pjEnemigo.danio
             else pjJugador.vida-=pjEnemigo.danio*2;
             if (pjJugador.vida<=0) then
               res_combate:=derrota;
           end;
         victoria:
           begin
            imprimirAccion(victoria,pjJugador,pjEnemigo,critico);
            if (not critico) then pjEnemigo.vida-=pjJugador.danio
            else pjEnemigo.vida-=pjJugador.danio*2;
            if (pjEnemigo.vida<=0) then
               res_combate:=victoria;
           end;
    end;

  until ((res_combate=derrota) or (res_combate=victoria));
END;



PROCEDURE jugarPersonaje(var archivoCuentas:tFicheroCuentas;caras:tArrCaras;cuentaIniciada:tCuenta;var pjJugador:tPersonaje);//PROCEDURE PARA JUGAR
var

pjEnemigo:tPersonaje;
res_combate:tResultado;
respuesta:string;
resultadoGrabado:integer;
n_random:real;
 BEGIN
  writeln;
  writeln('*** BIENVENIDO AL JUEGO ***');

  repeat

   pjEnemigo.nombre:='orco';
   pjEnemigo.nivel:=pjJugador.nivel+random(3);

   pjEnemigo.cara:=darCara(caras);
   if pjJugador.nivel=0 then
    begin
     pjEnemigo.danio:=7;
     pjEnemigo.vida:=80
    end
   else
     repeat
       randomize();
       n_random:=(random(101)-50)/100;
       pjEnemigo.danio:=pjJugador.danio+round(pjJugador.danio*n_random);
       n_random:=(random(101)-50)/100;
       pjEnemigo.vida:=pjJugador.vida+round(pjJugador.vida*n_random);
     until (pjEnemigo.danio>0) and (pjEnemigo.vida>0);

   writeln('Usted se va a enfrentar a ',pjEnemigo.nombre,'(Nivel ', pjEnemigo.nivel,') . ');

   combatir(pjJugador,pjEnemigo,res_combate);

   if (res_combate=victoria) then
    begin//mejorar
     writeln(slinebreak,'****',pjJugador.nombre, ' valientemente finiquito a el salvaje y vil ', pjEnemigo.nombre,'****');
     pjJugador.nCombates+=1;
     pjJugador.nCombatesGanados+=1;
     subirNivel(pjJugador,pjEnemigo);
    end
   else
    begin//mejorar
     writeln(slinebreak,'****', pjEnemigo.nombre, ' cruel y ferozmente finiquito a ', pjJugador.nombre,'****');
     pjJugador.nCombates+=1;
    end;

   grabarPersonaje(archivoCuentas,cuentaIniciada,pjJugador,resultadoGrabado);
   case resultadoGrabado of
    1:begin
     writeln(slinebreak,'Se guardo el juego exitosamente.');
     end;
    0:begin
     writeln('No se encontro la cuenta con la que se inicio sesion. No se pudo guardar el juego.');
     end;
    -1:begin
     writeln('No se encontro el fichero "archivoCuentas.bin". No se pudo guardar el juego.');
     end;
    end;

    writeln(slinebreak,'Quiere empezar otro combate o quiere volver al menu de personajes?, escriba "volver" para volver al menu. Enter para continuar:');
    readln(respuesta);
  until respuesta='volver';

 END;

begin//PROGRAMA PRINCIPAL
randomize;
    assignfile(archivoCuentas,'archivoCuentas.bin');
    assignfile(archivoCaras,'archivoCaras.txt');
    salirPrograma:=false;
    repeat
     sesionIniciada:=false;
     imprimirPantallaInicio();
     readln(eleccion);
     case eleccion of
      '1':crearCuenta(archivoCuentas,cuentaIniciada,sesionIniciada);
      '2':iniciarSesion(archivoCuentas,cuentaIniciada,sesionIniciada);
      '3':salirPrograma:=true;
     end;

    if (sesionIniciada) then
      begin
       repeat
        cargarCaras(archivoCaras,caras);
        imprimirPantallaGestionPJs(cuentaIniciada,false);
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
//esto es por si el usuario eligió al personaje 5 ó 6, al salir del case no se salga del repeat porque eleccion='5' ó eleccion='6'.
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
                 imprimirPantallaSelPJ('editarTexto');
                 readln(eleccion);
                if (eleccionPosible(eleccion)) then
                  begin
                   if (cuentaIniciada.personajes[StrToInt(eleccion)].nombre<>'NO_CREADO') then
                        begin
                          editarPersonaje(archivoCuentas,caras,cuentaIniciada,StrToInt(eleccion),false);
                        end
                      else
                        begin
                           writeln('No se puede editar el texto de un personaje no creado.');
                           readln();
                        end;
                    eleccion:='0';
                  end
                else writeln('Edicion de texto de personaje cancelada por el usuario.');
              end;

             '4':
              begin
                imprimirPantallaSelPJ('jugar');
                readln(eleccion);

                if (eleccionPosible(eleccion)) then
                  begin
                   if (cuentaIniciada.personajes[StrToInt(eleccion)].nombre<>'NO_CREADO') then
                        begin
                          jugarPersonaje(archivoCuentas,caras,cuentaIniciada,cuentaIniciada.personajes[StrToInt(eleccion)]);
                        end
                      else
                        begin
                           writeln('No se puede jugar con un personaje no creado.');
                           readln();
                        end;
                      eleccion:='0';
                  end
                else writeln('Seleccion del personaje a jugar cancelada por el usuario.');
              end;

             //'5':volver
             '6':salirPrograma:=true;
        end;

       until (eleccion='5')or(eleccion='6');
      end;

    until(salirPrograma);

      writeln('Cerrando juego...');
      readln;
end.








