with System.Machine_Code; use System.Machine_Code;

package body Port_Io_Linux is

   function Port_In(Port : in Word) return Byte is
      Tmp : Byte;
   begin
      Asm ("inb %%dx, %0",
           Byte'Asm_Output ("=a", Tmp),
           Word'Asm_Input  ("d",  Port));
      return Tmp;
   end Port_In;
   pragma Inline (Port_In);

   procedure Port_Out(Port : in Word; Data : in Byte) is
   begin
      Asm ("outb %0, %%dx",
           No_Output_Operands,
           (Byte'Asm_Input ("a", Data),
            Word'Asm_Input ("d", Port)));
   end Port_Out;
   pragma Inline (Port_Out);

   -- This one is only for initialisation of the pakage
   procedure Get_IOPL;
   pragma Import(C,Get_IOPL,"get_iopl_3");
   pragma Linker_Options("get_iopl_3.o");

  begin
   Get_IOPL;
end Port_Io_Linux;
