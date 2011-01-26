pragma Task_Dispatching_Policy(FIFO_Within_Priorities);
pragma Locking_Policy(Ceiling_Locking);

with Hanoi_Environment; use Hanoi_Environment;
with Ada.Text_IO; use Ada.Text_IO;
with Robot_Interface; use Robot_Interface;
with Robot_Monitor; use Robot_Monitor;

procedure Hanoi is
   Command : Character;
   myDelay : Duration := 0.04;
   More : Boolean;
   CurPos : Position;
begin
   Put_Line("Program started");

   Robot_Mon.Reset;

   loop
      Get_Immediate(Command);
      CurPos := Robot_Mon.Get_Pos;
      case Command is
         when  'a'      => --  Put("rot left");
            if (CurPos.Rotation > 0) then
               CurPos.Rotation := CurPos.Rotation -1;
               Move_Robot_To(CurPos);
               --Move_Robot(Rotate_CCW);
            else
               Put("DANGER");
            end if;
         when  'd'      => --  Put("rot right");
            if (CurPos.Rotation < 250) then
               CurPos.Rotation := CurPos.Rotation +1;
               Move_Robot_To(CurPos);
               --Move_Robot(Rotate_CW);
            else
               Put("DANGER");
            end if;
         when  'q'      => --  Put("up");
            if (CurPos.Height > 0) then
               CurPos.Height := CurPos.Height -1;
               Move_Robot_To(CurPos);
               --Move_Robot(Height_Up);
            else
               Put("DANGER");
            end if;
         when  'e'      => --  Put("down");
            if (CurPos.Height < 200) then
               CurPos.Height := CurPos.Height +1;
               Move_Robot_To(CurPos);
               --  Move_Robot(Height_Down);
            else
               Put("DANGER");
            end if;
         when  'w'      => --  Put("forward");
            if (CurPos.Forward < 130) then
               CurPos.Forward := CurPos.Forward +1;
               Move_Robot_To(CurPos);
               --  Move_Robot(Forward_Front);
            else
               Put("DANGER");
            end if;
         when  's'      => --  Put("backward");
            if (CurPos.Forward > 0) then
               CurPos.Forward := CurPos.Forward -1;
               Move_Robot_To(CurPos);
               --  Move_Robot(Forward_Back);
            else
               Put("DANGER");
            end if;
         when  'o'      => --  Put("open");
            if (CurPos.Clamp > 0) then
               CurPos.Clamp := CurPos.Clamp -1;
               Move_Robot_To(CurPos);
               --  Move_Robot(Clamp_Open);
            else
               Put("DANGER");
            end if;
         when  'c'      => --  Put("close");
            if (CurPos.Clamp < 36) then
               CurPos.Clamp := CurPos.Clamp +1;
               Move_Robot_To(CurPos);
               --  Move_Robot(Clamp_Close);
            else
               Put("DANGER");
            end if;
         when  '1'      =>
            Put("stored column 1 pos");
            Set_Pos(1,Robot_Mon.Get_Pos);
         when  '2'      =>
            Put("stored column 2 pos");
            Set_Pos(2,Robot_Mon.Get_Pos);
         when  '3'      =>
            Put("stored column 3 pos");
            Set_Pos(3,Robot_Mon.Get_Pos);
         when  '0'      =>
            Put("End of program");
            Robot_Mon.Print_Pos(Get_Pos(1));
            Robot_Mon.Print_Pos(Get_Pos(2));
            Robot_Mon.Print_Pos(Get_Pos(3));
            exit;
	 when '9' =>
	    exit;
         when  others =>
            null;
      end case;
      loop
         Get_Immediate(Command,More);
         exit when not More;
      end loop;

      delay MyDelay;
      Robot_Mon.Print_Pos(Robot_Mon.Get_Pos);
      --Move_Robot(Stop_All);
   end loop;



   --P3 from C1 to C2
      --
     ----
    ------
   -------- -------- --------
   Put_Line("P3 from C1 to C2");
   Hanoi_To(1,false);
   Hanoi_To(2,true);

   --P2 from C1 to C3
     ---
    -----     -
   ------- ------- -------
   Put_Line("P2 from C1 to C3");
   Hanoi_To(1,false);
   Hanoi_To(3,true);

   --P3 from C2 to C3
    ------     --      ----
   -------- -------- --------
   Put_Line("P3 from C2 to C3");
   Hanoi_To(2,false);
   Hanoi_To(3,true);
   --P1 from C1 to C2
                        --
    ------             ----
   -------- -------- --------
   Put_Line("P1 from C1 to C2");
   Hanoi_To(1,false);
   Hanoi_To(2,true);
   --P3 from C3 to C1
                        --
             ------    ----
   -------- -------- --------
   Put_Line("P3 from C3 to C1");
   Hanoi_To(3,false);
   Hanoi_To(1,true);

   --P2 from C3 to C2
      --     ------    ----
   -------- -------- --------
   Put_Line("P2 from C3 to C2");
   Hanoi_To(3,false);
   Hanoi_To(2,true);


   --P3 from C1 to C2
              ----
      --     ------
   -------- -------- --------
   Put_Line("P3 from C1 to C2");
   Hanoi_To(1,false);
   Hanoi_To(2,true);

               --
              ----
             ------
   -------- -------- --------
   Put_Line("Program finished");
end Hanoi;
