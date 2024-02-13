----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2024 21:38:22
-- Design Name: 
-- Module Name: top - Behavioral
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

ENTITY top IS
 PORT (
 RESET : in std_logic;
 CLK : in std_logic
 );
end top;

architecture Behavioral of top is

component pid_gen is
Generic (
    Kp : integer := 10; --constante proporcional del PID
    Ki : integer := 20; --constante integral del PID
    Kd : integer := 1; --constante derivativa del PID
    valSat : in  integer := 65535 -- valor saturación motor para WINDUP
    );
Port ( 
    RESET_N: in STD_LOGIC; --reset negado asíncrono
    SETVAL: in integer; --Valor de establecimiento 
    ADC_DATA : in  STD_LOGIC_VECTOR (15 downto 0); -- entrada analógica de 16 bits
    DAC_DATA : out  STD_LOGIC_VECTOR (15 downto 0); -- salida analógica de 16 bits
    CLK_PID : in STD_LOGIC
    );
end component;

component pwm_gen is
Port (
    CLK : in STD_LOGIC; --reloj de la placa
    RESET_N : in STD_LOGIC; --reset negado asíncrono
    PWM_IN : in STD_LOGIC_VECTOR(15 downto 0); --salida del PID
    PWM_OUT : out STD_LOGIC --senial de salida del PWM hacia el motor
 );
end component;

 component pos_encoder is
        Port (
            clk : in STD_LOGIC;
            reset_n : in STD_LOGIC;
            encoder_a : in STD_LOGIC;
            encoder_b : in STD_LOGIC;
            position : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
    
component com_uart is
   generic (DATA_WIDTH : integer := 16); --genérico para modificar la longitud de la palabra
  port (
    CLK       : in std_logic; --reloj de la placa
    RST_N      : in std_logic; --reset negado asíncrono
    BIT_INICIO : in std_logic; --marca el inicio de la transmisión
    TxD_WORD   : in std_logic_vector(DATA_WIDTH - 1 downto 0); --palabra transmitida
    TxD_BUSY   : out std_logic; --avisa de que la transmisión está en proceso
    TxD        : out std_logic --salida de la palabra y los bits de inicio y stop bit a bit
  );
end component;

signal pid_o : STD_LOGIC_VECTOR (15 downto 0);
signal pwm_o : STD_LOGIC;
signal val_estab: integer;
signal encoder_a : STD_LOGIC := '0';
signal encoder_o : STD_LOGIC;
signal encoder_b : STD_LOGIC := '0';
signal position : STD_LOGIC_VECTOR (7 downto 0);
signal busy : STD_LOGIC := '0';
constant bits : integer:=8;

begin

pid: pid_gen
Port map ( 
    RESET_N => RESET,
    SETVAL => val_estab,
    ADC_DATA => encoder_o, --mal
    DAC_DATA => pid_o,
    CLK_PID => CLK
    );

pwm: pwm_gen
Port map (
    CLK => CLK,
    RESET_N => RESET,
    PWM_IN => pid_o,
    PWM_OUT => pwm_o
 );


encoder_posicion: pos_encoder
        port map (
            clk => clk,
            reset_n => reset,
            encoder_a => encoder_a,
            encoder_b => encoder_b,
            position => position
        );
        
uart: com_uart 
port map (
    CLK => CLK,
    RST_N => RESET,
    BIT_INICIO => '1',
    TxD_WORD => position,
    TxD_BUSY => busy,
    TxD => encoder_o --duda
 );

end Behavioral;
