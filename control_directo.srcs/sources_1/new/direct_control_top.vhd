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
    PWM_SIZE: integer range 8 to 16:= 13;
    RPM_SIZE: integer range 8 to 16:= 8  
  );
  Port ( 
    CLK:          in std_logic; --senial de reloj
    RESET:        in std_logic; --reset asíncrono 
    EN1, EN2, EN3: out std_logic;
    A          : in std_logic;  --
    B          : in std_logic;  --seniales de salida del sensor hall sin filtrar
    C          : in std_logic;  --
    Duty : in INTEGER;
    switch : in std_logic_vector(2 downto 0);
    A_out       : out std_logic;   --
    B_out       : out std_logic;   --senial de salida del sensor hall filtrada
    C_out       : out std_logic;   --
    PWM_AH, PWM_BH, PWM_CH     : out std_logic;  
    PWM_AL, PWM_BL, PWM_CL     : out std_logic;
    PWM_HIGH    : out std_logic;
    PWM_LOW     : out std_logic; --senial de error en el sensor hall
    ERROR      : out std_logic;
    RPM_UART : out std_logic
  );
end direct_control_top;

architecture Behavioral of direct_control_top is

 COMPONENT pwm_top
    Generic(
      Frecuencies: integer range 1000 to 4800 := 4800;
      SIZE: integer range 8 to 16:= 13
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
Generic( SIZE: integer range 8 to 16:= 8);
Port ( 
    CLK : in STD_LOGIC;
    RESET : in STD_LOGIC;
    A, B, C : in STD_LOGIC;
    RPM : out std_logic_vector (SIZE-1 downto 0)
);
END COMPONENT;

COMPONENT frec_gen  
PORT  
( 
  CLK    : IN STD_LOGIC; 
  F_BASE    : IN INTEGER; 
  FREC_OUT  : OUT STD_LOGIC 
   
); 
END COMPONENT;

COMPONENT uart_tx IS
PORT ( 
  BAUD   : IN STD_LOGIC; 
  TxD_INICIO  : IN STD_LOGIC; 
  TxD_DATO  : IN STD_LOGIC_VECTOR (7 DOWNTO 0); 
  TxD  : OUT STD_LOGIC; 
  TxD_BUSY : OUT STD_LOGIC 
);    
END COMPONENT;

signal As,Bs,Cs: std_logic;
signal Duty_s: integer := 0;
signal rpm_s : std_logic_vector(RPM_SIZE-1 downto 0);

SIGNAL BAUD   : STD_LOGIC; 
SIGNAL TxD_INICIO  : STD_LOGIC; 
SIGNAL TxD_DATO  : STD_LOGIC_VECTOR (7 DOWNTO 0):= (OTHERS => '0'); 
SIGNAL TxD_OCUPADO : STD_LOGIC;
CONSTANT FREC_BAUD   : INTEGER :=2604*2;  
CONSTANT FREC_TxD_INICIO : INTEGER :=125000*2;

begin

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
generic map (SIZE => RPM_SIZE)
    port map (
        CLK => CLK,
        RESET => RESET,
        A => As,
        B => Bs,
        C => Cs,
        RPM => rpm_s
    );
    
    uu0_Top_PWM: pwm_top
GENERIC MAP(
    Frecuencies => PWM_Frecuencies,
    SIZE   => PWM_SIZE
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

frecuencia_baud : frec_gen 
PORT MAP (
    CLK => CLK,
    F_BASE => FREC_BAUD , 
    FREC_OUT => BAUD 
    ); 

frecuencia_transmision: frec_gen 
PORT MAP (
    CLK => CLK,
    F_BASE => FREC_TxD_INICIO , 
    FREC_OUT => TxD_INICIO
    );
    
PROCESS (CLK) BEGIN 
    IF CLK' EVENT AND CLK='1' THEN 
        IF TxD_OCUPADO = '0' THEN 
           TxD_DATO <= rpm_s; 
        END IF; 
    END IF; 
END PROCESS;

transmision_uart: uart_tx
port map ( 
  BAUD => BAUD,
  TxD_INICIO => TxD_INICIO,
  TxD_DATO => TxD_DATO,
  TxD => RPM_UART,
  TxD_BUSY => TxD_OCUPADO 
);    
    
Duty_s <= 65 when switch = "001" else
          400 when switch = "010" else
          1000 when switch = "100" else
          1800 when switch = "011" else
          2000 when switch = "111" else
          0;

--Salidas Hall Sensor--
A_out <= As;
B_out <= Bs;
C_out <= Cs;

EN1 <= '1';
EN2 <= '1';
EN3 <= '1';


--Proportional_s<="00000000" & Switch(7 downto 0);
--Duty_s(31 downto 10)<=(others=>'0');

--Duty_Led <= Duty;

--Set_Point_s <= std_logic_vector(to_unsigned(83333,20)) when Switch(10 downto 8) = "100" else
--               std_logic_vector(to_unsigned(125000,20)) when  Switch(10 downto 8)= "010"else
--               std_logic_vector(to_unsigned(166666,20)) when  Switch(10 downto 8) = "001"else
--               std_logic_vector(to_unsigned(125000,20));
          
end Behavioral;
