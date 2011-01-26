---------------------------------------------------------------
--                      Digital_IO_Sim                       --
-- Simulador de robots Fischertechnik, tipo Industrial Robot --
-- y Robot 3D                                                --
--                                                           --
-- Autor: Jorge Real, adaptación de un programa original de  --
--        Gloria Mainar (Enero 2003)                         --
--    Fecha: Noviembre 2008                                  --
--       Añadida comprobación de límites de los ejes         --
--    Fecha: Diciembre 2004                                  --
--       Ahora es Digital_IO con interfaz de tipo            --
--    Read_Low_Byte y Write_Low_Byte. Utiliza                --
--    una ventana de salida de texto de win_io para mostrar  --
--    el estado del robot.                                   --
--    Fecha: Diciembre 2003                                  --
--       La adaptación sólo cambia la forma de representar   --
--    el estado y actuadores del robot y, por tanto, la      --
--    forma de acceder a ellos. Se usan cláusulas de repre-  --
--    sentación para imitar la disposición de los bits de    --
--    entrada y salida de los robots.                        --
--                                                           --
-- Uso del paquete:                                          --
--   Para probar el funcionamiento de los programas que      --
--   utilizan los robots Fischertechnik. Basta sustituir el  --
--   paquete Digital_IO por Digital_IO_Sim en la sección de  --
--   contexto del programa principal para acceder a esta     --
--   versión simulada del robot.  Ello permite verificar el  --
--   funcionamiento sin necesidad de conectar físicamente    --
--   el robot.                                               --
--                                                           --
--   Digital_IO_Sim se encarga de simular los valores de los --
--   interruptores finales de carrera y marcadores de pulsos --
--   en función de la activación de los motores del robot.   --
--                                                           --
---------------------------------------------------------------


with Low_Level_Types;  use Low_Level_Types;
with Ada.Real_Time;    use Ada.Real_Time;
with System;                 -- Necesario para especificar la prioridad de la tarea simuladora
with Unchecked_Conversion;   -- Para conversiones de Byte a Actuador y de Sensor a Byte
with Output_Windows;   use Output_Windows;
with Message_Windows;  use Message_Windows;

package body Digital_Io_Sim is

   ------------------- Constantes de configuración del simulador -------------
   RPM_Max : constant Integer := 300;
   Periodo_De_Simulacion : constant Time_Span := Microseconds(7_500_000/RPM_Max);

   -- Número de flancos de cada motor desde el inicio (interruptor)
   -- hasta el extremo de cada articulación.
   P_Rotacion : constant Integer := 400;
   P_Fondo    : constant Integer := 400;
   P_Altura   : constant Integer := 400;
   P_Pinza    : constant Integer := 40;
   ---------------------------------------------------------------------------

   type Bit is mod 2;

   type Actuador_Robot is
      record
         M_Giro_Horario     : Bit := 0; -- Puesto a uno mueve el motor de giro en sentido horario
         M_Giro_Antihorario : Bit := 0; -- Puesto a uno mueve el motor de giro en sentido antihorario
         M_Fondo_Avance     : Bit := 0; -- Puesto a uno mueve el motor de avance en sentido hacia delante
         M_Fondo_Retroceso  : Bit := 0; -- Puesto a uno mueve el motor de avance en sentido hacia atrás
         M_Altura_Subir     : Bit := 0; -- Puesto a uno mueve el motor de altura hacia arriba
         M_Altura_Bajar     : Bit := 0; -- Puesto a uno mueve el motor de altura hacia abajo
         M_Pinza_Abrir      : Bit := 0; -- Puesto a uno cierra la pinza
         M_Pinza_Cerrar     : Bit := 0; -- Puesto a uno abre la pinza
      end record;

   for Actuador_Robot use  -- Cláusula de representación
      record
         M_Giro_Horario      at 0 range 0..0;
         M_Giro_Antihorario  at 0 range 1..1;
         M_Fondo_Avance      at 0 range 2..2;
         M_Fondo_Retroceso   at 0 range 3..3;
         M_Altura_Subir      at 0 range 4..4;
         M_Altura_Bajar      at 0 range 5..5;
         M_Pinza_Abrir       at 0 range 6..6;
         M_Pinza_Cerrar      at 0 range 7..7;
      end record;
   for Actuador_Robot'Size use 8;  -- Fijar tamaño de los objetos de este tipo
   pragma Pack(Actuador_Robot);    -- Empaquetar la representación

   type Sensor_Robot is
      record
         Fc_Giro     : Bit := 1; -- A cero indica posición de inicio del eje de giro
         Paso_Giro   : Bit := 0; -- Pulsos de paso del motor de giro
         Fc_Fondo    : Bit := 1; -- A cero indica posición de inicio del eje de fondo
         Paso_Fondo  : Bit := 0; -- Pulsos de paso del motor de fondo
         Fc_Altura   : Bit := 1; -- A cero indica posición de inicio del eje de altura
         Paso_Altura : Bit := 0; -- Pulsos de paso del motor de altura
         Fc_Pinza    : Bit := 1; -- A cero indica posición de inicio del eje de la pinza (completamente abierta)
         Paso_Pinza  : Bit := 0; -- Pulsos de paso del motor de pinza
      end record;

   for Sensor_Robot use  -- Cláusula de representación
      record
         Fc_Giro      at 0 range 0..0;
         Paso_Giro    at 0 range 1..1;
         Fc_Fondo     at 0 range 2..2;
         Paso_Fondo   at 0 range 3..3;
         Fc_Altura    at 0 range 4..4;
         Paso_Altura  at 0 range 5..5;
         Fc_Pinza     at 0 range 6..6;
         Paso_Pinza   at 0 range 7..7;
      end record;
   for Sensor_Robot'Size use 8;  -- Fijar tamaño de los objetos de este tipo
   pragma Pack(Sensor_Robot);    -- Empaquetar la representación para que ocupe 1 byte

   type Robot is
      record
         Actuadores : Actuador_Robot; -- Para mover los motores
         Sensores   : Sensor_Robot;   -- Para pulsos y finales de carrera
      end record;

   Robot_Sim : Robot;   -- Objeto que representa al robot

   -- Para conversión de los tipos Actuador_Robot y Sensor_Robot desde y hacia Byte:
   function Byte_A_Actuador is
      new Unchecked_Conversion(Source => Byte,           Target => Actuador_Robot);
   function Actuador_A_Byte is
      new Unchecked_Conversion(Source => Actuador_Robot, Target => Byte);
   function Sensor_A_Byte is
      new Unchecked_Conversion(Source => Sensor_Robot,   Target => Byte);

   ----- Subprogramas exportados por Port_IO_Sim -----
   procedure Write_Low_Byte(Value : in Byte) is
   begin
      Robot_Sim.Actuadores := Byte_A_Actuador(Value);
   end Write_Low_Byte;

   function Read_Low_Byte return Byte is
   begin
      return Sensor_A_Byte(Robot_Sim.Sensores);
   end Read_Low_Byte;
   ---------------------------------------------------


   -- Contadores de pulsos de cada motor
   -- Los valores asignados representan el estado inicial del robot simulado
   C_Rotacion : Integer := P_Rotacion / 2;
   C_Fondo    : Integer := P_Fondo / 2;
   C_Altura   : Integer := P_Altura / 2;
   C_Pinza    : Integer := P_Pinza / 2;

   -- For controlling forced articulations
   Forced_Limit: constant := 16; -- Nr of edges to consider axis forced
   type Axes is (Rotation, Forward, Height, Clamp);
   Forced_Count: array (Axes) of Natural := (others => 0);
   pragma Atomic_Components(Forced_Count);
   Forced: array (Axes) of Boolean := (others => False);
   pragma Atomic_Components(Forced);

   -- Tarea que simula el estado del robot de acuerdo al valor de los actuadores
   task Simulador is
      pragma Priority (System.Priority'Last);   -- Ojo: no hay mecanismo de protección para el estado, aparte de este
   end Simulador;

   task body Simulador is
      Siguiente_Activacion : Time;
   begin
      --delay 3.0;
      Siguiente_Activacion := Clock;
      loop
         -- Hay que interpretar el valor de Actuadores para simular lo que haría el robot
         if Robot_Sim.Actuadores.M_Giro_Horario = 1 then     -- Si ROTACIÓN en sentido HORARIO
            if (C_Rotacion < P_Rotacion) then       -- Si no hemos llegado al final del recorrido
               if Robot_Sim.Sensores.Fc_Giro = 0 then -- Si estábamos en la posición de inicio,
                  Robot_Sim.Sensores.Fc_Giro := 1;    -- ...desactivar final de carrera de giro
               end if;
               Robot_Sim.Sensores.Paso_Giro := Robot_Sim.Sensores.Paso_Giro xor 1;  -- Simular pulso
               C_Rotacion := C_Rotacion + 1;        -- Incrementar contador de posición de rotación
            else
               Forced_Count(Rotation) := Forced_Count(Rotation) + 1;
               if Forced_Count(Rotation) > Forced_Limit then
                  Forced(Rotation) := True;
               end if;
            end if;
         end if;

         if Robot_Sim.Actuadores.M_Giro_Antihorario = 1 then  -- Si ROTACIÓN en sentido ANTIHORARIO
            if Robot_Sim.Sensores.Fc_Giro = 1 then    -- Si no estamos en el final de carrera
               Robot_Sim.Sensores.Paso_Giro := Robot_Sim.Sensores.Paso_Giro xor 1;  -- Simular pulso
               C_Rotacion := C_Rotacion - 1;        -- Decrementar contador de posición de rotación
               if (C_Rotacion = 0) then             -- Si llegamos al inicio,
                  Robot_Sim.Sensores.Fc_Giro := 0;    -- ...activar final de carrera
               end if;
            else
               Forced_Count(Rotation) := Forced_Count(Rotation) + 1;
               if Forced_Count(Rotation) > Forced_Limit then
                  Forced(Rotation) := True;
               end if;
            end if;
         end if;

         if Robot_Sim.Actuadores.M_Fondo_Avance = 1 then  -- Si FONDO en sentido AVANCE
            if Robot_Sim.Sensores.Fc_Fondo = 0 then  -- Si estábamos en la posición de inicio,
               Robot_Sim.Sensores.Fc_Fondo := 1;     -- ...ya no
            end if;
            if (C_Fondo < P_Fondo) then            -- Si no hemos llegado al final
               Robot_Sim.Sensores.Paso_Fondo := Robot_Sim.Sensores.Paso_Fondo xor 1;  -- Simular pulso
               C_Fondo := C_Fondo + 1;             -- Incrementar contador de posición de fondo
            else
               Forced_Count(Forward) := Forced_Count(Forward) + 1;
               if Forced_Count(Forward) > Forced_Limit then
                  Forced(Forward) := True;
               end if;
            end if;
         end if;

         if Robot_Sim.Actuadores.M_Fondo_Retroceso = 1 then -- Si FONDO en sentido RETROCESO
            if Robot_Sim.Sensores.Fc_Fondo /= 0 then -- Si no estamos al final
               Robot_Sim.Sensores.Paso_Fondo := Robot_Sim.Sensores.Paso_Fondo xor 1;  -- Simular pulso
               C_Fondo := C_Fondo - 1;             -- Decrementar contador de posición de fondo
               if (C_Fondo = 0) then               -- Si llegamos al inicio,
                  Robot_Sim.Sensores.Fc_Fondo := 0;  -- ...simular activación del final de carrera de fondo
               end if;
            else
               Forced_Count(Forward) := Forced_Count(Forward) + 1;
               if Forced_Count(Forward) > Forced_Limit then
                  Forced(Forward) := True;
               end if;
            end if;
         end if;

         if Robot_Sim.Actuadores.M_Altura_Subir = 1 then    -- Si ALTURA en sentido SUBIR
            if Robot_Sim.Sensores.Fc_Altura /= 0 then -- Si no estamos al final de carrera
               Robot_Sim.Sensores.Paso_Altura := Robot_Sim.Sensores.Paso_Altura xor 1;  -- Simular pulso
               C_Altura := C_Altura - 1;            -- Decrementar contador de posición de altura
               if (C_Altura = 0) then               -- Si llegamos al inicio,
                  Robot_Sim.Sensores.Fc_Altura := 0;  -- ...simular activación del final de carrera de altura
               end if;
            else
               Forced_Count(Height) := Forced_Count(Height) + 1;
               if Forced_Count(Height) > Forced_Limit then
                  Forced(Height) := True;
               end if;
            end if;
         end if;

         if Robot_Sim.Actuadores.M_Altura_Bajar = 1 then    -- Si ALTURA en sentido BAJAR
            if Robot_Sim.Sensores.Fc_Altura = 0 then  -- Si estábamos en la posición de inicio,
               Robot_Sim.Sensores.Fc_Altura := 1;     -- ...desactivamos final de carrera de altura
            end if;
            if (C_Altura < P_Altura) then           -- Si no hemos llegado al final
               Robot_Sim.Sensores.Paso_Altura := Robot_Sim.Sensores.Paso_Altura xor 1;  -- Simular pulso
               C_Altura := C_Altura + 1;            -- Incrementar contador de posición de altura
            else
               Forced_Count(Height) := Forced_Count(Height) + 1;
               if Forced_Count(Height) > Forced_Limit then
                  Forced(Height) := True;
               end if;
            end if;
         end if;

         if Robot_Sim.Actuadores.M_Pinza_Cerrar = 1 then     -- Si PINZA en sentido CERRAR
            if Robot_Sim.Sensores.Fc_Pinza = 0 then   -- Si estábamos al final de carrera,
               Robot_Sim.Sensores.Fc_Pinza := 1;      -- ...desactivarlo
            end if;
            if (C_Pinza /= P_Pinza) then            -- Si no hemos llegado al final
               Robot_Sim.Sensores.Paso_Pinza := Robot_Sim.Sensores.Paso_Pinza xor 1;  -- Simular pulso
               C_Pinza := C_Pinza + 1;              -- Incrementar contador de posición de pinza
            else
               Forced_Count(Clamp) := Forced_Count(Clamp) + 1;
               if Forced_Count(Clamp) > Forced_Limit then
                  Forced(Clamp) := True;
               end if;
            end if;
         end if;

         if Robot_Sim.Actuadores.M_Pinza_Abrir = 1 then   -- Si PINZA en sentido Abrir
            if Robot_Sim.Sensores.Fc_Pinza /= 0 then   -- Si no hemos llegado al inicio
               Robot_Sim.Sensores.Paso_Pinza := Robot_Sim.Sensores.Paso_Pinza xor 1;  -- Simular pulso
               C_Pinza := C_Pinza - 1;               -- Decrementar contador de posición de pinza
               if (C_Pinza = 0) then                 -- Si hemos llegado al inicio,
                  Robot_Sim.Sensores.Fc_Pinza := 0;    -- ...activamos el final de carrera de pinza
               end if;
            else
               Forced_Count(Clamp) := Forced_Count(Clamp) + 1;
               if Forced_Count(Clamp) > Forced_Limit then
                  Forced(Clamp) := True;
               end if;
            end if;
         end if;

         Siguiente_Activacion := Siguiente_Activacion + Periodo_De_Simulacion;
         delay until Siguiente_Activacion;
      end loop;
   end Simulador;



   -- Tarea que muestra el estado del robot en una Output_Window de Win_IO

   task Muestreador is
      pragma Priority(System.Priority'First); -- Prioridad menor que la de la tarea de simulacion
   end Muestreador;

task body Muestreador is
   function To_Binary_String(B: in Byte) return String is -- Convierte Byte a String en binario
      S : String(1..8);
      My_B : Byte := B;
   begin
      for I in 1..8 loop
         if (My_B and 1) = 1 then
            S(8-I+1) := '1';
         else
            S(8-I+1) := '0';
         end if;
         My_B := My_B / 2;
      end loop;
      return S;
   end To_Binary_String;

   Display : Output_Window_Type := Output_Window("Robot state");
   Message : Message_Window_Type;
   Periodo_Muestreo : Time_Span := Periodo_De_Simulacion * 8;
   Proximo_Muestreo : Time := Clock;
begin
   --Create_Box(Display,"Sim period", Float(To_Duration(Periodo_De_Simulacion)));
   Create_Box(Display,"Rotation",C_Rotacion);
   Create_Box(Display,"Forward",C_Fondo);
   Create_Box(Display,"Height",C_Altura);
   Create_Box(Display,"Clamp",C_Pinza);
   Create_Box(Display,"Sensors",To_Binary_String(Sensor_A_Byte(Robot_Sim.Sensores)));
   Create_Box(Display,"Actuators",To_Binary_String(Actuador_A_Byte(Robot_Sim.Actuadores)));
   Draw(Display);
   loop
      Update_Box(Display,"Rotation",C_Rotacion);
      Update_Box(Display,"Forward",C_Fondo);
      Update_Box(Display,"Height",C_Altura);
      Update_Box(Display,"Clamp",C_Pinza);
      Update_Box(Display,"Sensors",To_Binary_String(Sensor_A_Byte(Robot_Sim.Sensores)));
      Update_Box(Display,"Actuators",To_Binary_String(Actuador_A_Byte(Robot_Sim.Actuadores)));
      Draw(Display);
      for I in Axes loop
         if Forced (I) then
            Message := Message_Window(Axes'Image(I)&" axis forced!");
            Wait(Message);
            Forced(I) := False;
            Forced_Count(I) := 0;
         end if;
      end loop;
      Proximo_Muestreo := Proximo_Muestreo + Periodo_Muestreo;
      delay until Proximo_Muestreo;
   end loop;
end Muestreador;

end Digital_Io_Sim;
