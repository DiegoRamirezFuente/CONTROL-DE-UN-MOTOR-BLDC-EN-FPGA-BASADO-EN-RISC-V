library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity direct_control_top_tb is
end direct_control_top_tb;

architecture testbench of direct_control_top_tb is
    -- Entity declaration
    COMPONENT direct_control_top IS
      Generic(
        PWM_Frecuencies: integer range 1000 to 4800:= 4800;
        SIZE: integer range 10 to 15:= 13  
      );
      Port ( 
        CLK:          in std_logic;
        RESET:        in std_logic;  
        A          : in std_logic;
        B          : in std_logic;
        C          : in std_logic;
        Duty : in INTEGER;
        --switch : in std_logic_vector(2 downto 0);
        A_out       : out std_logic;
        B_out       : out std_logic;
        C_out       : out std_logic;
        PWM_AH       : out std_logic;
        PWM_AL       : out std_logic;
        PWM_BH       : out std_logic;
        PWM_BL       : out std_logic;
        PWM_CH       : out std_logic;
        PWM_CL       : out std_logic;
        PWM_HIGH    : out std_logic;
        PWM_LOW     : out std_logic;
        ERROR      : out std_logic;
        RPM : out std_logic
        --RPM : out std_logic_vector(SIZE-1 downto 0)
      );
    END COMPONENT;
    
    constant CLK_PERIOD : time := 10 ns;
    constant PERIOD : time := 400 us;

    -- Signals declaration
    signal CLK_tb, RESET_tb, A_tb, B_tb, C_tb: std_logic;
    signal switch_tb: std_logic_vector(2 downto 0);
    signal A_out_tb, B_out_tb, C_out_tb: std_logic;
    signal As,Ass :  std_logic;
    signal PWM_AH_tb, PWM_AL_tb, PWM_BH_tb, PWM_BL_tb, PWM_CH_tb, PWM_CL_tb: std_logic;
    signal PWM_HIGH_tb, PWM_LOW_tb, ERROR_tb, RPM_tb: std_logic;
    signal Duty_tb: integer := 0; -- Variable para el Duty
    
    
begin

    -- DUT instantiation
    UUT: direct_control_top
        generic map (
            PWM_Frecuencies => 4800,  -- Set to desired values
            SIZE => 13  -- Set to desired values
        )
        port map (
            CLK => CLK_tb,
            RESET => RESET_tb,
            A => A_tb,
            B => B_tb,
            C => C_tb,
            Duty => Duty_tb,
            --switch => switch_tb,
            A_out => A_out_tb,
            B_out => B_out_tb,
            C_out => C_out_tb,
            PWM_AH => PWM_AH_tb,
            PWM_AL => PWM_AL_tb,
            PWM_BH => PWM_BH_tb,
            PWM_BL => PWM_BL_tb,
            PWM_CH => PWM_CH_tb,
            PWM_CL => PWM_CL_tb,
            PWM_HIGH => PWM_HIGH_tb,
            PWM_LOW => PWM_LOW_tb,
            ERROR => ERROR_tb,
            RPM => RPM_tb
        );

    -- Clock generation process
    clk_process :process
    begin
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
    end process;

RESET_tb <= '1', '0' after 1ms, '1' after 1ms + 200 ns, '0' after 2 ms, '1' after 13 ms ,'0' after 13ms + 20ns;

DUTY_PROCESS : process
    begin
        Duty_tb <= 0; -- Iniciamos Duty a 0
        wait for 3 ms; -- Esperar 3 ms antes de cambiar Duty
        Duty_tb <= 100; -- Cambiar Duty a 100
        wait for 14 ms; -- Esperar 14 ms
        Duty_tb <= 500; -- Cambiar Duty a 100
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 1000; -- Cambiar Duty a 1000
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 2500; -- Cambiar Duty a 2500
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 3500; -- Cambiar Duty a 3500
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 4500; -- Cambiar Duty a 4500
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 1500; -- Cambiar Duty a 1500
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 700; -- Cambiar Duty a 700
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 200; -- Cambiar Duty a 200
        wait for 1 ms; -- Esperar 1 ms
        Duty_tb <= 0; -- Cambiar Duty a 0
        wait;
    end process;
    
clockA : process
    begin 
        
        As <= '0';
        wait for 0.5*PERIOD;
        As <= '1' ;
        wait for 0.5*PERIOD;
end process;

---clockB
B_tb <= transport A_tb after 1*(PERIOD/3) ;
---clockC
C_tb <= transport A_tb after 2*(PERIOD/3);

A_tb <= As OR Ass;

Ass <= '0','1' after 10ms , '0' after 12ms + 30 ns; --Modificar se al buscando el error


end testbench;
