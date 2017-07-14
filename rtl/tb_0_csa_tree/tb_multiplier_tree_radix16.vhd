--====================================================================================================================--
-- Title: Testbench for multiplier tree radix 16
-- File Name: tb_multiplier_tree_radix16.vhd
-- Author: MS
-- Date: Thursday, June 11, 2017
--
-- Description:
-- * Provides stimuli to mul
-- * Verifies the output in response to the stimuli
-- * Reports the outcome of the verification on the console
--
--====================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.TxtUtil_pkg.all;
use work.mlite_pack.all; -- MS: for use of subtypes

entity tb_multiplier_tree_radix16 is
end entity tb_multiplier_tree_radix16;

architecture sim of tb_multiplier_tree_radix16 is

    ---------------------------------------------------------------------------------------------------------------------
    -- Simulation parameters and signals
    ---------------------------------------------------------------------------------------------------------------------
    constant cCLOCK_FREQ   : integer := 100000000; -- MS: 100 MHz
    constant cCLOCK_PERIOD : time := 1 sec / cCLOCK_FREQ;

    signal SimFinished     : boolean := false;

    ---------------------------------------------------------------------------------------------------------------------
    -- Clocks and Resets
    ---------------------------------------------------------------------------------------------------------------------

    signal Clk : std_logic := '0';
    signal Rst : std_logic := '0';
    ---------------------------------------------------------------------------------------------------------------------
    -- Unit under test connections
    ---------------------------------------------------------------------------------------------------------------------
    -- Original Multiplier
    signal a       : std_logic_vector(31 downto 0) := (others => '0');
    signal a2      : std_logic_vector(32 downto 0) := (others => '0');
    signal a4      : std_logic_vector(33 downto 0) := (others => '0');
    signal a8      : std_logic_vector(34 downto 0) := (others => '0');
    signal oldsum  : std_logic_vector(34 downto 0) := (others => '0');
    signal oldcar  : std_logic_vector(34 downto 0) := (others => '0');
    signal out_sum : std_logic_vector(37 downto 0) := (others => '0');
    signal out_car : std_logic_vector(37 downto 0) := (others => '0');
    signal randomnumber     : integer;

    component multiplier_tree_radix16 is
        generic (INPUT_SMALLEST_SIZE : positive := 32);
        port 
        (
            ia      : in std_logic_vector(INPUT_SMALLEST_SIZE - 1 downto 0);
            i2a     : in std_logic_vector(INPUT_SMALLEST_SIZE downto 0);
            i4a     : in std_logic_vector(INPUT_SMALLEST_SIZE + 1 downto 0);
            i8a     : in std_logic_vector(INPUT_SMALLEST_SIZE + 2 downto 0);
            ioldsum : in std_logic_vector(INPUT_SMALLEST_SIZE + 2 downto 0);
            ioldcar : in std_logic_vector(INPUT_SMALLEST_SIZE + 2 downto 0);
            osumm   : out std_logic_vector(INPUT_SMALLEST_SIZE + 5 downto 0);
            ocar    : out std_logic_vector(INPUT_SMALLEST_SIZE + 5 downto 0)
        );
    end component;

   component rand_gen is
       port(
           clk       : in std_logic;
           reset_in  : in std_logic;
           rand_num  : out integer
       );
   end component;


begin
    ---------------------------------------------------------------------------------------------------------------------
    -- Clock generation
    ---------------------------------------------------------------------------------------------------------------------
    prClockGen : process is
    begin
        Clk <= '0';
        while not SimFinished loop
        Clk <= not Clk;
        wait for (cCLOCK_PERIOD / 2);
    end loop;
    echo("Simulation ended at: " & time'IMAGE(now));
    wait;
    end process prClockGen;

    ---------------------------------------------------------------------------------------------------------------------
    -- Unit under test
    ---------------------------------------------------------------------------------------------------------------------
    UUT : multiplier_tree_radix16
        generic map(INPUT_SMALLEST_SIZE => 32)
    port map
    (
        ia      => a, 
        i2a     => a2, 
        i4a     => a4, 
        i8a     => a8, 
        ioldsum => oldsum, 
        ioldcar => oldcar, 
        osumm   => out_sum, 
        ocar    => out_car
    );

     RAND: rand_gen
      port map(
        clk       => Clk,
        reset_in  => Rst,
        rand_num  => randomnumber
      );
        ---------------------------------------------------------------------------------------------------------------------
        -- Stimulation
        ---------------------------------------------------------------------------------------------------------------------
        prStimuli           : process
            variable vSimResult : boolean := true;
            variable v_ia       : integer;
            variable v_i2a      : integer;
            variable v_i4a      : integer;
            variable v_i8a      : integer;
            variable v_ioldsum  : integer;
            variable v_ioldcar  : integer;
            variable v_outsum    : integer;
            variable v_outcar    : integer;
            variable vResult    : integer;
 
        begin
            Rst <= '0';
            v_ia      := 0; 
            v_i2a     := 0; 
            v_i4a     := 0;
            v_i8a     := 0;
            v_ioldsum := 0;
            v_ioldcar := 0;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            Rst <= '1';
            wait until rising_edge(Clk);
            wait for cCLOCK_PERIOD * 10;
            wait until rising_edge(Clk);
            Rst <= '0';
            wait until rising_edge(Clk);

            v_ia      := 1; 
            v_i2a     := 0; 
            v_i4a     := 0;
            v_i8a     := 0;
            v_ioldsum := 0;
            v_ioldcar := 0;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            if out_sum /= std_logic_vector(to_unsigned(1, out_sum'length)) then
                vSimResult := false;
                report "Test1 Failed!!" severity ERROR;
            end if;
            v_ia      := 0; 
            v_i2a     := 1; 
            v_i4a     := 0;
            v_i8a     := 0;
            v_ioldsum := 0;
            v_ioldcar := 0;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            if out_sum /= std_logic_vector(to_unsigned(1, out_sum'length)) then
                vSimResult := false;
                report "Test2 Failed!!" severity ERROR;
            end if;
            v_ia      := 0; 
            v_i2a     := 0; 
            v_i4a     := 1;
            v_i8a     := 0;
            v_ioldsum := 0;
            v_ioldcar := 0;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            if out_sum /= std_logic_vector(to_unsigned(1, out_sum'length)) then
                vSimResult := false;
                report "Test3 Failed!!" severity ERROR;
            end if;

            v_ia      := 0; 
            v_i2a     := 0; 
            v_i4a     := 0;
            v_i8a     := 1;
            v_ioldsum := 0;
            v_ioldcar := 0;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            if out_sum /= std_logic_vector(to_unsigned(1, out_sum'length)) then
                vSimResult := false;
                report "Test4 Failed!!" severity ERROR;
            end if;

            v_ia      := 0; 
            v_i2a     := 0; 
            v_i4a     := 0;
            v_i8a     := 0;
            v_ioldsum := 1;
            v_ioldcar := 0;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            if out_sum /= std_logic_vector(to_unsigned(1, out_sum'length)) then
                vSimResult := false;
                report "Test5 Failed!!" severity ERROR;
            end if;

            v_ia      := 0; 
            v_i2a     := 0; 
            v_i4a     := 0;
            v_i8a     := 0;
            v_ioldsum := 0;
            v_ioldcar := 1;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            if out_sum /= std_logic_vector(to_unsigned(1, out_sum'length)) then
                vSimResult := false;
                report "Test6 Failed!!" severity ERROR;
            end if;
            v_ia      := 0; 
            v_i2a     := 0; 
            v_i4a     := 0;
            v_i8a     := 0;
            v_ioldsum := 0;
            v_ioldcar := 1;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            v_outsum := to_integer(unsigned(oldcar));
            v_outcar := to_integer(unsigned(oldsum));
            vResult := v_outcar + v_outsum;
            if (v_ia + v_i2a + v_i4a + v_i8a + v_ioldcar + v_ioldsum) /= vResult then
                vSimResult := false;
                report "Test7 Failed!!" severity ERROR;
            end if;
            v_ia      := 32; 
            v_i2a     := 32; 
            v_i4a     := 32;
            v_i8a     := 32;
            v_ioldsum := 0;
            v_ioldcar := 0;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            v_outsum := to_integer(unsigned(out_sum));
            v_outcar := to_integer(unsigned(out_car));
            vResult := v_outsum + v_outcar;

            if (v_ia + v_i2a + v_i4a + v_i8a + v_ioldcar + v_ioldsum) /= vResult then
                vSimResult := false;
                report "Test8 Failed!!" severity ERROR;
            end if;

            v_ia      := 170; 
            v_i2a     := 170 * 2; 
            v_i4a     := 170 * 4;
            v_i8a     := 170 * 8;
            v_ioldsum := 95;
            v_ioldcar := 64;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            v_outsum := to_integer(unsigned(out_sum));
            v_outcar := to_integer(unsigned(out_car));
            vResult := v_outsum + v_outcar;

            if (v_ia + v_i2a + v_i4a + v_i8a + v_ioldcar + v_ioldsum) /= vResult then
                vSimResult := false;
                report "Test9 Failed!!" severity ERROR;
            end if;

            v_ia      := 666; 
            v_i2a     := 666 * 2; 
            v_i4a     := 666 * 4;
            v_i8a     := 666 * 8;
            v_ioldsum := 666;
            v_ioldcar := 666;
            a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
            a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
            a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
            a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
            oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
            oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

            wait until rising_edge(Clk);
            v_outsum := to_integer(unsigned(out_sum));
            v_outcar := to_integer(unsigned(out_car));
            vResult := v_outsum + v_outcar;

            if (v_ia + v_i2a + v_i4a + v_i8a + v_ioldcar + v_ioldsum) /= vResult then
                vSimResult := false;
                report "Test9 Failed!!" severity ERROR;
            end if;


           for i in 0 to 100000 loop
               v_ia      := randomnumber * randomnumber; 
               v_i2a     := randomnumber * randomnumber * 16;
               v_i4a     := randomnumber * 5555;
               v_i8a     := randomnumber * 6666;
               v_ioldsum := randomnumber * 7777;
               v_ioldcar := randomnumber * randomnumber + 666;
               a      <= std_logic_vector(to_unsigned(v_ia, a'length)); 
               a2     <= std_logic_vector(to_unsigned(v_i2a, a2'length));
               a4     <= std_logic_vector(to_unsigned(v_i4a, a4'length));
               a8     <= std_logic_vector(to_unsigned(v_i8a, a8'length));
               oldsum <= std_logic_vector(to_unsigned(v_ioldsum, oldsum'length));
               oldcar <= std_logic_vector(to_unsigned(v_ioldcar, oldcar'length));

               wait until rising_edge(Clk);
               v_outsum := to_integer(unsigned(out_sum));
               v_outcar := to_integer(unsigned(out_car));
               vResult := v_outsum + v_outcar;

               if (v_ia + v_i2a + v_i4a + v_i8a + v_ioldcar + v_ioldsum) /= vResult then
                   vSimResult := false;
                   report "Test loop Failed!!" severity ERROR;
               end if;
            end loop;


            if (vSimResult) then
                echo("-----------------------------------------------------------------");
                echo("");
                echo(" SIMULATION PASSED :-)");
                echo("");
                echo("-----------------------------------------------------------------");
            else
                echo("-----------------------------------------------------------------");
                echo("!@# ###### ###### ###### ###### ########## ### ##");
                echo("SIMULATION FAILED :-(");
                echo("##### ##### ##### ##### ##### ##### ");
                echo("-----------------------------------------------------------------");
            end if;

            SimFinished <= true;
            wait;
        end process prStimuli;
end architecture sim;