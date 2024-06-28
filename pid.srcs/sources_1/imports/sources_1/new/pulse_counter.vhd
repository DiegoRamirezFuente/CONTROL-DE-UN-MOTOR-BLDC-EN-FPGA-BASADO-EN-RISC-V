library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity pulse_counter is
  Generic (
    SAMPLES : INTEGER range 1 to 10 := 5; -- n�mero de muestras que se toman para hacer la media
    FREC : INTEGER range 0 to 1e9 := 100000000 -- frecuencia de conteo entre 10MHz y 1GHz
  );
  Port ( 
    CLK   : in std_logic;
    RESET : in std_logic;
    PULSE : in std_logic; -- pulso entrante procedente del sensor hall
    RPM : out std_logic_vector(19 downto 0) 
  );
end pulse_counter;

architecture Behavioral of pulse_counter is

  type state_type is (STOP, CALCULATE_S0, CALCULATE_S1, CALCULATE_S2, CALCULATE_S3);
  signal state, next_state : state_type := STOP;

  signal counter : INTEGER := 0; -- contador de pulsos de reloj
  signal pulse_count : INTEGER := 0; -- contador de pulsos entrantes del hall 

  signal Flag : std_logic := '0';

  constant MAX : INTEGER := 200000000; -- valor m�ximo del contador

  signal total : INTEGER := 0; -- almacena el sumatorio de las cuentas para hallar la media
  signal avg_count : INTEGER := 0; -- media de pulsos contados
  signal count_per_rev : INTEGER := 0;
  signal count_per_rev_frec : INTEGER := 0;
  signal rpm_v : INTEGER := 0;

begin

  counter_time: process(CLK, RESET)
  begin
    if RESET = '0' then
      state <= STOP;
      counter <= 0;
      pulse_count <= 0;
      total <= 0;
      avg_count <= 0;
      rpm_v <= 0;
    elsif rising_edge(CLK) then
      state <= next_state;
      
      case state is
        when STOP =>
          if Flag = '0' and PULSE = '1' then
            total <= total + counter;
            counter <= 0;
            Flag <= '1';
            pulse_count <= pulse_count + 1;
          elsif counter >= MAX then
              counter <= 0;
              pulse_count <= 0;
              total <= 0;
              avg_count <= 0;
              rpm_v <= 0;
          else
            counter <= counter + 1;
            Flag <= PULSE; -- Con esto se resetea el valor de flag permitiendo volver a detectar el flanco.
          end if;

          if pulse_count >= SAMPLES then
            next_state <= CALCULATE_S0;
          else
            next_state <= STOP;
          end if;

        when CALCULATE_S0 =>
          avg_count <= total / SAMPLES;
          pulse_count <= 0;
          next_state <= CALCULATE_S1;

        when CALCULATE_S1 =>
          count_per_rev <= avg_count * 24;
          next_state <= CALCULATE_S2;

        when CALCULATE_S2 =>
          count_per_rev_frec <= FREC / count_per_rev;
          total <= 0;
          next_state <= CALCULATE_S3;

        when CALCULATE_S3 =>
          rpm_v <= 60 * count_per_rev_frec;
          next_state <= STOP;

        when others =>
          next_state <= STOP;
      end case;
    end if;

    RPM <= std_logic_vector(to_unsigned(rpm_v, 20)); 

  end process;

end Behavioral;
