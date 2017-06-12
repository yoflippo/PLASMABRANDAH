library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mlite_pack.all;

entity mult_csa is
    generic (RADIX      : positive := 16;  
             LOG2RADIX  : positive := 4); -- MS: adjust this value if RADIX is changed
    port(
          clk                          : in  std_logic;
          reset                        : in  std_logic;
          iMultiplier, iMultiplicand   : in  std_logic_vector;
          oFinsihed                    : out std_logic
    );
end; --entity adder

Architecture logic Of mult_csa Is
    

    -- MS: signals for carry-select adder
    signal do_add           : std_logic := '1';     
    signal csel_a, csel_b   : std_logic_vector(iMultiplier'range);
    signal csel_c           : std_logic_vector(iMultiplier'length+1 downto 0);
    -- MS: signal for carry-SAVE adder
    signal csav_a, csav_b, csav_c   : std_logic_vector(iMultiplier'length+1 downto 0);
    signal csav_sum, csav_car       : std_logic_vector(iMultiplier'length+2 downto 0);
    -- MS: counter variable
    signal counter  : INTEGER range 0 to 31;
    -- MS: array of vectors
    subtype mulmul_add is integer range 0 to (LOG2RADIX)-1;
    type muxmul is array(mulmul_add) of std_logic_vector(iMultiplier'length+1 downto 0);
    signal muxMultiplicands : muxmul;

    component carry_sel_adder Port (
        a, b   : In std_logic_vector(31 Downto 0);
        do_add : In std_logic;
        c      : Out std_logic_vector(32 Downto 0)
    );
    end component;

    component carry_save_adder Port (
        ia, ib, ic   : in  std_logic_vector;
        osum, ocarry : out std_logic_vector
    );
    end component;

Begin
   
    lb_carry_sel : carry_sel_adder PORT MAP(
        a       => csel_a,
        b       => csel_b,
        do_add  => do_add,
        c       => csel_c
    );

    lb_carry_save_adder : carry_save_adder PORT MAP(
        ia      => csav_a,
        ib      => csav_b,
        ic      => csav_c,
        osum    => csav_sum,
        ocarry  => csav_car
    );

    -- MS : generate the muxes with a, 2a, 4a, etc.
    muxMultiplicands(counter) <= (others => '0') When iMultiplier(counter) = '0' else
                        "000" & iMultiplicand;
    muxMultiplicands(counter+1) <= (others => '0') When iMultiplier(counter+1) = '0' else
                        "00" & iMultiplicand & '0'; -- MS: times two 
    muxMultiplicands(counter+2) <= (others => '0') When iMultiplier(counter+2) = '0' else
                        '0' & iMultiplicand &  "00"; -- MS: times four                       
    muxMultiplicands(counter+3) <= (others => '0') When iMultiplier(counter+3) = '0' else
                         iMultiplicand &  "000"; -- MS: times four   


                            --for_gen_csa : for index in 0 to (LOG2RADIX)-1 generate
    --    muxMultiplicands(index) <= (others => '0') When iMultiplier(counter) = '0' else
    --    for_gen_shift : for i                 

    --                    --std_logic_vector(unsigned(iMultiplicand) sll to_integer(unsigned(index))) & (others => '0'); -- Shift left
     
    --end generate;

    -- MS: get 2's complement when subtracting
    --bb <= (Not b) + '1' When do_add = '0' Else
    --      b;

    --variable count : std_logic_vector(2 downto 0);

End; --architecture logic