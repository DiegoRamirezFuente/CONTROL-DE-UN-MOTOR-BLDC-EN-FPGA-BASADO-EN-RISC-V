----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.06.2024 17:33:57
-- Design Name: 
-- Module Name: ralent - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ralent is
  Port (
    CLK : in std_logic;
    RESET : in std_logic;
    INPUT : in std_logic_vector(19 downto 0);
    OUTPUT : out std_logic_vector(19 downto 0)
  );
end ralent;

architecture Behavioral of ralent is
  constant CLK_FREQUENCY: integer := 25000000; 
  constant DELAY_COUNT: integer := CLK_FREQUENCY;
  
  signal counter: integer range 0 to DELAY_COUNT - 1 := 0;
  signal delayed_vector: std_logic_vector(19 downto 0);
begin
  process (CLK, RESET)
  begin
    if RESET = '0' then  -- Reset asincrónico activo bajo
      counter <= 0;
      delayed_vector <= (others => '0');  -- Inicializa el vector de salida con ceros
    elsif rising_edge(CLK) then
      if counter = DELAY_COUNT - 1 then
        counter <= 0;
        delayed_vector <= INPUT;  -- Captura el vector de entrada cuando se alcanza el retardo deseado
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  OUTPUT <= delayed_vector;  -- Salida el vector retrasado después de 1 segundo
end Behavioral;

