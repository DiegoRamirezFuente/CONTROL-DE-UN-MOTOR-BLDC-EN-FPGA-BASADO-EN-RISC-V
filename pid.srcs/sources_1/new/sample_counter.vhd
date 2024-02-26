----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.02.2024 12:51:27
-- Design Name: 
-- Module Name: sample_counter - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sample_counter is
  generic(
  TIMES: integer range 1 to 100:= 100
  );
  Port ( 
  CLK : in std_logic;
  RESET : in std_logic;
  ENABLE : in std_logic;
  FLAG : out std_logic
  );
end sample_counter;

architecture Behavioral of sample_counter is
signal counter: integer;
begin

process(RESET,CLK)
begin
    if RESET = '1' then
        counter <= 0;
        FLAG <= '0';
    elsif rising_edge(CLK) then
        if ENABLE = '1' then
            counter <= counter + 1;
            if counter > TIMES*1E5 - 1 then
                counter <= 0;
                flag <= '1';
            else
                flag<='0';
            end if;
        else
            counter <= 0;
            flag <= '0';
        end if;
    end if;
end process;

end Behavioral;