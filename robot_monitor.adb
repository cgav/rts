with Ada.Real_Time; use Ada.Real_Time;
with Digital_IO_Sim; use Digital_IO_Sim;
with Ada.Text_IO;     use Ada.Text_IO;
with Low_Level_Types; use Low_Level_Types;
with Robot_Interface; use Robot_Interface;
with System;

package body Robot_Monitor is

   Sampler_period: constant Time_span := Microseconds(5000);
   Positioner_period: constant Time_span :=Milliseconds(8);

   protected body Robot_Mon is
      function Get_Pos return Position is
      begin
         return Pos;
      end Get_Pos;

      function Get_Init return Boolean is
      begin
         return Initialized;
      end Get_Init;

      procedure Reset is
      begin
         Move_Robot(Rotate_CCW);
         while( Robot_State and Rotation_Init) /= 0 loop
            null;
         end loop;

         Move_Robot(Forward_Back);
         while( Robot_State and Forward_Init) /= 0 loop
            null;
         end loop;

         Move_Robot(Height_Up);
         while( Robot_State and Height_Init) /= 0 loop
            null;
         end loop;

         Move_Robot(Clamp_Open);
         while( Robot_State and Clamp_Init) /= 0 loop
            null;
         end loop;

         Move_Robot(Stop_All);

         Pos := (0,0,0,0);
         Initialized:=True;
      end Reset;

      procedure Set_Pos (P : in Position) is
      begin
         Pos := P;
      end Set_Pos;

      procedure Print_Pos (P : in Position)is
      begin
	 Put_Line("-------------------------------------------------");
         Put_Line("Position of robot");
	 Put_Line("-------------------------------------------------");
         Put_Line("Rotation: " & Integer'Image(P.Rotation));
         Put_Line("Forward:  " & Integer'Image(P.Forward));
         Put_Line("Height:   " & Integer'Image(P.Height));
         Put_Line("Clamp:    " & Integer'Image(P.Clamp));
	 Put_Line("");
      end Print_Pos;

   end Robot_Mon;

   -- Added for positioning the robot
   procedure Move_Robot_To (P: in Position) is
   begin
      Positioner.Move_Robot_To(P);
   end Move_Robot_To;

   -- Counts the movemnt of the robot and stores the the Position in P1
   task body Robot_Sampler is
      P1: Position;
      Next: Time:=Clock;
      State_prev: Byte:=Robot_State;
      State_next: Byte;
      Command: Byte;
   begin

      while Robot_Mon.Get_Init = false loop
         Next:=Next+Sampler_Period;
         delay until Next;
      end loop;
      Put_Line("Robot is at initial position: starting to monitor");

      loop
         Command:= Robot_Command;
         P1:=Robot_Mon.Get_Pos;
         State_next:=Robot_State;

         if (State_prev and Rotation_Pulse) /= (State_next and Rotation_Pulse) then
            if (Rotate_CCW and Command)/=0 then
               P1.Rotation:=P1.Rotation-1;
            elsif (Rotate_CW and Command)/=0 then
               P1.Rotation:=P1.Rotation+1;
            end if;
         end if;

         if (State_prev and Forward_Pulse) /= (State_next and Forward_Pulse) then
            if (Forward_Back and Command)/=0 then
               P1.Forward:=P1.Forward-1;
            elsif (Forward_Front and Command)/=0 then
               P1.Forward:=P1.Forward+1;
            end if;
         end if;

         if (State_prev and Height_Pulse) /= (State_next and Height_Pulse) then
            if (Height_Up and Command)/=0 then
               P1.Height:=P1.Height-1;
            elsif (Height_Down and Command)/=0 then
               P1.Height:=P1.Height+1;
            end if;
         end if;

         if (State_prev and Clamp_Pulse) /= (State_next and Clamp_Pulse) then
            if (Clamp_Open and Command)/=0 then
               P1.Clamp:=P1.Clamp-1;
            elsif (Clamp_Close and Command)/=0 then
               P1.Clamp:=P1.Clamp+1;
            end if;
         end if;

         State_prev:=State_next;
         Robot_Mon.Set_Pos(P1);
         Next:=Next+Sampler_Period;
         delay until Next;
      end loop;

   end Robot_Sampler;

   task body Positioner is
      Target_Pos: Position;
      Act_Pos: Position;
      Com: Byte;
      Next: Time;
   begin
      loop
         accept Move_Robot_To(P: in Position) do
            Target_Pos:=P;
            Next := Clock;
         Act_Pos:=Robot_Mon.Get_Pos;
         Com:= Stop_All;
         while (Robot_Mon.Get_Pos/=Target_Pos) loop
            Com:= Stop_All;

            if (Target_Pos.Rotation > Act_Pos.Rotation) then
               Com:=(Com or Rotate_CW);
            elsif (Target_Pos.Rotation < Act_Pos.Rotation) then
               Com:=(Com or Rotate_CCW);
            end if;

            if (Target_Pos.Forward > Act_Pos.Forward) then
               Com:=(Com or Forward_Front);
            elsif (Target_Pos.Forward < Act_Pos.Forward) then
               Com:=(Com or Forward_Back);
            end if;

            if (Target_Pos.Height > Act_Pos.Height) then
               Com:=(Com or Height_Down);
            elsif (Target_Pos.Height < Act_Pos.Height) then
               Com:=(Com or Height_Up);
            end if;

            if (Target_Pos.Clamp > Act_Pos.Clamp) then
               Com:=(Com or Clamp_close);
            elsif (Target_Pos.Clamp < Act_Pos.Clamp) then
               Com:=(Com or Clamp_open);
            end if;

            Move_Robot(Com);

            Next:=Next+Positioner_period;

            delay until Next;
            Act_pos:=robot_Mon.Get_Pos;

         end loop;

         Move_Robot(Stop_All);
         end Move_Robot_To;

      end loop;

   end Positioner;

end Robot_Monitor;
