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
      variable v_tmp         : std_logic_vector(a'length downto 0);
      variable vRandNumSignedUnsigned   : integer := 0;
      variable vRandNumHighLow : integer := 0;
      variable vResultBig    : std_logic_vector(63 downto 0);
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

      a         <= x"11111111"; -- 
      b         <= x"11111111";
        wait until rising_edge(Clk);
      vResultBig := bv_twos_complement(a,b); --bv_adder(resultL,resultH,'1');
       wait until rising_edge(Clk);
       
        a       <= x"22222222"; -- 
      b         <= x"11111111";
        wait until rising_edge(Clk);
      vResultBig := bv_twos_complement(a,b); --bv_adder(resultL,resultH,'1');
       wait until rising_edge(Clk);

      a         <= x"FFFFFFFF"; -- 
      b         <= x"FFFFFFFF";
        wait until rising_edge(Clk);
      vResultBig := bv_twos_complement(a,b); --bv_adder(resultL,resultH,'1');
       wait until rising_edge(Clk);

      a         <= x"FFFFFFFF"; -- 
      b         <= x"FFFFFFFE";
        wait until rising_edge(Clk);
      vResultBig := bv_twos_complement(a,b); --bv_adder(resultL,resultH,'1');
       wait until rising_edge(Clk);
       
      a         <= x"FFFFFFFE"; -- 
      b         <= x"FFFFFFFF";
        wait until rising_edge(Clk);
      vResultBig := bv_twos_complement(a,b); --bv_adder(resultL,resultH,'1');
       wait until rising_edge(Clk);
              
      a         <= x"00000000"; -- 
      b         <= x"00000000";
        wait until rising_edge(Clk);
      vResultBig := bv_twos_complement(a,b); --bv_adder(resultL,resultH,'1');
       wait until rising_edge(Clk);
       
       
        wait for cCLOCK_PERIOD * 10;

        a <= x"FFFFFFFF";
        wait until rising_edge(Clk);
        v_ia2 := bv_negate(a); --bv_adder(resultL,resultH,'1');
        wait until rising_edge(Clk);
        a<=x"00000000";
        wait until rising_edge(Clk);
        v_ia2 := bv_negate(a); --bv_adder(resultL,resultH,'1');
            wait until rising_edge(Clk);
        a<=x"00000001";
        wait until rising_edge(Clk);
           v_ia2 := bv_negate(a); --bv_adder(resultL,resultH,'1');
        wait until rising_edge(Clk);
                a<=x"00000002";
        wait until rising_edge(Clk);
           v_ia2 := bv_negate(a); --bv_adder(resultL,resultH,'1');
        wait until rising_edge(Clk);
        
      -- err <= '0';
      -- a         <= x"DF060D93"; -- 
      -- b         <= x"9CBD5177";
      -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);
      -- --if (v_ch & v_cl) /= x"0000000000000000"  then
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D93 9CBD5177 Test 666 - LOW UNSIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D93 9CBD5177 Test  666 - HIGH UNSIGNED Failed!!" severity ERROR;
      -- end if;
      
      -- wait until rising_edge(Clk);
      -- err <= '0';
      -- v_ia := to_integer(signed(a));
      -- v_ib := to_integer(signed(b));
      -- mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);

      -- --if (v_ch & v_cl) /= x"0000000000000000"  then
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D93 9CBD5177 Test 12i - LOW SIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D93 9CBD5177 Test  666 - HIGH SIGNED Failed!!" severity ERROR;
      -- end if;
      

      
      
-- ----------------------------------------------------------------------------
      -- wait until rising_edge(Clk);
      -- err <= '0';
      -- a         <= x"DF060D95"; -- 
      -- b         <= x"9CBD5179";
      -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);
      
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D95 9CBD5179 Test odd number increased - LOW UNSIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D95 9CBD5179 Test odd number increased - HIGH UNSIGNED Failed!!" severity ERROR;
      -- end if;

      -- wait until rising_edge(Clk);
      -- err <= '0';
      -- v_ia := to_integer(signed(a));
      -- v_ib := to_integer(signed(b));
      -- mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);

      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D95 9CBD5179 Test odd number increased - LOW SIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "DF060D95 9CBD5179 Test odd number increased - HIGH SIGNED Failed!!" severity ERROR;
      -- end if;
      

-- ----------------------------------------------------------------------------
      -- err <= '0';
      -- a         <= x"D0000095"; -- 
      -- b         <= x"90000079";
      -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);
      
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "D0000095 90000079 Test odd number low- LOW UNSIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "D0000095 90000079 Test odd number low- HIGH UNSIGNED Failed!!" severity ERROR;
      -- end if;

      -- wait until rising_edge(Clk);
      -- err <= '0';
      -- v_ia := to_integer(signed(a));
      -- v_ib := to_integer(signed(b));
      -- mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);

      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "D0000095 90000079 Test odd number low- LOW SIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "D0000095 90000079 Test odd number low- HIGH SIGNED Failed!!" severity ERROR;
      -- end if;
      
 -- ----------------------------------------------------------------------------
      -- wait until rising_edge(Clk);
      -- err <= '0';
      -- a         <= x"00000095"; -- 
      -- b         <= x"00000079";
      -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);
      
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "00000095 00000079 Test odd number very low LOW UNSIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "00000095 00000079 Test odd number very low HIGH UNSIGNED Failed!!" severity ERROR;
      -- end if;

     -- wait until rising_edge(Clk);
      -- err <= '0';
      -- v_ia := to_integer(signed(a));
      -- v_ib := to_integer(signed(b));
      -- mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);

      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "00000095 00000079 Test odd number very low LOW SIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "00000095 00000079 Test odd number very low HIGH SIGNED Failed!!" severity ERROR;
      -- end if;
 
 
 
 
 
 
 
 -- ----------------------------------------------------------------------------
      -- wait until rising_edge(Clk);
      -- err <= '0';
      -- a         <= x"80000095"; -- 
      -- b         <= x"80000079";
      -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);
      
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "80000095 80000079 Test odd number very low LOW UNSIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "80000095 80000079 Test odd number very low HIGH UNSIGNED Failed!!" severity ERROR;
      -- end if;

      -- wait until rising_edge(Clk);
      -- err <= '0';
      -- v_ia := to_integer(signed(a));
      -- v_ib := to_integer(signed(b));
      -- mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      -- wait until rising_edge(Clk);
      -- mult_func <= MULT_READ_LO;  
      -- wait until falling_edge(pause_out);
      -- wait until rising_edge(Clk);

      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "80000095 80000079 Test odd number very low LOW SIGNED Failed!!" severity ERROR;
      -- end if;
      -- mult_func <= MULT_READ_HI;
      -- wait until rising_edge(Clk);
      -- if c_mult /= c_mult2 then
         -- vSimResult := false; err <= '1';
         -- report "80000095 80000079 Test odd number very low HIGH SIGNED Failed!!" severity ERROR;
      -- end if;


      -- v_ia2         := x"00000095"; -- 
      -- v_ib2         := x"F0000080";

      -- for i in 0 to 1000 loop
      -- --while err = '0' loop -- MS: endless loop
         -- for j in 0 to 15 loop
            -- --report "Test: " & integer'image(0) & "_" & integer'image(j);
            -- a         <= v_ia2;
            -- b         <= v_ib2;

            -- wait until rising_edge(Clk);
            -- mult_func <= MULT_MULT;       -- MS: choose type of multiplication
            -- wait until rising_edge(Clk);
            -- mult_func <= MULT_READ_LO; 
            -- err <= '0';
            -- wait until falling_edge(pause_out);
            -- wait until rising_edge(Clk);
            -- if c_mult /= c_mult2 then
                -- vSimResult := false; 
                -- err <= '1';
                -- report "Test MULTIPLIER- LOW  *&^%$#@*&^%$#@  UNSIGNED Failed!!" severity ERROR;
            -- end if;
            
            -- wait until rising_edge(Clk);
            -- mult_func <= MULT_READ_HI;
            -- err <= '0';
            -- wait until rising_edge(Clk);
            -- if c_mult /= c_mult2 then
                -- vSimResult := false; err <= '1';
                -- report "Test MULTIPLIER- HIGH *&^%$#@*&^%$#@      UNSIGNED Failed!!" severity ERROR;
            -- end if;

            -- wait until rising_edge(Clk);
            -- mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
            -- wait until rising_edge(Clk);
            -- mult_func <= MULT_READ_LO; 
            -- err <= '0';
            -- wait until falling_edge(pause_out);
            -- wait until rising_edge(Clk);
            -- if c_mult /= c_mult2 then
            -- vSimResult := false; 
            -- err <= '1';
            -- report "Test MULTIPLIER - LOW SIGNED Failed!!" severity ERROR;
            -- end if;

            -- wait until rising_edge(Clk);
            -- mult_func <= MULT_READ_HI;
            -- err <= '0';
            -- wait until rising_edge(Clk);
            -- if c_mult /= c_mult2 then
            -- vSimResult := false; 
            -- err <= '1';
            -- report "Test MULTIPLIER- HIGH SIGNED Failed!!" severity ERROR;
            -- end if;

            -- v_ia2 :=  bv_inc(v_ia2);
         -- end loop;
         -- v_tmp :=  bv_adder(v_ib2,x"00000001",'1');--bv_inc(v_ib2);
         -- v_ib2 := v_tmp(v_ib2'range);
         -- v_ia2 := x"00000095";
        -- end loop;


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