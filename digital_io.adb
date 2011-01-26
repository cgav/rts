---------------------------------------------------------------
--                      Digital_IO                           --
-- Interface to the digital IO card of the GEME PC-104 board --
--                                                           --
--                                                           --
-- Jorge Real                                                --
--                                                           --
---------------------------------------------------------------


with Port_IO_Linux;     use Port_IO_Linux;
with Interfaces;  use Interfaces;


package body Digital_Io is

   Base : Word := 16#300#; -- I/O address of the DIO card

   procedure Write_Low_Byte (Value: in Byte) is
   begin
      Port_Out(Base,Value);
   end Write_Low_Byte;

   function Read_Low_Byte return Byte is
   begin
      return Port_In(Base);
   end Read_Low_Byte;

end Digital_Io;
