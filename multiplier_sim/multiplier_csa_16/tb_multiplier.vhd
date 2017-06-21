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
   signal multiplier,multiplicand      : std_logic_vector(31 downto 0) := (others => '0');
   signal resultH,resultL              : std_logic_vector(31 downto 0);
   signal finished                     : std_logic;

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
   UUT: entity work.mult_csa
     port map(
         iclk          => Clk,
         ireset        => Rst,
         iMultiplier   => multiplier,
         iMultiplicand => multiplicand,
         oFinished     => finished,
         oResultL      => resultL,
         oResultH      => resultH     
    );



   ---------------------------------------------------------------------------------------------------------------------
   -- Target model(s)
   ---------------------------------------------------------------------------------------------------------------------


   ---------------------------------------------------------------------------------------------------------------------
   -- Stimulation
   ---------------------------------------------------------------------------------------------------------------------
   prStimuli: process
      variable vSimResult  : boolean := true;
      variable ia          : integer := 0;
      variable ib          : integer := 0;
      variable vresult     : integer := 0;
   begin
      Rst   <= '0';
      wait until rising_edge(Clk);
      Rst   <= '1';
      wait until rising_edge(Clk);
      wait for cCLOCK_PERIOD * 10;
      wait until rising_edge(Clk);
      Rst   <= '0';
      wait until rising_edge(Clk);

      ---- MS : test
      --ia := 255;
      --ib := 4;
      --multiplier         <= std_logic_vector(to_unsigned(ia, multiplier'length));
      --multiplicand       <= std_logic_vector(to_unsigned(ib, multiplier'length));
 	    --wait until rising_edge(Clk);
 	    --wait until rising_edge(finished);
      --vresult := to_integer(unsigned(resultH & resultL));
      --if vresult /= (ia*ib) then
      --   vSimResult := false;
      --   report "Test1 Failed!!" severity ERROR;
      --end if;
      --wait until rising_edge(Clk);

    -- MS : test
      ia := 666;
      ib := 666;
      multiplier         <= std_logic_vector(to_unsigned(ia, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(ib, multiplier'length));
      wait until rising_edge(Clk);
      wait until rising_edge(finished);
      vresult := to_integer(unsigned(resultL));
      if vresult /= (ia*ib) then
         vSimResult := false;
         report "Test1 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);

      ia := 555;
      ib := 555;
      multiplier         <= std_logic_vector(to_unsigned(ia, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(ib, multiplier'length));
      wait until rising_edge(Clk);
      wait until rising_edge(finished);
      vresult := to_integer(unsigned(resultL));
      if vresult /= (ia*ib) then
         vSimResult := false;
         report "Test1 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      
      --    -- MS : test
      --ia := 777;
      --ib := 777;
      --multiplier         <= std_logic_vector(to_unsigned(ia, multiplier'length));
      --multiplicand       <= std_logic_vector(to_unsigned(ib, multiplier'length));
      --wait until rising_edge(Clk);
      --wait until rising_edge(finished);
      --vresult := to_integer(unsigned(resultL));
      --if vresult /= (ia*ib) then
      --   vSimResult := false;
      --   report "Test1 Failed!!" severity ERROR;
      --end if;
      --wait until rising_edge(Clk);
      --Rst   <= '1';
      --wait until rising_edge(Clk);
      --Rst   <= '0';
      --wait until rising_edge(Clk);
      --ia := 666;
      --ib := 666;
      --multiplier         <= std_logic_vector(to_unsigned(ia, multiplier'length));
      --multiplicand       <= std_logic_vector(to_unsigned(ib, multiplier'length));
      --wait until rising_edge(Clk);
      --wait until rising_edge(finished);
      --vresult := to_integer(unsigned(resultH & resultL));
      --if vresult /= (ia*ib) then
      --   vSimResult := false;
      --   report "Test2 Failed!!" severity ERROR;
      --end if;
      --wait until rising_edge(Clk);
     -- ia := 1024;
     -- ib := 16;
     -- a         <= std_logic_vector(to_unsigned(ia, a'length));
     -- b         <= std_logic_vector(to_unsigned(ib, b'length));
     -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
     -- wait until rising_edge(Clk);
     -- mult_func <= MULT_READ_LO;
     -- wait until falling_edge(pause_out);
     -- if c_mult /= std_logic_vector(to_unsigned(ia*ib, c_mult'length)) then
     --    vSimResult := false;
     --    report "Test2 Failed!!" severity ERROR;
     -- end if;


     -- a         <= x"FFFFFFFF";
     -- b         <= x"00000010";
     -- ia := to_integer(unsigned(a));
     -- ib := to_integer(unsigned(b));
     -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
     -- wait until rising_edge(Clk);
     -- mult_func <= MULT_READ_LO;
     -- wait until falling_edge(pause_out);
     -- if c_mult /= x"FFFFFFF0" then
     --    vSimResult := false;
     --    report "Test3 Failed!!" severity ERROR;
     -- end if;



     -- -- MS : other cases like division and signed multiplication...
     -- -- PENDING...
      
     -- a         <= x"FFFFFFFF";
     -- b         <= x"00000010";
     -- ia := to_integer(unsigned(a));
     -- ib := to_integer(unsigned(b));
     -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
     -- wait until rising_edge(Clk);
     -- mult_func <= MULT_READ_LO;
     -- wait until falling_edge(pause_out);
     -- if c_mult /= x"FFFFFFF0" then
     --    vSimResult := false;
     --    report "Test3 Failed!!" severity ERROR;
     -- end if;
      





      if (vSimResult) then
         echo("-----------------------------------------------------------------");
         echo("");
         echo(" SIMULATION PASSED            :-)");
         echo("");
         echo("-----------------------------------------------------------------");
      else
         echo("-----------------------------------------------------------------");
         echo("!@#  ###### ###### ###### ###### ########## ### ##");
         echo("SIMULATION FAILED             :-(");
         echo("#####  ##### #####  ##### #####  ##### ");
         echo("-----------------------------------------------------------------");
      end if;

      SimFinished  <= true;
      wait;
   end process prStimuli;

end architecture sim;