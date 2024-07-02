library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity pulse_counter is
  Generic (
    SIZE : INTEGER := 20;
    SAMPLES : INTEGER range 1 to 10 := 5; -- número de muestras que se toman para hacer la media
    FREC : INTEGER range 0 to 1e9 := 100000000 -- frecuencia de conteo entre 10MHz y 1GHz
  );
  Port ( 
    CLK   : in std_logic;
    RESET : in std_logic;
    PULSE : in std_logic; -- pulso entrante procedente del sensor hall
    RPM : out std_logic_vector(SIZE-1 downto 0) 
  );
end pulse_counter;

architecture Behavioral of pulse_counter is

  type state_type is (STOP, CALCULATE_S0, CALCULATE_S1, CALCULATE_S2, CALCULATE_S3);
  signal state, next_state : state_type := STOP;

  signal counter : INTEGER := 0; -- contador de pulsos de reloj
  signal pulse_count : INTEGER := 0; -- contador de pulsos entrantes del hall
  signal p_count : INTEGER range 0 to SAMPLES := 0; -- índice para el buffer circular

  signal Flag : std_logic := '0';

  constant MAX : INTEGER := 200000000; -- valor máximo del contador

  -- Buffer circular para almacenar las últimas SAMPLES muestras
  type pulse_history_type is array (0 to SAMPLES-1) of INTEGER;
  signal pulse_history : pulse_history_type := (others => 0);

  signal avg_count : INTEGER := 0; -- media de pulsos contados
  signal count_per_rev : INTEGER := 0;
  signal count_per_rev_frec : INTEGER := 0;
  signal rpm_v : INTEGER := 0;

begin

  counter_time_and_rpm_calculation: process(CLK, RESET)
    variable pulse_sum : INTEGER := 0; -- suma de las muestras en pulse_history
  begin
    if RESET = '0' then
      -- Estado de reset: inicialización de variables
      state <= STOP;
      counter <= 0;
      pulse_count <= 0;
      p_count <= 0;
      pulse_sum := 0;
      avg_count <= 0;
      rpm_v <= 0;
      Flag <= '0';
      -- Inicialización del buffer pulse_history con valores válidos (ejemplo: 0s)
      for i in 0 to SAMPLES-1 loop
        pulse_history(i) <= 0;
      end loop;
    elsif rising_edge(CLK) then
      state <= next_state;
      -- Incrementar contador de pulsos de reloj siempre
      counter <= counter + 1;
      
        if counter >= MAX then
              counter <= 0;
              pulse_count <= 0;
              pulse_sum := 0;
              avg_count <= 0;
              rpm_v <= 0;
      
          elsif PULSE = '1' and Flag = '0' then
        --pulse_sum := pulse_sum + counter - pulse_history(p_count mod SAMPLES); -- Actualizar la suma restando el valor antiguo
        pulse_history(p_count mod SAMPLES) <= counter; -- Guardar el pulso actual en el historial circular
        counter <= 0;
        p_count <= p_count + 1;
        if pulse_count < SAMPLES then
            pulse_count <= pulse_count + 1;
        end if;
        Flag <= '1';
      elsif PULSE = '0' then
        Flag <= '0'; -- Resetear Flag cuando PULSE vuelva a ser '0'
      end if;

      -- Control de estado independiente del contador de pulsos
      case state is
        when STOP =>
            -- Inicializar `pulse_sum` solo una vez, cuando se entra en el estado STOP
            
              pulse_sum := 0;
              for i in 0 to SAMPLES-1 loop
                pulse_sum := pulse_sum + pulse_history(i);
              end loop;
            
            next_state <= CALCULATE_S0;
            
        when CALCULATE_S0 =>
          -- Cálculo de la media móvil ajustada según la cantidad de muestras válidas en pulse_history
          if pulse_count > 0 then
            avg_count <= pulse_sum / pulse_count; -- Media móvil ajustada al número actual de muestras en pulse_history
          else
            avg_count <= 0;  -- Asignación por defecto si no hay muestras
          end if;
          next_state <= CALCULATE_S1;

        when CALCULATE_S1 =>
          count_per_rev <= avg_count * 24;
          next_state <= CALCULATE_S2;

        when CALCULATE_S2 =>
          if count_per_rev /= 0 then
            count_per_rev_frec <= FREC / count_per_rev;
          else
            count_per_rev_frec <= 0;  -- Asignación por defecto si count_per_rev es cero
          end if;
          next_state <= CALCULATE_S3;

        when CALCULATE_S3 =>
          rpm_v <= 60 * count_per_rev_frec;
          next_state <= STOP;

        when others =>
          next_state <= STOP;
      end case;
    end if;
  end process;

  -- Salida de las RPM calculadas
  RPM <= std_logic_vector(to_unsigned(rpm_v, SIZE)); 

end Behavioral;
