----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2024 17:54:28
-- Design Name: 
-- Module Name: pwm_gen - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm_gen is
Port (
    CLK : in STD_LOGIC; --reloj de la placa
    RESET_N : in STD_LOGIC; --reset negado asíncrono
    PWM_IN : in STD_LOGIC_VECTOR(15 downto 0); --salida del PID
    PWM_OUT : out STD_LOGIC --senial de salida del PWM hacia el motor
 );
end pwm_gen;

architecture Behavioral of pwm_gen is

signal counter : unsigned(16 downto 0);
signal duty : unsigned(15 downto 0);
constant period : unsigned(16 downto 0):="11111111111111111"; --periodo o valor máximo del duty

begin

duty <= unsigned(PWM_IN); --asignamos al duty de la senial PWM
                          --el valor de la salida del PID

process(CLK,RESET_N)
begin
    if RESET_N = '0' then
        counter <= (others => '0');
    elsif rising_edge(CLK) then
        if counter = period then
           counter <= (others => '0');
        else
           counter <= counter + 1;
        end if;
    end if;
end process;

PWM_OUT <= '0' WHEN (counter < duty) ELSE --genera la senial PWM de salida
           '1';

end Behavioral;
