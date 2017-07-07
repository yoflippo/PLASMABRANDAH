					data_read0        
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity sim_tb_cache is

end entity sim_tb_cache;

architecture arch of sim_tb_cache is
    
  constant CLK_PERIOD_NS      : real := 10000.0 / 1000.0;
  constant TCYC_SYS           : real := CLK_PERIOD_NS/2.0;
  constant TCYC_SYS_DIV2      : time := TCYC_SYS * 1 ns;

  component cache_ram is
      port(
			clk               : in std_logic;
			enable            : in std_logic;
			write_byte_enable : in std_logic_vector(3 downto 0);
			read_address      : in std_logic_vector(31 downto 2);	--TvE: Added 2 port blockrams so 1 port can be used for reads and one for writes
			write_address     : in std_logic_vector(31 downto 2);
			data_write        : in std_logic_vector(31 downto 0);
			data_read0        : out std_logic_vector(31 downto 0);
			data_read1        : out std_logic_vector(31 downto 0) --TvE: added output so both data in the sets can be put on output in parallel
      );
  end component; --cache_ram

	
	signal enable            :  std_logic:='0';
	signal write_byte_enable :  std_logic_vector(3 downto 0) := "0000";
	signal read_address      :  std_logic_vector(31 downto 2);	
	signal write_address     :  std_logic_vector(31 downto 2);
	signal data_write        :  std_logic_vector(31 downto 0);
	signal data_read0        :  std_logic_vector(31 downto 0);
	signal data_read1        :  std_logic_vector(31 downto 0);
	
	signal sys_clk           :   std_logic := '0';
	signal sys_rst_n         :   std_logic := '0';

begin
  read_address(31 downto 30) <= "00";
	write_address(31 downto 30) <= "00";
  --***************************************************************************
  -- Clock generation and reset
  --***************************************************************************
  process           -- Generate 100 MHz, i.e., the clk on FPGA board
  begin
    wait for (TCYC_SYS_DIV2);
    sys_clk <= not sys_clk;
  end process;

  process           -- The reset on FPGA board is active low
  begin
    sys_rst_n <= '0';
    wait for 1000 ns;
    sys_rst_n <= '1';
    wait;
  end process;

   process           -- The reset on FPGA board is active low
  begin
    rst <= '1';
    wait for 10 ns;
    rst <= '0';
    wait;
  end process;

 
-- State machine for testbench
  statemachine: process(sys_clk)
  begin
  if rising_edge(sys_clk) then

    if rst = '0' then
    case status is 
      when "0000" =>              
        read_address(29 downto 2) <= X"0000000"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"FFFFFF0";
				write_byte_enable <= "1111";
				enable <= '1';
        data_write <= X"ECA86420";        -- Dummy data input
        status <= "0001";
      when "0001" =>             
			  read_address(29 downto 2) <= X"0000001"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"FFFFFF1";
				write_byte_enable <= "1111";
				enable <= '1';
        data_write <= X"FDB97531";        -- Dummy data input
        status <= "0010";
      when "0010" =>              
				read_address(29 downto 2) <= X"0000002"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"FFFFFF2";
				write_byte_enable <= "1111";
				enable <= '1';
        data_write <= X"0F0F0F0F";        -- Dummy data input
        status <= "0011";
      when "0011" =>              
				read_address(29 downto 2) <= X"0000003"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"FFFFFF3";
				write_byte_enable <= "1111";
				enable <= '1';
        data_write <= X"11111111";        -- Dummy data input
        status <= "0100";
      when "0100" =>    
				read_address(29 downto 2) <= X"FFFFFF0"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"00000000";
				write_byte_enable <= "0000";
				enable <= '0';
        data_write <= X"00000000";        -- Dummy data input
        status <= "0101";
      when "0101" =>   
				read_address(29 downto 2) <= X"FFFFFF1"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"00000000";
				write_byte_enable <= "0000";
				enable <= '0';
        data_write <= X"00000000";        -- Dummy data input			
        status <= "0110";
      when "0110" =>             
				read_address(29 downto 2) <= X"FFFFFF2"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"00000000";
				write_byte_enable <= "0000";
				enable <= '0';
        data_write <= X"00000000";        -- Dummy data input
        status <= "0111";
      when "0111" => 
				read_address(29 downto 2) <= X"FFFFFF3"; -- TvE: Should always output the data on the address of both sets
				write_address(29 downto 2) <= X"00000000";
				write_byte_enable <= "0000";
				enable <= '0';
        data_write <= X"00000000";        -- Dummy data input
        status <= "1000";
      when "1000" =>              
        status <= "1001";
      when "1001" =>              
        status <= "1010";
      when "1010" =>              
        status <= "1011";
      when "1011" => 
        status <= "1100";
      when "1100" =>              
        status <= "1101";
      when "1101" =>              
        status <= "1110";
      when "1110" =>              
        status <= "1111";
      when "1111" =>              
        status <= "0000";     
      when others =>
        status <= "0000";
      --when "0001" =>             -- Read state of prev write address
      --  byte_we_next <= "0000"; 
      --  address_next(25 downto 2) <= X"05B4B4";
      --  status <= "0010";
      --when "0010" =>              -- Write state
      --  byte_we_next <= "1111"; 
      --  address_next(25 downto 2) <= X"05A4B4"; -- Address that maps to set 1 with same index
      --  cache_ram_data_w <= X"FDB97531";    -- TvE: Dummy data input
      --  status <= "0011";
      --when "0011" =>              -- Read state of prev write address
      --  byte_we_next <= "0000"; 
      --  address_next(25 downto 2) <= X"05A4B4"; 
      --  status <= "0100";
      --when "0100" =>              -- Check if data is still in cache of 1 write
      --  byte_we_next <= "0000"; 
      --  address_next(25 downto 2) <= X"05B4B4";           
      --  status <= "0101";
      --when "0101" =>              -- Overwrite data in cache
      --  byte_we_next <= "1111"; 
      --  address_next(25 downto 2) <= X"05C4B4"; -- Address that maps to set 0 (should)
      --  cache_ram_data_w <= X"0F0F0F0F";    -- TvE: Dummy data input
      --  status <= "0110";
      --when "0110" =>              -- Check if overwritten data is in cache
      --  byte_we_next <= "0000"; 
      --  address_next(25 downto 2) <= X"05C4B4";
      --  status <= "0111";
      --when "0111" => 
      --  byte_we_next <= "1111"; 
      --  address_next(25 downto 2) <= X"05D4B4"; -- Address that maps to set 1 (should)
      --  cache_ram_data_w <= X"F0F0F0F0";    -- TvE: Dummy data input
      --  status <= "1000";
      --when "1000" =>              -- Check if overwritten data is in cache
      --  byte_we_next <= "0000"; 
      --  address_next(25 downto 2) <= X"05D4B4";
      --  status <= "1001";
      --when "1001" =>              -- Write in other cache line
      --  byte_we_next <= "1111"; 
      --  address_next(25 downto 2) <= X"05D4B0";
      --  cache_ram_data_w <= X"FF00FF00";    -- TvE: Dummy data input
      --  status <= "1010";
      --when "1010" =>              -- Check if data is in cache
      --  byte_we_next <= "0000"; 
      --  address_next(25 downto 2) <= X"05D4B0";
      --  status <= "0000";  
      --when others =>
      --  status <= "0000";
      end case;
      end if;
    end if;
  end process;

  process(sys_clk, sys_rst_n)
  begin
  if sys_rst_n = '1' then
    
  elsif rising_edge(sys_clk) then
    cpu_address <= address_next;   
  end if;
  end process;

    
  --***************************************************************************
  -- Cache instantiation
  --*************************************************************************** 
	cache_ram1: cache_ram
	port map(
					clk => sys_clk,       
					enable => enable,
					write_byte_enable => write_byte_enable, 
					read_address =>read_address,
					write_address => write_address,
					data_write => data_write,
					data_read1 => data_read1
					);
end;