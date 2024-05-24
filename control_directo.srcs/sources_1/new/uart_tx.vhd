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

LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


------------------------------------------------------------------------- 
 ENTITY uart_tx IS  
 
PORT ( 
  BAUD   : IN STD_LOGIC; 
  TxD_INICIO  : IN STD_LOGIC; 
  TxD_DATO  : IN STD_LOGIC_VECTOR (7 DOWNTO 0); 
  TxD  : OUT STD_LOGIC; 
  TxD_BUSY : OUT STD_LOGIC 
); 

 
END uart_tx; 
 
 
ARCHITECTURE BEHAVIORAL OF uart_tx IS 
 
SIGNAL TxD_AUX_DATO : STD_LOGIC_VECTOR (7 DOWNTO 0); 
SIGNAL STATE : STD_LOGIC_VECTOR (3 DOWNTO 0):="0000"; 
SIGNAL NEXT_STATE : STD_LOGIC_VECTOR (3 DOWNTO 0):="0000"; 
SIGNAL TxD_READY : STD_LOGIC; 
 
 
BEGIN 
 
PROCESS (STATE) 
BEGIN 
CASE STATE IS  
 
   WHEN "0000" => TxD_READY <= '1'; 
   WHEN OTHERS => TxD_READY <= '0'; 
    
END CASE; 
 
END PROCESS; 
 
PROCESS (STATE) 
BEGIN 
CASE STATE IS  
 
   WHEN "0000" => TxD_BUSY <= '0'; 
   WHEN OTHERS => TxD_BUSY <= '1'; 
    
END CASE;

END PROCESS; 
 
   
 
PROCESS (TxD_READY) 
BEGIN 
 
IF TxD_READY'EVENT AND TxD_READY ='1' THEN 
 
TxD_AUX_DATO <= TxD_DATO; 
 
END IF; 
 
END PROCESS; 
 
 
PROCESS (BAUD) 
BEGIN 
IF BAUD'EVENT AND BAUD = '1' THEN 
 
 IF TxD_INICIO = '0' THEN 
   STATE <= "0000"; 
 ELSE 
   STATE<= NEXT_STATE; 
 END IF; 
END IF; 
 
END PROCESS; 
 
PROCESS (STATE) 
BEGIN 
CASE STATE IS  
 
 WHEN "0000" => NEXT_STATE <= "0001"; 
 WHEN "0001" => NEXT_STATE <= "0010"; 
 WHEN "0010" => NEXT_STATE <= "0011"; 
 WHEN "0011" => NEXT_STATE <= "0100"; 
 WHEN "0100" => NEXT_STATE <= "0101"; 
 WHEN "0101" => NEXT_STATE <= "0110"; 
 WHEN "0110" => NEXT_STATE <= "0111"; 
 WHEN "0111" => NEXT_STATE <= "1000"; 
 WHEN "1000" => NEXT_STATE <= "1001"; 
 WHEN "1001" => NEXT_STATE <= "1010"; 
 WHEN "1010" => NEXT_STATE <= "1011"; 
 WHEN "1011" => NEXT_STATE <= "1011"; 
 WHEN OTHERS => NEXT_STATE <= "1011"; 
  
END CASE; 
 
END PROCESS; 
 
 
PROCESS (STATE,TXD_AUX_DATO) 
BEGIN 
CASE STATE IS 
WHEN "0000" => TxD  <= '1' ; 
 WHEN "0001" => TxD  <= '0' ; 
 WHEN "0010" => TxD  <= TxD_AUX_DATO(0); 
 WHEN "0011" => TxD  <= TxD_AUX_DATO(1); 
 WHEN "0100" => TxD  <= TxD_AUX_DATO(2); 
 WHEN "0101" => TxD  <= TxD_AUX_DATO(3); 
 WHEN "0110" => TxD  <= TxD_AUX_DATO(4); 
 WHEN "0111" => TxD  <= TxD_AUX_DATO(5); 
 WHEN "1000" => TxD  <= TxD_AUX_DATO(6); 
 WHEN "1001" => TxD  <= TxD_AUX_DATO(7); 
 WHEN "1010" => TxD  <= '1'; 
 WHEN "1011" => TxD  <= '1'; 
 WHEN OTHERS => TxD  <= '1';  
 
END CASE; 
 
END PROCESS; 
 
END BEHAVIORAL;