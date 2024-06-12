library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity direct_control_top_tb is
end direct_control_top_tb;

architecture testbench of direct_control_top_tb is
    -- Entity declaration
    COMPONENT direct_control_top IS
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
    END COMPONENT;
    
    constant CLK_PERIOD : time := 10 ns;
    constant PERIOD : time := 5 ms;

    -- Signals declaration
    signal CLK_tb, RESET_tb, A_tb, B_tb, C_tb: std_logic;
    signal switch_tb: std_logic_vector(5 downto 0);
    signal As,Ass :  std_logic;
    signal PWM_AH_tb, PWM_BH_tb, PWM_CH_tb : std_logic;
    signal ERROR_tb, RPM_tb: std_logic;
    signal Duty_tb: integer := 0; -- Variable para el Duty
    signal EN1_tb, EN2_tb, EN3_tb : std_logic;
    signal digctrl_tb : std_logic_vector(7 downto 0);
    signal segment_tb : std_logic_vector(6 downto 0);
    
begin

    -- DUT instantiation
    UUT: direct_control_top
        generic map (
            Frecuencies => 2000,  -- Set to desired values
            SIZE_PWM => 16,
            SIZE_HALL => 16
        )
        port map (
            CLK => CLK_tb,
            RESET => RESET_tb,
            A => A_tb,
            B => B_tb,
            C => C_tb,
            SWITCH => switch_tb,
            PWM_AH => PWM_AH_tb,
            PWM_BH => PWM_BH_tb,
            PWM_CH => PWM_CH_tb,
            EN1 => EN1_tb,
            EN2 => EN2_tb,
            EN3 => EN3_tb,
            ERROR => ERROR_tb,
            digctrl => digctrl_tb,
            segment => segment_tb
        );

    -- Clock generation process
    clk_process :process
    begin
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
    end process;

RESET_tb <='0', '1' after 4ms;

DUTY_PROCESS : process
    begin
        switch_tb <= "000000";
        wait for 30 ms;
        switch_tb <= "000001";
        wait for 140 ms;
        switch_tb <= "000010";
        wait for 140 ms;
        switch_tb <= "000100";
        wait for 140 ms;
        switch_tb <= "001000";
        wait for 140 ms;
        switch_tb <= "010000";
        wait for 140 ms;
        switch_tb <= "100000";
        wait;
    end process;
    
clockA : process
    begin 
        
        A_tb <= '0';
        wait for 0.5*PERIOD;
        A_tb <= '1' ;
        wait for 0.5*PERIOD;
end process;

---clockB
B_tb <= transport A_tb after 1*(PERIOD/3) ;
---clockC
C_tb <= transport A_tb after 2*(PERIOD/3);


end testbench;