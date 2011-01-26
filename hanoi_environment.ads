with Robot_Monitor; use Robot_Monitor;

package Hanoi_Environment is

  height : constant Integer;
  clamp_closed : constant Integer;
  clamp_opened : constant Integer;

   function Get_Pos(I : in Integer) return Position;
   procedure Set_Pos(I : in Integer; Loc : in Position);

   function Get_Column_Index(I: in Natural) return Natural;
   procedure Set_Column_Index(I: in Natural; Value: in Natural);
   procedure Inc_Column_Index(I: in Natural);
   procedure Dec_Column_Index(I: in Natural);

   procedure Hanoi_To(To: in Natural; Plate : in Boolean);

private

  height : constant Integer := 58;
  clamp_closed : constant Integer := 33;
  clamp_opened : constant Integer := 0;

   Locations: array (1..3) of Position :=
     (1=> ( 80,  37, 188, 40),
      2=> ( 117,  52, 197, 40),
      3=> ( 160,  100, 190, 40));
   Column_Counter: array (1..3) of Natural := ( 3, 0, 0);

   pos_index : Natural := 1;

end Hanoi_Environment;
