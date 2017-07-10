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
use ieee.math_real.all;

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
   signal c_mult2          : std_logic_vector(31 downto 0) := (others => '0');
   signal pause_out        : std_logic;
   signal err              : std_logic;
   signal randomnumber     : integer;

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
        c_mult2   => c_mult2,
        pause_out => pause_out
    );

   RAND: entity work.rand_gen
      port map(
        clk       => Clk,
        reset_in  => Rst,
        rand_num  => randomnumber
      );
   ---------------------------------------------------------------------------------------------------------------------
   -- Stimulation
   ---------------------------------------------------------------------------------------------------------------------
   prStimuli: process
      variable vSimResult    : boolean := true;
      variable v_ia          : integer;
      variable v_ib          : integer;
      variable vsequence     : integer;
      variable v_cl          : std_logic_vector(c_mult'range) := (others => '0');
      variable v_ch          : std_logic_vector(c_mult'range) := (others => '0');
      variable v_ia2         : std_logic_vector(a'range);
      variable v_ib2         : std_logic_vector(b'range);
      variable vRandNumSignedUnsigned   : integer := 0;
      variable vRandNumHighLow : integer := 0;

   begin
      Rst   <= '0';
      err <= '0';
      wait until rising_edge(Clk);
      Rst   <= '1';
      mult_func <= MULT_MULT;
      wait until rising_edge(Clk);
      wait for cCLOCK_PERIOD * 10;
      wait until rising_edge(Clk);
      Rst   <= '0';
      wait until rising_edge(Clk);


      v_ia2         := x"FFFFFF80"; -- 
      v_ib2         := x"FFFFFF80";

      vsequence     := 0;
      --for i in 0 to 44444444444 loop
      while err = '0' loop -- MS: endless loop
         for j in 0 to 15 loop
            report "Test: " & integer'image(0) & "_" & integer'image(j);
            a         <= v_ia2;
            b         <= v_ib2;
            
            vRandNumSignedUnsigned := randomnumber mod 2;

            if vRandNumSignedUnsigned = 0 then

               wait until rising_edge(Clk);
               mult_func <= MULT_MULT;       -- MS: choose type of multiplication
               wait until rising_edge(Clk);

               vRandNumHighLow := randomnumber mod 2;
               if vRandNumHighLow = 0 then
                  mult_func <= MULT_READ_LO; 
                  err <= '0';
                  wait until falling_edge(pause_out);
                  
                  wait until rising_edge(Clk);
                  if c_mult /= c_mult2 then
                     vSimResult := false; 
                     err <= '1';
                     report "Test MULTIPLIER- LOW UNSIGNED Failed!!" severity ERROR;
                  end if;
               else

                  mult_func <= MULT_READ_HI;
                  err <= '0';
                  wait until falling_edge(pause_out);

                  wait until rising_edge(Clk);
                  if c_mult /= c_mult2 then
                     vSimResult := false; err <= '1';
                     report "Test MULTIPLIER- HIGH UNSIGNED Failed!!" severity ERROR;
                  end if;
               end if;

            else 

               wait until rising_edge(Clk);
               mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
               wait until rising_edge(Clk);

               vRandNumHighLow := randomnumber mod 2;
               if vRandNumHighLow = 0 then
                  mult_func <= MULT_READ_LO; 
                  err <= '0';
                  wait until falling_edge(pause_out);
                  
                  wait until rising_edge(Clk);
                  if c_mult /= c_mult2 then
                     vSimResult := false; 
                     err <= '1';
                     report "Test MULTIPLIER - LOW SIGNED Failed!!" severity ERROR;
                  end if;
               else 

                  wait until rising_edge(Clk);
                  mult_func <= MULT_READ_HI;
                  err <= '0';
                  wait until falling_edge(pause_out);

                  wait until rising_edge(Clk);
                  if c_mult /= c_mult2 then
                     vSimResult := false; 
                     err <= '1';
                     report "Test MULTIPLIER- HIGH SIGNED Failed!!" severity ERROR;
                  end if;
               end if;

            end if; -- if signed / unsigned

            v_ia2 :=  bv_inc(v_ia2);
         end loop;
         v_ib2 :=  bv_inc(v_ib2);
         v_ia2 := x"FFFFFF80";
      end loop;


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