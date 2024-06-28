library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity pid_top is
    Generic (
        Kp : integer range 0 to 255 := 0; --constante proporcional del PID
        Ki : integer range 0 to 255 := 0; --constante integral del PID
        Kd : integer range 0 to 255 := 0; --constante derivativa del PID
        T : integer := 100;
        valSat : integer := 2000 -- valor saturación motor para WINDUP
    );
    Port (
        CLK : in STD_LOGIC; -- senial de reloj
        RESET : in STD_LOGIC; -- reset asíncrono
        SETVAL : in integer; -- valor de establecimiento
        SENSOR_VAL : in std_logic_vector(19 downto 0); -- valor de realimentación recibido por el sensor
        PID_OUTPUT : out integer range 0 to 2000 -- salida del PID
    );
end pid_top;

architecture Behavioral of pid_top is

COMPONENT RampGenerator
    Port (
        CLK : in std_logic;
        RESET : in std_logic;  -- Reset asíncrono negado
        SETVAL : in integer;
        RAMPA : out integer
    );
END COMPONENT;

COMPONENT pid_gen
Generic (
    Kp : integer range 0 to 255 := 0; --constante proporcional del PID
    Ki : integer range 0 to 255 := 0; --constante integral del PID
    Kd : integer range 0 to 255 := 0; --constante derivativa del PID
    T : integer := 100;
    valSat : integer := 2000 -- valor saturación motor para WINDUP
    );
Port ( 
    CLK : in STD_LOGIC; --senial de reloj
    RESET: in STD_LOGIC; --reset asíncrono
    SETVAL: in integer; --Valor de establecimiento 
    sensVal : in std_logic_vector(19 downto 0); -- valor de realimentación recibido por el sensor
    PID_OUT : out  integer -- salida del PID    
    );
END COMPONENT;

    signal rampa_output : integer;

begin

    -- Instancia del generador de rampa
    RampGen_inst : RampGenerator
        Port map (
            CLK => CLK,
            RESET => RESET,
            SETVAL => SETVAL,
            RAMPA => rampa_output
        );

    -- Instancia del PID
    PIDGen_inst : pid_gen
        Generic map (
            Kp => Kp,
            Ki => Ki,
            Kd => Kd,
            valSat => valSat
        )
        Port map (
            CLK => CLK,
            RESET => RESET,
            SETVAL => rampa_output, -- Conexión de la salida del generador de rampa a la entrada de SETVAL del PID
            sensVal => SENSOR_VAL,
            PID_OUT => PID_OUTPUT
        );

end Behavioral;
