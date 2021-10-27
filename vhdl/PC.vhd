library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
    signal current_add_count : signed(31 downto 0) := to_signed(0, 32);
    signal next_add_count    : signed(31 downto 0) := to_signed(0, 32);
    signal sig_imm           : std_logic_vector(31 downto 0);
    signal shifted_imm       : std_logic_vector(15 downto 0);
    signal sig_a             : std_logic_vector(31 downto 0);
    constant sixteenzeros    : std_logic_vector(15 downto 0) := (others <= 0)

begin
    shifted_imm <= imm(13 downto 0) & "00";
    sig_imm <= (31 downto shifted_imm'length => '0') & shifted_imm;
    sig_a   <= (31 downto a'length => '0') & a;
    next_add_count <= current_add_count + signed(imm) when (add_imm = '1') else 
                      signed(sig_imm) when (sel_imm = '1') else 
                      signed(sig_a) when (sel_a = '1') else 
                      current_add_count + 4;
    counter : process(clk, en, reset_n) is 
    begin 
        if(reset_n = '0') then 
            current_add_count <= (others => '0');
            else if (rising_edge(clk) and en = '1') then 
            current_add_count <= next_add_count;
            else --nothing 
            end if;
        end if;
    end process counter; 
addr <= std_logic_vector (current_add_count) ;
addr(1 downto 0) <= "00";
addr(31 downto 15) <= sixteenzeros;         
end synth;

// address: everything on 16v bits -> output cincantenate 16 0s and override 2 LSBs to 0s

// 