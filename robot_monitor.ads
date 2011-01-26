with System;

package Robot_Monitor is

   type Position is
      record
         Rotation,
         Forward,
         Height,
         Clamp: Natural := 0;
      end record;

   protected Robot_Mon is
      pragma Priority(System.Priority'Last-1);
      function Get_Pos return Position;
      function Get_Init return Boolean;
      procedure Reset;
      procedure Set_Pos (P : in Position);
      procedure Print_Pos (P : in Position);
   private
      initialized: Boolean := false;
      Pos: Position;
   end Robot_Mon;

   -- Added for positioning the robot
   procedure Move_Robot_To (P: in Position);

private

   task Robot_Sampler is
      pragma Priority(System.Priority'Last-1);
   end Robot_Sampler;

   task Positioner is
      pragma Priority(System.Priority'Last - 2);
      entry Move_Robot_To (P: in Position);
   end Positioner;

end Robot_Monitor;
