----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.02.2024 18:35:48
-- Design Name: 
-- Module Name: control_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_top is
  Generic(
    Frecuencies: integer range 1000 to 2500 := 1000;
    Duty_SIZE: integer range 10 to 12 := 10;
    TIMES: integer range 1 to 100 := 100;
    SIZE: integer range 10 to 12 := 10;
    Kp: integer range 0 to 255 := 0;
    Ki: integer range 0 to 255 := 0;
    Kd: integer range 0 to 255 := 0
  );
  Port ( 
    CLK : in std_logic;
    RESET : in std_logic;
    A, B, C : in std_logic;
    Duty : in std_logic_vector(Duty_SIZE-1 downto 0);
    SETVAL: in integer;
    sensVal : in std_logic_vector(SIZE-1 downto 0);
    PID_OUT : out std_logic_vector(SIZE-1 downto 0);
    RPM : out REAL;
    PWM_AH,PWM_BH,PWM_CH: out std_logic;
    PWM_AL,PWM_BL,PWM_CL: out std_logic;
    PWM_HIGH    : out std_logic;
    PWM_LOW     : out std_logic;
    ERROR      : out std_logic
  );
end control_top;

architecture Behavioral of control_top is

  -- Instancias de las entidades
  component pwm_top is
    Generic(
      Frecuencies: integer range 1000 to 2500 := 1000;
      Duty_SIZE: integer range 10 to 12 := 10
    );
    Port ( 
      CLK : in std_logic;
      RESET : in std_logic;
      Duty : in std_logic_vector(Duty_SIZE-1 downto 0);
      A, B, C : in std_logic;
      PWM_AH,PWM_BH,PWM_CH: out std_logic;
      PWM_AL,PWM_BL,PWM_CL: out std_logic;
      PWM_HIGH    : out std_logic;
      PWM_LOW     : out std_logic;
      ERROR      : out std_logic
    );
  end component;

  component pid_top is
    Generic(
      TIMES: integer range 1 to 100 := 100;
      SIZE: integer range 10 to 12 := 10;
      Kp: integer range 0 to 255 := 0;
      Ki: integer range 0 to 255 := 0;
      Kd: integer range 0 to 255 := 0
    );
    Port ( 
      CLK:    in std_logic;
      RESET:  in std_logic;
      A, B, C : in std_logic;
      SETVAL: in integer; -- Valor de establecimiento 
      sensVal : in  STD_LOGIC_VECTOR (SIZE-1 downto 0); -- Valor de realimentación recibido por el sensor
      PID_OUT : out  STD_LOGIC_VECTOR (SIZE-1 downto 0); -- Salida del PID    
      RPM : out REAL;
      ERROR:  out std_logic
    );
  end component;

begin

  -- Instanciación de las entidades
  pwm_inst: pwm_top
    generic map(
      Frecuencies => Frecuencies,
      Duty_SIZE => Duty_SIZE
    )
    port map(
      CLK => CLK,
      RESET => RESET,
      Duty => Duty,
      A => A,
      B => B,
      C => C,
      PWM_AH => PWM_AH,
      PWM_BH => PWM_BH,
      PWM_CH => PWM_CH,
      PWM_AL => PWM_AL,
      PWM_BL => PWM_BL,
      PWM_CL => PWM_CL,
      PWM_HIGH => PWM_HIGH,
      PWM_LOW => PWM_LOW,
      ERROR => ERROR
    );

  pid_inst: pid_top
    generic map(
      TIMES => TIMES,
      SIZE => SIZE,
      Kp => Kp,
      Ki => Ki,
      Kd => Kd
    )
    port map(
      CLK => CLK,
      RESET => RESET,
      A => A,
      B => B,
      C => C,
      SETVAL => SETVAL,
      sensVal => sensVal,
      PID_OUT => PID_OUT,
      RPM => RPM,
      ERROR => ERROR
    );

end Behavioral;