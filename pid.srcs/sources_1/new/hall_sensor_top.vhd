----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2024 17:46:32
-- Design Name: 
-- Module Name: pid_top - Behavioral
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

entity hall_sensor_top is
Generic( SIZE: integer range 10 to 15 := 13);
Port ( 
    CLK : in STD_LOGIC;
    RESET : in STD_LOGIC;
    A, B, C : in STD_LOGIC;
    RPM : out STD_LOGIC_VECTOR (SIZE-1 downto 0) 
);
end hall_sensor_top;

architecture Behavioral of hall_sensor_top is

signal sig_pulse : std_logic := '0';
signal rpm_s : integer := 0;

COMPONENT hall_pulse_gen IS
Port(
    CLK : in std_logic;
	RESET : in std_logic;
    A, B, C : in std_logic;
    PULSE : out std_logic
);
END COMPONENT;

COMPONENT pulse_counter is
    Port (
        CLK : in STD_LOGIC;
        RESET : in STD_LOGIC;
        PULSE : in STD_LOGIC;
        RPM : out INTEGER
    );
END COMPONENT;

begin

RPM <= std_logic_vector(to_unsigned(rpm_s,SIZE));

uut_hall_pulse_gen: hall_pulse_gen
Port map(
    CLK => CLK,
	RESET => RESET,
    A => A,
    B => B,
    C => C,
    PULSE => sig_pulse
);

uut_pulse_counter: pulse_counter
Port map (
    CLK => CLK,
    RESET => RESET,
    PULSE => sig_pulse,
    RPM => rpm_s
);

end Behavioral;