----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.02.2024 18:03:55
-- Design Name: 
-- Module Name: pwm_decod - Behavioral
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

entity hall_pulse_gen is
Port(
    CLK : in std_logic;
	RESET : in std_logic;
    A, B, C : in std_logic;
    ERROR : out std_logic;
    PULSE : out std_logic
);
end hall_pulse_gen;

architecture Behavioral of hall_pulse_gen is

type state_t is (S0,S1,S2,S3,S4,S5,S6);                            --Posible state of hall reception
signal state , next_state : state_t := S6; --Registro almacena el valor de sentido para poder comparar.
signal abc : std_logic_vector(2 downto 0);
signal counter : integer range 0 to 2 := 0;
signal sig_pulse : std_logic := '0';

begin

abc <= A & B & C;
PULSE <= sig_pulse;

state_reg : process(CLK, RESET)
begin

    if RESET = '1' then
    
    ERROR <= '0';
    
        case abc is
        WHEN "101" =>
            state <= S0;
        WHEN "100" =>
            state <= S1;
        WHEN "110" =>
            state <= S2;
        WHEN "010" =>
            state <= S3;
        WHEN "011" =>
            state <= S4;
        WHEN "001" =>
            state <= S5;
        WHEN others =>
            state <= S6;
        end case;
              
    elsif rising_edge(CLK) then
        state <= next_state;    
    end if;
    
end process;
   
next_state_decoder : process(abc,state)
begin
    next_state <= state; 
        
        case state is	
            when S0 =>
        	   if abc = "001" then      
                next_state <= S5;
               elsif abc = "100" then
                next_state <= S1;
               elsif abc = "101" then
                next_state <=S0;
               else
                next_state <=S6;
               end if;

            when S1 =>
        	   if abc = "101" then      
                next_state <= S0;
               elsif abc = "110" then
                next_state <= S2;
               elsif abc = "100" then
                next_state <= S1;
               else
                next_state <= S6;
               end if;
               
            when S2 =>           
        	   if abc = "100" then      
                next_state <= S1;
               elsif abc = "010" then
                next_state <= S3;
               elsif abc = "110" then
                next_state <= S2;
               else
                next_state <= S6;
               end if;
               
            when S3 =>
        	   if abc = "110" then      
                next_state <= S2;
               elsif abc = "011" then
                next_state <= S4;
               elsif abc = "010" then
                next_state <= S3;
               else
                next_state <= S6;
                    end if; 
                               
            when S4 =>           
        	   if abc = "010" then      
                next_state <= S3;
               elsif abc = "001" then
                next_state <= S5;
               elsif abc = "011" then
                next_state <=S4;
               else
                next_state <= S6;
               end if;
                    
            when S5 =>
    
        	   if abc = "011" then     
                next_state <= S4;
               elsif abc = "101" then
                next_state <= S0;
               elsif abc = "001" then
                next_state <=S5;
               else
                next_state <= S6;
               end if; 
                    
            when others =>
        end case;
end process;

pulse_gen: process(CLK, RESET, state, next_state)
    begin
        if RESET = '1' then
            sig_pulse <= '0';
            counter <= 0;
        elsif rising_edge(clk) then
            if state /= next_state AND next_state /= S6 AND state /= S6 then
                sig_pulse <= '1';
                counter <= 0;
            else
                sig_pulse <= '0';    
            end if;
            
            if sig_pulse = '1' then
                if counter = 2 then 
                    counter <= 0;
                    sig_pulse <= '0';
                else 
                    counter <= counter + 1;
                end if;  
            end if;
        end if;
    end process;

end architecture;