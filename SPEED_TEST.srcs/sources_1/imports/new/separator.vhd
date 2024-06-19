----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.03.2024 17:47:29
-- Design Name: 
-- Module Name: separator - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity separator is
    Generic(SIZE : integer range 8 to 20 := 8);
    port (
        input : in  std_logic_vector(SIZE-1 DOWNTO 0);
        digit1, digit2, digit3, digit4 : out std_logic_vector(3 DOWNTO 0);
        digit5, digit6, digit7, digit8 : out std_logic_vector(3 DOWNTO 0)
    );
end separator;

architecture Behavioural of separator is

begin

    process(input)
        variable s_digit1, s_digit2, s_digit3, s_digit4 : integer range 0 to 9;
        variable s_digit5, s_digit6, s_digit7, s_digit8 : integer range 0 to 9;
        variable s_input : integer range 0 to 99999999 := 0;
    begin
        s_input := to_integer(unsigned(input));
        s_digit1 := s_input mod 10;
        s_digit2 := (s_input/10) mod 10;
        s_digit3 := (s_input/100) mod 10;
        s_digit4 := (s_input/1000) mod 10;
        s_digit5 := (s_input/10000) mod 10;
        s_digit6 := (s_input/100000) mod 10;
        s_digit7 := (s_input/1000000) mod 10;
        s_digit8 := (s_input/10000000) mod 10;
        
        digit1 <= std_logic_vector(to_unsigned(s_digit1,4));
        digit2 <= std_logic_vector(to_unsigned(s_digit2,4));
        digit3 <= std_logic_vector(to_unsigned(s_digit3,4));
        digit4 <= std_logic_vector(to_unsigned(s_digit4,4));
        
        digit5 <= std_logic_vector(to_unsigned(s_digit5,4));
        digit6 <= std_logic_vector(to_unsigned(s_digit6,4));
        digit7 <= std_logic_vector(to_unsigned(s_digit7,4));
        digit8 <= std_logic_vector(to_unsigned(s_digit8,4));
    end process;
    
    
    
end Behavioural;
