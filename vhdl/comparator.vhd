library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    port(
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector(2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is
    signal less_or_equal_sign, greater_sign, not_equal, equal, less_or_equal_uns, greater_uns : std_logic := '0';
begin
    --computing the compairison, in function of the output of the subtraction--
    equal <= zero;
    not_equal <= not zero;
    less_or_equal_sign <= ((a_31 and (not b_31)) or ((a_31 xnor b_31) and (diff_31 or zero)));
    greater_sign <= ((not a_31 and b_31) or ((a_31 xnor b_31) and (not diff_31 and (not zero))));
    less_or_equal_uns <= not carry or zero;
    greater_uns <= carry and not zero;

    --computing the output, in function of the asked operation--
    r <= less_or_equal_sign when op = "001" else
         greater_sign       when op = "010" else
         not_equal          when op = "011" else 
         less_or_equal_uns  when op = "101" else 
         greater_uns        when op = "110" else 
         equal;

end synth;
