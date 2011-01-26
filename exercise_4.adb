pragma Task_Dispatching_Policy(FIFO_Within_Priorities);
pragma Locking_Policy(Ceiling_Locking);

with Robot_Interface; use Robot_Interface;
with Robot_Monitor;   use Robot_Monitor;
with Ada.Text_IO;     use Ada.Text_IO;

procedure Exercise_4 is
   Pos : Position;
   Target_Pos : array (1..4) of Position :=
     (1 => ( 10,  10,  10, 10), 2 => (  5,  50, 200, 20),
      3 => (300, 300, 300, 30), 4 => (111, 222, 333,  0));
begin
   Put_Line("Please, wait 3 seconds...");
   delay 3.0; -- Needed to give time for Gtk windows to be created
   Robot_Mon.Reset;
   for I in 1..4 loop
      Put_Line("Searching position:");
      Robot_Mon.Print_Pos(Target_Pos(I));
      New_Line;
      Move_Robot_To(Target_Pos(I));
      while Target_Pos(I) /= Robot_Mon.Get_Pos loop
         delay 0.5;
      end loop;
      Put_Line("Position reached:");
      Robot_Mon.Print_Pos (Robot_Mon.Get_Pos);
      New_Line;
      if I < 4 then
         delay 5.0; -- Pause between targets
      end if;
   end loop;
   Put_Line("End of program.");
end Exercise_4;
