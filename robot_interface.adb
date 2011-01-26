with Digital_IO_Sim; use Digital_IO_Sim;
with System;

package body Robot_Interface is

   protected Robot is
      pragma Priority(System.Priority'Last-1);
      procedure Move_Robot (Command: in Byte);
      function Robot_State return Byte;
      function Current_Command return Byte;
   private
      Last_Command_Applied: Byte := 0;
   end Robot;

   protected body Robot is
      procedure Move_Robot (Command : in Byte) is
      begin
         Last_Command_Applied := Command;
         Write_Low_Byte(Command);
      end Move_Robot;

      function Robot_State return Byte is
      begin
         return Read_Low_Byte;
      end Robot_State;
      function Current_Command return Byte is
      begin
         return Last_Command_Applied;
      end Current_Command;
   end Robot;



   ----------------
   -- Move_Robot --
   ----------------
   procedure Move_Robot (Command: in Byte) is
   begin
      Robot.Move_Robot(Command);
   end Move_Robot;


   -----------------
   -- Robot_State --
   -----------------
   function Robot_State return Byte is
   begin
      return Robot.Robot_State;
   end Robot_State;

   -------------------
   -- Robot_Command --
   -------------------
   function Robot_Command return Byte is
   begin
      return Robot.Current_Command;
   end Robot_Command;


end Robot_Interface;
