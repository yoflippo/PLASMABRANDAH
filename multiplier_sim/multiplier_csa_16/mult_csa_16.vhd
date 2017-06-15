--====================================================================================================================--
--  Title:        Multiplier CSA tree
--  File Name:    mult_csa_16.vhd
--  Author:       MS
--  Date:         13-06-17
--
--  Description:  This is a faster multiplier than the default plasma processor multiplier.
--                  It uses a partial CSA-adder tree @radix-16.
--                  It reduces the number of clockcycles with a factor of 4.
--                  Future improvements: use booths recoding based on paper: 
--                      An Efficient Softcore Multiplier Architecture for Xilinx FPGAs
--====================================================================================================================--

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
          oFinished                   : out std_logic;
          oResultL                    : out std_logic_vector(31 downto 0);
          oResultH                    : out std_logic_vector(31 downto 0)
    );
end; --entity adder

Architecture logic Of mult_csa Is

    ----------------------------------------------------------------------------------------------
    -- Components
    ----------------------------------------------------------------------------------------------
    component carry_sel_adder Port (
        a, b   : In std_logic_vector(31 Downto 0);
        do_add : In std_logic;
        c      : Out std_logic_vector(32 Downto 0)
    );
    end component;

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

    ----------------------------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------------------------
    constant BUS_WIDTH : integer    := 32;
    signal counter     : integer    := 7;
    signal do_add      : std_logic  := '1'; 
    signal car_out_bv  : std_logic  := '0';    
    --signal csel_a, csel_b : std_logic_vector(iMultiplier'range);
    --signal csel_c         : std_logic_vector(iMultiplier'length+1 downto 0);
    signal a           : std_logic_vector(BUS_WIDTH-1 downto 0);
    signal a2          : std_logic_vector(BUS_WIDTH+0 downto 0);
    signal a4          : std_logic_vector(BUS_WIDTH+1 downto 0);
    signal a8          : std_logic_vector(BUS_WIDTH+2 downto 0);
    signal oldsum      : std_logic_vector(BUS_WIDTH+2 downto 0) := (others => '0');
    signal oldcar      : std_logic_vector(BUS_WIDTH+2 downto 0) := (others => '0');
    signal sum         : std_logic_vector(BUS_WIDTH+5 downto 0);
    signal car         : std_logic_vector(BUS_WIDTH+5 downto 0);
    signal part_sum    : std_logic_vector(3 downto 0);
    signal part_car    : std_logic_vector(2 downto 0);
    signal part_car_com: std_logic_vector(3 downto 0); -- complete signal
    signal part_result : std_logic_vector(3 downto 0);
    signal part_out    : std_logic_vector(4 downto 0);
    signal finished    : std_logic := '0';

    subtype mulmul_add is integer range 0 to 15;
    type res is array(mulmul_add) of std_logic_vector(3 downto 0);
    signal result : res;

Begin
    ----------------------------------------------------------------------------------------------
    -- Instantiations
    ----------------------------------------------------------------------------------------------
    LBL_CSA_PART_TREE: multiplier_tree_radix16
    generic map ( INPUT_SMALLEST_SIZE => 32 )
    port map(
        ia      => a,
        i2a     => a2,
        i4a     => a4,
        i8a     => a8,
        ioldsum => oldsum,
        ioldcar => oldcar,
        osum    => sum,
        ocar    => car   
    );


    ----------------------------------------------------------------------------------------------
    -- Combinatorics
    ----------------------------------------------------------------------------------------------
    ---- select the right a, a2, a4 and a8
    --a                <= (others => '0') When iMultiplier((counter*4)+0) = '0' else iMultiplicand;
    --a2               <= (others => '0') When iMultiplier((counter*4)+1) = '0' else iMultiplicand & "0";   
    --a4               <= (others => '0') When iMultiplier((counter*4)+2) = '0' else iMultiplicand & "00";                         
    --a8               <= (others => '0') When iMultiplier((counter*4)+3) = '0' else iMultiplicand & "000";   
    -- part of carry and sum has to be saved 8 times to get 32 bits
    part_car         <= car(2 downto 0); -- split the output of the CSA_PART_TREE
    part_car_com     <= part_car & car_out_bv; 
    oldcar           <= car(car'high downto 3);-- split the output of the CSA_PART_TREE
    part_sum         <= sum(3 downto 0);       -- split the output of the CSA_PART_TREE
    oldsum           <= '0' & sum(sum'high downto 4);-- split the output of the CSA_PART_TREE
    finished         <= '1' when counter = 0 else '0';
    oFinished        <= finished;
    oResultH         <= (others => '0');
    oResultL(3  downto 0 ) <= result(0) when finished = '1' else (others => '0');
    oResultL(7  downto 4 ) <= result(1) when finished = '1' else (others => '0');
    oResultL(11 downto 8 ) <= result(2) when finished = '1' else (others => '0');
    oResultL(15 downto 12) <= result(3) when finished = '1' else (others => '0');
    oResultL(19 downto 16) <= result(4) when finished = '1' else (others => '0');
    oResultL(23 downto 20) <= result(5) when finished = '1' else (others => '0');
    oResultL(27 downto 24) <= result(6) when finished = '1' else (others => '0');
    oResultL(31 downto 28) <= result(7) when finished = '1' else (others => '0');
    
    result(counter)  <= part_out(3 downto 0);  -- the output of bv_adder has to be saved for next clk
   
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
        counter  <= 0;
    elsif rising_edge(iclk) then
        if counter < 8 then
            if iMultiplier((counter*4)+0) = '0' then
                a <= (others => '0');
            else
                a <= iMultiplicand;
            end if;

            if iMultiplier((counter*4)+1) = '0' then
                a2 <= (others => '0');
            else
                a2 <= iMultiplicand & '0';
            end if;

            if iMultiplier((counter*4)+2) = '0' then
                a4 <= (others => '0');
            else
                a4 <= iMultiplicand & "00";
            end if;

            if iMultiplier((counter*4)+3) = '0' then
                a8 <= (others => '0');
            else
                a8 <= iMultiplicand & "000";
            end if;

            part_out    <= bv_adder(part_sum,part_car_com,do_add);
            car_out_bv  <= part_out(4);           -- the carry of bv_adder has to be saved for next clk
            counter     <= counter + 1;
        end if;     
    end if;
end process;

End; --architecture logic


    -- -- MS : use the bv_adder instead, for the time being
    --LBL_SELECT_ADDER : carry_sel_adder 
    --port map(
    --    a      => part_sum,
    --    b      => part_car,  
    --    do_add => do_add,
    --    c      => part_out
    --);
