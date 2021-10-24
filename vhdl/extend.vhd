library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
    signal sig : std_logic_vector(31 downto 0);
    signal ext : std_logic;
begin
    ext <= signed and imm16(15);
    sig <= (15 downto 0 => ext) & imm16; 
    imm32 <= sig;

end synth;
