----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.02.2024 19:01:41
-- Design Name: 
-- Module Name: pid_gen_tb - Behavioral
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

entity pid_gen_tb is
end pid_gen_tb;

architecture Behavioral of pid_gen_tb is

    constant CLK_PERIOD : time := 10 ns; -- Definir el periodo de la señal de reloj (ejemplo: 10 ns)
    signal CLK_PID : std_logic := '0'; -- Señal de reloj
    signal RESET : std_logic := '0'; -- Señal de reset
    signal SETVAL : integer := 0; -- Valor de establecimiento 
    signal sensVal : INTEGER:=0; -- Valor de realimentación recibido por el sensor
    signal PID_OUT : std_logic_vector(9 downto 0); -- Salida del PID

    -- Componente Under Test (UUT)
    component pid_gen
    Generic (
    SIZE: integer range 10 to 12 := 10;
    Kp : real range 0.0 to 255.0 := 0.0; --constante proporcional del PID
    Ki : real range 0.0 to 255.0 := 0.0; --constante integral del PID
    Kd : real range 0.0 to 255.0 := 0.0; --constante derivativa del PID
    T : real := 10.0E-9;
    valSat : integer := 1000 -- valor saturación motor para WINDUP
    );
    Port ( 
        CLK_PID : in STD_LOGIC; --senial de reloj
        RESET: in STD_LOGIC; --reset asíncrono
        SETVAL: in integer; --Valor de establecimiento 
        sensVal : in  INTEGER; -- valor de realimentación recibido por el sensor
        PID_OUT : out  STD_LOGIC_VECTOR (SIZE-1 downto 0) -- salida del PID    
        );
    end component;

begin

    UUT : pid_gen
    generic map (
        SIZE => 10,  -- Ejemplo de valores de prueba para los generics
        Kp => 10.0,
        Ki => 1.0,
        Kd => 1.0,
        T => 10.0E-9,
        valSat => 50000
    )
    port map (
        CLK_PID => CLK_PID,
        RESET => RESET,
        SETVAL => SETVAL,
        sensVal => sensVal,
        PID_OUT => PID_OUT
    );

    -- Proceso para generar la señal de reloj
    CLK_PROCESS : process
    begin
            CLK_PID <= '1';
            wait for (CLK_PERIOD/2);
            CLK_PID <= '0';
            wait for (CLK_PERIOD/2);
    end process;
    
    RESET <= '1', '0' after 1ms, '1' after 1ms + 200 ns, '0' after 2 ms,'1' after 3ms ,'0' after 3ms+20ns, '1' after 13 ms ,'0' after 13ms + 20ns;
    
    SETVAL <= 2000,1500 after 4ms ;
 
    sensVal <= 1991,1508 after 3ms+290ns,1998 after 3ms+445ns ;
    
end Behavioral;

