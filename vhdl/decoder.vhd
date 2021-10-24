library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
        cs_BUTTONS : out std_logic
    );
end decoder;

architecture synth of decoder is
    signal IncomingAddress : std_logic_vector(15 downto 0);
    signal AddressValue: unsigned(15 downto 0);
    signal ROM: std_logic;
    signal RAM: std_logic;
    signal LED: std_logic;
    signal BUT : std_logic;
    constant ROMLB : unsigned(15 downto 0) := to_unsigned(0, 16);
    constant ROMUB : unsigned(15 downto 0) := to_unsigned(4092, 16);
    constant RAMLB : unsigned(15 downto 0) := to_unsigned(4096, 16);
    constant RAMUB : unsigned(15 downto 0) := to_unsigned(8188, 16);
    constant LEDLB : unsigned(15 downto 0) := to_unsigned(8192, 16);
    constant LEDUB : unsigned(15 downto 0) := to_unsigned(8204, 16);
    constant NULLB : unsigned(15 downto 0) := to_unsigned(8208, 16);
    constant BUT1  : unsigned(15 downto 0) := to_unsigned(8240, 16);
    constant BUT2  : unsigned(15 downto 0) := to_unsigned(8244, 16);
    constant NULUB : unsigned(15 downto 0) := to_unsigned(65532, 16);

begin
    IncomingAddress <= address;
    AddressValue <= unsigned(IncomingAddress);
        
    ROM <= '1' when (( AddressValue >= ROMLB) and (ROMUB  >= AddressValue)) else 
            '0';

    RAM <= '1' when ((AddressValue >= RAMLB) and (RAMUB  >= AddressValue)) else 
            '0';

    LED <= '1' when ((AddressValue >= LEDLB) and (LEDUB  >= AddressValue)) else 
            '0';
    
    BUT <= '1' when ((AddressValue >= BUT1) and (BUT2 >= AddressValue)) else 
            '0';        


    cs_RAM <= RAM;
    cs_ROM <= ROM;
    cs_LEDS <= LED;
    cs_BUTTONS <= BUT;

end synth;
