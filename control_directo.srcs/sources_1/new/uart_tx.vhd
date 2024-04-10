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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity uart_tx is
  generic(BITS       : positive := 10);
  port   (clk_i      : in  std_logic;
          rst_i      : in  std_logic; 
          dat_i      : in  std_logic_vector(BITS-1 downto 0);
          enviando_i : in  std_logic;
          dat_o      : out std_logic);   
end entity uart_tx;

architecture Behavioural of uart_tx is

COMPONENT baudRate IS
  port (clk_i    : in  std_logic;
        rst_i    : in  std_logic; 
        pulso_o  : out std_logic);   
END COMPONENT;

  type     estado is (idle, start, enviando_datos, stop);
  signal   proximo   : estado;
  signal   pulso     : std_logic;
  signal   registro  : std_logic_vector(BITS-1 downto 0);
  signal   contador  : unsigned(3 downto 0);  
           
begin
  dut: baudRate port map(clk_i   => clk_i,
                                   rst_i   => rst_i,
                                   pulso_o => pulso);                                                                                                        
  tx: 
  process (pulso) begin
    if rising_edge(pulso) then
      if rst_i = '1' then
        proximo  <= idle;
        contador <= (others => '0');
        registro <= (others => '0');
        dat_o    <= '1';
      else  
        case proximo is
          when idle =>      
            if enviando_i='1' then
              registro <= dat_i;
              dat_o    <= '1';
              proximo  <= start;
            end if;
            
          when start =>
              dat_o    <= '0';
              contador <= (others => '0');
              proximo  <= enviando_datos;          
            
          when enviando_datos =>
              contador <= contador + 1;
              dat_o    <= registro(0);
              registro <= registro(0) & registro(BITS-1 downto 1);
              if contador = BITS - 1 then
                proximo <= stop;
              end if;  
            
          when stop =>
              dat_o   <= '1';            
              proximo <= idle; 
    
        end case;    
      end if;
    end if;
  end process; 

end Behavioural;