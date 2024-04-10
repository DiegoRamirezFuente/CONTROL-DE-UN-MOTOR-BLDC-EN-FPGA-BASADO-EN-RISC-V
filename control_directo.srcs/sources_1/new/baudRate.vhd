----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.04.2024 19:08:38
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
 
-- GENERA UN RELOJ PARA EL BAUD RATE. CREA UNA "SENIAL" PULSANTE, NORMALMENTE 
-- ESTA EN '0' CON UN PULSO EN '1' DURANTE LA DURACIÓN DE UN CLOCK.
library IEEE;   
use IEEE.STD_LOGIC_1164.ALL;   
-----------------------------------------------------------------------------
entity baudRate is
  port (clk_i    : in  std_logic;
        rst_i    : in  std_logic; 
        pulso_o  : out std_logic);   
end entity baudRate;
-----------------------------------------------------------------------------
-- LA FRECUENCIA DEL OSCILADOR DE LA FPGA ES DE 100 MHz, DE MANERA QUE
-- PARA OBTENER UNA FRECUENCIA DE 9600 bits/s, HAY QUE CONTAR: 
-- 100.000.000 (1/s) / 9600 (bits/s) = 10.417 PULSOS.

architecture Behavioural of baudRate is
  type     estadoBaud is (inicial, contando);
  signal   proximoBaud   : estadoBaud;
  constant CUENTA        : integer := 100000000/9600;
  signal   contadorBaud  : integer range 0 to CUENTA;

begin
  baud: 
	process (clk_i) begin
      if rising_edge(clk_i) then
        if rst_i='1' then
          proximoBaud <= inicial;
        else  

        case proximoBaud is
        
          when inicial =>      
               pulso_o      <= '0';
               contadorBaud <= 0;
               proximoBaud  <= contando;

          when contando =>
               if contadorBaud<CUENTA-1 then   
                 contadorBaud <= contadorBaud + 1;         
               else
                 pulso_o     <= '1'; 
                 proximoBaud <= inicial;
               end if;

        end case;    
      end if;
    end if;
  end process baud;
 
end Behavioural;