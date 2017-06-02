---------------------------------------------------------------------
-- TITLE: Multiplication and Division Unit
-- AUTHORS: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 1/31/01
-- FILENAME: mult.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the multiplication and division unit in 32 clocks.
--
-- MULTIPLICATION
-- long64 answer = 0;
-- for(i = 0; i < 32; ++i)
-- {
--    answer = (answer >> 1) + (((b&1)?a:0) << 31);
--    b = b >> 1;
-- }
--
-- DIVISION
-- long upper=a, lower=0;
-- a = b << 31;
-- for(i = 0; i < 32; ++i)
-- {
--    lower = lower << 1;
--    if(upper >= a && a && b < 2)
--    {
--       upper = upper - a;
--       lower |= 1;
--    }
--    a = ((b&2) << 30) | (a >> 1);
--    b = b >> 1;
-- }
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.mlite_pack.all;

entity adder is

    port(
        a, b      : in std_logic_vector(31 downto 0);
        do_add    : in std_logic;
        c         : out std_logic_vector(32 downto 0)
    );
end; --entity adder

architecture logic of adder is

    signal adder0       : std_logic_vector(8 downto 0);
    signal adder1_0     : std_logic_vector(8 downto 0);
    signal adder1_1     : std_logic_vector(8 downto 0);
    signal adder2_0     : std_logic_vector(8 downto 0);
    signal adder2_1     : std_logic_vector(8 downto 0);
    signal adder3_0     : std_logic_vector(8 downto 0);
    signal adder3_1     : std_logic_vector(8 downto 0);
    signal adder4_0     : std_logic_vector(8 downto 0);
    signal adder4_1     : std_logic_vector(8 downto 0);
    signal carry_0      : std_logic;
    signal carry_1      : std_logic;
    signal carry_2      : std_logic;
    signal result       : std_logic_vector(32 downto 0);

    signal partresult1  : std_logic_vector(8 downto 0);
    signal partresult2  : std_logic_vector(8 downto 0);

begin

   adder0 <= bv_adder_ci(a(7 downto 0),b(7 downto 0),0);

   adder1_0  <=  bv_adder_ci(a(15 downto 8),a(15 downto 8),0);
   adder1_1  <=  bv_adder_ci(a(15 downto 8),a(15 downto 8),1);

   adder2_0  <=  bv_adder_ci(a(23 downto 16),a(23 downto 16),0);
   adder2_1  <=  bv_adder_ci(a(23 downto 16),a(23 downto 16),1);

   adder3_0  <=  bv_adder_ci(a(31 downto 24),a(31 downto 24),0);
   adder3_1  <=  bv_adder_ci(a(31 downto 24),a(31 downto 24),1);

   carry_0   <= adder0(8);
   
   -- first half of two - level carry-select adder k/4-adder
    if carry_0 = '1' then
        result(15 downto 0) <= adder1_1 & adder0;
        carry_1 <= adder1_1(8);
    else
        result(15 downto 0) <= adder1_0 & adder0;
        carry_1 <= adder1_0(8);
    end if;


   -- first smaller last part
    if adder2_1(8) = '1'
        partresult1 <= adder3_1;
    else
        partresult1 <= adder3_0;
    end

    if adder2_0(8) = '1'
        partresult2 <= adder3_1;
    else
        partresult2 <= adder3_0;
    end


    if carry_1 = '1' then
        result(23 downto 16) <= partresult1 & adder2_1;
    else
        result(32 downto 16) <= partresult2 & adder2_0;
    end if;
 
end; --architecture logic
