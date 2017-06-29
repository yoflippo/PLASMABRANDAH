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
   signal c_mult2           : std_logic_vector(31 downto 0) := (others => '0');
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
        c_mult2   => c_mult2,
        pause_out => pause_out
    );


   ---------------------------------------------------------------------------------------------------------------------
   -- Stimulation
   ---------------------------------------------------------------------------------------------------------------------
   prStimuli: process
      variable vSimResult  : boolean := true;
      variable v_ia          : integer;
      variable v_ib          : integer;
      variable v_cl          : std_logic_vector(c_mult'range) := (others => '0');
      variable v_ch          : std_logic_vector(c_mult'range) := (others => '0');
   begin
      Rst   <= '0';
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
      mult_func <= MULT_MULT; 		-- MS: choose type of multiplication
 	   wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
 	   wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      if c_mult /= std_logic_vector(to_unsigned(v_ia*v_ib, c_mult'length)) then
         vSimResult := false;
         report "Test1 Failed!!" severity ERROR;
      end if;


      v_ia := 1024;
      v_ib := 16;
      a         <= std_logic_vector(to_unsigned(v_ia, a'length));
      b         <= std_logic_vector(to_unsigned(v_ib, b'length));
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      if c_mult /= std_logic_vector(to_unsigned(v_ia*v_ib, c_mult'length)) then
         vSimResult := false;
         report "Test2 Failed!!" severity ERROR;
      end if;


      a         <= x"FFFFFFFF";
      b         <= x"FF00FF00";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      if (v_ch & v_cl) /= x"ff00feff00ff0100"  then
         vSimResult := false;
         report "Test3 Failed!!" severity ERROR;
      end if;


      a         <= x"ABCDEF00";
      b         <= x"0ABCDEF0";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      if (v_ch & v_cl) /= x"0734cc2f2a521000"  then
         vSimResult := false;
         report "Test4 Failed!!" severity ERROR;
      end if;

      
      a         <= x"FFFFFFFF";
      b         <= x"00000010";
      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      if (v_ch & v_cl) /= x"0000000FFFFFFFF0"  then
         vSimResult := false;
         report "Test5 Failed!!" severity ERROR;
      end if;
      
      wait until rising_edge(Clk);
      a         <= x"00000000";
      b         <= x"00000000";
      wait until rising_edge(Clk);
      a         <= x"FFFFFFFF";
      b         <= x"00000010";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      --if (v_ch & v_cl) /= std_logic_vector(to_signed(v_ia*v_ib, c_mult'length*2))  then
      if to_integer(signed(v_ch & v_cl)) /= (v_ia*v_ib)  then
         vSimResult := false;
         report "Test 6 - SIGNED Failed!!" severity ERROR;
      end if;
      
      a         <= x"FFFFFFFE";
      b         <= x"FFFFFFFE";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      --if (v_ch & v_cl) /= x"0000000000000004"  then
      if to_integer(signed(v_ch & v_cl)) /= (v_ia*v_ib)  then
         vSimResult := false;
         report "Test 7 - SIGNED Failed!!" severity ERROR;
      end if;


      a         <= x"FFFFF752"; -- -2222
      b         <= x"FFFFF752";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      --if (v_ch & v_cl) /= x"00000000004B5644"  then
      if to_integer(signed(v_ch & v_cl)) /= (v_ia*v_ib)  then
         vSimResult := false;
         report "Test 8 - SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      --if (v_ch & v_cl) /= x"ffffeea4004b5644"  then
      if to_integer(signed(v_ch & v_cl)) /= (v_ia*v_ib)  then
         vSimResult := false;
         report "Test 8A - UNSIGNED Failed!!" severity ERROR;
      end if;


      a         <= x"B669FD2E"; -- -1234567890
      b         <= x"00000002";
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      --if (v_ch & v_cl) /= x"FFFFFFFF6CD3FA5C"  then
      if to_integer(signed(v_ch & v_cl)) /= (v_ia*v_ib)  then
         vSimResult := false;
         report "Test 9 - SIGNED Failed!!" severity ERROR;
      end if;


      a         <= x"00000000"; -- 
      b         <= x"00000000";
      v_ia := to_integer(signed(a));
      v_ib := to_integer(signed(b));
      mult_func <= MULT_SIGNED_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if to_integer(signed(v_ch & v_cl)) /= (v_ia*v_ib)  then
         vSimResult := false;
         report "Test 10 - SIGNED Failed!!" severity ERROR;
      end if;

      mult_func <= MULT_MULT;       -- MS: choose type of multiplication
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until falling_edge(pause_out);
      wait until rising_edge(Clk);
      mult_func <= MULT_READ_LO;
      wait until rising_edge(Clk);
      v_cl := c_mult;
      mult_func <= MULT_READ_HI;
      wait until rising_edge(Clk);
      v_ch := c_mult;

      --if (v_ch & v_cl) /= x"0000000000000000"  then
      if to_integer(signed(v_ch & v_cl)) /= (v_ia*v_ib)  then
         vSimResult := false;
         report "Test 10A - UNSIGNED Failed!!" severity ERROR;
      end if;

     -- MS : other cases like division and signed multiplication...
      -- PENDING...

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
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

--library work;
--use work.TxtUtil_pkg.all;
--use work.mlite_pack.all;  -- MS: for use of subtypes


--entity  multiplier_tb is
--end entity  multiplier_tb;

--architecture sim of multiplier_tb is

--   ---------------------------------------------------------------------------------------------------------------------
--   -- Simulation parameters and signals
--   ---------------------------------------------------------------------------------------------------------------------
--   constant cCLOCK_FREQ    : integer   := 100000000; -- MS: 100 MHz
--   constant cCLOCK_PERIOD  : time      := 1 sec / cCLOCK_FREQ;

--   signal SimFinished      : boolean   := false;

--   ---------------------------------------------------------------------------------------------------------------------
--   -- Clocks and Resets
--   ---------------------------------------------------------------------------------------------------------------------

--   signal Clk              : std_logic := '0';
--   signal Rst              : std_logic := '0';


--   ---------------------------------------------------------------------------------------------------------------------
--   -- Unit under test connections
--   ---------------------------------------------------------------------------------------------------------------------
--   -- Original Multiplier
--   signal a                : std_logic_vector(31 downto 0) := (others => '0');
--   signal b                : std_logic_vector(31 downto 0) := (others => '0');
--   signal mult_func        : mult_function_type;
--   signal c_mult           : std_logic_vector(31 downto 0) := (others => '0');
--   signal pause_out        : std_logic;

--   component mult is
--      port(
--         clk       : in std_logic;
--         reset_in  : in std_logic;
--         a, b      : in std_logic_vector(31 downto 0);
--         mult_func : in mult_function_type;
--         c_mult    : out std_logic_vector(31 downto 0);
--         pause_out : out std_logic
--      );
--   end component; 



--begin

--   ---------------------------------------------------------------------------------------------------------------------
--   -- Clock generation
--   ---------------------------------------------------------------------------------------------------------------------
--   prClockGen: process is
--   begin
--      Clk <= '0';
--      while NOT SimFinished loop
--         Clk <= NOT Clk;
--         wait for (cCLOCK_PERIOD / 2);
--      end loop;
--      echo("Simulation ended at: " & time'IMAGE(now));
--      wait;
--   end process prClockGen;

--   ---------------------------------------------------------------------------------------------------------------------
--   -- Unit under test
--   ---------------------------------------------------------------------------------------------------------------------
--   UUT: entity work.mult
--     port map(
--        clk       => Clk,
--        reset_in  => Rst,
--        a         => a,
--        b         => b,
--        mult_func => mult_func,
--        c_mult    => c_mult,
--        pause_out => pause_out
--    );



--   ---------------------------------------------------------------------------------------------------------------------
--   -- Target model(s)
--   ---------------------------------------------------------------------------------------------------------------------


--   ---------------------------------------------------------------------------------------------------------------------
--   -- Stimulation
--   ---------------------------------------------------------------------------------------------------------------------
--   prStimuli: process
--      variable vSimResult : boolean := true;

--   begin
--      Rst   <= '0';
--      wait until rising_edge(Clk);
--      Rst   <= '1';
--      wait until rising_edge(Clk);
--      wait for cCLOCK_PERIOD * 10;
--      wait until rising_edge(Clk);
--      Rst   <= '0';


--      wait until rising_edge(Clk);
--      a         <= X"00000303";
--      b         <= X"00000002";
--      mult_func <= MULT_MULT;           -- MS: choose type of multiplication
--      wait until rising_edge(Clk);
--      mult_func <= MULT_NOTHING ; -- MS: start multiplier
--      wait for cCLOCK_PERIOD * 10;
--      mult_func <= MULT_READ_LO ; -- MS: start multiplier
--      wait until rising_edge(pause_out);

--      wait until rising_edge(Clk);
--      a         <= X"33333333";
--      b         <= X"00000010";
--      mult_func <= MULT_MULT;           -- MS: choose type of multiplication
--      wait until rising_edge(Clk);
--      mult_func <= MULT_NOTHING ; -- MS: start multiplier
--      wait for cCLOCK_PERIOD * 10;
--      mult_func <= MULT_READ_LO ; -- MS: start multiplier
--      wait until rising_edge(pause_out);

--      if (vSimResult) then
--         echo("-----------------------------------------------------------------");
--         echo("");
--         echo(" SIMULATION PASSED            :-)");
--         echo("");
--         echo("-----------------------------------------------------------------");
--      else
--         echo("-----------------------------------------------------------------");
--         echo("");
--         echo("SIMULATION FAILED             :-(");
--         echo("");
--         echo("-----------------------------------------------------------------");
--      end if;

--      SimFinished  <= true;
--      wait;
--   end process prStimuli;

--end architecture sim;
