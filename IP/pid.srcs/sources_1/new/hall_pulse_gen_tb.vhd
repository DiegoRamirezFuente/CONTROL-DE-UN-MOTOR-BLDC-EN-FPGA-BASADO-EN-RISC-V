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

entity pid_top_tb is
end pid_top_tb;

architecture Behavioral of pid_top_tb is

constant CLK_PERIOD : time := 10 ns;
constant PERIOD : time := 50 ms;
signal CLK : std_logic := '0';
signal ERROR : std_logic := '0';

signal RESET : std_logic := '0';
signal A, B, C : std_logic := '0';
signal As,Ass :  std_logic;
signal sig_rpm : real := 0.0;

COMPONENT pid_top is
    Port ( 
        CLK : in STD_LOGIC;
        RESET : in STD_LOGIC;
        A, B, C : in STD_LOGIC;
        ERROR: out STD_LOGIC; 
        RPM : out REAL 
    );
END COMPONENT;

begin

    uut: pid_top
    port map (
        CLK => CLK,
        RESET => RESET,
        A => A,
        B => B,
        C => C,
        ERROR => ERROR,
        RPM => sig_rpm
    );

    clk_process :process
    begin
        CLK <= '1';
        wait for CLK_PERIOD/2;
        CLK <= '0';
        wait for CLK_PERIOD/2;
    end process;

RESET <= '1', '0' after 125ms, '1' after 125ms + 25 us, '0' after 250 ms, '1' after 1625 ms ,'0' after 1625ms + 2.5 us;
   
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

Ass <= '0','1' after 1250 ms , '0' after 1500ms+3.75 us; --Modificar se al buscando el error

end Behavioral;