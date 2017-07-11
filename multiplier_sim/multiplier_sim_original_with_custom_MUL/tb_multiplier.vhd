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




      -- MS : test the multiplier with(out) faster adder
      v_ia := 3333;
      v_ib := 2;
      a         <= std_logic_vector(to_unsigned(v_ia, a'length));
      b         <= std_logic_vector(to_unsigned(v_ib, b'length));
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      if c_mult /= std_logic_vector(to_unsigned(v_ia*v_ib, c_mult'length)) then
         vSimResult := false; err <= '1';
         report "Test1 Failed!!" severity ERROR;
      end if;


      v_ia := 1024;
      v_ib := 16;
      a         <= std_logic_vector(to_unsigned(v_ia, a'length));
      b         <= std_logic_vector(to_unsigned(v_ib, b'length));
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test2 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test2 Failed!!" severity ERROR;
      end if;

      a         <= x"FFFFFFFF";
      b         <= x"FF00FF00";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"ff00feff00ff0100"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test3 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test3 Failed!!" severity ERROR;
      end if;


      a         <= x"ABCDEF00";
      b         <= x"0ABCDEF0";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0734cc2f2a521000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test4 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test4 Failed!!" severity ERROR;
      end if;

      
      a         <= x"FFFFFFFF";
      b         <= x"00000010";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000FFFFFFFF0"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test5 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test5 Failed!!" severity ERROR;
      end if;
      
      wait until rising_edge(Clk);
      a         <= x"FFFFFFFF";
      b         <= x"00000010";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= std_logic_vector(to_signed(v_ia*v_ib, c_mult'length*2))  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test6 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test6 Failed!!" severity ERROR;
      end if;
      
      a         <= x"FFFFFFFE";
      b         <= x"FFFFFFFE";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000004"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test7 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test7 Failed!!" severity ERROR;
      end if;


      a         <= x"FFFFF752"; -- -2222
      b         <= x"FFFFF752";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"00000000004B5644"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test8 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test8 Failed!!" severity ERROR;
      end if;



      a         <= x"B669FD2E"; -- -1234567890
      b         <= x"00000002";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"ffffeea4004b5644"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test9 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test9 Failed!!" severity ERROR;
      end if;


      a         <= x"B669FD2E"; -- -1234567890
      b         <= x"00000002";
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"FFFFFFFF6CD3FA5C"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test10 Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test10 Failed!!" severity ERROR;
      end if;


      a         <= x"00000000"; -- 
      b         <= x"00000000";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 10 - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 10 - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 10 - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 10 - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;



      a         <= x"00666000"; -- 
      b         <= x"00066600";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 11 - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 11 - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 11 - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 11 - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;

      a         <= x"FFFFFFFF"; -- 
      b         <= x"FFFFFFFF";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12 - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12 - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12 - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12 - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;

      a         <= x"FFFFFFFE"; -- 
      b         <= x"FFFFFFFF";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12a - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12a - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12a - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12a - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;

      a         <= x"FFFFFFFF"; -- 
      b         <= x"00000000";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12b - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12b - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12b - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12b - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;

      a         <= x"FFFFFFFF"; -- 
      b         <= x"00000001";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12c - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12c - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12c - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12c - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;


      a         <= x"FFFFFFFD"; -- 
      b         <= x"FFFFFFFF";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; 
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12d - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false;
         report "Test 12d - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false;
         report "Test 12d - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12d - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;
     -- MS : other cases like division and signed multiplication...
      -- PENDING...


      a         <= x"FFFFFFFF"; -- 
      b         <= x"FFFFFF00";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; 
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12e - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12e - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12e - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12e - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;
     -- MS : other cases like division and signed multiplication...
      -- PENDING...


      a         <= x"FFFFFFFF"; -- 
      b         <= x"FFFFF000";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; 
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12f - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12f - HIGH SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12f - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12f - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;
     -- MS : other cases like division and signed multiplication...
      -- PENDING...


      a         <= x"FFFFFFFF"; -- 
      b         <= x"FFFFFE00";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12g - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12g - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;
     -- MS : other cases like division and signed multiplication...
      -- PENDING...
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12g - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12g - HIGH SIGNED Failed!!" severity ERROR;
      end if;



      a         <= x"FFFFFFFF"; -- 
      b         <= x"F0000000";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12h - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12h - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;
     -- MS : other cases like division and signed multiplication...
      -- PENDING...
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12h - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12h - HIGH SIGNED Failed!!" severity ERROR;
      end if;




      a         <= x"FFFFFF00"; -- 
      b         <= x"FFFFFF00";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12hi - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12hi - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;
     -- MS : other cases like division and signed multiplication...
      -- PENDING...
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12i - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12hi - HIGH SIGNED Failed!!" severity ERROR;
      end if;




      a         <= x"FFFFFF80"; -- 
      b         <= x"FFFFFF80";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12hj - LOW UNSIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12hj - HIGH UNSIGNED Failed!!" severity ERROR;
      end if;
     -- MS : other cases like division and signed multiplication...
      -- PENDING...
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO; err <= '0';
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12j - LOW SIGNED Failed!!" severity ERROR;
      end if;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      if c_mult /= c_mult2 then
         vSimResult := false; err <= '1';
         report "Test 12hj - HIGH SIGNED Failed!!" severity ERROR;
      end if;






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
                  --err <= '0';
                  wait until falling_edge(pause_out);
                  
                  wait until rising_edge(Clk);
                  if c_mult /= c_mult2 then
                     vSimResult := false; 
                     err <= '1';
                     report "Test MULTIPLIER- LOW UNSIGNED Failed!!" severity ERROR;
                  end if;
               else

                  mult_func <= MULT_READ_HI;
                  --err <= '0';
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
                  --err <= '0';
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
                  --err <= '0';
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
         v_tmp :=  bv_adder(v_ib2,x"00000003",'1');--bv_inc(v_ib2);
         v_ib2 := v_tmp(v_ib2'range);
         v_ia2 := x"FFFFFFF8";
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