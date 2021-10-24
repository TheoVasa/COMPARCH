library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
    type reg_type is array(0 to 1023) of std_logic_vector(31 downto 0);
    signal reg: reg_type := (others =>(others => '0'));
    signal tri_state_buffer : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(0, 32));
    signal adress_saved : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0, 10));
    signal cs_saved : std_logic := '0';
    signal read_saved : std_logic := '0';

begin

    --the buffer for the output read_data
    tri_state_buffer <= reg(to_integer(unsigned(adress_saved)));

    --manage the output for the output reading data 
    rddata <= tri_state_buffer when (read_saved = '1' and cs_saved = '1') else (others => 'Z');

    --read process 
    read_proc : process(clk) is
        begin 
        if(rising_edge(clk)) then 
        adress_saved <= address; 
        read_saved <= read;
        cs_saved <= cs;
        else 
        end if;
    end process read_proc;


    --write process 
    write_proc : process(clk, cs, write) is 
        begin 
        if(rising_edge(clk) and write = '1' and cs = '1') then 
        reg(to_integer(unsigned(address))) <= wrdata;
        end if;
    end process write_proc;    

end synth;
