library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mlite_pack.all;

entity mult_csa is
    port(
          iclk                        : in  std_logic;
          ireset                      : in  std_logic;
          iMultiplier, iMultiplicand  : in  std_logic_vector(31 downto 0);
          oFinished                   : out std_logic
    );
end; --entity adder

Architecture logic Of mult_csa Is
    

    -- MS: signals for carry-select adder
    signal do_add           : std_logic := '1';     
    signal csel_a, csel_b   : std_logic_vector(iMultiplier'range);
    signal csel_c           : std_logic_vector(iMultiplier'length+1 downto 0);
    ---- MS: signal for carry-SAVE adder
    --signal csav_a, csav_b, csav_c   : std_logic_vector(iMultiplier'length+1 downto 0);
    --signal csav_sum, csav_car       : std_logic_vector(iMultiplier'length+2 downto 0);
    -- MS: counter variable
    signal counter  : INTEGER range 0 to 31;
    -- MS: array of vectors
    subtype mulmul_add is integer range 0 to 3;
    type muxmul is array(mulmul_add) of std_logic_vector(iMultiplier'length+2 downto 0);
    signal muxMultiplicands : muxmul;

    component carry_sel_adder Port (
        a, b   : In std_logic_vector(31 Downto 0);
        do_add : In std_logic;
        c      : Out std_logic_vector(32 Downto 0)
    );
    end component;

    --component carry_save_adder Port (
    --    ia, ib, ic   : in  std_logic_vector;
    --    osum, ocarry : out std_logic_vector
    --);
    --end component;

    component multiplier_tree_radix16 is
    generic ( INPUT_SMALLEST_SIZE : POSITIVE := 32 ); 
    port(
            ia     : in  std_logic_vector(INPUT_SMALLEST_SIZE-1 downto 0);
            i2a    : in  std_logic_vector(INPUT_SMALLEST_SIZE   downto 0);
            i4a    : in  std_logic_vector(INPUT_SMALLEST_SIZE+1 downto 0);
            i8a    : in  std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0);
            ioldsum: in  std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0);
            ioldcar: in  std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0);
            osum   : out std_logic_vector(INPUT_SMALLEST_SIZE+5 downto 0);
            ocar   : out std_logic_vector(INPUT_SMALLEST_SIZE+5 downto 0)
    );
    end component multiplier_tree_radix16;

    constant BUS_WIDTH : integer := 32;
    signal a     : std_logic_vector(BUS_WIDTH-1 downto 0);
    signal a2    : std_logic_vector(BUS_WIDTH   downto 0);
    signal a4    : std_logic_vector(BUS_WIDTH+1 downto 0);
    signal a8    : std_logic_vector(BUS_WIDTH+2 downto 0);
    signal oldsum: std_logic_vector(BUS_WIDTH+2 downto 0) := (others => '0');
    signal oldcar: std_logic_vector(BUS_WIDTH+2 downto 0) := (others => '0');
    signal sum   : std_logic_vector(BUS_WIDTH+5 downto 0);
    signal car   : std_logic_vector(BUS_WIDTH+5 downto 0);

    signal part_sum : std_logic_vector(3 downto 0);
    signal part_car : std_logic_vector(3 downto 0);
    signal part_out : std_logic_vector(4 downto 0);

Begin

    LBL_CSA_PART_TREE: multiplier_tree_radix16
    generic map ( INPUT_SMALLEST_SIZE => 32 )
    port map(
            ia      => a     ,
            i2a     => a2    ,
            i4a     => a4    ,
            i8a     => a8    ,
            ioldsum => oldsum,
            ioldcar => oldcar,
            osum    => sum   ,
            ocar    => car   
    );

    LBL_SELECT_ADDER : carry_sel_adder 
    port map(
        a      => part_sum,
        b      => part_car,  
        do_add => do_add,
        c      => part_out
    );

    -- MS : generate the muxes with a, 2a, 4a, etc.
    a  <= (others => '0') When iMultiplier(counter)   = '0' else iMultiplicand;
    a2 <= (others => '0') When iMultiplier(counter+1) = '0' else iMultiplicand & "0";   -- MS: times two 
    a4 <= (others => '0') When iMultiplier(counter+2) = '0' else iMultiplicand & "00";  -- MS: times four                       
    a8 <= (others => '0') When iMultiplier(counter+3) = '0' else iMultiplicand & "000"; -- MS: times eight   

pMulProcess : process(iclk, ireset)
begin
    if ireset = '1' then
        a        <= (others => '0'); 
        a2       <= (others => '0'); 
        a4       <= (others => '0'); 
        a8       <= (others => '0'); 
        oldsum   <= (others => '0'); 
        oldcar   <= (others => '0'); 
        sum      <= (others => '0'); 
        car      <= (others => '0'); 
        part_sum <= (others => '0');
        part_car <= (others => '0');
    elsif rising_edge(iclk) then
        

    end if;
end process;

End; --architecture logic