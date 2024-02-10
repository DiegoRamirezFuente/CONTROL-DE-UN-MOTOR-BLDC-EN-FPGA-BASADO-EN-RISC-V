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
   generic (DATA_WIDTH : integer := 16); --genérico para modificar la longitud de la palabra
  port (
    CLK       : in std_logic; --reloj de la placa
    RST_N      : in std_logic; --reset negado asíncrono
    BIT_INICIO : in std_logic; --marca el inicio de la transmisión
    TxD_WORD   : in std_logic_vector(DATA_WIDTH - 1 downto 0); --palabra transmitida
    TxD_BUSY   : out std_logic; --avisa de que la transmisión está en proceso
    TxD        : out std_logic --salida de la palabra y los bits de inicio y stop bit a bit
  );
end com_uart;

architecture Behavioral of com_uart is

signal word: std_logic_vector(DATA_WIDTH - 1 downto 0); --señal auxiliar para almacenar la palabra
signal BAUD : std_logic;

type state_type is (IDLE,START,SEND,STOP);	-- estados de la maquina de estados de la transmisión                          
signal state: state_type := IDLE; 
signal next_state : state_type := state; 

signal TxD_READY : STD_LOGIC; --avisa de que la transmisión puede comenzar
signal counter : unsigned(3 downto 0); --para contar el numero de bits que hay que transmitir

component baudRate is --instancia de la entidad que crea el pulso a 9600 baudios para la transmisión
  port (clk_i    : in  std_logic;
        rst_i    : in  std_logic; 
        pulso_o  : out std_logic);
 end component;       

begin
   
 dut: component baudRate port map(clk_i   => CLK,
                                   rst_i   => RST_N,
                                   pulso_o => BAUD);
                                   
state_reg:process(BAUD,RST_N) -- actualiza el estado de trabajo en cada flanco de reloj
begin
    if RST_N = '0' then --si se activa reset se vuelve al estado de reposo
        state <= IDLE;
        counter <= (others => '0');
        word <= (others => '0');
    elsif rising_edge(BAUD) then --cada flanco de reloj se cambia de estado,
    if BIT_INICIO ='0' then      --siempre que el bit de inicio de la transmisión esté activo
        state <=IDLE;
        else 
        state <= next_state;
    end if;
    end if;
end process;
    
next_state_decoder:process(state) -- establece la secuencia de estados
begin
    case state is
        when IDLE => next_state <= START; 
        when START => next_state <= SEND;            
        when SEND => if counter = DATA_WIDTH-1 then --cuando se hayan trasnmitido todos los bits
                        next_state <= STOP;            --de la palabra se pasa a estado STOP
                     end if;
        when STOP => next_state <= IDLE; 
        when others => next_state <= STOP;
    end case;      
end process;

idle_state:process(state)
begin
    if state = IDLE then
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
        word <= TxD_WORD;          --se transmite la palabra entrante
    end if;
end process;

output_decoder:process(state) -- establece las funciones que realizará cada estado
begin
case state is
    when IDLE => TxD <= '1';
    
    when START => TxD <= '0'; --avisa del inicio de la palabra
                  counter <= (others => '0');
                  
    when SEND => counter <= counter + 1; --incrementa el contador
                 TxD <= word(0);           --actualiza el valor de la salida
                 word <= word(0) & word(DATA_WIDTH-1 downto 1); --permite que en la siguiente iteracion se mande el siguiente bit 
   
    when STOP => TxD <= '1'; --avisa del final de la palabra
    
    when others => TxD <= '1';
end case;      
end process;

end Behavioral;
