----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.05.2024 23:05:45
-- Design Name: 
-- Module Name: frec_gen - Behavioral
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

ENTITY frec_gen IS  
PORT  
( 
  CLK    : IN STD_LOGIC; 
  F_BASE    : IN INTEGER; 
  FREC_OUT  : OUT STD_LOGIC 
   
); 
END frec_gen; 
 
 
ARCHITECTURE BEHAVIORAL OF frec_gen IS 
 
SIGNAL COUNT  : INTEGER := 0; 
SIGNAL CLK_OUT    : STD_LOGIC:='0'; 
 
BEGIN 
 
PROCESS (CLK) 
BEGIN 
 
  IF CLK'EVENT AND CLK = '1' THEN 
    
    IF COUNT >= F_BASE THEN 
       COUNT <= 0; 
       CLK_OUT <= NOT CLK_OUT; 
    ELSE 
       COUNT <= COUNT + 1; 
    END IF;
    
END IF; 
END PROCESS; 
 
FREC_OUT <= CLK_OUT; 
 
END BEHAVIORAL;