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
    signal result      : std_logic_vector(32 downto 0);

    signal partresult1 : std_logic_vector(8 downto 0);
    signal partresult2 : std_logic_vector(8 downto 0);

begin
    -- MS: carry-select adder based on Parhami
    -- calculate different parts of words
    adder1              <= bv_real_adder(a(7  downto 0 ), b(7  downto 0 ), not ci);
    adder2_0            <= bv_real_adder(a(15 downto 8 ), a(15 downto 8 ), not ci);
    adder2_1            <= bv_real_adder(a(15 downto 8 ), a(15 downto 8 ),     ci);
    adder3_0            <= bv_real_adder(a(23 downto 16), a(23 downto 16), not ci);
    adder3_1            <= bv_real_adder(a(23 downto 16), a(23 downto 16),     ci);
    adder4_0            <= bv_real_adder(a(31 downto 24), a(31 downto 24), not ci);
    adder4_1            <= bv_real_adder(a(31 downto 24), a(31 downto 24),     ci);
    carry_0             <= adder1(8);

    -- MS: switch the right parts to the end result
    result(15 downto 0)     <= adder2_1(7 downto 0) & adder1(7 downto 0)
    when carry_0 = '1'else     adder2_0(7 downto 0) & adder1(7 downto 0);

    carry_1                 <= adder2_1(8) 
    when carry_0 = '1' else    adder2_0(8);
 
    partresult1  <= adder4_1 when adder3_1(8) = '1' else adder4_0;
    partresult2  <= adder4_1 when adder3_0(8) = '1' else adder4_0;

    result(32 downto 16)    <= partresult1(8 downto 0) & adder3_1(7 downto 0)
    when carry_1 = '1' else    partresult2(8 downto 0) & adder3_0(7 downto 0);
            --pCarrySelect :process (a, b, do_add)
            --begin
            -- -- first half of two - level carry-select adder k/4-adder
            -- if carry_0 = '1' then
            -- result(15 downto 0) <= adder2_1 & adder1;
            -- carry_1 <= adder2_1(8);
            -- else
            -- result(15 downto 0) <= adder2_0 & adder1;
            -- carry_1 <= adder2_0(8);
            -- end if;

            -- -- first smaller last part
            -- if adder3_1(8) = '1' then
            -- partresult1 <= adder3_1;
            -- else
            -- partresult1 <= adder3_0;
            -- end if;

            -- if adder3_0(8) = '1' then
            -- partresult2 <= adder3_1;
            -- else
            -- partresult2 <= adder3_0;
            -- end if;

            -- if carry_1 = '1' then
            -- result(32 downto 16) <= partresult1(8 downto 0) & adder3_1(7 downto 0);
            -- else
            -- result(32 downto 16) <= partresult2(8 downto 0) & adder3_0(7 downto 0);
            -- end if;

            --end process;
end; --architecture logic