----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.02.2024 11:50:45
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pid_gen is
Generic (
    Kp : integer := 10; --constante proporcional del PID
    Ki : integer := 20; --constante integral del PID
    Kd : integer := 1; --constante derivativa del PID
    valSat : in  integer := 65535 -- valor saturación motor para WINDUP
    );
Port ( 
    RESET_N: in STD_LOGIC; --reset negado asíncrono
    SETVAL: in integer; --Valor de establecimiento 
    ADC_DATA : in  STD_LOGIC_VECTOR (15 downto 0); -- entrada analógica de 16 bits
    DAC_DATA : out  STD_LOGIC_VECTOR (15 downto 0); -- salida analógica de 16 bits
    CLK_PID : in STD_LOGIC
    );
end pid_gen;

architecture Behavioral of pid_gen is

type state_type is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9);	-- estados de la maquina para calcular el PID                             
    signal state: state_type := S0; 
    signal next_state : state_type := state;    
    signal sAdc : integer := 0; 
    signal err,uk,uk1,ek,ek1,ek2 : integer;
    signal q1,q2,q3 : integer;
    constant T : integer := 0;
    
begin

state_reg:process(CLK_PID,RESET_N) -- actualiza el estado de trabajo en cada flanco de reloj
begin
    if RESET_N = '0' then
        state <= S0;
    elsif rising_edge(CLK_PID) then    
        state <=next_state;
    end if;
end process;
    
next_state_decoder:process(state) -- establece la secuencia de estados
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
    when S9 => next_state <= S1;
    when others => next_state <= S0;
end case;      
end process;

output_decoder:process(state) -- establece las funciones que realizará cada estado
begin
case state is
    when S0 => sAdc <= to_integer(unsigned(ADC_DATA)); -- se almacena el valor recibido del motor
               uk <= 0;                                -- establecimiento de todas las señales de error a 0 en el estado de reposo
               uk1 <= 0; 
               ek <= 0; 
               ek1 <= 0;
               ek2 <= 0; 
                
    when S1 => ek <= SETVAL-sAdc; -- cálculo del error con la diferencia entre el valor de establecimiento y el obtenido del motor
    
    when S2 => q1 <= Kp+Kd/T; 
      
    when S3 => q2 <= -Kp+Ki*T-2*Kd/T;
    
    when S4 => q3 <= Kd/T;  
    
    when S5 => uk <= uk1 + q1*ek + q2*ek1 + q3*ek2; -- cálculo de la salida del PID
    
    when S6 => if (uk > valSat) THEN -- se satura la salida para evitar efecto WINDUP
                    uk <= valSat;
               elsif uk <= 0 THEN
                    uk <= 0;
               end if;   
               
    when S7 => DAC_DATA <= std_logic_vector(to_unsigned(uk,DAC_DATA' length)); -- asignación de la salida analógica del PID
    
    when S8 => uk1 <= uk; -- actualización de los valores de la salida y el error para la siguiente iteración
               ek2 <= ek1;
               
    when S9 => ek1 <= ek; -- se separa esta actualización en otro estado para evitar errores
end case;      
end process;

end Behavioral;
