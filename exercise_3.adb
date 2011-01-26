pragma Task_Dispatching_Policy(FIFO_Within_Priorities);
pragma Locking_Policy(Ceiling_Locking);

with Robot_Interface; use Robot_Interface;
with Robot_Monitor;   use Robot_Monitor;
with Ada.Text_IO;     use Ada.Text_IO;
with Low_Level_Types; use Low_Level_Types;

procedure Exercise_3 is
   Pos : Position;
begin
   delay 3.0; -- Needed to give time for Gtk windows to be createda

   Put_Line("ex3 started");
   Robot_Mon.Reset;

   Move_Robot(Rotate_CW);
   delay 3.0;
   Move_Robot(Stop_All);
   Pos := Robot_Mon.Get_Pos;
   Robot_Mon.Print_Pos(Pos);

   Put_Line("End of program.");
end Exercise_3;
