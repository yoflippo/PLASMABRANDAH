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

  component cache is
      port(
          clk                 : in  std_logic;
          reset               : in  std_logic;
          address_next        : in  std_logic_vector(31 downto 2);
          byte_we_next        : in  std_logic_vector(3 downto 0);
          cpu_address         : in  std_logic_vector(31 downto 2);
          mem_busy            : in  std_logic;

          cache_ram_enable    : in  std_logic;
          cache_ram_byte_we   : in  std_logic_vector(3 downto 0);
          cache_ram_address   : in  std_logic_vector(31 downto 2);
          cache_ram_data_w    : in  std_logic_vector(31 downto 0);
          cache_ram_data_r    : out std_logic_vector(31 downto 0);

          cache_access        : out std_logic;   --access 4KB cache
          cache_checking      : out std_logic;   --checking if cache hit
          cache_miss          : out std_logic    --cache miss
      );
  end component; --cache

  component cache_16kB is
    port(
        clk                 : in  std_logic;
        reset               : in  std_logic;
        address_next        : in  std_logic_vector(31 downto 2);
        byte_we_next        : in  std_logic_vector(3 downto 0);
        cpu_address         : in  std_logic_vector(31 downto 2);
        mem_busy            : in  std_logic;

        cache_ram_enable    : in  std_logic;
        cache_ram_byte_we   : in  std_logic_vector(3 downto 0);
        cache_ram_address   : in  std_logic_vector(31 downto 2);
        cache_ram_data_w    : in  std_logic_vector(31 downto 0);
        cache_ram_data_r    : out std_logic_vector(31 downto 0);

        cache_access        : out std_logic;   --TvE: access 16KB cache 
        cache_checking      : out std_logic;   --checking if cache hit
        cache_miss          : out std_logic    --cache miss
    );
end component; --cache

  signal sys_clk              :   std_logic := '0';
  signal sys_rst_n            :   std_logic := '0';

  signal address_next         :   std_logic_vector(31 downto 2);
  signal byte_we_next         :   std_logic_vector(3 downto 0) := "1111";
  signal cpu_address          :   std_logic_vector(31 downto 2);
  signal mem_busy             :   std_logic;

  signal cache_ram_enable     :   std_logic;
  signal cache_ram_byte_we    :   std_logic_vector(3 downto 0);
  signal cache_ram_BB_address :   std_logic_vector(31 downto 2);
  signal cache_ram_16k_address:   std_logic_vector(31 downto 2);
  signal cache_ram_data_w     :   std_logic_vector(31 downto 0);
  signal cache_ram_data_r     :   std_logic_vector(31 downto 0);

  signal cache_access         :   std_logic;   
  signal cache_checking       :   std_logic;   
  signal cache_miss           :   std_logic; 
  signal status               :   std_logic_vector(2 downto 0) := "000";

begin
  
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

  mem_busy <= '0';
  address_next(31 downto 26) <= "000100"; -- Bit that checks bitje 28
 
  cache_ram_enable <= '1';
  cache_ram_byte_we <= byte_we_next;
  cache_ram_BB_address(31 downto 12) <= "00000000000000000000";
  cache_ram_16k_address(31 downto 14) <= "000000000000000000";
  cache_ram_BB_address(11 downto 2) <= address_next(11 downto 2);
  cache_ram_16k_address(13 downto 2) <= address_next(13 downto 2);
  
-- State machine for testbench
  statemachine: process(sys_clk)
  begin
  if rising_edge(sys_clk) then
  case status is 
    when "000" =>              -- Write state
      byte_we_next <= "1111"; 
      address_next(25 downto 2) <= X"05BF80";
      cache_ram_data_w <= X"ECA86420";    -- TvE: Dummy data input
      status <= "001";
    when "001" =>             -- Read state of prev write address
      byte_we_next <= "0000"; 
      address_next(25 downto 2) <= X"05BF80";
      status <= "010";
    when "010" =>              -- Write state
      byte_we_next <= "1111"; 
      address_next(25 downto 2) <= X"050FFF"; 
      cache_ram_data_w <= X"FDB97531";    -- TvE: Dummy data input
      status <= "011";
    when "011" =>              -- Read state of prev write address
      byte_we_next <= "0000"; 
      address_next(25 downto 2) <= X"050FFF"; 
      status <= "100";
    when "100" =>              -- Check if data is still in cache of 1 write
      byte_we_next <= "0000"; 
      address_next(25 downto 2) <= X"05BF80";           
      status <= "101";
    when "101" =>              -- Overwrite data in cache
      byte_we_next <= "1111"; 
      address_next(25 downto 2) <= X"05BF80";
      cache_ram_data_w <= X"0F0F0F0F";    -- TvE: Dummy data input
      status <= "110";
    when "110" =>              -- Check if overwritten data is in cache
      byte_we_next <= "0000"; 
      address_next(25 downto 2) <= X"05BF80";
      status <= "111";
    when "111" => 
      byte_we_next <= "0000"; 
      address_next(25 downto 2) <= X"000080";
      status <= "000";
    when others =>
      status <= "000";
    end case;
    end if;
  end process;

  process(sys_clk, sys_rst_n)
  begin
  if sys_rst_n = '1' then
    
  elsif rising_edge(sys_clk) then
    cpu_address <= address_next;   
  end if;
  end process;

  --***************************************
  -- Check all signals in senslist are effective: TODO
  --***************************************
--    cache_ram_proc: process(cache_access, cache_miss,
--                     address_next, cpu_address,
--                     byte_we_next)
--    begin
--        if cache_access = '1' then    --Check if cache hit or write through
--            cache_ram_enable <= '1';
--            cache_ram_byte_we <= byte_we_next;
--            cache_ram_address(31 downto 2) <= ZERO(31 downto 12) & address_next(11 downto 2);
--            cache_ram_data_w <= X"ECA86420";    -- TvE: Dummy data input
--        elsif cache_miss = '1' then  --Update cache after cache miss
--            cache_ram_enable <= '1';
--            cache_ram_byte_we <= "1111";
--            cache_ram_address(31 downto 2) <= ZERO(31 downto 12) & address_next(11 downto 2);
--           cache_ram_data_w <= X"FDB97531"; -- TvE: Dummy data input
--        else                         --Disable cache ram when Normal non-cache access
--            cache_ram_enable <= '0';
--            cache_ram_byte_we <= byte_we_next;
--            cache_ram_address(31 downto 2) <= address_next(31 downto 2);
--            cache_ram_data_w <= X"0F0F0F0F";  -- TvE: Dummy data input
--       end if;
--    end process;
      
    
  --***************************************************************************
  -- Cache instantiation
  --*************************************************************************** 
    cache_BB: cache
        port map(
            clk                 => sys_clk,
            reset               => sys_rst_n,
            address_next        => address_next,      --: in  std_logic_vector(31 downto 2);  -- TvE: Asynchronous
            byte_we_next        => byte_we_next,      --: in  std_logic_vector(3 downto 0); -- TvE: Asynchronous
            cpu_address         => cpu_address,     --: in  std_logic_vector(31 downto 2);  -- TvE: Synchronous
            mem_busy            => mem_busy,        --: in  std_logic;

            cache_ram_enable    => cache_ram_enable,    --: in  std_logic;
            cache_ram_byte_we   => cache_ram_byte_we, --: in  std_logic_vector(3 downto 0);
            cache_ram_address   => cache_ram_BB_address,  --: in  std_logic_vector(31 downto 2);
            cache_ram_data_w    => cache_ram_data_w,    --: in  std_logic_vector(31 downto 0);
            cache_ram_data_r    => cache_ram_data_r,    --: out std_logic_vector(31 downto 0);

            cache_access        => cache_access,      --: out std_logic;   --access 4KB cache
            cache_checking      => cache_checking,    --: out std_logic;   --checking if cache hit
            cache_miss          => cache_miss     --: out std_logic    --cache miss
        );

      cache_16k: cache_16kB
        port map(
            clk                 => sys_clk,
            reset               => sys_rst_n,
            address_next        => address_next,      --: in  std_logic_vector(31 downto 2);  -- TvE: Asynchronous
            byte_we_next        => byte_we_next,      --: in  std_logic_vector(3 downto 0); -- TvE: Asynchronous
            cpu_address         => cpu_address,     --: in  std_logic_vector(31 downto 2);  -- TvE: Synchronous
            mem_busy            => mem_busy,        --: in  std_logic;

            cache_ram_enable    => cache_ram_enable,    --: in  std_logic;
            cache_ram_byte_we   => cache_ram_byte_we, --: in  std_logic_vector(3 downto 0);
            cache_ram_address   => cache_ram_16k_address, --: in  std_logic_vector(31 downto 2);
            cache_ram_data_w    => cache_ram_data_w,    --: in  std_logic_vector(31 downto 0);
            cache_ram_data_r    => cache_ram_data_r,    --: out std_logic_vector(31 downto 0);

            cache_access        => cache_access,      --: out std_logic;   --access 4KB cache
            cache_checking      => cache_checking,    --: out std_logic;   --checking if cache hit
            cache_miss          => cache_miss     --: out std_logic    --cache miss
        );
end;
