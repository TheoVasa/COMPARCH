library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
    signal b_sig : unsigned(32 downto 0) := to_unsigned (0, 33);
    signal sum : unsigned(32 downto 0) := to_unsigned(0, 33);
    signal a_sig : unsigned(32 downto 0) := to_unsigned(0, 33);
    signal RESULT  : STD_LOGIC_VECTOR(31 downto 0);


begin
    a_sig <= '0' & unsigned(a);
    
    --invert b if sub-mode on-- 
    b_sig <='0' &  unsigned(b) when sub_mode = '0' else 
            '0' &  unsigned(not b); 

    --generate the sum         
    sum <= a_sig + b_sig + 1 when sub_mode = '1' else a_sig + b_sig;

    --check the carry 
    carry <= sum(32);

    RESULT <= std_logic_vector(sum(31 downto 0));

    --check if zero 
    zero <= '1' when RESULT = STD_LOGIC_VECTOR(to_unsigned(0, 32)) else '0';

    --result 
    r <= RESULT;


end synth;
