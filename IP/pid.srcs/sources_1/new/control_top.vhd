----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.06.2024 12:15:43
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_top is
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
        medida : out std_ulogic_vector(SIZE_HALL-1 downto 0)
    );
end control_top;



architecture Behavioral of control_top is


component ralent
  Generic (SIZE :  integer := 20);
  Port (
    CLK : in std_logic;
    RESET : in std_logic;
    INPUT : in std_logic_vector(SIZE-1 downto 0);
    OUTPUT : out std_logic_vector(SIZE-1 downto 0)
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
    
    COMPONENT PID_TOPSENSOR
      Generic ( SIZE :  integer := 20);
      Port ( 
      CLK:      in std_logic;
      RESET:    in std_logic;
      A:        in std_logic;
      B:        in std_logic;
      C:        in std_logic;
      Count:    out std_logic_vector(SIZE-1 downto 0);
      ERROR:    out std_logic
      );
    END COMPONENT;
    
    COMPONENT GEN_FREC  
    PORT  
    ( 
      CLK    : IN STD_LOGIC; 
      F_BASE    : IN INTEGER; 
      FREC_OUT  : OUT STD_LOGIC 
       
    ); 
    END COMPONENT; 

    COMPONENT pid_top is
    Generic (
        FREC : integer := 10**8;
        SIZE : integer := 20;
        T : integer := 100;
        valSat : integer := 2000 -- valor saturación motor para WINDUP
    );
    Port (
        CLK : in STD_LOGIC; -- senial de reloj
        RESET : in STD_LOGIC; -- reset asíncrono
        Kp : in integer range 0 to 255 := 0; --constante proporcional del PID
        Ki : in integer range 0 to 255 := 0; --constante integral del PID
        Kd : in integer range 0 to 255 := 0; --constante derivativa del PID
        SETVAL : in integer; -- valor de establecimiento
        SENSOR_VAL : in std_logic_vector(SIZE-1 downto 0); -- valor de realimentación recibido por el sensor
        PID_OUTPUT : out integer range 0 to 2000 -- salida del PID
    );
    END COMPONENT;
    
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

    signal As,Bs,Cs: std_logic;
    signal An,Bn,Cn: std_logic;

    signal CLK100Hz: std_logic;

    signal DUTY : INTEGER;
    
    signal ERROR1, ERROR2 :  std_logic;
    
    signal RPM_r : std_logic_vector(SIZE_HALL-1 downto 0);
    signal RPM_s : std_logic_vector(SIZE_HALL-1 downto 0);
    
    signal rev : std_logic_vector(SIZE_HALL-1 downto 0);
    signal dut_s : std_logic_vector(SIZE_HALL-1 downto 0);
    signal pid_out : INTEGER;

begin

uut: ralent 
  Generic map (SIZE => SIZE_HALL)
  PORT MAP(
    CLK => CLK,
    RESET => RESET,
    INPUT => RPM_s,
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
        Generic map (SIZE => SIZE_HALL)
        Port map(
            CLK => CLK,
            RESET => RESET,
            A => An,
            B => Bn,
            C => Cn,
            Count => rpm_s,
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
        
        gen: GEN_FREC  
    PORT MAP  
    ( 
      CLK    => CLK,
      F_BASE  =>  10**6,
      FREC_OUT  => CLK100Hz
       
    );
    
        pid_top_inst : pid_top
    generic map (
        SIZE => SIZE_HALL,
        valSat => 2000
    )
    port map (
        CLK => CLK100Hz,
        RESET => RESET,
        Kp => Kp,
        Ki => Ki,
        Kd => Kd,
        SETVAL => SETVAL,
        SENSOR_VAL => rpm_s,
        PID_OUTPUT => DUTY
    );
        
        --dut_s <= std_logic_vector(to_unsigned(pid_out,20));
        
        -- Instancia del componente top_display
--    DISPLAY_INST : top_display
--        Generic map(
--            SIZE => SIZE_HALL
--        )
--        Port map(
--            clk_disp => CLK,
--            reset_disp => RESET,
--            input => rpm_s, -- RPM se conecta a la entrada de display
--            v_sal => digctrl,
--            segment => segment
--        );
        
        medida <= std_ulogic_vector(rpm_s);
        
        EN1 <= '1';
        EN2 <= '1';
        EN3 <= '1';
        
        ERROR <= ERROR1 or ERROR2;
end Behavioral;
