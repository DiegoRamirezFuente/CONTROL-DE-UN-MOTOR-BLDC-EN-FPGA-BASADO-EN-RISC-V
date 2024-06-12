library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY top_display IS
Generic(SIZE : integer range 8 to 20 := 8);
 PORT ( 
 clk_disp:in std_logic;
 reset_disp:in std_logic;
 input : in  std_logic_vector(SIZE-1 DOWNTO 0);
 v_sal : OUT std_logic_vector(7 DOWNTO 0);
 segment : OUT std_logic_vector(6 DOWNTO 0)
 );
END top_display;
architecture Behavioral of top_display is

COMPONENT decoder
PORT (
code : IN std_logic_vector(3 DOWNTO 0);
led : OUT std_logic_vector(6 DOWNTO 0)
);
END COMPONENT;

COMPONENT cambio_digsel is
    port (
        clk : in std_logic;
        segment_uni_in:in std_logic_vector(6 downto 0);
        segment_dec_in:in std_logic_vector(6 downto 0);
        segment_cen_in:in std_logic_vector(6 downto 0);
        segment_mil_in:in std_logic_vector(6 downto 0);
        segment_uni2_in:in std_logic_vector(6 downto 0);
        segment_dec2_in:in std_logic_vector(6 downto 0);
        segment_cen2_in:in std_logic_vector(6 downto 0);
        segment_mil2_in:in std_logic_vector(6 downto 0);
        digsel : out std_logic_vector(7 downto 0);
        segment_out:out std_logic_vector(6 downto 0)
    );
    END COMPONENT;

COMPONENT separator
    Generic(SIZE : integer range 8 to 20 := 8);
    port (
        input : in  std_logic_vector(SIZE-1 DOWNTO 0);
        digit1, digit2, digit3, digit4 : out std_logic_vector(3 DOWNTO 0);
        digit5, digit6, digit7, digit8 : out std_logic_vector(3 DOWNTO 0)
    );
END COMPONENT;

signal uni, dec, cen, mil: std_logic_vector(3 DOWNTO 0);
signal segment_uni_sig:std_logic_vector(6 downto 0);
signal segment_dec_sig: std_logic_vector(6 downto 0);
signal segment_cen_sig: std_logic_vector(6 downto 0);
signal segment_mil_sig: std_logic_vector(6 downto 0);

signal uni2, dec2, cen2, mil2: std_logic_vector(3 DOWNTO 0);
signal segment_uni2_sig:std_logic_vector(6 downto 0);
signal segment_dec2_sig: std_logic_vector(6 downto 0);
signal segment_cen2_sig: std_logic_vector(6 downto 0);
signal segment_mil2_sig: std_logic_vector(6 downto 0);


begin
    
separador_de_cifras1: separator
    Generic map(SIZE => SIZE )
    port map (
        input => input,
        digit1 => uni ,
        digit2 => dec ,
        digit3 => cen ,
        digit4 => mil ,
        digit5 => uni2 ,
        digit6 => dec2 ,
        digit7 => cen2 ,
        digit8 => mil2     
    );


    display_unidades: decoder port map(
    code => uni ,
    led => segment_uni_sig
    );

    display_decenas: decoder port map(
    code => dec ,
    led => segment_dec_sig
    );
    
    display_centenas: decoder port map(
    code => cen ,
    led => segment_cen_sig
    );

    display_millares: decoder port map(
    code => mil ,
    led => segment_mil_sig
    );
    
    display_unidades2: decoder port map(
    code => uni2 ,
    led => segment_uni2_sig
    );

    display_decenas2: decoder port map(
    code => dec2 ,
    led => segment_dec2_sig
    );
    
    display_centenas2: decoder port map(
    code => cen2 ,
    led => segment_cen2_sig
    );

    display_millares2: decoder port map(
    code => mil2 ,
    led => segment_mil2_sig
    );
    
    gestion_digsel: cambio_digsel
    port map (
        clk => clk_disp,
        segment_uni_in => segment_uni_sig, 
        segment_dec_in => segment_dec_sig,
        segment_cen_in => segment_cen_sig, 
        segment_mil_in => segment_mil_sig,
        segment_uni2_in => segment_uni2_sig, 
        segment_dec2_in => segment_dec2_sig,
        segment_cen2_in => segment_cen2_sig, 
        segment_mil2_in => segment_mil2_sig,
        digsel => v_sal,
        segment_out => segment
    );
    
end Behavioral;