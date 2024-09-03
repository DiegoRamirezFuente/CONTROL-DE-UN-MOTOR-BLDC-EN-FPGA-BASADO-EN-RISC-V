----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.02.2024 19:58:07
-- Design Name: 
-- Module Name: pwm_top - Behavioral
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

entity pwm_top is
Generic(
    Frecuencies: integer range 1000 to 2500:= 2000; --Valor de la frecuencia Frecuencies : range 1000 to 4800:= 4800;
    SIZE: integer range 1 to 16:=16 --tamanio en bits  SIZE: integer range 8 to 16:=13
);
  Port ( 
    CLK : in std_logic;
    RESET : in std_logic;
    --DUTY : in INTEGER;
    A, B, C : in std_logic;
    --PWM_AH,PWM_BH,PWM_CH: out std_logic;
    --PWM_AL,PWM_BL,PWM_CL: out std_logic;
    --PWM_HIGH    : out std_logic;
    --PWM_LOW     : out std_logic;
    PWM_AH, PWM_BH, PWM_CH : out std_logic;
    EN1, EN2, EN3 : out std_logic;
    DUTY : in INTEGER;
    ESTADO : out std_logic_vector(5 downto 0);
    ERROR      : out std_logic
);
end pwm_top;

architecture Behavioral of pwm_top is

COMPONENT pwm_decod
Generic(
    DELAY: integer range 4 to 10 := 4
);
Port(
    CLK : in std_logic;
	RESET : in std_logic;
    A, B, C : in std_logic;
    PWM_IN_H : in std_logic;
    --PWM_IN_L : in std_logic;
    PWM_AH,PWM_BH,PWM_CH: out std_logic;
    --PWM_AL,PWM_BL,PWM_CL: out std_logic;
    ESTADO : out std_logic_vector(5 downto 0);
    ERROR : out std_logic
);
END COMPONENT;

COMPONENT pwm_gen
Generic (
    FREC : integer range 1000 to 2500:= 1000; --Valor de la frecuencia FREC : integer range 1000 to 4800:= 4800;
    SIZE: integer range 1 to 16:=16 --tamanio en bits  SIZE: integer range 8 to 16:=13
);
Port (
    CLK : in STD_LOGIC; --reloj de la placa
    RESET : in STD_LOGIC; --reset negado asíncrono
    DUTY : in INTEGER; --salida del PID
    PWM_OUT : out STD_LOGIC  
 );
END COMPONENT;


--signal sig_pwmh,sig_pwml : std_logic;
signal PWM_OUT : std_logic;

begin

uut_PWM_Generator: pwm_gen 
GENERIC MAP(
    FREC => Frecuencies,
    SIZE => SIZE
)
PORT MAP(
  CLK => CLK,
  RESET  => RESET,
  DUTY => DUTY,
  --PWM_H => sig_pwmh,
  --PWM_L => sig_pwml,
  PWM_OUT => PWM_OUT
);

uut_pwm_decod: pwm_decod PORT MAP(
    CLK =>CLK,
	RESET => RESET,
    A => A,
    B => B,
    C => C,
    PWM_IN_H => PWM_OUT,
    PWM_AH => PWM_AH,
    PWM_BH => PWM_BH,
    PWM_CH => PWM_CH,
    --PWM_AL => EN1,
    --PWM_BL => EN2,
    --PWM_CL => EN3,
    ESTADO => ESTADO,
    ERROR => ERROR
);

end Behavioral;