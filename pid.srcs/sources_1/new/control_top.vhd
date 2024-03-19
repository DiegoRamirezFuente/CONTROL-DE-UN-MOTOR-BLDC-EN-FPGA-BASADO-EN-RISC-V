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
    SIZE: integer range 10 to 15 := 13;
    TIMES: integer range 1 to 100 := 100;
    Kp : real range 0.0 to 255.0 := 0.0; --constante proporcional del PID
    Ki : real range 0.0 to 255.0 := 0.0; --constante integral del PID
    Kd : real range 0.0 to 255.0 := 0.0; --constante derivativa del PID
    T : real := 10.0E-9
  );
  Port ( 
    CLK : in std_logic;
    RESET : in std_logic;
    A, B, C : in std_logic;
    SETVAL: in STD_LOGIC_VECTOR (SIZE-1 downto 0);
    sensVal :STD_LOGIC_VECTOR (SIZE-1 downto 0);
    PID_OUT : out std_logic_vector(SIZE-1 downto 0);
    PWM_AH,PWM_BH,PWM_CH: out std_logic;
    PWM_AL,PWM_BL,PWM_CL: out std_logic;
    PWM_HIGH    : out std_logic;
    PWM_LOW     : out std_logic;
    v_sal : OUT std_logic_vector(7 DOWNTO 0);
    segment : OUT std_logic_vector(6 DOWNTO 0);
    ERROR      : out std_logic
  );
end control_top;

architecture Behavioral of control_top is

  -- Instancias de las entidades
  
  COMPONENT Filter_HALL 
  Generic(
  Delay: integer:= 10      -- Delay*10^3
  );
  Port ( 
  CLK: in std_logic;
  INPUT: in std_logic;
  OUTPUT: out std_logic
  );
END COMPONENT;
  
  component pwm_top is
    Generic(
      Frecuencies: integer range 1000 to 2500 := 1000;
      PWM_SIZE: integer range 10 to 15 := 13
    );
    Port ( 
      CLK : in std_logic;
      RESET : in std_logic;
      Duty : in std_logic_vector(PWM_SIZE-1 DOWNTO 0);
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
      PID_SIZE: integer range 10 to 15 := 13;
      Kp : real range 0.0 to 255.0 := 0.0; --constante proporcional del PID
      Ki : real range 0.0 to 255.0 := 0.0; --constante integral del PID
      Kd : real range 0.0 to 255.0 := 0.0; --constante derivativa del PID
      T : real := 10.0E-9
    );
    Port ( 
      CLK:    in std_logic;
      RESET:  in std_logic;
      A, B, C : in std_logic;
      SETVAL: in STD_LOGIC_VECTOR (PID_SIZE-1 downto 0); -- Valor de establecimiento 
      sensVal : in  STD_LOGIC_VECTOR (PID_SIZE-1 downto 0); -- Valor de realimentación recibido por el sensor
      PID_OUT : out  STD_LOGIC_VECTOR (PID_SIZE-1 downto 0); -- Salida del PID    
      RPM : out STD_LOGIC_VECTOR (PID_SIZE-1 downto 0)
    );
  end component;

COMPONENT top_display
 Generic(SIZE : integer range 10 to 15 := 13);
 PORT ( 
 clk_disp:in std_logic;
 reset_disp:in std_logic;
 input : in  std_logic_vector(SIZE-1 DOWNTO 0);
 v_sal : OUT std_logic_vector(7 DOWNTO 0);
 segment : OUT std_logic_vector(6 DOWNTO 0)
 );
END COMPONENT;

signal feedback : std_logic_vector(SIZE-1 DOWNTO 0);
signal As,Bs,Cs: std_logic;

begin

  -- Instanciación de las entidades
  
      uut1_Filter: Filter_HALL PORT MAP(
      CLK       =>CLK,
      INPUT     =>A,
      OUTPUT    =>As
    );
    uut2_Filter: Filter_HALL PORT MAP(
      CLK       =>CLK,
      INPUT     =>B,
      OUTPUT    =>Bs
    );
    uut3_Filter: Filter_HALL PORT MAP(
      CLK       =>CLK,
      INPUT     =>C,
      OUTPUT    =>Cs
    );
  
  pwm_inst: pwm_top
    generic map(
      Frecuencies => Frecuencies,
      PWM_SIZE => SIZE
    )
    port map(
      CLK => CLK,
      RESET => RESET,
      Duty => feedback,
      A => As,
      B => Bs,
      C => Cs,
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
      PID_SIZE => SIZE,
      Kp => Kp,
      Ki => Ki,
      Kd => Kd
    )
    port map(
      CLK => CLK,
      RESET => RESET,
      A => As,
      B => Bs,
      C => Cs,
      SETVAL => SETVAL,
      sensVal => sensVal,
      PID_OUT => PID_OUT,
      RPM => feedback
      
    );
    
display:top_display
 Generic map(SIZE => SIZE)
 PORT MAP ( 
 clk_disp => CLK,
 reset_disp => RESET,
 input => feedback,
 v_sal => v_sal,
 segment => segment
 );

end Behavioral;