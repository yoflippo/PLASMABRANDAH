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

entity mult is
    generic(
        mult_type  : string := "DEFAULT"
    );
    port(
        clk       : in std_logic;
        reset_in  : in std_logic;
        a, b      : in std_logic_vector(31 downto 0);
        mult_func : in mult_function_type;
        c_mult    : out std_logic_vector(31 downto 0);
        c_mult2    : out std_logic_vector(31 downto 0);
        pause_out : out std_logic
    );
end; --entity mult

architecture logic of mult is

    constant MODE_MULT : std_logic := '1';
    constant MODE_DIV  : std_logic := '0';
    constant ONE       : std_logic_vector := x"00000001";
    signal mode_reg    : std_logic;
    signal negate_reg  : std_logic;
    signal sign_reg   : std_logic;
    signal sign2_reg   : std_logic;
    signal count_reg   : std_logic_vector(5 downto 0);
    signal aa_reg      : std_logic_vector(31 downto 0);
    signal bb_reg      : std_logic_vector(31 downto 0);
    signal aa_reg2     : std_logic_vector(31 downto 0);
    signal bb_reg2     : std_logic_vector(31 downto 0);
    signal upper_reg   : std_logic_vector(31 downto 0);
    signal lower_reg   : std_logic_vector(31 downto 0);

    signal a_neg       : std_logic_vector(31 downto 0);
    signal b_neg       : std_logic_vector(31 downto 0);  
    signal sum         : std_logic_vector(32 downto 0);
    
    signal custom_mul_finished : std_logic;
    signal resultL : std_logic_vector(31 downto 0);
    signal resultH : std_logic_vector(31 downto 0);
    signal resultLFin : std_logic_vector(31 downto 0); 
    signal resultHFin : std_logic_vector(31 downto 0);

    component adder Port (
        a, b   : In std_logic_vector(31 Downto 0);
        do_add : In std_logic;
        c      : Out std_logic_vector(32 Downto 0)
    );
    end component;


begin

    CUSTUM_MULT: entity work.mult_csa
     port map(
         iclk          => clk,
         ireset        => reset_in,
         iMultiplier   => aa_reg2,
         iMultiplicand => bb_reg2,
         oFinished     => custom_mul_finished,
         oResultL      => resultL,
         oResultH      => resultH     
    );

    --custom_cs_adder :  adder PORT MAP(
    --    a       => upper_reg,
    --    b       => aa_reg,
    --    do_add  => mode_reg,
    --    c       => sum
    --);

    sum     <= bv_adder(upper_reg, aa_reg, mode_reg);

    -- Result
    c_mult2 <=  resultLFin               when mult_func = MULT_READ_LO and custom_mul_finished = '1' else
                resultHFin               when mult_func = MULT_READ_HI and custom_mul_finished = '1' else
                (others => '0');

    c_mult <=   lower_reg               when mult_func = MULT_READ_LO and negate_reg = '0' else
                bv_negate(lower_reg)    when mult_func = MULT_READ_LO and negate_reg = '1' else
                upper_reg               when mult_func = MULT_READ_HI and negate_reg = '0' else
                bv_negate(upper_reg)    when mult_func = MULT_READ_HI and negate_reg = '1' else ZERO;
    -- MS: the multiplier only sends the pause_out signal if the results is read prematurely
    pause_out <= '1' when (count_reg /= "000000") and (mult_func = MULT_READ_LO or mult_func = MULT_READ_HI) else '0';

    -- ABS and remainder signals
    a_neg   <= bv_negate(a);
    b_neg   <= bv_negate(b);


    --multiplication/division unit
    mult_proc: process(clk, reset_in, a, b, mult_func,
      a_neg, b_neg, sum, sign_reg, mode_reg, negate_reg,
      count_reg, aa_reg, bb_reg, upper_reg, lower_reg, custom_mul_finished)
      
      variable vCount        : std_logic_vector(2 downto 0);
      variable vResultBig    : std_logic_vector(63 downto 0);
      variable vTmpResultBig : std_logic_vector(63 downto 0);
      variable vSign_value : std_logic := '0'; -- MS: register for saving the result signess
      variable vSign_a_bit : std_logic;
      variable vSign_b_bit : std_logic;
      variable vSigned_mul : std_logic;
    begin
        vCount := "001";
        if reset_in = '1' then
            mode_reg <= '0';
            negate_reg <= '0';
            sign_reg <= '0';
            vSign_value := '0';
            sign2_reg <= '0';
            vSign_b_bit := '0';
            vSign_a_bit := '0';
            vSigned_mul := '0';
            count_reg <= "000000";
            aa_reg <= ZERO;
            bb_reg <= ZERO;
            upper_reg <= ZERO;
            lower_reg <= ZERO;
            aa_reg2 <= ZERO;
            bb_reg2 <= ZERO;
            resultLFin <= (others => '0');
            resultHFin <= (others => '0');
        elsif rising_edge(clk) then
            case mult_func is
                when MULT_WRITE_LO =>
                    lower_reg <= a;
                    negate_reg <= '0';
                when MULT_WRITE_HI =>
                    upper_reg <= a;
                    negate_reg <= '0';
                when MULT_MULT =>
                    mode_reg <= MODE_MULT;
                    aa_reg <= a;        -- MS : copy value port a to signal aa_reg
                    bb_reg <= b;
                    upper_reg <= ZERO;
                    count_reg <= "100000";
                    negate_reg <= '0';
                    sign_reg <= '0';
                    sign2_reg <= '0';
                    vSign_value := '0';
                    aa_reg2 <= a;
                    bb_reg2 <= b;
                    vSigned_mul := '0';
                    resultLFin <= (others => '0');
                    resultHFin <= (others => '0');
                when MULT_SIGNED_MULT =>
                    mode_reg <= MODE_MULT;
                    vSigned_mul := '1';
                    if b(31) = '0' then
                        aa_reg <= a;
                        bb_reg <= b;
                        vSign_a_bit := a(31);
                        vSign_b_bit := b(31);
                    else
                        aa_reg <= a_neg;
                        bb_reg <= b_neg;
                    end if;
                    if a /= ZERO then
                        vSign_value  := a(31) xor b(31);
                        sign_reg <= vSign_value;
                    else
                        vSign_value := '0';
                        sign_reg <= '0';
                    end if;
                    sign2_reg <= '0';
                    upper_reg <= ZERO;
                    count_reg <= "100000";
                    negate_reg <= '0';
                    
                    -- MS: 2's complement when one of operands is negative
                    if (a(31) = '1')  then  
                      aa_reg2 <= a_neg;
                    end if;

                    if (b(31) = '1') then
                      bb_reg2  <= b_neg;
                    end if;
                    resultLFin <= (others => '0');
                    resultHFin <= (others => '0');
                when MULT_DIVIDE =>
                    mode_reg <= MODE_DIV;
                    aa_reg <= b(0) & ZERO(30 downto 0);
                    bb_reg <= b;
                    upper_reg <= a;
                    count_reg <= "100000";
                    negate_reg <= '0';
                when MULT_SIGNED_DIVIDE =>
                    mode_reg <= MODE_DIV;
                    if b(31) = '0' then         -- MS: check MSB bit for signedness
                        aa_reg(31) <= b(0);     -- MS: if UNsigned
                        bb_reg <= b;
                    else
                        aa_reg(31) <= b_neg(0);
                        bb_reg <= b_neg;
                    end if;
                    if a(31) = '0' then
                        upper_reg <= a;
                    else
                        upper_reg <= a_neg;
                    end if;
                    aa_reg(30 downto 0) <= ZERO(30 downto 0); -- MS: always make aa_reg zero (except 31)
                    count_reg <= "100000";
                    negate_reg <= a(31) xor b(31);
                when others =>
                    if count_reg /= "000000" then -- MS: countdown from 31 to 0
                        if mode_reg = MODE_MULT then
                            -- Multiplication
                            if bb_reg(0) = '1' then
                                upper_reg   <= (sign_reg xor sum(32)) & sum(31 downto 1);
                                lower_reg   <= sum(0) & lower_reg(31 downto 1);
                                sign2_reg   <= sign2_reg or sign_reg;
                                sign_reg    <= '0';
                                bb_reg      <= '0' & bb_reg(31 downto 1);
                                -- The following six lines are optional for speedup
                                --elsif bb_reg(3 downto 0) = "0000" and sign2_reg = '0' and
                                --      count_reg(5 downto 2) /= "0000" then
                                --   upper_reg <= "0000" & upper_reg(31 downto 4);
                                --   lower_reg <=  upper_reg(3 downto 0) & lower_reg(31 downto 4);
                                --   vCount := "100";
                                --   bb_reg <= "0000" & bb_reg(31 downto 4);
                            else
                                upper_reg   <= sign2_reg & upper_reg(31 downto 1);
                                lower_reg   <= upper_reg(0) & lower_reg(31 downto 1);
                                bb_reg      <= '0' & bb_reg(31 downto 1);
                            end if;
                        else
                            -- Division
                            if sum(32) = '0' and aa_reg /= ZERO and
                               bb_reg(31 downto 1) = ZERO(31 downto 1) then
                                upper_reg       <= sum(31 downto 0);
                                lower_reg(0)    <= '1';
                            else
                                lower_reg(0)    <= '0';
                            end if;
                            aa_reg                  <= bb_reg(1) & aa_reg(31 downto 1);
                            lower_reg(31 downto 1)  <= lower_reg(30 downto 0);
                            bb_reg                  <= '0' & bb_reg(31 downto 1);
                        end if;
                    count_reg <= count_reg - vCount; -- MS: decrease the count_reg with one
                    else
         
                    end if; --vCount
            end case;
        end if; -- clck
                        -- MS: Convert WARNING: VERY SLOW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                if  custom_mul_finished = '1' then  
                    if vSigned_mul = '1' AND vSign_value = '1' then
                        --vTmpResultBig := resultH & resultL;
                        --vResultBig  := bv_negate(vTmpResultBig);
                        vResultBig := bv_twos_complement(resultL,resultH);
                        resultLFin <= vResultBig(a'range);
                        resultHFin <= vResultBig(vResultBig'high downto resultL'length);
                    else 
                        resultLFin <= resultL;
                        resultHFin <= resultH;    
                    end if;
                else  
                    resultLFin <= (others => '0');
                    resultHFin <= (others => '0');
                end if;
                
   end process;
end; --architecture logic
