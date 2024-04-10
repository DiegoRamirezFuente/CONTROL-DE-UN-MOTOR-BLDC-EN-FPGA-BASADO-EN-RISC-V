----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.03.2024 18:33:07
-- Design Name: 
-- Module Name: direct_control_top - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity direct_control_top is
  Generic(
    PWM_Frecuencies: integer range 1000 to 4800:= 4800;
    SIZE: integer range 10 to 15:= 13  
  );
  Port ( 
    CLK:          in std_logic; --senial de reloj
    RESET:        in std_logic; --reset asíncrono 
    A          : in std_logic;  --
    B          : in std_logic;  --seniales de salida del sensor hall sin filtrar
    C          : in std_logic;  --
    Duty : in INTEGER;
    --switch : in std_logic_vector(2 downto 0);
    A_out       : out std_logic;   --
    B_out       : out std_logic;   --senial de salida del sensor hall filtrada
    C_out       : out std_logic;   --
    PWM_AH, PWM_BH, PWM_CH     : out std_logic;  
    PWM_AL, PWM_BL, PWM_CL     : out std_logic;
    PWM_HIGH    : out std_logic;
    PWM_LOW     : out std_logic; --senial de error en el sensor hall
    ERROR      : out std_logic;
    RPM : out std_logic
    --RPM : out std_logic_vector(SIZE-1 downto 0)
  );
end direct_control_top;

architecture Behavioral of direct_control_top is

 COMPONENT pwm_top
    Generic(
      Frecuencies: integer range 1000 to 4800 := 4800;
      Duty_SIZE: integer range 10 to 15 := 13
    );
    Port ( 
      CLK : in std_logic;
      RESET : in std_logic;
      Duty : in INTEGER;
      A, B, C : in std_logic;
      PWM_AH,PWM_BH,PWM_CH: out std_logic;
      PWM_AL,PWM_BL,PWM_CL: out std_logic;
      PWM_HIGH    : out std_logic;
      PWM_LOW     : out std_logic;
      ERROR      : out std_logic
    );
  END COMPONENT;

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

COMPONENT hall_sensor_top
Generic( Duty_SIZE: integer range 10 to 15 := 13);
Port ( 
    CLK : in STD_LOGIC;
    RESET : in STD_LOGIC;
    A, B, C : in STD_LOGIC;
    RPM : out std_logic_vector (Duty_SIZE-1 downto 0)
);
END COMPONENT;

COMPONENT uart_tx IS
  generic(BITS       : positive := 10);
  port   (clk_i      : in  std_logic;
          rst_i      : in  std_logic; 
          dat_i      : in  std_logic_vector(BITS-1 downto 0);
          enviando_i : in  std_logic;
          dat_o      : out std_logic);   
END COMPONENT;


signal As,Bs,Cs: std_logic;
signal Duty_s: integer := 0;
signal HALL_s: std_logic_vector(SIZE-1 downto 0);
signal rpm_i_s : std_logic_vector(SIZE-1 downto 0);
signal rpm_o_s : std_logic;

begin

uu0_Top_PWM: pwm_top
GENERIC MAP(
    Frecuencies => PWM_Frecuencies,
    Duty_SIZE   => SIZE
)
PORT MAP(
    CLK => CLK,
    RESET => RESET,
    Duty => Duty,
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

hall_sensor_top_inst : hall_sensor_top
    port map (
        CLK => CLK,
        RESET => RESET,
        A => As,
        B => Bs,
        C => Cs,
        RPM => rpm_i_s
    );
    
transmision_uart: uart_tx
  generic map (
  BITS => SIZE
  )
  port map  (
        clk_i => CLK,
        rst_i => RESET, 
        dat_i => rpm_i_s,
        enviando_i => '1' ,
        dat_o  => RPM
        );
    
--Duty_s <= 65 when switch = "001" else
--          400 when switch = "010" else
--          1000 when switch = "100" else
--          1800 when switch = "011" else
--          2000 when switch = "111" else
--          0;

--Salidas Hall Sensor--
A_out <= As;
B_out <= Bs;
C_out <= Cs;

--A_PMOD<=As;
--B_PMOD<=Bs;
--C_PMOD<=Cs;

HALL_s(0) <= As;
HALL_s(1)<= Bs;
HALL_s(2)<= Cs;

--Proportional_s<="00000000" & Switch(7 downto 0);
--Duty_s(31 downto 10)<=(others=>'0');

--Duty_Led <= Duty;

--Set_Point_s <= std_logic_vector(to_unsigned(83333,20)) when Switch(10 downto 8) = "100" else
--               std_logic_vector(to_unsigned(125000,20)) when  Switch(10 downto 8)= "010"else
--               std_logic_vector(to_unsigned(166666,20)) when  Switch(10 downto 8) = "001"else
--               std_logic_vector(to_unsigned(125000,20));
          
end Behavioral;
