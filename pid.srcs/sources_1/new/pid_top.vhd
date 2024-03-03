----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.02.2024 18:03:55
-- Design Name: 
-- Module Name: pwm_decod - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pid_top is
 Generic(
  TIMES: integer range 1 to 100 := 100;
  SIZE: integer range 10 to 12 := 10;
  Kp : real range 0.0 to 255.0 := 0.0; --constante proporcional del PID
    Ki : real range 0.0 to 255.0 := 0.0; --constante integral del PID
    Kd : real range 0.0 to 255.0 := 0.0; --constante derivativa del PID
    T : real := 10.0E-9
  );
  Port ( 
    CLK:    in std_logic;
    RESET:  in std_logic;
    A, B, C : in std_logic;
    SETVAL: in integer; --Valor de establecimiento 
    sensVal : in INTEGER; -- valor de realimentación recibido por el sensor
    PID_OUT : out  STD_LOGIC_VECTOR (SIZE-1 downto 0); -- salida del PID    
    RPM : out INTEGER   
  );
end pid_top;

architecture Behavioral of pid_top is

COMPONENT pid_gen
Generic (
    SIZE: integer range 10 to 12 := 10;
    Kp : real range 0.0 to 255.0 := 0.0; --constante proporcional del PID
    Ki : real range 0.0 to 255.0 := 0.0; --constante integral del PID
    Kd : real range 0.0 to 255.0 := 0.0; --constante derivativa del PID
    T : real := 10.0E-9;
    valSat : integer := 1000 -- valor saturación motor para WINDUP
    );
Port ( 
    CLK_PID : in STD_LOGIC; --senial de reloj
    RESET: in STD_LOGIC; --reset asíncrono
    SETVAL: in integer; --Valor de establecimiento 
    sensVal : in  INTEGER; -- valor de realimentación recibido por el sensor
    PID_OUT : out  STD_LOGIC_VECTOR (SIZE-1 downto 0) -- salida del PID    
    );
END COMPONENT;

COMPONENT sample_counter
  Generic(
  TIMES: integer range 1 to 100:= 100
  );
  Port ( 
  CLK:  in std_logic;
  RESET: in std_logic;
  Enable: in std_logic;
  Flag: out std_logic
  );
END COMPONENT;

COMPONENT hall_sensor_top
Port ( 
    CLK : in STD_LOGIC;
    RESET : in STD_LOGIC;
    A, B, C : in STD_LOGIC;
    RPM : out INTEGER 
);
END COMPONENT;

signal sig_flag: std_logic;
signal sig_enable: std_logic := '1';
signal sig_sensor: std_logic_vector(19 downto 0);

begin

pid_gen_inst : pid_gen
    generic map (
        SIZE => SIZE,
        Kp => Kp,
        Ki => Ki,
        Kd => Kd,
        valSat => 1000
    )
    port map (
        CLK_PID => CLK,
        RESET => RESET,
        SETVAL => SETVAL,
        sensVal => sensVal,
        PID_OUT => PID_OUT
    );

sample_counter_inst : sample_counter
    generic map (
        TIMES => TIMES
    )
    port map (
        CLK => CLK,
        RESET => RESET,
        Enable => sig_enable,
        Flag => sig_flag
    );

hall_sensor_top_inst : hall_sensor_top
    port map (
        CLK => CLK,
        RESET => RESET,
        A => A,
        B => B,
        C => C,
        RPM => RPM
    );

end Behavioral;