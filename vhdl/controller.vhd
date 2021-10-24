library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
    type state_type is (
        FETCH1, 
        FETCH2, 
        DECODE, 
        R_OP, 
        STORE, 
        BREAK, 
        LOAD1, 
        I_OP, 
        LOAD2,
        BRANCH,
        CALL, 
        CALLR,
        JMP,
        JMPI
    );
    -----state-machine-----------
    signal s_current_state : state_type; 
    signal s_next_state    : state_type;

    -----some-signals------------
    signal s_op_alu        : std_logic_vector(5 downto 0);
    signal s_imm_signed    : std_logic           := '0';
    
    -----different-op-type------
    constant op_r_type      : std_logic_vector   := "111010"; --- 0x3A
    constant op_load        : std_logic_vector   := "010111"; --- 0x17
    constant op_store       : std_logic_vector   := "010101"; --- 0x15
    constant op_break       : std_logic_vector   := "111010"; --- 0x3A
    constant op_addi        : std_logic_vector   := "000100"; --- 0x04
    constant op_br          : std_logic_vector   := "000110"; --- 0x06
    constant op_br_leq      : std_logic_vector   := "001110"; --- 0x0E
    constant op_br_great    : std_logic_vector   := "010110"; --- 0x16
    constant op_br_neq      : std_logic_vector   := "011110"; --- 0x1E
    constant op_br_eq       : std_logic_vector   := "100110"; --- 0x26 
    constant op_br_leq_uns  : std_logic_vector   := "101110"; --- 0x2E
    constant op_br_great_uns: std_logic_vector   := "110110"; --- 0x36
    constant op_call        : std_logic_vector   := "000000"; --- 0x00
    constant op_jmpi        : std_logic_vector   := "000001"; --- 0x01


    -----different-opx-type------
    constant opx_and       : std_logic_vector   := "001110"; --- 0x0E
    constant opx_srl       : std_logic_vector   := "011011"; --- 0x1B
    constant opx_break     : std_logic_vector   := "110100"; --- 0x34
    constant opx_callr     : std_logic_vector   := "011101"; --- 0x1D
    constant opx_jmp       : std_logic_vector   := "001101"; --- 0x0D
    constant opx_ret       : std_logic_vector   := "000101"; --- 0x05

    -----ALU-OP-----------------
    constant alu_add       : std_logic_vector   := "000000";
    constant alu_sub       : std_logic_vector   := "001000";
    constant alu_leq_si    : std_logic_vector   := "011001";
    constant alu_great_si  : std_logic_vector   := "011010";
    constant alu_noteq     : std_logic_vector   := "011011";
    constant alu_eq        : std_logic_vector   := "011100";
    constant alu_leq_uns   : std_logic_vector   := "011101";
    constant alu_great_uns : std_logic_vector   := "011110";
    constant alu_nor       : std_logic_vector   := "100000";
    constant alu_and       : std_logic_vector   := "100001";
    constant alu_or        : std_logic_vector   := "100010";
    constant alu_xnor      : std_logic_vector   := "100011";
    constant alu_rol       : std_logic_vector   := "110000";
    constant alu_ror       : std_logic_vector   := "110001";
    constant alu_sll       : std_logic_vector   := "110010";
    constant alu_srl       : std_logic_vector   := "110011";
    constant alu_sra       : std_logic_vector   := "110111";

begin

-------------------TRANSITION-LOGIC----------------------  
s_next_state <= FETCH2 when (s_current_state = FETCH1) else 
                DECODE when (s_current_state = FETCH2) else 
                BRANCH when ((s_current_state = DECODE) and 
                            ((op = op_br)        or 
                            (op = op_br_leq)     or 
                            (op = op_br_great)   or
                            (op = op_br_neq)     or 
                            (op = op_br_eq)      or 
                            (op = op_br_leq_uns) or 
                            (op = op_br_great_uns)))   else        
                CALL   when (s_current_state = DECODE  and op = op_call) else      
                CALLR  when (s_current_state = DECODE  and op = op_r_type and opx = opx_callr) else 
                JMP    when (s_current_state = DECODE and op = op_r_type and (opx = opx_jmp or opx = opx_ret)) else  
                JMPI   when (s_current_state = DECODE and op = op_jmpi) else       
                BREAK  when ((s_current_state = DECODE and (op = op_break and opx = opx_break)) or (s_current_state = BREAK)) else 
                R_OP   when (s_current_state = DECODE  and (op = op_r_type)) else 
                STORE  when (s_current_state = DECODE  and (op = op_store)) else 
                LOAD1  when (s_current_state = DECODE  and (op = op_load)) else 
                LOAD2  when (s_current_state = LOAD1) else 
                I_OP   when (s_current_state = DECODE) else 
                FETCH1;

------------------TRANSITION-FLIP-FLOPS------------------
flp :process(clk, reset_n) is 
begin
        if(reset_n = '0') then 
        s_current_state <= FETCH1; 
        else if(rising_edge(clk)) then 
            s_current_state <= s_next_state; 
            else 
        --do nothing 
            end if;  
        end if;      
end process flp;   

------------------OP_ALU_GEN-AND-SIGNED----------------------------
op_alu_gen :process(op, opx) is 
begin 
    case op is 
    ------------R_OP----------
        when op_r_type  => 
            case opx is 
                --and--
                when opx_and => 
                    s_op_alu <= alu_and;

                --srl--    
                when opx_srl =>
                    s_op_alu <= alu_srl;

                when others => 
                    --do nothing--    
            end case;                
    ----------LOAD-----------
        when op_load  => 
            s_op_alu <= alu_add;
            s_imm_signed <= '1';

    ----------STORE----------
        when op_store =>
            s_op_alu <= alu_add;
            s_imm_signed <= '1';

    ----------ADDI------------
        when op_addi => 
            s_op_alu <= alu_add;
            s_imm_signed <= '1';
 
    ---------BRANCH------------
    when op_br =>
    s_op_alu <= alu_eq;

    when op_br_eq =>
    s_op_alu <= alu_eq;

    when op_br_leq =>
    s_op_alu <= alu_leq_si;

    when op_br_neq =>
    s_op_alu <= alu_noteq;

    when op_br_great =>
    s_op_alu <= alu_great_si;

    when op_br_great_uns =>
    s_op_alu <= alu_great_uns;

    when op_br_leq_uns =>
    s_op_alu <= alu_leq_uns;

    ----------------------------      
    when others =>
            --do nothing--
    end case;
    
end process op_alu_gen;
        
-----------------------OUTPUT-LOGIC--------------------------

-- activates branch condition
branch_op <= '1' when s_current_state = BRANCH else '0'; 

-- immediate value sign extention
imm_signed <= s_imm_signed when (s_current_state = LOAD1 or s_current_state = STORE or s_current_state = I_OP) else '0'; 

-- instruction register enable
ir_en <= '1' when s_current_state = FETCH2 else '0';

-- PC control signals
pc_add_imm <= '1' when s_current_state = BRANCH else '0';
pc_en <= '1' when (s_current_state = FETCH2 or s_current_state = CALL or s_current_state = CALLR or s_current_state = JMP or s_current_state = JMPI) else '0';
pc_sel_a <= '1' when (s_current_state = CALLR or s_current_state = JMP) else '0'; 
pc_sel_imm <= '1' when (s_current_state = CALL or s_current_state = JMPI) else '0';

-- register file enable
rf_wren <= '1' when (s_current_state = I_OP  or s_current_state = R_OP or s_current_state = LOAD2 or s_current_state = CALL or s_current_state = CALLR) else '0'; 

-- multiplexers selections
sel_addr <= '1' when (s_current_state = LOAD1 or s_current_state = STORE) else '0';
sel_b <= '1' when (s_current_state = R_OP or s_current_state = BRANCH) else '0';
sel_mem <= '1' when s_current_state = LOAD2 else '0';
sel_pc <= '1' when (s_current_state = CALL or s_current_state = CALLR) else '0';
sel_ra <= '1' when (s_current_state = CALL or s_current_state = CALLR) else '0';
sel_rC <= '1' when s_current_state = R_OP else '0';

-- write memory output
read  <= '1' when (s_current_state = LOAD1 or s_current_state = FETCH1) else '0';
write <= '1' when s_current_state = STORE else '0';

-- alu op
op_alu <= s_op_alu;

end synth;
