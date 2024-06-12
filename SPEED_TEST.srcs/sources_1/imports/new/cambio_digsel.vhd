----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.12.2023 20:06:18
-- Design Name: 
-- Module Name: cambio_digsel - Behavioral
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
entity cambio_digsel is
    port (
        clk : in std_logic;
        segment_uni_in:in std_logic_vector(6 downto 0);
        segment_dec_in:in std_logic_vector(6 downto 0);
        segment_cen_in:in std_logic_vector(6 downto 0);
        segment_mil_in:in std_logic_vector(6 downto 0);
        segment_uni2_in:in std_logic_vector(6 downto 0);
        segment_dec2_in:in std_logic_vector(6 downto 0);
        segment_cen2_in:in std_logic_vector(6 downto 0);
        segment_mil2_in:in std_logic_vector(6 downto 0);
        digsel : out std_logic_vector(7 downto 0);
        segment_out:out std_logic_vector(6 downto 0)
    );
end cambio_digsel;

architecture Behavioral of cambio_digsel is
    signal counter : integer range 0 to 1e5 := 0;--1e5=1ms
begin
    process(clk)
    begin
        if rising_edge(clk) then
         if counter = 1e5 then
            counter <= 0;
         else counter<=counter+1;
         end if;
            if counter >= 0 and counter < 125e2  then
                digsel <= "11111110";
                segment_out <= segment_uni_in;
            elsif counter >= 125e2 and counter < 25e3  then
                digsel <= "11111101";
                segment_out <= segment_dec_in;
            elsif counter >= 25e3 and counter < 25e3+125e2  then
                digsel <= "11111011";
                segment_out <= segment_cen_in;   
            elsif counter >= 25e3+125e2 and counter < 50e3 then
                digsel <= "11110111";
                segment_out <= segment_mil_in;
                elsif counter >= 50e3 and counter < 50e3+125e2  then
                digsel <= "11101111";
                segment_out <= segment_uni2_in;
            elsif counter >= 50e3+125e2  and counter < 75e3  then
                digsel <= "11011111";
                segment_out <= segment_dec2_in;   
            elsif counter >= 75e3 and counter < 75e3+125e2 then
                digsel <= "10111111";
                segment_out <= segment_cen2_in;
            elsif counter >= 75e3+125e2 then
                digsel <= "01111111";
                segment_out <= segment_mil2_in;                       
            else digsel <= "11111111";
            end if;
            end if;
    end process;
end Behavioral;