library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is
--ROM BLOCK 
component ROM_Block is 
    port(
        address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
end component;    

signal q : std_logic_vector(31 downto 0); 
signal tri_state_buffer : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(0, 32));
signal address_saved : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0, 10));
signal cs_saved : std_logic := '0';
signal read_saved : std_logic := '0';

begin

    --instantiating the ROM block 
    ROM_Block_0 : ROM_Block port map(
        address => address_saved, 
        clock => clk, 
        q => q
    );

    --the buffer for the output read_data
    tri_state_buffer <= q;

    --manage the output for the output reading data 
    rddata <= tri_state_buffer when (read_saved = '1' and cs_saved = '1') else (others => 'Z');

    --read process 
    read_proc : process(clk) is
        begin 
        if(rising_edge(clk)) then 
        address_saved <= address; 
        read_saved <= read;
        cs_saved <= cs;
        else 
        end if;
    end process read_proc;

end synth;
