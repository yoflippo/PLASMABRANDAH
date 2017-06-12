Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.std_logic_unsigned.All;
Use IEEE.std_logic_arith.All;

Library work;
Use work.mlite_pack.All;

Entity carry_select_adder Is
    Port (
        a, b   : In std_logic_vector(31 Downto 0);
        do_add : In std_logic;
        c      : Out std_logic_vector(32 Downto 0)
    );
End; --entity carry_select_adder

Architecture logic Of carry_select_adder Is

    Constant ci        : std_logic := '0';
    Signal bb          : std_logic_vector(31 Downto 0);
    Signal byte1_a     : std_logic_vector(7 Downto 0);
    Signal byte2_a     : std_logic_vector(7 Downto 0);
    Signal byte3_a     : std_logic_vector(7 Downto 0);
    Signal byte4_a     : std_logic_vector(7 Downto 0);

    Signal byte1_b     : std_logic_vector(7 Downto 0);
    Signal byte2_b     : std_logic_vector(7 Downto 0);
    Signal byte3_b     : std_logic_vector(7 Downto 0);
    Signal byte4_b     : std_logic_vector(7 Downto 0);

    Signal carry_select_adder1      : std_logic_vector(8 Downto 0);
    Signal carry_select_adder2_0    : std_logic_vector(8 Downto 0);
    Signal carry_select_adder2_1    : std_logic_vector(8 Downto 0);
    Signal carry_select_adder3_0    : std_logic_vector(8 Downto 0);
    Signal carry_select_adder3_1    : std_logic_vector(8 Downto 0);
    Signal carry_select_adder4_0    : std_logic_vector(8 Downto 0);
    Signal carry_select_adder4_1    : std_logic_vector(8 Downto 0);
    Signal carry_0     : std_logic;
    Signal carry_1     : std_logic;
    Signal carry_2     : std_logic;

    Signal partresult1 : std_logic_vector(8 Downto 0);
    Signal partresult2 : std_logic_vector(8 Downto 0);

    Signal result      : std_logic_vector(32 Downto 0);

Begin
    -- MS: get 2's complement when subtracting
    bb <= (Not b) + '1' When do_add = '0' Else
          b;

    -- MS: assign signals to part of parameters a & b for the function
    -- bv_carry_select_adder to work
    loop_assign : For i In 0 To 7 Generate
        byte1_a(i) <= a(i); 
        byte2_a(i) <= a(i + 8);
        byte3_a(i) <= a(i + 16);
        byte4_a(i) <= a(i + 24);
        byte1_b(i) <= bb(i); 
        byte2_b(i) <= bb(i + 8);
        byte3_b(i) <= bb(i + 16);
        byte4_b(i) <= bb(i + 24);
    End Generate;
 
    -- MS: carry-select carry_select_adder based on Parhami
    -- calculate different parts of words
    carry_select_adder1   <= bv_real_adder(byte1_a, byte1_b, do_add, ci);
    carry_select_adder2_0 <= bv_real_adder(byte2_a, byte2_b, do_add, ci);
    carry_select_adder2_1 <= bv_real_adder(byte2_a, byte2_b, do_add, Not ci);
    carry_select_adder3_0 <= bv_real_adder(byte3_a, byte3_b, do_add, ci);
    carry_select_adder3_1 <= bv_real_adder(byte3_a, byte3_b, do_add, Not ci);
    carry_select_adder4_0 <= bv_real_adder(byte4_a, byte4_b, do_add, ci);
    carry_select_adder4_1 <= bv_real_adder(byte4_a, byte4_b, do_add, Not ci);
    carry_0  <= carry_select_adder1(8);

    -- MS: switch the right parts to the end result
    result(15 Downto 0) <= carry_select_adder2_1(7 Downto 0) & carry_select_adder1(7 Downto 0)
    When carry_0 = '1'Else carry_select_adder2_0(7 Downto 0) & carry_select_adder1(7 Downto 0);

    carry_1 <= carry_select_adder2_1(8)
    When carry_0 = '1' Else carry_select_adder2_0(8);

    partresult1 <= carry_select_adder4_1 When carry_select_adder3_1(8) = '1' Else carry_select_adder4_0;
    partresult2 <= carry_select_adder4_1 When carry_select_adder3_0(8) = '1' Else carry_select_adder4_0;

    result(31 Downto 16) <= partresult1(7 Downto 0) & carry_select_adder3_1(7 Downto 0)
    When carry_1 = '1' Else partresult2(7 Downto 0) & carry_select_adder3_0(7 Downto 0);

    -- MS: logic to give the correct MSB after subtracting or adding
    result(32) <= '1' When do_add = '0' And b > a Else
    '0' When do_add = '0' Else
    partresult1(8) When carry_1 = '1' Else
    partresult2(8);

    c <= result;
End; --architecture logic