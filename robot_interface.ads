with Low_Level_Types; use Low_Level_Types;

package Robot_Interface is

   -- Available robot commands
   Rotate_CW     : constant Byte := 2#0000_0001#; -- Rotate clockwise
   Rotate_CCW    : constant Byte := 2#0000_0010#; -- Rotate counterclock wise
   Forward_Front : constant Byte := 2#0000_0100#; -- Forward to front
   Forward_Back  : constant Byte := 2#0000_1000#; -- Forward to back
   Height_Up     : constant Byte := 2#0001_0000#; -- Height up
   Height_Down   : constant Byte := 2#0010_0000#; -- Height down
   Clamp_Open    : constant Byte := 2#0100_0000#; -- Open clamp
   Clamp_Close   : constant Byte := 2#1000_0000#; -- Close clamp
   Stop_All      : constant Byte := 2#0000_0000#; -- Stop all motors

   -- Useful bit masks
   Rotation_Init  : constant Byte := 2#0000_0001#; -- Rotation axis in initial position
   Rotation_Pulse : constant Byte := 2#0000_0010#; -- Rotation pulse value
   Forward_Init   : constant Byte := 2#0000_0100#; -- Same for rest of axes
   Forward_Pulse  : constant Byte := 2#0000_1000#;
   Height_Init    : constant Byte := 2#0001_0000#;
   Height_Pulse   : constant Byte := 2#0010_0000#;
   Clamp_Init     : constant Byte := 2#0100_0000#;
   Clamp_Pulse    : constant Byte := 2#1000_0000#;
   Stop_Rotation  : constant Byte := 2#1111_1100#; -- Mask to stop rotation motor
   Stop_Forward   : constant Byte := 2#1111_0011#; -- Mask to stop forward motor
   Stop_Height    : constant Byte := 2#1100_1111#; -- Mask to stop height motor
   Stop_Clamp     : constant Byte := 2#0011_1111#; -- Mask to stop clamp motor


   -- Procedure for issuing robot commands
   procedure Move_Robot (Command : in Byte);

   -- Function for querying robot state
   function Robot_State return Byte;

   -- Function for querying current command
   function Robot_Command return Byte;

end Robot_Interface;
