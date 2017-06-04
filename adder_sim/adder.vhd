library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library work;
use work.mlite_pack.all;

entity adder is

    port (
        a, b   : in std_logic_vector(31 downto 0);
        do_add : in std_logic;
        c      : out std_logic_vector(32 downto 0)
    );
end; --entity adder

architecture logic of adder is

    constant ci        : std_logic := '0';
    signal bb           : std_logic_vector(31 downto 0);
    signal byte1_a     : std_logic_vector(7 downto 0);
    signal byte2_a     : std_logic_vector(7 downto 0);
    signal byte3_a     : std_logic_vector(7 downto 0);
    signal byte4_a     : std_logic_vector(7 downto 0);

    signal byte1_b     : std_logic_vector(7 downto 0);
    signal byte2_b     : std_logic_vector(7 downto 0);
    signal byte3_b     : std_logic_vector(7 downto 0);
    signal byte4_b     : std_logic_vector(7 downto 0);

    signal adder1      : std_logic_vector(8 downto 0);
    signal adder2_0    : std_logic_vector(8 downto 0);
    signal adder2_1    : std_logic_vector(8 downto 0);
    signal adder3_0    : std_logic_vector(8 downto 0);
    signal adder3_1    : std_logic_vector(8 downto 0);
    signal adder4_0    : std_logic_vector(8 downto 0);
    signal adder4_1    : std_logic_vector(8 downto 0);
    signal carry_0     : std_logic;
    signal carry_1     : std_logic;
    signal carry_2     : std_logic;

    signal partresult1 : std_logic_vector(8 downto 0);
    signal partresult2 : std_logic_vector(8 downto 0);

    signal result      : std_logic_vector(32 downto 0);

begin

    bb <= (not b)+'1' when do_add = '0' else b;
    -- MS: assign signals to part of parameters a & b for the function
    -- bv_adder to work
    loop_assign : for i in 0 to 7  generate
        byte1_a(i) <= a(i);   
        byte2_a(i) <= a(i+8); 
        byte3_a(i) <= a(i+16);
        byte4_a(i) <= a(i+24);
        byte1_b(i) <= bb(i);   
        byte2_b(i) <= bb(i+8); 
        byte3_b(i) <= bb(i+16);
        byte4_b(i) <= bb(i+24);
    end generate;
        

    -- MS: carry-select adder based on Parhami
    -- calculate different parts of words
    adder1              <= bv_real_adder(byte1_a, byte1_b,do_add,     ci);
    adder2_0            <= bv_real_adder(byte2_a, byte2_b,do_add,     ci);
    adder2_1            <= bv_real_adder(byte2_a, byte2_b,do_add, not ci);
    adder3_0            <= bv_real_adder(byte3_a, byte3_b,do_add,     ci);
    adder3_1            <= bv_real_adder(byte3_a, byte3_b,do_add, not ci);
    adder4_0            <= bv_real_adder(byte4_a, byte4_b,do_add,     ci);
    adder4_1            <= bv_real_adder(byte4_a, byte4_b,do_add, not ci);
    carry_0             <= adder1(8);


    -- MS: switch the right parts to the end result
    result(15 downto 0)     <= adder2_1(7 downto 0) & adder1(7 downto 0)
    when carry_0 = '1'else     adder2_0(7 downto 0) & adder1(7 downto 0);

    carry_1                 <= adder2_1(8) 
    when carry_0 = '1' else    adder2_0(8);
 
    partresult1  <= adder4_1 when adder3_1(8) = '1' else adder4_0;
    partresult2  <= adder4_1 when adder3_0(8) = '1' else adder4_0;

    result(31 downto 16)    <= partresult1(7 downto 0) & adder3_1(7 downto 0)
    when carry_1 = '1' else    partresult2(7 downto 0) & adder3_0(7 downto 0);
    
    result(32)  <=  '1'             when do_add = '0' AND b > a else
                    '0'             when do_add = '0' else 
                    partresult1(8)  when carry_1 = '1' else
                    partresult2(8);
            
    c <= result;
end; --architecture logic