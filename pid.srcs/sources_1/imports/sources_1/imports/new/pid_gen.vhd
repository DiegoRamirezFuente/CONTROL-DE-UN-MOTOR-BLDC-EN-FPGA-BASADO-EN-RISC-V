----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.02.2024 18:22:37
-- Design Name: 
-- Module Name: pid_gen - Behavioral
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

entity pid_gen is
Generic (
    T : integer := 100; -- 10ms FREC = 100Hz
    valSat : integer := 2000 -- valor saturación motor para WINDUP
    );
Port ( 
    CLK : in STD_LOGIC; -- señal de reloj
    RESET: in STD_LOGIC; -- reset asíncrono
    Kp : in integer range 0 to 255 := 0; -- constante proporcional del PID
    Ki : in integer range 0 to 255 := 0; -- constante integral del PID
    Kd : in integer range 0 to 255 := 0; -- constante derivativa del PID
    SETVAL: in integer; -- Valor de establecimiento 
    sensVal : in std_logic_vector(19 downto 0); -- valor de realimentación recibido por el sensor
    PID_OUT : out  integer -- salida del PID    
    );
end pid_gen;

architecture Behavioral of pid_gen is

    type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11); -- estados de la máquina para calcular el PID
    signal state: state_type := S0; 
    signal next_state : state_type := state;
        
    signal sAdc : integer := 0; 
    signal uk_aux, uk, uk1, ek, ek1, ek2 : integer;
    signal pout : INTEGER := 0;
    
    signal q1, q2, q3 : integer;
    
begin

state_reg: process(CLK, RESET) -- actualiza el estado de trabajo en cada flanco de reloj
begin
    if RESET = '0' then
        state <= S0;
    elsif rising_edge(CLK) then    
        state <= next_state;
    end if;
end process;
    
next_state_decoder: process(state) -- establece la secuencia de estados
begin
    case state is
        when S0 => next_state <= S1; 
        when S1 => next_state <= S2; 
        when S2 => next_state <= S3;  
        when S3 => next_state <= S4; 
        when S4 => next_state <= S5;  
        when S5 => next_state <= S6;
        when S6 => next_state <= S7; 
        when S7 => next_state <= S8; 
        when S8 => next_state <= S9;
        when S9 => next_state <= S10;
        when S10 => next_state <= S11;
        when S11 => next_state <= S1;
        when others => next_state <= S0;
    end case;      
end process;

output_decoder: process(state, CLK, SETVAL, sensVal) -- establece las funciones que realizará cada estado


begin
if rising_edge(CLK) then
    case state is
        when S0 =>
            pout <= 0;
            uk_aux <= 0; 
            uk1 <= 0; 
            ek <= 0; 
            ek1 <= 0; 
            ek2 <= 0;
                
        when S1 => 
            sAdc <= to_integer(unsigned(sensVal));
    
        when S2 => 
            ek <= SETVAL - sAdc;
    
        when S3 => 
            q1 <= Kp + (Kd/T);
    
        when S4 => 
            q2 <= -Kp + Ki*T - (2 * Kd/T);
    
        when S5 => 
            q3 <= Kd/T;
    
        when S6 => 
            uk_aux <= uk1 + q1 * ek + q2 * ek1 + q3 * ek2;
            
        when S7 => 
            if (uk_aux > 4000) then
                uk <= 4000;
            elsif uk_aux < 0 then
                uk <= 0;
            else 
                uk <= uk_aux;
            end if;   
               
        when S8 => 
            -- Escalar uk al rango de 0 a valSat
            pout <= (uk * valSat) / 4000;  -- Asume que 4000 es el valor máximo de uk antes del escalado
    
        when S9 => 
            uk1 <= uk;
             
        when S10 =>     
            ek2 <= ek1;
    
        when S11 => 
            ek1 <= ek;
    end case;
end if;   
end process;

PID_OUT <= pout; -- Salida del controlador PID.

end Behavioral;