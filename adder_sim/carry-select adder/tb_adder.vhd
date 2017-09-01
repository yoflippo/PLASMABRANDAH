--====================================================================================================================--
-- Title: Testbench for adder_tb module
-- File Name: adder_tb.vhd
-- Author: MS
-- Date: Thursday, June 01, 2017
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
entity adder_tb is
end entity adder_tb;

architecture sim of adder_tb is

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

    signal a, b            : std_logic_vector(31 downto 0);
    signal c               : std_logic_vector(32 downto 0);
    signal do_add          : std_logic;
    signal result_bv_adder : std_logic_vector(32 downto 0);

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
    UUT : entity work.adder
        port map(
            a      => a, 
            b      => b, 
            do_add => do_add, 
            c      => c
        );
            ---------------------------------------------------------------------------------------------------------------------
            -- Target model(s)
            ---------------------------------------------------------------------------------------------------------------------
            ---------------------------------------------------------------------------------------------------------------------
            -- Stimulation
            ---------------------------------------------------------------------------------------------------------------------

            prStimuli           : process
                variable vSimResult : boolean := true;
                variable va, vb     : std_logic_vector(31 downto 0);
                variable vdo_add    : std_logic;
            begin
                Rst <= '0';
                wait until rising_edge(Clk);
                Rst             <= '1';
                a               <= X"00000000";
                b               <= X"00000000";
                do_add          <= '1';
                result_bv_adder <= bv_adder(a, b, do_add);
                wait until rising_edge(Clk);
                result_bv_adder <= bv_adder(a, b, do_add);
                wait for cCLOCK_PERIOD * 10;
                wait until rising_edge(Clk);
                Rst <= '0';

                -- first test subtracting
                va      := X"00000303";
                vb      := X"00000002";
                vdo_add := '0';
                a               <= va;
                b               <= vb;
                do_add          <= vdo_add;
                result_bv_adder <= bv_adder(va, vb, vdo_add);
                wait until rising_edge(Clk);
                assert (c = result_bv_adder) report "Test1 subtraction Failed!!" severity ERROR;
                if result_bv_adder /= c then
                    vSimResult := false;
                end if;

                -- second test subtracting
                wait until rising_edge(Clk);
                va      := X"06660303";
                vb      := X"00000666";
                vdo_add := '0';
                a               <= va;
                b               <= vb;
                do_add          <= vdo_add;
                result_bv_adder <= bv_adder(va, vb, vdo_add);
                wait until rising_edge(Clk);
                assert (c = result_bv_adder) report "Test2 subtraction Failed!!" severity ERROR;
                if result_bv_adder /= c then
                    vSimResult := false;
                end if;

                -- third test subtracting
                wait until rising_edge(Clk);
                va      := X"00000100";
                vb      := X"00000666";
                vdo_add := '0';
                a               <= va;
                b               <= vb;
                do_add          <= vdo_add;
                result_bv_adder <= bv_adder(va, vb, vdo_add);
                wait until rising_edge(Clk);
                assert (c = result_bv_adder) report "Test3 subtraction Failed!!" severity ERROR;
                if result_bv_adder /= c then
                    vSimResult := false;
                end if;

                -- 4th test subtracting
                wait until rising_edge(Clk);
                va      := X"00000000";
                vb      := X"FFFFFFFF";
                vdo_add := '0';
                a               <= va;
                b               <= vb;
                do_add          <= vdo_add;
                result_bv_adder <= bv_adder(va, vb, vdo_add);
                wait until rising_edge(Clk);
                assert (c = result_bv_adder) report "Test4 subtraction Failed!!" severity ERROR;
                if result_bv_adder /= c then
                    vSimResult := false;
                end if;

                -- test addition
                wait until rising_edge(Clk);
                va      := X"00000303";
                vb      := X"00000002";
                vdo_add := '1';
                a               <= va;
                b               <= vb;
                do_add          <= vdo_add;
                result_bv_adder <= bv_adder(va, vb, vdo_add);
                wait until rising_edge(Clk);
                assert (c = result_bv_adder) report "Test1 Failed!!" severity ERROR;
                if result_bv_adder /= c then
                    vSimResult := false;
                end if;

                -- test addition
                wait until rising_edge(Clk);
                va      := X"06660303";
                vb      := X"00000666";
                vdo_add := '1';
                a               <= va;
                b               <= vb;
                do_add          <= vdo_add;
                result_bv_adder <= bv_adder(va, vb, vdo_add);
                wait until rising_edge(Clk);
                assert (c = result_bv_adder) report "Test2 Failed!!" severity ERROR;
                if result_bv_adder /= c then
                    vSimResult := false;
                end if;

                -- test addition
                wait until rising_edge(Clk);
                va      := X"FFFFFFFF";
                vb      := X"FFFFFFFF";
                vdo_add := '1';
                a               <= va;
                b               <= vb;
                do_add          <= vdo_add;
                result_bv_adder <= bv_adder(va, vb, vdo_add);
                wait until rising_edge(Clk);
                assert (c = result_bv_adder) report "Test3 Failed!!" severity ERROR;
                if result_bv_adder /= c then
                    vSimResult := false;
                end if;

                if (vSimResult) then
                    echo("-----------------------------------------------------------------");
                    echo("");
                    echo(" SIMULATION PASSED :-)");
                    echo("");
                    echo("-----------------------------------------------------------------");
                else
                    echo("-----------------------------------------------------------------");
                    echo("#######################################");
                    echo("SIMULATION FAILED :-(");
                    echo("#########################");
                    echo("-----------------------------------------------------------------");
                end if;

                SimFinished <= true;
                wait;
            end process prStimuli;

end architecture sim;