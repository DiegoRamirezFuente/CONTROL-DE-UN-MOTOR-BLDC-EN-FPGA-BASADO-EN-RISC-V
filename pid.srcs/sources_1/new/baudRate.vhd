----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2024 15:41:40
-- Design Name: 
-- Module Name: baudRate - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity baudRate is
  port (clk_i    : in  std_logic;
        rst_i    : in  std_logic; 
        pulso_o  : out std_logic);   
end entity baudRate;

-- GENERA UN RELOJ PARA EL BAUD RATE. CREA UNA SEÑAL PULSANTE, NORMALMENTE 
-- ESTA EN '0' CON UN PULSO EN '1' DURANTE LA DURACIÓN DE UN CLOCK.
-- LA FRECUENCIA DEL RELOJ DE LA PLACA ES DE 24 MHz, DE MANERA QUE
-- PARA OBTENER UNA FRECUENCIA DE 9600 bits/s, HAY QUE CONTAR: 
-- 24.000.000 (1/s) / 9600 (bits/s) = 2500 PULSOS.

architecture Behavioral of baudRate is

  type     estadoBaud is (inicial, contando);
  signal   proximoBaud   : estadoBaud;
  constant CUENTA        : integer := 24000000/9600;
  signal   contadorBaud  : integer range 0 to CUENTA;
  
begin

    process (clk_i,rst_i) begin
	   if rst_i='0' then
          proximoBaud <= inicial;
       elsif rising_edge(clk_i) then
  
        case proximoBaud is
        
          when inicial =>      
               pulso_o      <= '0';
               contadorBaud <= 0;
               proximoBaud  <= contando;

          when contando =>
               if contadorBaud < CUENTA - 1 then   
                 contadorBaud <= contadorBaud + 1;         
               else
                 pulso_o <= '1'; 
                 proximoBaud <= inicial;
               end if;

        end case;    
      end if;
  end process;

end Behavioral;
