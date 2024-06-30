  -- #################################################################################################
-- # << NEORV32 - Test Setup using the internal IMEM as ROM to run pre-installed executables >>    #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2023, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32                           #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_test_setup_diego is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 100_000_000;  -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 16 * 1_024;  -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural :=  8 * 1_024   -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    CLK100MHZ      : in  std_ulogic;                     -- board clock
    CPU_RESETN       : in  std_ulogic;  -- reset button
    -- UART0
    UART_RXD_OUT  : out std_ulogic;
    UART_TXD_IN  : in  std_ulogic;
    -- PID CONTROL--
    A, B, C : in std_logic;
    PWM_A, PWM_B, PWM_C : out std_logic;
    EN1, EN2, EN3 : out std_logic;
    LED : out std_logic_vector(5 downto 0);
    LED16_R : out std_logic;
    AN : out std_logic_vector(7 downto 0);
    SEGMENT : out std_logic_vector(6 downto 0) 
  );
end entity;

architecture riscv_soc_top_rtl of neorv32_test_setup_diego is

COMPONENT top_gpio
    Generic(
        Frecuencies: integer range 1000 to 2500:= 2000; -- Valor de la frecuencia
        SIZE : integer := 32
        );
    Port (
        CLK : in std_logic;
        RESET : in std_logic;
        entrada : in std_ulogic_vector(SIZE-1 downto 0); -- Cambiado a std_ulogic_vector
        A, B, C : in std_logic;
        PWM_AH, PWM_BH, PWM_CH : out std_logic;
        EN1, EN2, EN3 : out std_logic;
        ESTADO : out std_logic_vector(5 downto 0);
        ERROR : out std_logic;
        digctrl : out std_logic_vector(7 downto 0);
        segment : out std_logic_vector(6 downto 0)
    );
END COMPONENT;

  signal con_gpio_o : std_ulogic_vector(63 downto 0);
  signal led_s : std_ulogic_vector(39 downto 0);  -- LED array
--  signal rgb_led_o  : std_ulogic_vector(2 downto 0);

begin
  -- The Core Of The Problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_top_inst: neorv32_top
  generic map (
    -- General --
    CLOCK_FREQUENCY              => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    INT_BOOTLOADER_EN            => false,             -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- RISC-V CPU Extensions --
    CPU_EXTENSION_RISCV_C        => true,              -- implement compressed extension?
    CPU_EXTENSION_RISCV_M        => true,              -- implement mul/div extension?
    CPU_EXTENSION_RISCV_Zicntr   => true,              -- implement base counters?
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN              => true,              -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN              => true,              -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_GPIO_NUM                  => 40,                 -- number of GPIO input/output pairs (0..64)
    IO_UART0_EN                  => true,              -- implement primary universal asynchronous receiver/transmitter (UART0)?
    --IO_UART0_TX_FIFO             => 16,                -- TX fifo depth, has to be a power of two, min 1
    IO_MTIME_EN                  => true               -- implement machine system timer (MTIME)?
  )
  port map (
    -- Global control --
    clk_i  => CLK100MHZ,         -- global clock, rising edge
    rstn_i => CPU_RESETN,  -- global reset, low-active, async
    -- UART --
    uart0_txd_o => UART_RXD_OUT,
    uart0_rxd_i => UART_TXD_IN,
    -- GPIO (available if IO_GPIO_NUM > 0) --
    gpio_o => con_gpio_o -- parallel output
  );
  
  led_s <= con_gpio_o(39 downto 0);
  
  UUT: top_gpio
    Generic map(
        Frecuencies => 2000,
        SIZE => 40
    )
    Port map (
        CLK => CLK100MHZ,
        RESET => CPU_RESETN,
        entrada => led_s,
        A => A,
        B => B,
        C => C,
        PWM_AH => PWM_A,
        PWM_BH => PWM_B,
        PWM_CH => PWM_C,
        EN1 => EN1,
        EN2 => EN2,
        EN3 => EN3,
        ESTADO => LED,
        ERROR => LED16_R,
        digctrl => AN,
        segment => SEGMENT
    );
  
  
end architecture;
