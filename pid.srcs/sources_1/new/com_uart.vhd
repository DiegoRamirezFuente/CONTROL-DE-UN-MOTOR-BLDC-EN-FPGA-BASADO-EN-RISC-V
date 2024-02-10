----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.02.2024 14:07:35
-- Design Name: 
-- Module Name: com_uart - Behavioral
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


library ieee;   
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity com_uart is
   generic (
    CLK_PERIOD_NS  : time    := 10 ns;
    UART_PERIOD_NS : time    := 8680 ns;
    DATA_WIDTH     : integer := 8; --genérico para modificar la longitud de la palabra
    PARITY_TYPE    : integer := 0; -- 0 is Even and 1 is Odd
    N_PARITY_BIT   : integer := 0
  );
  port (
    BAUD       : in std_logic; --señal de reloj de la transmisión a 9600 baudios
    RST_N      : in std_logic; --reset negado asíncrono
    BIT_INICIO : in std_logic; --marca el inicio de la transmisión
    TxD_WORD     : in std_logic_vector(DATA_WIDTH - 1 downto 0); --palabra transmitida
    TxD_BUSY   : out std_logic; --avisa de que la transmisión está en proceso
    TxD        : out std_logic --salida de la palabra y los bits de inicio y stop bit a bit
  );
end com_uart;

architecture Behavioral of com_uart is

signal word: std_logic_vector(DATA_WIDTH - 1 downto 0); --señal auxiliar para almacenar la palabra
type state_type is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11);	-- estados de la maquina para calcular el PID                             
signal state: state_type := S0; 
signal next_state : state_type := state; 
signal TxD_READY : STD_LOGIC; --avisa de que la transmisión puede comenzar

begin

state_reg:process(BAUD,RST_N) -- actualiza el estado de trabajo en cada flanco de reloj
begin
    if RST_N = '0' then --si se activa reset se vuelve al estado de reposo
        state <= S0;
    elsif rising_edge(BAUD) then --cada flanco de reloj se cambia de estado
    if BIT_INICIO ='0' then    --siempre que el bit de inicio de la transmisión esté activo
        state <= S0;
        else 
        state <= next_state;
    end if;
    end if;
end process;
    
next_state_decoder:process(state) -- establece la secuencia de estados
begin
case state is
    when S0 => next_state <= S1; 
    when S1 => next_state <= S2; 
    when S2 => next_state <= S3;  
    when S3 => next_state <= S4; 
    when S4 => next_state <= S5;  
    when S5 => next_state <= S6;
    when S6 => next_state <= S7; 
    when S7 => next_state <= S8; 
    when S8 => next_state <= S9;
    when S9 => next_state <= S10;
    when S10 => next_state <= S11;
    when S11 => next_state <= S11;
    when others => next_state <= S11;
end case;      
end process;

idle_state:process(state)
begin
if state = S0 then
TxD_READY <= '1'; --la transmision comenzará siempre desde el estado de reposo
TxD_BUSY <= '0';
else 
TxD_READY <= '0'; --en cualquier otro estado el proceso estará ocupado
TxD_BUSY <= '1';
end if;
end process;

word_assignment:process(TxD_READY)
begin
if rising_edge(TxD_READY) then --cada vez que se active el bit de ready
word <= TxD_WORD; --se transmite la palabra entrante
end if;
end process;

output_decoder:process(state) -- establece las funciones que realizará cada estado
begin
case state is
    when S0 => TxD <= '1';
    when S1 => TxD <= '0'; --avisa del inicio de la palabra
    when S2 => TxD <= TxD_WORD(0);
    when S3 => TxD <= TxD_WORD(1);
    when S4 => TxD <= TxD_WORD(2);
    when S5 => TxD <= TxD_WORD(3);
    when S6 => TxD <= TxD_WORD(4);
    when S7 => TxD <= TxD_WORD(5);
    when S8 => TxD <= TxD_WORD(6);
    when S9 => TxD <= TxD_WORD(7);
    when S10 => TxD <= '1'; --avisa del final de la palabra
    when S11 => TxD <= '1';
    when others => TxD <= '1';
end case;      
end process;

end Behavioral;
