---------------------------------------
--           Digital_IO              --
--                                   --
-- Interface to Fischertechnik robot --
--                                   --
-- Jorge Real                        --
---------------------------------------

with Low_Level_Types; use Low_Level_Types;

package Digital_IO is

   procedure Write_Low_Byte(Value: in Byte);
   --procedure Write_High_Byte(Value: in Byte);
   --procedure Write_Low_Word(Value: in Word);

   function Read_Low_Byte return Byte;
   --function Read_High_Byte return Byte;
   --function Read_High_Word return Word;

end Digital_IO;
