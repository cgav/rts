with Ada.Text_IO; use Ada.Text_IO;
with Robot_Interface; use Robot_Interface;
with Low_Level_Types; use Low_Level_Types;

package body Hanoi_Environment is

   function Get_Pos(I : in Integer) return Position is
   begin
      return Locations(I);
   end Get_Pos;

  procedure Set_Pos(I : in Integer; Loc : in Position) is
  begin
    Locations(I) := Loc;
  end Set_Pos;

   function Get_Column_Index(I: in Natural) return Natural is
   begin
      return Column_Counter(I);
   end Get_Column_Index;

   procedure Set_Column_Index(I: in Natural; Value: in Natural) is
   begin
      Column_Counter(I) := Value;
   end Set_Column_Index;

   procedure Inc_Column_Index(I: in Natural) is
   begin
    Column_Counter(I) := Column_Counter(I) + 1;
  end Inc_Column_Index;

   procedure Dec_Column_Index(I: in Natural) is
   begin
    Column_Counter(I) := Column_Counter(I) - 1;
  end Dec_Column_Index;



  procedure Hanoi_To(To: in Natural; Plate : in Boolean) is
     Pos : Position;
     Rot_Height : constant Integer := 20;
  begin

     -- grab plate
     Pos := Robot_Mon.Get_Pos;
     if Plate = true then
        Pos.Clamp := clamp_closed;
        Dec_Column_Index(pos_index);
        Inc_Column_Index(To);
     else
        Pos.Clamp := clamp_opened;
     end if;
     Move_Robot_To(Pos);

    -- move up
    Pos.Height := Rot_Height;
    Move_Robot_To(Pos);

    -- go to new position, keep height and clamp state
    Pos := Get_Pos(To);
    Pos.Height := Robot_Mon.Get_Pos.Height;
    Pos.Clamp := Robot_Mon.Get_Pos.Clamp;
    Move_Robot_To(Pos);
    pos_index := To;

    -- move down
    Pos.Height := Get_Pos(To).Height - (Get_Column_Index(To)-1) * height;
    Move_Robot_To(Pos);


   end Hanoi_To;


end Hanoi_Environment;
