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
            osumm  : out std_logic_vector(INPUT_SMALLEST_SIZE+5 downto 0);
            ocar   : out std_logic_vector(INPUT_SMALLEST_SIZE+5 downto 0)
    );
    end component multiplier_tree_radix16;

    ----------------------------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------------------------
    constant BUS_WIDTH : integer    := 32;
    signal counter     : integer    := 0;
    signal do_add      : std_logic  := '1';    
    signal a           : std_logic_vector(BUS_WIDTH-1 downto 0);
    signal a2          : std_logic_vector(BUS_WIDTH+0 downto 0);
    signal a4          : std_logic_vector(BUS_WIDTH+1 downto 0);
    signal a8          : std_logic_vector(BUS_WIDTH+2 downto 0);
    signal oldsum      : std_logic_vector(BUS_WIDTH+2 downto 0) := (others => '0');
    signal oldcar      : std_logic_vector(BUS_WIDTH+2 downto 0) := (others => '0');
    signal sum         : std_logic_vector(BUS_WIDTH+5 downto 0);
    signal car         : std_logic_vector(BUS_WIDTH+5 downto 0);
    signal part_vResult : std_logic_vector(3 downto 0);
    signal finished    : std_logic := '0';
    signal MulPliOld   : std_logic_vector(31 downto 0) := (others => '0');
    signal MulCanOld   : std_logic_vector(31 downto 0) := (others => '0');

    subtype mulmul_add is integer range 0 to (15+2); -- MS: 17 because we have 1 cc extra
    type res is array(mulmul_add) of std_logic_vector(3 downto 0);
    

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
        osumm   => sum,
        ocar    => car   
    );


    ----------------------------------------------------------------------------------------------
    -- Combinatorics
    ----------------------------------------------------------------------------------------------  
     --part of carry and sum has to be saved 8 times to get 32 bits
    oFinished              <= finished;
    --oResultH               <= (others => '0');
    --oResultL(3  downto 0 ) <= vResult(1) when finished = '1' else (others => '0');
    --oResultL(7  downto 4 ) <= vResult(2) when finished = '1' else (others => '0');
    --oResultL(11 downto 8 ) <= vResult(3) when finished = '1' else (others => '0');
    --oResultL(15 downto 12) <= vResult(4) when finished = '1' else (others => '0');
    --oResultL(19 downto 16) <= vResult(5) when finished = '1' else (others => '0');
    --oResultL(23 downto 20) <= vResult(6) when finished = '1' else (others => '0');
    --oResultL(27 downto 24) <= vResult(7) when finished = '1' else (others => '0');
    --oResultL(31 downto 28) <= vResult(8) when finished = '1' else (others => '0');

   
pMulProcess : process(iclk, ireset)
    variable vCounter      : integer    := 0;
    variable vcar_out_bv   : std_logic  := '0';
    variable vBv_adder_out : std_logic_vector(4 downto 0); 
    variable vResult       : res;
    variable vStarted      : std_logic := '0';
    variable vAlmostFinished: std_logic := '0';
begin
    if ireset = '1' then
        a            <= (others => '0'); 
        a2           <= (others => '0'); 
        a4           <= (others => '0'); 
        a8           <= (others => '0');
        oldcar       <= (others => '0');    
        oldsum       <= (others => '0'); 
        counter      <= 0;
        finished     <= '0';   
        part_vResult  <= (others => '0');
        vBv_adder_out     := (others => '0'); 
        vcar_out_bv  := '0';  
        vAlmostFinished := '0';  

    elsif rising_edge(iclk) then
             -- MS: logic for when the multiplier and multiplicand are cahnge
        if MulPliOld /= iMultiplier or MulCanOld /= iMultiplicand then
            MulPliOld <= iMultiplier;
            MulCanOld <= iMultiplicand;
            finished <= '0';
            vCounter := 0;
            vStarted := '1';
            vAlmostFinished := '0'; 
        end if;

        if vStarted = '1' then
            if vCounter < 8 then
                if iMultiplier((vCounter*4)+0) = '0' then
                    a <= (others => '0');
                else
                    a <= iMultiplicand;
                end if;
            
                if iMultiplier((vCounter*4)+1) = '0' then
                    a2 <= (others => '0');
                else
                    a2 <= iMultiplicand & '0';
                end if;
            
                if iMultiplier((vCounter*4)+2) = '0' then
                    a4 <= (others => '0');
                else
                    a4 <= iMultiplicand & "00";
                end if;
            
                if iMultiplier((vCounter*4)+3) = '0' then
                    a8 <= (others => '0');
                else
                    a8 <= iMultiplicand & "000";
                end if;
            end if;
            vBv_adder_out     := bv_adder(sum(3 downto 0),car(3 downto 1) & vBv_adder_out(4),do_add);
            vResult(vCounter) := vBv_adder_out(3 downto 0);        -- the output of bv_adder has to be saved for next clk
             
            oldcar           <= '0' & car(car'high downto 4);      -- split the output of the CSA_PART_TREE
            oldsum           <= '0' & sum(sum'high downto 4);-- split the output of the CSA_PART_TREE

            if vCounter < 8 then
                vCounter := (vCounter+1);
            else
                if vAlmostFinished = '1' then
                    finished <= '1';
                    for i in 0 to 7 loop
                        oResultL((3+(i*4)) downto (i*4)) <= vResult(i+1);
                    end loop;
                end if;       
                vAlmostFinished := '1';
            end if; 


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
    --    c      => vBv_adder_out
    --);
