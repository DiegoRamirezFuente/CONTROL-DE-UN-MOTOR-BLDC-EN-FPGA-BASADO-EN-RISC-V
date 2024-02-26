----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2024 17:29:22
-- Design Name: 
-- Module Name: pulse_counter - Behavioral
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

entity pulse_counter is
    Generic (
        SAMPLES : INTEGER range 1 to 10 := 5; --numero de muestras que se toman para hacer la media
        FREC : INTEGER range 10e6 to 1e9 := 100e6 --frecuencia de conteo entre 10Mhz y 1Ghz
        );                                        --por defecto 100 MHz de la placa NexysDDR4
    Port (
        CLK : in STD_LOGIC; --senial de reloj
        RESET : in STD_LOGIC; --reset asíncrono
        PULSE : in STD_LOGIC; --pulso entrante procedente del sensor hall
        RPM : out REAL --velocidad de giro del motor en RPM
    );
end pulse_counter;

architecture Behavioral of pulse_counter is
    signal counter : INTEGER := 0; --contador de pulsos de reloj
    signal pulse_count : INTEGER := 0; -- contador de pulsos entrantes del hall 
    signal total : INTEGER := 0; --almacena el sumatorio de las cuentas para hallar la media
    signal avg_count : REAL := 0.0; --media de pulsos contados
    
begin

process(CLK, RESET, PULSE)
begin
    if RESET = '1' then --valores de reset
        counter <= 0;
        pulse_count <= 0;
        total <= 0;
        avg_count <= 0.0;
        
    elsif rising_edge(PULSE) then --detector de flanco de PULSE
        pulse_count <= pulse_count + 1; --incrementa e contador de pulsos
        total <= total + counter; --acumula los pulsos de reloj contados
        counter <= 0; --reinicia la cuenta
        if pulse_count = SAMPLES then --cuando cuenta el número de pulsos establecidos
            avg_count <= REAL(total) / REAL(SAMPLES); --calcula la media
            pulse_count <= 0; --reinicia la cuenta
            total <= 0;
        end if;
    elsif rising_edge(CLK) then    
         counter <= counter + 1; --se incrementa con cada flanco de reloj
    end if;
end process;

 RPM <= 0.0 when avg_count <= 0.0 else 
(10.0*REAL(FREC))/avg_count when avg_count > 0.0;

end Behavioral;