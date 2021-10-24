library ieee;
use ieee.std_logic_1164.all;

entity IR is
    port(
        clk    : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector(31 downto 0);
        Q      : out std_logic_vector(31 downto 0)
    );
end IR;

architecture synth of IR is
    signal current_data : std_logic_vector(31 downto 0);
begin
    flp :process(clk, enable) is 
        begin
            if(rising_edge(clk) and enable = '1') then 
                current_data <= D; 
                else 
                --do nothing 
            end if;    
        end process flp;    
Q <= current_data;            
end synth;
