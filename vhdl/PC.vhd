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
    signal add_count : unsigned(31 downto 0) := to_unsigned(0, 32);
begin
    counter : process(clk, en, reset_n) is 
    begin 
        if(reset_n = '0') then 
            add_count <= (others => '0');
            else if (rising_edge(clk) and en = '1') then 
                if(add_imm = '1') then 
                    add_count <= add_count + unsigned(imm);
                    else 
                add_count <= add_count + 4;
                end if; 
            else --nothing 
            end if;
        end if;
    end process counter; 
addr <= std_logic_vector (add_count);                
end synth;
