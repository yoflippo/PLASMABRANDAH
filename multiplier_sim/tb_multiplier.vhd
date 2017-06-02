--====================================================================================================================--
--  Title:        Testbench for multiplier_tb module
--  File Name:    multiplier_tb.vhd
--  Author:       MS
--  Date:         Thursday, June 01, 2017
--
--  Description:
--                * Provides stimuli to mul
--                * Verifies the output in response to the stimuli
--                * Reports the outcome of the verification on the console
--
--====================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.TxtUtil_pkg.all;
use work.mlite_pack.all;  -- MS: for use of subtypes


entity  multiplier_tb is
end entity  multiplier_tb;

architecture sim of multiplier_tb is

   ---------------------------------------------------------------------------------------------------------------------
   -- Simulation parameters and signals
   ---------------------------------------------------------------------------------------------------------------------
   constant cCLOCK_FREQ    : integer   := 100000000; -- MS: 100 MHz
   constant cCLOCK_PERIOD  : time      := 1 sec / cCLOCK_FREQ;

   signal SimFinished      : boolean   := false;

   ---------------------------------------------------------------------------------------------------------------------
   -- Clocks and Resets
   ---------------------------------------------------------------------------------------------------------------------

   signal Clk              : std_logic := '0';
   signal Rst              : std_logic := '0';


   ---------------------------------------------------------------------------------------------------------------------
   -- Unit under test connections
   ---------------------------------------------------------------------------------------------------------------------
   -- Original Multiplier
   signal a                : std_logic_vector(31 downto 0) := (others => '0');
   signal b                : std_logic_vector(31 downto 0) := (others => '0');
   signal mult_func        : mult_function_type;
   signal c_mult           : std_logic_vector(31 downto 0) := (others => '0');
   signal pause_out        : std_logic;

   component mult is
      port(
         clk       : in std_logic;
         reset_in  : in std_logic;
         a, b      : in std_logic_vector(31 downto 0);
         mult_func : in mult_function_type;
         c_mult    : out std_logic_vector(31 downto 0);
         pause_out : out std_logic
      );
   end component; 



begin

   ---------------------------------------------------------------------------------------------------------------------
   -- Clock generation
   ---------------------------------------------------------------------------------------------------------------------
   prClockGen: process is
   begin
      Clk <= '0';
      while NOT SimFinished loop
         Clk <= NOT Clk;
         wait for (cCLOCK_PERIOD / 2);
      end loop;
      echo("Simulation ended at: " & time'IMAGE(now));
      wait;
   end process prClockGen;

   ---------------------------------------------------------------------------------------------------------------------
   -- Unit under test
   ---------------------------------------------------------------------------------------------------------------------
   UUT: entity work.mult
     port map(
        clk       => Clk,
        reset_in  => Rst,
        a         => a,
        b         => b,
        mult_func => mult_func,
        c_mult    => c_mult,
        pause_out => pause_out
    );


   ---------------------------------------------------------------------------------------------------------------------
   -- Target model(s)
   ---------------------------------------------------------------------------------------------------------------------


   ---------------------------------------------------------------------------------------------------------------------
   -- Stimulation
   ---------------------------------------------------------------------------------------------------------------------
   prStimuli: process
      variable vSimResult : boolean := true;
   begin
      Rst   <= '0';

      wait until rising_edge(Clk);
      Rst   <= '1';
      wait until rising_edge(Clk);
      wait for cCLOCK_PERIOD * 10;
      wait until rising_edge(Clk);
      Rst   <= '0';

      wait until rising_edge(Clk);

      a         <= X"00000303";
      b         <= X"00000002";
      mult_func <= MULT_MULT; 		-- MS: choose type of multiplication
 	  wait until rising_edge(Clk);
      mult_func <=  MULT_NOTHING;	-- MS: start multiplier
      wait for cCLOCK_PERIOD * 11;
      mult_func <= MULT_READ_LO;


 	  wait until rising_edge(pause_out);

      wait for cCLOCK_PERIOD * 10;

      a         <= X"00000333";
      b         <= X"00000002";
      mult_func <= MULT_MULT; 

      wait for cCLOCK_PERIOD * 10;
      

      if (vSimResult) then
         echo("-----------------------------------------------------------------");
         echo("");
         echo(" SIMULATION PASSED            :-)");
         echo("");
         echo("-----------------------------------------------------------------");
      else
         echo("-----------------------------------------------------------------");
         echo("");
         echo("SIMULATION FAILED             :-(");
         echo("");
         echo("-----------------------------------------------------------------");
      end if;

      SimFinished  <= true;
      wait;
   end process prStimuli;

end architecture sim;
