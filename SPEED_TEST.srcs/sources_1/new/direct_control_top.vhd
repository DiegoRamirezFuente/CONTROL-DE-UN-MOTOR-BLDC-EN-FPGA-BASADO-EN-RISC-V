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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity direct_control_top is
    Generic(
        Frecuencies: integer range 1000 to 2500:= 2000; -- Valor de la frecuencia
        SIZE_PWM: integer range 1 to 16:=16; -- Tamaño en bits para pwm_top
        SIZE_HALL: integer range 8 to 16 := 16 -- Tamaño en bits para hall_sensor_top
    );
    Port (
        CLK : in std_logic;
        RESET : in std_logic;
        A, B, C : in std_logic;
        SWITCH : in std_logic_vector(5 downto 0);
        PWM_AH, PWM_BH, PWM_CH : out std_logic;
        EN1, EN2, EN3 : out std_logic;
        ESTADO : out std_logic_vector(5 downto 0);
        ERROR : out std_logic;
        digctrl : out std_logic_vector(7 downto 0);
        segment : out std_logic_vector(6 downto 0)
    );
end direct_control_top;



architecture Behavioral of direct_control_top is


component ralent
  Port (
    CLK : in std_logic;
    RESET : in std_logic;
    INPUT : in std_logic_vector(19 downto 0);
    OUTPUT : out std_logic_vector(19 downto 0)
  );
end component;

    -- Declaración del componente pwm_top
    component pwm_top
        Generic(
            Frecuencies: integer range 1000 to 2500:= 2000; -- Valor de la frecuencia
            SIZE: integer range 8 to 16 := 13 -- Tamaño en bits
        );
        Port (
            CLK : in std_logic;
            RESET : in std_logic;
            A, B, C : in std_logic;
            PWM_AH, PWM_BH, PWM_CH : out std_logic;
            EN1, EN2, EN3 : out std_logic;
            DUTY : in INTEGER;
            ESTADO : out std_logic_vector(5 downto 0);
            ERROR : out std_logic
        );
    end component;
    
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
    
COMPONENT PID_TOPSENSOR is
  Port ( 
  CLK:      in std_logic;
  RESET:    in std_logic;
  A:        in std_logic;
  B:        in std_logic;
  C:        in std_logic;
  Count:    out std_logic_vector(19 downto 0);
  ERROR:    out std_logic
  );
END COMPONENT;
    
    component top_display
    Generic(SIZE : integer range 8 to 20 := 16);
     PORT ( 
     clk_disp:in std_logic;
     reset_disp:in std_logic;
     input : in  std_logic_vector(SIZE-1 DOWNTO 0);
     v_sal : OUT std_logic_vector(7 DOWNTO 0);
     segment : OUT std_logic_vector(6 DOWNTO 0)
     );
   end component;

    signal As,Bs,Cs: std_logic;
    signal An,Bn,Cn: std_logic;

    signal RPM : std_logic_vector(19 downto 0);
    signal DUTY : INTEGER:=0;
    
    signal ERROR1, ERROR2 :  std_logic;
    
    signal RPM_r : std_logic_vector(19 downto 0);

begin

uut: ralent PORT MAP(
    CLK => CLK,
    RESET => RESET,
    INPUT => RPM,
    OUTPUT => RPM_r
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
    
    An <= not As;
    Bn <= not Bs;
    Cn <= not Cs;

    HALL_INST : PID_TOPSENSOR
        Port map(
            CLK => CLK,
            RESET => RESET,
            A => An,
            B => Bn,
            C => Cn,
            Count => RPM,
            ERROR => ERROR1
        );
        
    -- Instancia del componente pwm_top
    PWM_INST : pwm_top
        Generic map(
            Frecuencies => Frecuencies,
            SIZE => SIZE_PWM
        )
        Port map(
            CLK => CLK,
            RESET => RESET,
            A => An,
            B => Bn,
            C => Cn,
            PWM_AH => PWM_AH,
            PWM_BH => PWM_BH,
            PWM_CH => PWM_CH,
            EN1 => EN1,
            EN2 => EN2,
            EN3 => EN3,
            DUTY => DUTY,
            ESTADO => ESTADO,
            ERROR => ERROR2
        );
        
        -- Instancia del componente top_display
    DISPLAY_INST : top_display
        Generic map(
            SIZE => 20
        )
        Port map(
            clk_disp => CLK,
            reset_disp => RESET,
            input => RPM_r, -- RPM se conecta a la entrada de display
            v_sal => digctrl,
            segment => segment
        );
        
        EN1 <= '1';
        EN2 <= '1';
        EN3 <= '1';

        DUTY <= 100 when SWITCH = "000001" else --5%
        400 when SWITCH = "000010" else --20%
        800 when SWITCH = "000100" else --40%
        1200 when SWITCH = "001000" else --60%
        1600 when SWITCH = "010000" else --80%
        2000 when SWITCH = "100000" else --100%
        200 when SWITCH = "100001" else --10%
        300 when SWITCH = "100010" else --10%
        0;
        
        ERROR <= ERROR1 or ERROR2;
end Behavioral;
