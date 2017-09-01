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
   signal randomnumber                 : integer;
   signal randomnumber2                : std_logic_vector(31 downto 0);

   component rand_gen is
      port(
         clk       : in std_logic;
         reset_in  : in std_logic;
         rand_num  : out integer
      );
   end component;


   component random_uniform is
    generic (  SEED        : STD_LOGIC_VECTOR(30 downto 0):= (others => '0');
               OUT_WIDTH   : integer := 32);
    Port ( clk    : in  STD_LOGIC;
           random : out  STD_LOGIC_VECTOR (OUT_WIDTH-1 downto 0);
           reset  : in  STD_LOGIC);
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

   RAND: rand_gen
   port map(
      clk       => Clk,
      reset_in  => Rst,
      rand_num  => randomnumber
   );

   RANDD: random_uniform 
    port map(
      clk      => Clk,
      reset    => Rst,  
      random   => randomnumber2
   );


   ---------------------------------------------------------------------------------------------------------------------
   -- Target model(s)
   ---------------------------------------------------------------------------------------------------------------------


   ---------------------------------------------------------------------------------------------------------------------
   -- Stimulation
   ---------------------------------------------------------------------------------------------------------------------
   prStimuli: process
      variable vSimResult  : boolean := true;
      variable vIa         : integer := 0;
      variable vIb         : integer := 0;
      variable vResult     : integer := 0;
   begin
      Rst   <= '0';
      wait until rising_edge(Clk);
      Rst   <= '1';
      wait until rising_edge(Clk);
      wait for cCLOCK_PERIOD * 10;
      wait until rising_edge(Clk);
      Rst   <= '0';
      wait until rising_edge(Clk);

      vIa := 1;
      vIb := 2;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test1 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);

      vIa := 1;
      vIb := -2;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_signed(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(signed(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test1-neg A Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      vIa := -1;
      vIb := -2;
      multiplier         <= std_logic_vector(to_signed(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_signed(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test1-neg B Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      vIa := 22;
      vIb := 69;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test2 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);

      vIa := 987;
      vIb := 567;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test3 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      vIa := 999;
      vIb := 999;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test 3A Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      vIa := 4321;
      vIb := 1234;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test4 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);

      vIa := 555;
      vIb := 555;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test5 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      vIa := 5555;
      vIb := 5555;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test6 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      vIa := 55555;
      vIb := 55555;
      multiplier         <= std_logic_vector(to_unsigned(vIa, multiplier'length));
      multiplicand       <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      vResult := to_integer(unsigned(resultH & resultL));
      if vResult /= (vIa*vIb) then
         vSimResult := false;
         report "Test7 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      multiplier         <= x"00087A23"; --integer 555555
      multiplicand       <= x"00087A23";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      --vResult := to_integer(unsigned(resultH & resultL));
      if (resultH /= x"00000047") OR (resultL /= x"DC7560C9") then
         vSimResult := false;
         report "Test8 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      multiplier         <= x"0098967F"; --integer 9999999
      multiplicand       <= x"0098967F";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      if (resultH /= x"00005AF3") OR (resultL /= x"0F491301") then
         vSimResult := false;
         report "Test9 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      multiplier         <= x"FFFFFFFF"; --integer 4294967294
      multiplicand       <= x"00000010";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      if (resultH /= x"0000000F") OR (resultL /= x"FFFFFFF0") then
         vSimResult := false;
         report "Test10 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      multiplier         <= x"00ABCDEF"; -- 
      multiplicand       <= x"00ABCDEF";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      if (resultH /= x"0000734c") OR (resultL /= x"c2f2a521") then
         vSimResult := false;
         report "Test11 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      multiplier         <= x"0ABCDEF0"; -- 
      multiplicand       <= x"0ABCDEF0";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      if (resultH /= x"00734cc2") OR (resultL /= x"f2a52100") then
         vSimResult := false;
         report "Test12 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      multiplier         <= x"11111111"; -- 
      multiplicand       <= x"11111111";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      if (resultH /= x"01234567") OR (resultL /= x"87654321") then
         vSimResult := false;
         report "Test13 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);



      multiplier         <= x"ABCDEF00"; -- 
      multiplicand       <= x"ABCDEF00";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      --vResult := to_integer(unsigned(resultH & resultL));
      if (resultH /= x"734cc2f2") OR (resultL /= x"a5210000") then
         vSimResult := false;
         report "Test14 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);


      multiplier         <= x"Df060D93"; -- 
      multiplicand       <= x"9CBD5177";
      wait until rising_edge(finished);
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);
      --vResult := to_integer(unsigned(resultH & resultL));
      if (resultH /= x"888C9EB6") OR (resultL /= x"2FA2D255") then
         vSimResult := false;
         report "Test14 Failed!!" severity ERROR;
      end if;
      wait until rising_edge(Clk);
      wait until rising_edge(Clk);

      --for i in 0 to 100000 loop
      --   wait until rising_edge(Clk);
      --   vIa     := randomnumber*randomnumber; 
      --   vIb     := randomnumber*randomnumber; 
      --   multiplier     <= std_logic_vector(to_unsigned(vIa, multiplier'length)); 
      --   multiplicand   <= std_logic_vector(to_unsigned(vIb, multiplier'length));
      --   wait until rising_edge(Clk);
      --   wait for cCLOCK_PERIOD * 32;

      --   vResult := to_integer(unsigned(resultH & resultL));

      --   if (multiplier * multiplicand) /= vResult then
      --       vSimResult := false;
      --       report "Test loop Failed!!" severity ERROR;
      --   end if;
      --end loop;


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