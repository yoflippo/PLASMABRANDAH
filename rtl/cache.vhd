---------------------------------------------------------------------
-- TITLE: Cache Controller
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 12/22/08
-- FILENAME: cache.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    4KB unified cache that uses the lower 4KB of the 8KB cache_ram.
--    Only lowest 2MB of DDR is cached.

-------------------------------------------  DIRECT MAPPED CACHE (MS)---------------------------------
--        TAG                |         INDEX           |   BYTE ADDRESSING    |    DESCRIPTION
--   address_next(20 : 12)   |   address_next(11: 2)   |   address_next(1:0)  |   4kb  Cache, 2MB Ram
--   address_next(20 : 13)   |   address_next(12: 2)   |   address_next(1:0)  |   8kb  Cache, 2MB Ram
--   address_next(20 : 14)   |   address_next(13: 2)   |   address_next(1:0)  |   16kb Cache, 2MB Ram
--   address_next(21 : 12)   |   address_next(11: 2)   |   address_next(1:0)  |   4kb  Cache, 4MB Ram
--   address_next(21 : 13)   |   address_next(12: 2)   |   address_next(1:0)  |   8kb  Cache, 4MB Ram
--   address_next(21 : 14)   |   address_next(13: 2)   |   address_next(1:0)  |   16kb Cache, 4MB Ram
------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;
use work.mlite_pack.all;

entity cache is
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
end; --cache

architecture logic of cache is
    subtype state_type is std_logic_vector(1 downto 0);
    constant STATE_IDLE     : state_type := "00";
    constant STATE_CHECKING : state_type := "01";
    constant STATE_MISSED   : state_type := "10";
    constant STATE_WAITING  : state_type := "11";

    signal state_reg        : state_type;
    signal state            : state_type;
    signal state_next       : state_type;

    signal cache_address    : std_logic_vector(10 downto 0);
    signal cache_tag_in     : std_logic_vector(7 downto 0); -- TvE: Changed from 8 downto 0
    signal cache_tag_reg    : std_logic_vector(7 downto 0); -- TvE: Changed from 8 downto 0
    signal cache_we         : std_logic_vector(1 downto 0);

    --TvE: Adjustments for 16 kB Cache (Tag doubling)-----------------------------------------
    type mem8_vector IS ARRAY (NATURAL RANGE<>) OF std_logic_vector(7 downto 0);
    signal cache_tag_out    : mem8_vector(1 downto 0); -- TvE: Output of the tag block
    signal cache_tag_r_out  : mem8_vector(1 downto 0); -- TvE: Output of the tag block
    signal cache_tag_w_out  : mem8_vector(1 downto 0); -- TvE: Output of the tag block

    ---------------------------------------------------------------------------------------
    -----2-way set adjustment signals------------------------------
    signal LRU_in               : std_logic_vector(0 downto 0);
    signal LRU_out              : std_logic_vector(0 downto 0);
    signal LRU_r_out            : std_logic_vector(0 downto 0);
    signal LRU_w_out            : std_logic_vector(0 downto 0);
    signal LRU_we               : std_logic;
    signal LRU_read_enable      : std_logic;
    signal LRU_read_enable_reg  : std_logic;
    signal LRU_write_addr       : std_logic_vector(10 downto 0);

    signal cache_ram_data_r0            : std_logic_vector(31 downto 0);
    signal cache_ram_data_r1            : std_logic_vector(31 downto 0);
    signal cache_ram_write_address_temp : std_logic_vector(31 downto 2);
    signal cache_ram_data_w_reg         : std_logic_vector(31 downto 0);
    signal cache_ram_byte_we_reg        : std_logic_vector(3 downto 0);
    signal write_toggle                 : std_logic:='0';
    signal cache_ram_address_reg        : std_logic_vector(31 downto 2);       
    signal miss_state_prev              : std_logic:='0';
    signal miss_state_prev_reg          : std_logic:='0';
    signal read_enable                  : std_logic:='1';
    signal cache_ram_enable_reg         : std_logic;
    signal tag_write_addr               : std_logic_vector(10 downto 0);
    signal tag_read_enable              : std_logic;
    signal tag_read_enable_reg          : std_logic;


    -------------------------------------------------------
begin
    ------------------------
    cache_ram_write_address_temp(31 downto 15) <= cache_ram_address_reg(31 downto 15);
    --TvE: only the 13 and 14th bits needs to be set according to which cache block must be updated/read
    cache_ram_write_address_temp(12 downto 2) <= cache_ram_address_reg(12 downto 2);

    LRU_write_addr(10 downto 0) <= cpu_address(12 downto 2); -- TvE: To make sure the LRU is updated in the right line.
    tag_write_addr(10 downto 0) <= cpu_address(12 downto 2); -- TvE: To make sure the tag is updated in the right line.
    cache_address <= address_next(12 downto 2);              -- TvE: When cache read occurs the tag must be available next clockcycle!

    read_ram_proc: process(address_next, cpu_address)       --TvE: process that tracks the current and previous accessed address.
    begin                                                   -- When they match the read port of both LRU and cache_ram must be disabled
        if address_next(12 downto 2) = cpu_address(12 downto 2) then                  -- And the output from the write port should be propagated out
            read_enable <= '0';
            LRU_read_enable <= '0';
        else       
            read_enable <= '1';
            LRU_read_enable <= '1';
        end if;
    end process;

    proc_LRU_enable_reg: process (LRU_read_enable, clk) is
    variable vLRU_enable : std_logic;
    begin
      if rising_edge(clk) then
        LRU_read_enable_reg <= vLRU_enable;
      end if;
      vLRU_enable := LRU_read_enable;
    end process;

    LRU_read_proc: process(LRU_w_out, LRU_r_out, LRU_read_enable_reg)    -- TvE: Process to determine which output of the 2 port LRU block has to be on the LRU_out
    begin
        if LRU_read_enable_reg = '1' then
            LRU_out <= LRU_r_out;
        else       
            LRU_out <= LRU_w_out;
        end if;         
    end process;

    proc_tag_read_enable_reg: process (tag_read_enable, clk) is
    variable vtag_read_enable : std_logic;
    begin
      if rising_edge(clk) then
        tag_read_enable_reg <= vtag_read_enable;
      end if;
      vtag_read_enable := tag_read_enable;
    end process;

    tag_rw_proc: process (cache_tag_r_out, cache_tag_w_out) IS --TvE: Process that tracks is a tag has to be written or only read.
    begin
      if (tag_read_enable_reg = '1') then
        cache_tag_out(0) <= cache_tag_r_out(0);
        cache_tag_out(1) <= cache_tag_r_out(1);
      else
        cache_tag_out(0) <= cache_tag_w_out(0);
        cache_tag_out(1) <= cache_tag_w_out(1);
      end if;
    end process;

    tag_read_enable_proc: process (cpu_address, state, state_reg, state_next) IS 
    begin
            if ((address_next(12 downto 2) /= cpu_address(12 downto 2)) and (state = STATE_IDLE) 
            and (byte_we_next = "0000")) then
                tag_read_enable <= '1';
            else       
                tag_read_enable <= '0';
            end if;
    end process;


    cache_proc: process(clk, reset, mem_busy, cache_address, LRU_out, cache_ram_data_r0, cache_ram_data_r1,
        state_reg, state, state_next,
        address_next, byte_we_next, cache_tag_in, --Stage1
        cache_tag_reg, cache_tag_out,            --Stage2
        cpu_address) --Stage3
    begin
        
        case state_reg is
            when STATE_IDLE =>            --cache idle
                cache_checking <= '0';
                cache_miss <= '0';
                state <= STATE_IDLE;
            when STATE_CHECKING =>        --current read in cached range, check if match
                cache_checking <= '1';
                LRU_we <= '1';            
                write_toggle <= '0';

                if (cache_tag_out(1) /= cache_tag_reg and cache_tag_out(0) /= cache_tag_reg) or
                   (cache_tag_out(1) = ONES(7 downto 0) and cache_tag_out(0) = ONES(7 downto 0)) then                     
                    cache_miss <= '1';
                    if LRU_out(0) = '1' then
                        cache_ram_data_r <= cache_ram_data_r0;      --TvE: data_r must be set in every case.
                        cache_ram_write_address_temp(14 downto 13) <= "01";    --TvE: Enables data set 1 to write to 
                        cache_we <= "10";                               --TvE: Enable cache tag block 1 to write tag to
                        LRU_in(0) <= '0';                                   --TvE: LRU after write to set 1 is set 0
                    else
                        cache_ram_data_r <= cache_ram_data_r1;      --TvE: data_r must be set in every case.
                        cache_ram_write_address_temp(14 downto 13) <= "00";    --TvE: Enables data set 0 to write to
                        cache_we <= "01";                               --TvE: Enable cache tag block 0 to write tag to
                        LRU_in(0) <= '1';                                   --TvE: LRU after write to set 0 is set 1
                    end if;
                    state <= STATE_MISSED;
                else
                    cache_we <= "00";
                    cache_miss <= '0';

                        if cache_tag_out(0) = cache_tag_reg then
                            cache_ram_data_r <= cache_ram_data_r0;      --TvE: tag of set 0 was correct so data in set 0 is routed to output
                            LRU_in(0) <= '1';                            --TvE: Data in set 1 was Least Recently Used
                        elsif cache_tag_out(1) = cache_tag_reg then
                            cache_ram_data_r <= cache_ram_data_r1;      --TvE: tag of set 1 was correct so data in set 1 is routed to output
                            LRU_in(0) <= '0';                              --TvE: Data in set 0 was Least Recently Used
                        else        -- TvE: Do nothing

                        end if;
                    state <= STATE_IDLE;
                end if;
            when STATE_MISSED =>          --current read cache miss
                cache_checking <= '0';
                cache_miss <= '1';
                LRU_we <= '0';
                cache_we <= "00";
                miss_state_prev <= '1';     --TvE: signal to detect if the miss state was previous then no addresses or LRU's have to be checked again
                cache_ram_data_r <= cache_ram_data_w_reg; --TvE: Output written data a clockcycle later.
                if mem_busy = '1' then
                    state <= STATE_MISSED;
                else
                    state <= STATE_WAITING;
                end if;
            when STATE_WAITING =>         --waiting for memory access to complete
                cache_checking <= '0';
                cache_miss <= '0';
                cache_ram_data_r <= cache_ram_data_w_reg; --TvE: Output written data the a clockcycle later.

                if miss_state_prev_reg = '1' then
                    miss_state_prev <= '0';         --TvE: signal to detect if the miss state was previous then no addresses or LRU's have to be checked again
                else
                    if write_toggle = '0' then                           --TvE: To make sure that when cache is waiting until DDR is also updated that it doesnt toggle the LRU continuously
                        LRU_we <= '1';                                
                        if LRU_out(0) = '1' then
                            cache_ram_write_address_temp(14 downto 13) <= "01";    --TvE: Enables data set 1 to write to
                            cache_we <= "10";                               --TvE: Enable cache tag block 1 to write tag to
                            LRU_in(0) <= '0';                                   --TvE: LRU after write to set 1 is set 0
                        else
                            cache_ram_write_address_temp(14 downto 13) <= "00";    --TvE: Enables data set 0 to write to
                            cache_we <= "01";                               --TvE: Enable cache tag block 0 to write tag to
                            LRU_in(0) <= '1';                                   --TvE: LRU after write to set 0 is set 1
                        end if;
                    end if;
                end if;
                
                if mem_busy = '1' then
                    state <= STATE_WAITING;
                    write_toggle <= '1';
                else
                    state <= STATE_IDLE;
                end if;
            when others =>
                cache_checking <= '0';
                cache_miss <= '0';
                state <= STATE_IDLE;
        end case; --state

        if state = STATE_IDLE then    --check if next access in cached range
            if address_next(30 downto 21) = "0010000000" then  --first 2MB of DDR, MS: first and only 1 is for activating DDR
                cache_access <= '1';
                if byte_we_next = "0000" then     --read cycle
                    state_next <= STATE_CHECKING;  --need to check if match
                else
                    write_toggle <= '0';
                    state_next <= STATE_WAITING;
                end if;
            else
                LRU_we <= '0';
                cache_access <= '0';
                cache_we <= "00";
                state_next <= STATE_IDLE;
            end if;
        else
            cache_access <= '0';
            state_next <= state;
        end if;

        if byte_we_next = "0000" or byte_we_next = "1111" then  --read or 32-bit write
            cache_tag_in <= address_next(20 downto 13);   -- TvE changed to get correct tag length for 2 MB
        else
            cache_tag_in <= ONES(7 downto 0);  --invalid tag -- 
        end if;

        if reset = '1' then
            state_reg <= STATE_IDLE;
            cache_tag_reg <= ZERO(7 downto 0);  -- TvE: changed to get correct tag length
            cache_ram_address_reg <= ZERO(31 downto 2);
            cache_ram_data_w_reg <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
            cache_ram_byte_we_reg <= "0000";
            cache_ram_data_r <= cache_ram_data_r0;
        elsif rising_edge(clk) then
            state_reg <= state_next;
            cache_ram_enable_reg <= cache_ram_enable; 
            cache_ram_address_reg <= cache_ram_address;
            cache_ram_data_w_reg <= cache_ram_data_w;   --TvE: when a write occurs the data must be latched because we have to wait to see in which set it must be placed
            cache_ram_byte_we_reg <= cache_ram_byte_we;
            miss_state_prev_reg <= miss_state_prev;
            if state = STATE_IDLE and state_reg /= STATE_MISSED then
                cache_tag_reg <= cache_tag_in;
            end if;
        end if;

    end process;


    cache_tag1: RAMB16_S9_S9  --Xilinx specific
        generic map (
            INIT_A => "111111111", -- Initial values on A output port
            INIT_B => "111111111", -- Initial values on B output port
            SRVAL_A => X"000", -- Port A ouput value upon SSR assertion
            SRVAL_B => X"000", -- Port B ouput value upon SSR assertion
            WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
            WRITE_MODE_B => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
            --In WRITE_FIRST mode, the input data is simultaneously written into memory and stored in the data output (transparent write)
            --In READ_FIRST mode, data previously stored at the write address appears on the output latches, while the input data is being stored in memory (read before write)
            --In NO_CHANGE mode, the output latches remain unchanged during a write operationIT_xx declarations specify the initial contents of the RAM
            -- Address 0 to 511
            INIT_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_03 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_07 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_08 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_09 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 512 to 1023
            INIT_10 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_11 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_12 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_13 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_14 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_15 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_16 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_17 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_18 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_19 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1024 to 1535
            INIT_20 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_21 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_22 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_23 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_24 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_25 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_26 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_27 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_28 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_29 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1536 to 2047
            INIT_30 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_31 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_32 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_33 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_34 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_35 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_36 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_37 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_38 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_39 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- The next set of INITP_xx are for the parity bits
            -- Address 0 to 511
            INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 512 to 1023
            INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1024 to 1535
            INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1536 to 2047
            INITP_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_07 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
        )
        port map (
            -- Port A is "read" port-----------------------------------------------------------------
            DOA => cache_tag_r_out(0)(7 downto 0), -- 8-bit A port Data Output  TvE: the read output port
            DOPA => open, -- 1-bit A port Parity Output                     TvE: Parity unused
            ADDRA => cache_address, -- 11-bit A port Address Input              TvE: Read address
            CLKA => clk, -- Port A Clock
            DIA => ZERO(7 downto 0), -- 8-bit A port Data Input             TvE: No writes on the "read" port
            DIPA => ZERO(0 downto 0), -- 1-bit A port parity Input          TvE: Parity unused
            ENA => tag_read_enable, -- 1-bit A port Enable Input                        TvE: "Read" port always enabled
            SSRA => ZERO(0), -- 1-bit A port Synchronous Set/Reset Input    TvE: Unused
            WEA => ZERO(0), -- 1-bit A port Write Enable Input      TvE: "Read" port can never be written on
            
            -- Port B is "write" port----------------------------------------------------------------
            DOB => cache_tag_w_out(0)(7 downto 0), -- 8-bit B port Data Output                        TvE: no reads from the "write" port
            DOPB => open, -- 1-bit B port Parity Output                     TvE: Parity unused
            ADDRB => tag_write_addr, -- 11-bit B port Address Input             TvE: Write address
            CLKB => clk, -- Port B Clock
            DIB => cache_tag_reg(7 downto 0), -- 8-bit B port Data Input     TvE: Data input
            DIPB => ZERO(0 downto 0), -- 1-bit B port parity Input          TvE: Parity unused
            ENB => '1', -- 1-bit B port Enable Input            TvE: Enable based on higher bits of the write_address
            SSRB => ZERO(0), -- 1-bit B port Synchronous Set/Reset Input    TvE: Unused
            WEB => cache_we(0) -- 1-bit B port Write Enable Input  TvE: "Write" port enable based on byte_enable
        );

        cache_tag2: RAMB16_S9_S9  --Xilinx specific
        generic map (
            INIT_A => "111111111", -- Initial values on A output port
            INIT_B => "111111111", -- Initial values on B output port
            SRVAL_A => X"000", -- Port A ouput value upon SSR assertion
            SRVAL_B => X"000", -- Port B ouput value upon SSR assertion
            WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
            WRITE_MODE_B => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
            --In WRITE_FIRST mode, the input data is simultaneously written into memory and stored in the data output (transparent write)
            --In READ_FIRST mode, data previously stored at the write address appears on the output latches, while the input data is being stored in memory (read before write)
            --In NO_CHANGE mode, the output latches remain unchanged during a write operation
            INIT_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_03 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_07 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_08 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_09 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 512 to 1023
            INIT_10 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_11 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_12 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_13 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_14 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_15 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_16 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_17 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_18 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_19 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1024 to 1535
            INIT_20 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_21 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_22 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_23 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_24 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_25 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_26 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_27 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_28 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_29 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1536 to 2047
            INIT_30 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_31 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_32 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_33 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_34 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_35 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_36 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_37 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_38 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_39 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- The next set of INITP_xx are for the parity bits
            -- Address 0 to 511
            INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 512 to 1023
            INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1024 to 1535
            INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1536 to 2047
            INITP_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_07 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
        )
        port map (
            -- Port A is "read" port-----------------------------------------------------------------
            DOA => cache_tag_r_out(1)(7 downto 0), -- 8-bit A port Data Output  TvE: the read output port
            DOPA => open, -- 1-bit A port Parity Output                     TvE: Parity unused
            ADDRA => cache_address, -- 11-bit A port Address Input              TvE: Read address
            CLKA => clk, -- Port A Clock
            DIA => ZERO(7 downto 0), -- 8-bit A port Data Input             TvE: No writes on the "read" port
            DIPA => ZERO(0 downto 0), -- 1-bit A port parity Input          TvE: Parity unused
            ENA => tag_read_enable, -- 1-bit A port Enable Input                        TvE: "Read" port always enabled
            SSRA => ZERO(0), -- 1-bit A port Synchronous Set/Reset Input    TvE: Unused
            WEA => ZERO(0), -- 1-bit A port Write Enable Input      TvE: "Read" port can never be written on
            
            -- Port B is "write" port----------------------------------------------------------------
            DOB => cache_tag_w_out(1)(7 downto 0), -- 8-bit B port Data Output                        TvE: no reads from the "write" port
            DOPB => open, -- 1-bit B port Parity Output                     TvE: Parity unused
            ADDRB => tag_write_addr, -- 11-bit B port Address Input             TvE: Write address
            CLKB => clk, -- Port B Clock
            DIB => cache_tag_reg(7 downto 0), -- 8-bit B port Data Input     TvE: Data input
            DIPB => ZERO(0 downto 0), -- 1-bit B port parity Input          TvE: Parity unused
            ENB => '1', -- 1-bit B port Enable Input            TvE: Enable based on higher bits of the write_address
            SSRB => ZERO(0), -- 1-bit B port Synchronous Set/Reset Input    TvE: Unused
            WEB => cache_we(1) -- 1-bit B port Write Enable Input  TvE: "Write" port enable based on byte_enable
        );

        cache_LRU: RAMB16_S9_S9  --Xilinx specific
        generic map (
            INIT_A => "111111111", -- Initial values on A output port
            INIT_B => "111111111", -- Initial values on B output port
            SRVAL_A => X"000", -- Port A ouput value upon SSR assertion
            SRVAL_B => X"000", -- Port B ouput value upon SSR assertion
            WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
            WRITE_MODE_B => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
            --In WRITE_FIRST mode, the input data is simultaneously written into memory and stored in the data output (transparent write)
            --In READ_FIRST mode, data previously stored at the write address appears on the output latches, while the input data is being stored in memory (read before write)
            --In NO_CHANGE mode, the output latches remain unchanged during a write operation

            INIT_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_03 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_07 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_08 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_09 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 512 to 1023
            INIT_10 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_11 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_12 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_13 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_14 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_15 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_16 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_17 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_18 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_19 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_1F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1024 to 1535
            INIT_20 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_21 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_22 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_23 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_24 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_25 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_26 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_27 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_28 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_29 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_2F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1536 to 2047
            INIT_30 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_31 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_32 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_33 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_34 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_35 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_36 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_37 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_38 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_39 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3A => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3B => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_3F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- The next set of INITP_xx are for the parity bits
            -- Address 0 to 511
            INITP_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_01 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 512 to 1023
            INITP_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_03 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1024 to 1535
            INITP_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_05 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            -- Address 1536 to 2047
            INITP_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INITP_07 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
        )
        port map (
            -- Port A is "read" port-----------------------------------------------------------------
            DOA => open, -- 8-bit A port Data Output  TvE: the read output port
            DOPA => LRU_r_out, -- 1-bit A port Parity Output                     TvE: Parity unused
            ADDRA => cache_address, -- 11-bit A port Address Input              TvE: Read address
            CLKA => clk, -- Port A Clock
            DIA => ZERO(7 downto 0), -- 8-bit A port Data Input             TvE: No writes on the "read" port
            DIPA => ZERO(0 downto 0), -- 1-bit A port parity Input          TvE: Parity unused
            ENA => LRU_read_enable, -- 1-bit A port Enable Input                        TvE: "Read" port always enabled
            SSRA => ZERO(0), -- 1-bit A port Synchronous Set/Reset Input    TvE: Unused
            WEA => ZERO(0), -- 1-bit A port Write Enable Input      TvE: "Read" port can never be written on
            
            -- Port B is "write" port----------------------------------------------------------------
            DOB => open, -- 8-bit B port Data Output                        TvE: no reads from the "write" port
            DOPB => LRU_w_out, -- 1-bit B port Parity Output                     TvE: Parity unused
            ADDRB => LRU_write_addr, -- 11-bit B port Address Input             TvE: Write address
            CLKB => clk, -- Port B Clock
            DIB => ZERO(7 downto 0), -- 8-bit B port Data Input     TvE: Data input
            DIPB => LRU_in, -- 1-bit B port parity Input          TvE: Parity unused
            ENB => '1', -- 1-bit B port Enable Input            TvE: Enable based on higher bits of the write_address
            SSRB => ZERO(0), -- 1-bit B port Synchronous Set/Reset Input    TvE: Unused
            WEB => LRU_we -- 1-bit B port Write Enable Input  TvE: "Write" port enable based on byte_enable
        );

    cache_data: cache_ram     -- cache data storage
        port map (
            clk               => clk,
            enable            => cache_ram_enable_reg,
            read_enable       => read_enable,
            write_byte_enable => cache_ram_byte_we_reg,
            read_address      => cache_ram_address,
            write_address     => cache_ram_write_address_temp,
            data_write        => cache_ram_data_w_reg,
            data_read0        => cache_ram_data_r0,
            data_read1        => cache_ram_data_r1
        );
end; --logic

