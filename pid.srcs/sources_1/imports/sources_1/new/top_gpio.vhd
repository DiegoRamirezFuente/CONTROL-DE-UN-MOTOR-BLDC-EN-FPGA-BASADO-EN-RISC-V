----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.06.2024 12:15:43
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_gpio is
    Generic(
        Frecuencies: integer range 1000 to 2500:= 2000; -- Valor de la frecuencia
        PIN_OUT : integer range 0 to 64 := 16;
        PIN_IN : integer range 0 to 64 := 40
        );
    Port (
        CLK : in std_logic;
        RESET : in std_logic;
        entrada : in std_ulogic_vector(PIN_IN-1 downto 0); -- Cambiado a std_ulogic_vector
        A, B, C : in std_logic;
        PWM_AH, PWM_BH, PWM_CH : out std_logic;
        EN1, EN2, EN3 : out std_logic;
        ESTADO : out std_logic_vector(5 downto 0);
        ERROR : out std_logic;
        digctrl : out std_logic_vector(7 downto 0);
        segment : out std_logic_vector(6 downto 0);
        medida : inout std_ulogic_vector(PIN_OUT-1 downto 0) -- Cambiado a std_ulogic_vector
    );
end top_gpio;

architecture Behavioral of top_gpio is

component top_display
    Generic(SIZE : integer := 16);
     PORT ( 
     clk_disp:in std_logic;
     reset_disp:in std_logic;
     input : in  std_ulogic_vector(SIZE-1 DOWNTO 0);
     v_sal : OUT std_logic_vector(7 DOWNTO 0);
     segment : OUT std_logic_vector(6 DOWNTO 0)
     );
   end component;
   
COMPONENT control_top
    Generic(
        Frecuencies: integer range 1000 to 2500:= 2000; -- Valor de la frecuencia
        FREC : integer := 10**8;
        SIZE_PWM: integer range 1 to 16:=16; -- Tamaño en bits para pwm_top
        SIZE_HALL: integer := 16 -- Tamaño en bits para hall_sensor_top
    );
    Port (
        CLK : in std_logic;
        RESET : in std_logic;
        Kp : in integer range 0 to 255 := 0; --constante proporcional del PID
        Ki : in integer range 0 to 255 := 0; --constante integral del PID
        Kd : in integer range 0 to 255 := 0; --constante derivativa del PID
        A, B, C : in std_logic;
        PWM_AH, PWM_BH, PWM_CH : out std_logic;
        EN1, EN2, EN3 : out std_logic;
        ESTADO : out std_logic_vector(5 downto 0);
        ERROR : out std_logic;
        SETVAL : in integer; -- valor de establecimiento
        digctrl : out std_logic_vector(7 downto 0);
        segment : out std_logic_vector(6 downto 0);
        medida : out std_ulogic_vector(PIN_OUT-1 downto 0)
    );
END COMPONENT;

signal vel : integer;
signal kp, ki, kd : integer;

signal num : integer;
signal numero : std_logic_vector (PIN_IN-1 downto 0);

signal medida_s : std_ulogic_vector(PIN_OUT-1 downto 0);

begin
  vel <= to_integer(unsigned(entrada(PIN_IN-1 DOWNTO PIN_IN-16)));
  kp <= to_integer(unsigned(entrada(PIN_IN-17 DOWNTO PIN_IN-24)));
  ki <= to_integer(unsigned(entrada(PIN_IN-25 DOWNTO PIN_IN-32)));
  kd <= to_integer(unsigned(entrada(PIN_IN-33 DOWNTO 0)));
  
--  num <= vel*10000 + kp*100 + ki*10 + kd;
--  numero <= std_logic_vector(to_unsigned(num, PIN_IN));

    medida_s <= medida;

  inst_cont: control_top
    Generic map(
        Frecuencies => 2000,
        SIZE_HALL => PIN_OUT   
    )
    Port map (
        CLK => CLK,
        RESET => RESET,
        Kp => Kp,
        Ki => Ki,
        Kd => Kd,
        A => A,
        B => B,
        C => C,
        PWM_AH => PWM_AH,
        PWM_BH => PWM_BH,
        PWM_CH => PWM_CH,
        EN1 => EN1,
        EN2 => EN2,
        EN3 => EN3,
        ESTADO => ESTADO,
        ERROR => ERROR,
        SETVAL => vel,
        digctrl => digctrl,
        segment => segment,
        medida => medida
    );
    
    DISPLAY_INST : top_display
        Generic map(
            SIZE => PIN_OUT
        )
        Port map(
            clk_disp => CLK,
            reset_disp => RESET,
            input => medida_s, -- RPM se conecta a la entrada de display
            v_sal => digctrl,
            segment => segment
        );
        
        
end Behavioral;
