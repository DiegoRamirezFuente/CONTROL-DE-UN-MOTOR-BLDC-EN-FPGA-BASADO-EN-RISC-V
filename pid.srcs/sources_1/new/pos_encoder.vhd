----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.02.2024 23:23:44
-- Design Name: 
-- Module Name: pos_encoder - Behavioral
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

entity pos_encoder is
    Port (
        clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        encoder_a : in STD_LOGIC;
        encoder_b : in STD_LOGIC;
        position : out STD_LOGIC_VECTOR (7 downto 0)
    );
end pos_encoder;

architecture Behavioral of pos_encoder is
    signal last_encoder_a : STD_LOGIC;
    signal count : INTEGER RANGE 0 to 255;
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            count <= 0;
            last_encoder_a <= '0';
        elsif rising_edge(clk) then
            if encoder_a /= last_encoder_a then
                if encoder_a = encoder_b then
                    count <= count + 1;
                else
                    count <= count - 1;
                end if;
            end if;
            last_encoder_a <= encoder_a;
        end if;
    end process;

    position <= STD_LOGIC_VECTOR(TO_UNSIGNED(count, 8));
end Behavioral;
