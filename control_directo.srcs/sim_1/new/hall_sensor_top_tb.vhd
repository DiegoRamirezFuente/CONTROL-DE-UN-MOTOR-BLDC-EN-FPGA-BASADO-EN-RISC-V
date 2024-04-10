----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.02.2024 20:32:59
-- Design Name: 
-- Module Name: pwm_top_tb - Behavioral
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

entity hall_sensor_top_tb is
end hall_sensor_top_tb;

architecture Behavioral of hall_sensor_top_tb is

COMPONENT hall_sensor_top
Generic( Duty_SIZE: integer range 10 to 15 := 13);
Port ( 
    CLK : in STD_LOGIC;
    RESET : in STD_LOGIC;
    A, B, C : in STD_LOGIC;
    RPM : out std_logic_vector (Duty_SIZE-1 downto 0)
);
END COMPONENT;

constant Duty_SIZE : integer := 13; -- Definir Duty_SIZE como constante
constant CLK_PERIOD : time := 10 ns;
constant PERIOD : time := 400 us;
signal CLK : std_logic := '0';

signal RESET : std_logic := '0';
signal A, B, C : std_logic := '0';
signal As,Ass :  std_logic;
signal sig_rpm : std_logic_vector(Duty_SIZE - 1 downto 0);

begin

  hall_sensor_top_inst : hall_sensor_top
    port map (
        CLK => CLK,
        RESET => RESET,
        A => A,
        B => B,
        C => C,
        RPM => sig_rpm
    );

    clk_process :process
    begin
        CLK <= '1';
        wait for CLK_PERIOD/2;
        CLK <= '0';
        wait for CLK_PERIOD/2;
    end process;

RESET <='1', '0' after 1ms, '1' after 1ms + 200 ns, '0' after 2 ms, '1' after 13 ms ,'0' after 13ms + 20ns;
    
    clockA : process
    begin 
        
        As <= '0';
        wait for 0.5*PERIOD;
        As <= '1' ;
        wait for 0.5*PERIOD;
end process;

---clockB
B <= transport A after 1*(PERIOD/3) ;
---clockC
C <= transport A after 2*(PERIOD/3);

A <= As OR Ass;

Ass <= '0','1' after 10ms , '0' after 12ms + 30 ns; --Modificar señal buscando el error

end Behavioral;
