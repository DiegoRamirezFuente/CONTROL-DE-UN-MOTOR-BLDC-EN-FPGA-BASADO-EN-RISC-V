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

entity pwm_decod is
Generic(
    DELAY: integer range 4 to 10 := 4
);
Port(
    CLK : in std_logic;
	RESET : in std_logic;
    A, B, C : in std_logic;
    PWM_IN_H : in std_logic;
    --PWM_IN_L : in std_logic;
    PWM_AH,PWM_BH,PWM_CH: out std_logic;
    --PWM_AL,PWM_BL,PWM_CL: out std_logic;
    --PWM_H,PWM_L : out std_logic;
    ESTADO : out std_logic_vector(5 downto 0);
    ERROR : out std_logic
);
end pwm_decod;

architecture Behavioral of pwm_decod is

type state_t is (S0,S1,S2,S3,S4,S5,S6);                            --Posible state of hall reception
signal state , next_state : state_t := S6; --Registro almacena el valor de sentido para poder comparar.
signal counter: std_logic_vector(17 downto 0);
signal abc : std_logic_vector(2 downto 0);

begin

abc <= A & B & C;

state_reg : process(CLK, RESET)
begin

    if RESET = '0' then
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
               
    counter <= (others=>'0');
    
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
   
   
   
output_decod: process(RESET,state,PWM_IN_H)
begin

    ERROR <= '0';
    PWM_AH <='0';
    PWM_BH  <='0';
    PWM_CH  <='0';

    if RESET = '0' then
    PWM_AH <= '0';
    PWM_BH <= '0';
    PWM_CH <= '0'; 
       
    else    
     
    case state is
        
        WHEN S0 =>
            PWM_AH <= '0';
            PWM_BH <= PWM_IN_H;
            PWM_CH <= '0';   
    
        WHEN S1 =>
            PWM_AH <= '0';
            PWM_BH <= PWM_IN_H;
            PWM_CH <='0';    
    
        WHEN S2 =>
            PWM_AH <= '0';
            PWM_BH <= '0';
            PWM_CH <= PWM_IN_H;    
    
        WHEN S3 =>
            PWM_AH <= '0';
            PWM_BH <= '0';
            PWM_CH <= PWM_IN_H;  
     
        WHEN S4 =>
            PWM_AH <= PWM_IN_H;
            PWM_BH <= '0';
            PWM_CH <= '0'; 
     
        WHEN S5 =>
            PWM_AH <= PWM_IN_H;
            PWM_BH <= '0';
            PWM_CH <= '0';
            
        WHEN S6 =>
            PWM_AH <= '0';
            PWM_BH <= '0';
            PWM_CH <= '0'; 

    ERROR <= '1';
    WHEN OTHERS =>        
        end case;
            
    end if;
end process;

with state select
        ESTADO <= "000001" when S0, -- S0: LED 0 ON
                  "000010" when S1, -- S1: LED 1 ON
                  "000100" when S2, -- S2: LED 2 ON
                  "001000" when S3, -- S3: LED 3 ON
                  "010000" when S4, -- S4: LED 4 ON
                  "100000" when S5, -- S5: LED 5 ON
                  "000000" when others; -- Others: all LEDs OFF

end architecture;