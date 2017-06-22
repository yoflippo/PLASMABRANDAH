--====================================================================================================================--
-- Title: Multiplier CSA tree
-- File Name: mult_csa_16.vhd
-- Author: MS
-- Date: 13-06-17
--
-- Description: This is a faster multiplier than the default plasma processor multiplier.
-- It uses a partial CSA-adder tree @radix-16.
-- It reduces the number of clockcycles with a factor of 4.
-- Future improvements: use booths recoding based on paper:
-- An Efficient Softcore Multiplier Architecture for Xilinx FPGAs
--====================================================================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mlite_pack.all;

entity mult_csa is
    port (
        iclk                       : in std_logic;
        ireset                     : in std_logic;
        iMultiplier, iMultiplicand : in std_logic_vector(31 downto 0);
        oFinished                  : out std_logic;
        oResultL                   : out std_logic_vector(31 downto 0);
        oResultH                   : out std_logic_vector(31 downto 0)
    );
end; --entity adder

architecture logic of mult_csa is

    ----------------------------------------------------------------------------------------------
    -- Components
    ----------------------------------------------------------------------------------------------
    component carry_sel_adder
        port (
            a, b   : in std_logic_vector(31 downto 0);
            do_add : in std_logic;
            c      : out std_logic_vector(32 downto 0)
        );
    end component;

    component multiplier_tree_radix16 is
        generic (INPUT_SMALLEST_SIZE : positive := 32);
        port (
            ia      : in std_logic_vector(INPUT_SMALLEST_SIZE - 1 downto 0);
            i2a     : in std_logic_vector(INPUT_SMALLEST_SIZE downto 0);
            i4a     : in std_logic_vector(INPUT_SMALLEST_SIZE + 1 downto 0);
            i8a     : in std_logic_vector(INPUT_SMALLEST_SIZE + 2 downto 0);
            ioldsum : in std_logic_vector(INPUT_SMALLEST_SIZE + 2 downto 0);
            ioldcar : in std_logic_vector(INPUT_SMALLEST_SIZE + 2 downto 0);
            osumm   : out std_logic_vector(INPUT_SMALLEST_SIZE + 5 downto 0);
            ocar    : out std_logic_vector(INPUT_SMALLEST_SIZE + 5 downto 0)
        );
    end component multiplier_tree_radix16;

    ----------------------------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------------------------
    constant BUS_WIDTH  : integer := 32;
    signal counter      : integer := 0;
    signal do_add       : std_logic := '1'; 
    signal a            : std_logic_vector(BUS_WIDTH - 1 downto 0);
    signal a2           : std_logic_vector(BUS_WIDTH + 0 downto 0);
    signal a4           : std_logic_vector(BUS_WIDTH + 1 downto 0);
    signal a8           : std_logic_vector(BUS_WIDTH + 2 downto 0);
    signal oldsum       : std_logic_vector(BUS_WIDTH + 2 downto 0) := (others => '0');
    signal oldcar       : std_logic_vector(BUS_WIDTH + 2 downto 0) := (others => '0');
    signal sum          : std_logic_vector(BUS_WIDTH + 5 downto 0);
    signal car          : std_logic_vector(BUS_WIDTH + 5 downto 0);
    signal part_vResult : std_logic_vector(3 downto 0);
    signal finished     : std_logic := '0';
    signal MulPliOld    : std_logic_vector(31 downto 0) := (others => '0');
    signal MulCanOld    : std_logic_vector(31 downto 0) := (others => '0');

    subtype mulmul_add is integer range 0 to (15 + 2); -- MS: 17 because we have 1 cc extra
    type res is array(mulmul_add) of std_logic_vector(3 downto 0);
 

begin
    ----------------------------------------------------------------------------------------------
    -- Instantiations
    ----------------------------------------------------------------------------------------------
    LBL_CSA_PART_TREE : multiplier_tree_radix16
        generic map(INPUT_SMALLEST_SIZE => 32)
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
        -- MS: part of carry and sum has to be saved 8 times to get 32 bits
        oFinished <= finished;


 
        pMulProcess              : process (iclk, ireset)
            variable vCounter        : integer := 0;
            variable vcar_out_bv     : std_logic := '0';
            variable vBv_adder_out   : std_logic_vector(4 downto 0);
            variable vResult         : res;
            variable vStarted        : std_logic := '0';
            variable vAlmostFinished : std_logic := '0';

    variable resultH      : std_logic_vector(BUS_WIDTH + 6 downto 0);
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
                part_vResult <= (others => '0');
                vBv_adder_out   := (others => '0');
                vcar_out_bv     := '0'; 
                vAlmostFinished := '0'; 
            elsif rising_edge(iclk) then
                -- MS: logic for when the multiplier and multiplicand are changed
                if MulPliOld /= iMultiplier or MulCanOld /= iMultiplicand then
                    MulPliOld <= iMultiplier;
                    MulCanOld <= iMultiplicand;
                    finished  <= '0';
                    vCounter        := 0;
                    vStarted        := '1';
                    vAlmostFinished := '0';
                end if;

                if vAlmostFinished = '1' then
                        -- MS: reset the tree, to prevent residue values
                        resultH   := bv_adder(sum, car, do_add);
                        oResultH  <= resultH(oResultH'range);
                        vAlmostFinished := '0';
                        a      <= (others => '0');
                        a2     <= (others => '0');
                        a4     <= (others => '0');
                        a8     <= (others => '0');
                        oldcar <= (others => '0'); 
                        oldsum <= (others => '0');
                end if;

                -- MS: only do multiplication when new values are received
                if vStarted = '1' then
                    if vCounter < 8 then
                        if iMultiplier((vCounter * 4) + 0) = '0' then
                            a <= (others => '0');
                        else
                            a <= iMultiplicand;
                        end if;
 
                        if iMultiplier((vCounter * 4) + 1) = '0' then
                            a2 <= (others => '0');
                        else
                            a2 <= iMultiplicand & '0';
                        end if;
 
                        if iMultiplier((vCounter * 4) + 2) = '0' then
                            a4 <= (others => '0');
                        else
                            a4 <= iMultiplicand & "00";
                        end if;
 
                        if iMultiplier((vCounter * 4) + 3) = '0' then
                            a8 <= (others => '0');
                        else
                            a8 <= iMultiplicand & "000";
                        end if;
                        else
                            
                    end if;
                    -- MS: sum the last part
                    vBv_adder_out     := bv_adder(sum(3 downto 0), car(3 downto 1) & vBv_adder_out(4), do_add);
                    vResult(vCounter) := vBv_adder_out(3 downto 0); 
                    -- MS: relay the remaining part of the sum and carry
                    oldcar <= '0' & car(car'HIGH downto 4); 
                    oldsum <= '0' & sum(sum'HIGH downto 4); 

                    if vCounter < 8 then -- MS: this test case is repeated up top
                        vCounter := (vCounter + 1);
                    else
                        finished <= '1';
                        for i in 0 to 6 loop
                            oResultL((3 + (i * 4)) downto (i * 4)) <= vResult(i + 1);
                        end loop;
                        oResultL(31 downto 28) <= vBv_adder_out(3 downto 0);
                        vStarted := '0';
                        vAlmostFinished := '1';

                        a      <= (others => '0');
                        a2     <= (others => '0');
                        a4     <= (others => '0');
                        a8     <= (others => '0');
                    end if; -- counter
                end if; -- started
            end if; -- rising edge
        end process;
end; --architecture logic