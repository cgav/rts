with Low_Level_Types; use Low_Level_Types;

package Port_IO_Linux is
   procedure Port_Out(Port : in Word; Data : in Byte);
   function Port_In(Port : in Word) return Byte;
end Port_IO_Linux;
