library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity sim_tb_top is

end entity sim_tb_top;

architecture arch of sim_tb_top is
    
    constant CLK_PERIOD_NS      : real := 10000.0 / 1000.0;
    constant TCYC_SYS           : real := CLK_PERIOD_NS/2.0;
    constant TCYC_SYS_DIV2      : time := TCYC_SYS * 1 ns;

	constant log_file  : string :=                  -- UART output is stored in output.txt
	--   "UNUSED";
   "output.txt";
   
  --constant sdramfile : string := "ddr_content/custom.srec";
  
    component cache
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

    signal sys_clk      		: 	std_logic := '0';
    signal sys_rst_n    		: 	std_logic := '0';

    signal address_next        	:   std_logic_vector(31 downto 2);
    signal byte_we_next         :   std_logic_vector(3 downto 0);
    signal cpu_address         	:   std_logic_vector(31 downto 2);
	signal mem_busy            	:   std_logic;

	signal cache_ram_enable    	:   std_logic;
    signal cache_ram_byte_we   	:   std_logic_vector(3 downto 0);
    signal cache_ram_address   	:   std_logic_vector(31 downto 2);
    signal cache_ram_data_w    	:   std_logic_vector(31 downto 0);
    signal cache_ram_data_r    	:   std_logic_vector(31 downto 0);

    signal cache_access        	:   std_logic;   
    signal cache_checking      	:   std_logic;   
    signal cache_miss          	:   std_logic; 

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
  
  address_next <= X"040FFF80"; -- increase the address, cpu_address is clocked, not complete yet
  
  process(sys_clk)
  begin
	if sys_rst = 1 then
		
	else if rising_edge(sys_clk)
		cpu_address <= address_next;
	end if;
	
      
    
  --***************************************************************************
  -- Plasma & DDR controller
  --*************************************************************************** 
    cache_1: cache
        port map(
            clk                 => sys_clk,
            reset               => sys_rst,
            address_next        => address_next			--: in  std_logic_vector(31 downto 2);
            byte_we_next        => byte_we_next			--: in  std_logic_vector(3 downto 0);
            cpu_address         => cpu_address			--: in  std_logic_vector(31 downto 2);
            mem_busy            => mem_busy				--: in  std_logic;

            cache_ram_enable    => cache_ram_enable		--: in  std_logic;
            cache_ram_byte_we   => cache_ram_byte_we	--: in  std_logic_vector(3 downto 0);
            cache_ram_address   => cache_ram_address	--: in  std_logic_vector(31 downto 2);
            cache_ram_data_w    => cache_ram_data_w		--: in  std_logic_vector(31 downto 0);
            cache_ram_data_r    => cache_ram_data_r		--: out std_logic_vector(31 downto 0);

            cache_access        => cache_access			--: out std_logic;   --access 4KB cache
            cache_checking      => cache_checking		--: out std_logic;   --checking if cache hit
            cache_miss          => cache_miss			--: out std_logic    --cache miss
        );
	
end architecture;
