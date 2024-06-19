library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity pulse_counter is
  Generic (
    SAMPLES : INTEGER range 1 to 10 := 5; -- numero de muestras que se toman para hacer la media
    FREC : INTEGER range 0 to 1e9 := 1000000 -- frecuencia de conteo entre 10Mhz y 1Ghz
  );
  Port ( 
    CLK   : in std_logic;
    RESET : in std_logic;
    PULSE : in STD_LOGIC; -- pulso entrante procedente del sensor hall
    RPM : out std_logic_vector(19 downto 0) 
  );
end pulse_counter;

architecture Behavioral of pulse_counter is

  type state_type is (STOP, CALCULATE_S0, CALCULATE_S1, CALCULATE_S2, CALCULATE_S3);
  signal state, next_state : state_type := STOP;

  signal counter : INTEGER := 0; -- contador de pulsos de reloj
  signal pulse_count : INTEGER := 0; -- contador de pulsos entrantes del hall 

  signal Flag : std_logic := '0';

  constant MAX : std_logic_vector(32 downto 0) := (others => '1');

  signal total : INTEGER := 0; -- almacena el sumatorio de las cuentas para hallar la media
  signal avg_count : INTEGER := 0; -- media de pulsos contados
  signal count_per_rev : integer := 0;
  signal count_per_rev_frec : integer := 0;
  signal time_per_rev : integer := 0;
  signal rpm_v : integer := 0;

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
          elsif counter = to_integer(unsigned(MAX)) then
            avg_count <= to_integer(unsigned(MAX));
            total <= 0;
            pulse_count <= 0;
          else
            counter <= counter + 1;
            Flag <= PULSE; -- Con esto se resetea el valor de flag permitiendo volver a detectar el flanco.
          end if;

          if pulse_count >= SAMPLES then
            next_state <= CALCULATE_S0;
          end if;

        when CALCULATE_S0 =>
          avg_count <= total / SAMPLES;
          pulse_count <= 0;
          next_state <= CALCULATE_S1;

        when CALCULATE_S1 =>
          count_per_rev <= avg_count * 6;
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
