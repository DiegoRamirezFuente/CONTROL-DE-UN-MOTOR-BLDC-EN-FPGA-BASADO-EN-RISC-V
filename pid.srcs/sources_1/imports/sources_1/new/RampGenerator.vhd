library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RampGenerator is
    Port (
        CLK : in std_logic;
        RESET : in std_logic;  -- Reset asíncrono negado
        SETVAL : in integer;
        RAMPA : out integer
    );
end RampGenerator;

architecture Behavioral of RampGenerator is
    signal count : unsigned(31 downto 0) := (others => '0');
    signal last_setval : integer := 0;
begin
    process(CLK, RESET)
    begin
        if RESET = '0' then  -- Comprueba si reset es '0'
            count <= (others => '0');
            last_setval <= 0;
        elsif rising_edge(CLK) then
            if SETVAL > last_setval and count < to_unsigned(SETVAL, 32) then
                count <= count + 1;
            elsif SETVAL < last_setval and count > to_unsigned(SETVAL, 32) then
                count <= count - 1;
            end if;
            if count = to_unsigned(SETVAL, 32) then
                last_setval <= SETVAL;
            end if;
        end if;
    end process;

    RAMPA <= to_integer(count);
end Behavioral;
