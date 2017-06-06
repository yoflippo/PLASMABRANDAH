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
    signal a, b, c  : std_logic_vector(31 downto 0);
    signal sum      : std_logic_vector(31 downto 0);
    signal carry    : std_logic_vector(32 downto 0);

    signal as, bs, cs, sums  : std_logic_vector(11 downto 0);
    signal carrys            : std_logic_vector(as'length downto 0);

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
    UUT : entity work.csa_adder
        Port map (
        ia => a,
        ib => b,
        ic => c,
        osum => sum,
        ocarry => carry  
    );

    UUT_S : entity work.csa_adder
        Port map (
        ia => as,
        ib => bs,
        ic => cs,
        osum => sums,
        ocarry => carrys  
    );
    --        ---------------------------------------------------------------------------------------------------------------------
            -- Target model(s)
            ---------------------------------------------------------------------------------------------------------------------
            ---------------------------------------------------------------------------------------------------------------------
            -- Stimulation
            ---------------------------------------------------------------------------------------------------------------------

            prStimuli           : process
                variable vSimResult     : boolean := true;
                variable va, vb, vc     : std_logic_vector(31 downto 0);
                variable vas, vbs, vcs  : std_logic_vector(as'length-1 downto 0);
            begin
                Rst <= '0';
                wait until rising_edge(Clk);
                Rst             <= '1';
                wait until rising_edge(Clk);
                wait for cCLOCK_PERIOD * 10;
                Rst <= '0';
                wait until rising_edge(Clk);
                

                -- TEST 1
                va      := X"11111111";
                vb      := X"11111111";
                vc      := X"00000000";
                a      <= va;
                b      <= vb;
                c      <= vc;

                -- TEST 1.1 - shorter words
                vas      := X"000";
                vbs      := X"111";
                vcs      := X"111";
                as      <= vas;
                bs      <= vbs;
                cs      <= vcs;

                wait until rising_edge(Clk);
                if sum = X"000" AND carry = X"0222" then
                    vSimResult := false;
                    report "Test3 Failed!!" severity ERROR;
                end if;
                wait until rising_edge(Clk);
                if sum = X"00000000" AND carry = X"022222222" then
                    vSimResult := false;
                    report "Test1 Failed!!" severity ERROR;
                end if;

                -- TEST 2
                va      := X"11111111";
                vb      := X"00000000";
                vc      := X"11111111";
                a      <= va;
                b      <= vb;
                c      <= vc;
                wait until rising_edge(Clk);
                if sum = X"00000000" AND carry = X"022222222" then
                    vSimResult := false;
                    report "Test2 Failed!!" severity ERROR;
                end if;

                -- TEST 3
                va      := X"00000000";
                vb      := X"11111111";
                vc      := X"11111111";
                a      <= va;
                b      <= vb;
                c      <= vc;
                wait until rising_edge(Clk);
                if sum = X"00000000" AND carry = X"022222222" then
                    vSimResult := false;
                    report "Test3 Failed!!" severity ERROR;
                end if;

                -- TEST 4
                va      := X"00000000";
                vb      := X"00000000";
                vc      := X"11111111";
                a      <= va;
                b      <= vb;
                c      <= vc;
                wait until rising_edge(Clk);
                if sum = X"11111111" AND carry = X"000000000" then
                    vSimResult := false;
                    report "Test4 Failed!!" severity ERROR;
                end if;

                -- TEST 5
                va      := X"FFFFFFFF";
                vb      := X"FFFFFFFF";
                vc      := X"FFFFFFFF";
                a      <= va;
                b      <= vb;
                c      <= vc;
                wait until rising_edge(Clk);
                if sum = X"FFFFFFFF" AND carry = X"1FFFFFFE" then
                    vSimResult := false;
                    report "Test5 Failed!!" severity ERROR;
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