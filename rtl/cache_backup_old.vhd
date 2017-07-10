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
--   address_next(20 : 13)   |   address_next(12: 2)   |   address_next(1:0)  |   16kb Cache, 2MB Ram, 2-way set associative
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
    subtype state_type is std_logic_vector(2 downto 0);
    constant STATE_IDLE     : state_type := "000";
    constant STATE_CHECKING : state_type := "001";
    constant STATE_MISSED   : state_type := "010";
    constant STATE_WAITING  : state_type := "011";
    constant STATE_SET_ASS	: state_type := "111";

    signal state_reg        : state_type;
    signal state            : state_type;
    signal state_next       : state_type;

    signal cache_address    : std_logic_vector(10 downto 0);
    signal cache_tag_in     : std_logic_vector(7 downto 0); -- TvE: Changed from 8 downto 0
    signal cache_tag_reg    : std_logic_vector(7 downto 0); -- TvE: Changed from 8 downto 0
    --signal cache_tag_out    : std_logic_vector(8 downto 0); -- TvE: not used, changed to tag_block_do
    signal cache_we         : std_logic_vector(1 downto 0);

    --TvE: Adjustments for 16 kB Cache (Tag doubling)-----------------------------------------
    type mem8_vector IS ARRAY (NATURAL RANGE<>) OF std_logic_vector(7 downto 0);
    signal tag_block_do: mem8_vector(1 downto 0); -- TvE: Output of the tag block

    ---------------------------------------------------------------------------------------
    
    --TvE: Adjustments for 2-way set associative Cache -----------------------------------------
    signal cache_ram_enable_temp    : std_logic;						--TvE: latched	
    signal cache_ram_byte_we_temp   : std_logic_vector(3 downto 0);		--TvE: latched
    signal cache_ram_address_temp   : std_logic_vector(31 downto 2);	--TvE: Determined by combinatorics
    signal cache_ram_data_w_temp    : std_logic_vector(31 downto 0);	--TvE: Data_input Latched
    signal cache_ram_address_next   : std_logic_vector(31 downto 2);    --TvE: address input next
    signal cache_ram_address_reg    : std_logic_vector(31 downto 2);    --TvE: address input Latched
    --signal cache_ram_data_r_temp    : std_logic_vector(31 downto 0);	--data_output

    subtype cache_state is std_logic_vector(1 downto 0);
    constant CACHE_0_FO	    : cache_state := "00";	--TvE: Meaning replace cache line in set 0
    constant CACHE_1_FO	    : cache_state := "01";	--TvE: Meaning replace cache line in set 1
    constant CACHE_1_FO2 	: cache_state := "10";	--TvE: Meaning replace cache line in set 1
    constant CACHE_0_FO2  	: cache_state := "11";	--TvE: Meaning replace cache line in set 0

    signal cache_FIFO_flag_in		: cache_state;      --FIFO flag
    signal cache_FIFO_flag_out		: cache_state;      --FIFO flag
    signal FIFO_flag 			    : cache_state;		--FIFO flag
    signal cache_FIFO_flag_reg		: cache_state;		--FIFO flag
    signal write_cycle_set_ass      : std_logic := '0'; --Track the progress in the write cycle, takes more cycles than

    ---------------------------------------------------------------------------------------
begin
   	-- TvE: Assignment of cache_ram_..._temp signals! 
   	--cache_ram_data_r <= cache_ram_data_r_temp;
   	
    cache_proc: process(clk, reset, mem_busy, cache_address,
        state_reg, state, state_next,
        address_next, byte_we_next, cache_tag_in, --Stage1
        cache_tag_reg, tag_block_do, cache_FIFO_flag_out, --Stage2 TvE: changed cache_tag_out to tag_block_do
        cpu_address) --Stage3
    begin

    ------------------------
    cache_ram_address_temp(31 downto 14) <= cache_ram_address(31 downto 14);
    --TvE: only the 13th bit needs to be set according to which cache block must be updated/read
    --cache_ram_address_temp(12 downto 2) <= cache_ram_address(12 downto 2);
	
    ------------------------
    ------------------------
    -- TvE: Assignment of FIFO_flag_in data!
    ------------------------

        
        case state_reg is
            when STATE_IDLE =>            --cache idle
                cache_checking <= '0';
                cache_miss <= '0';
                state <= STATE_IDLE;
            when STATE_CHECKING =>        --current read in cached range, check if match
                cache_checking <= '1';
                if (tag_block_do(1) /= cache_tag_reg and tag_block_do(0) /= cache_tag_reg) or
                   (tag_block_do(1) = ONES(7 downto 0) and tag_block_do(0) = ONES(7 downto 0)) then --TvE: changed cache_tag_out to tag_block_do
                   	FIFO_flag <= cache_FIFO_flag_out;
                    cache_miss <= '1';
                    state <= STATE_MISSED;
                else
                	cache_miss <= '0';
                    state <= STATE_IDLE;
                    cache_ram_address_temp(12 downto 2)<= cache_ram_address_reg(12 downto 2);
                    if tag_block_do(1) = cache_tag_reg then
                    	cache_ram_address_temp(13) <= '1';		-- TvE: Selection bit to determine which block the confirmed data is in
                    else
                    	cache_ram_address_temp(13) <= '0';		-- TvE: Selection bit to determine which block the confirmed data is in
                    end if;
                end if;
            when STATE_MISSED =>          --current read cache miss
                cache_checking <= '0';
                cache_miss <= '1';
                if mem_busy = '1' then
                    state <= STATE_MISSED;
                else
                    state <= STATE_WAITING;
                end if;
            when STATE_WAITING =>         --waiting for memory access to complete
                cache_checking <= '0';
                cache_miss <= '0';
                write_cycle_set_ass <= '0';     --TvE: extra signal to be sure it takes 1 more cycle for writing
                --if cache_FIFO_flag_reg = CACHE_1_FO or cache_FIFO_flag_reg = CACHE_1_FO2 then
                --    cache_ram_address_temp(13) <= '1';      -- TvE: Selection bit to determine which block to write the data to
                --else
                --    cache_ram_address_temp(13) <= '0';      -- TvE: Selection bit to determine which block to write the data to
                --end if;
                if mem_busy = '1' then
                    state <= STATE_WAITING;
                else
                    state <= STATE_IDLE;
                end if;
            when STATE_SET_ASS =>			--TvE: added state to check the FIFO flags in order to write the data to the correct cache block
                
                cache_ram_address_temp(12 downto 2)<= cache_ram_address_reg(12 downto 2);
                cache_address <= cache_ram_address_reg(12 downto 2);
                case cache_FIFO_flag_out is           --TvE: Can also be the (un)clocked flag
                        when CACHE_0_FO =>      --"00"
                            cache_we <= "01";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "01";
                            cache_ram_address_temp(13) <= '0';      -- TvE: Selection bit to determine which block to write the data to
                        when CACHE_1_FO =>      --"01"
                            cache_we <= "10";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "11";
                            cache_ram_address_temp(13) <= '1';      -- TvE: Selection bit to determine which block to write the data to
                        when CACHE_0_FO2 =>     --"11"
                            cache_we <= "01";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "10";
                            cache_ram_address_temp(13) <= '0';      -- TvE: Selection bit to determine which block to write the data to
                        when CACHE_1_FO2 =>     --"10"
                            cache_we <= "10";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "00";
                            cache_ram_address_temp(13) <= '1';      -- TvE: Selection bit to determine which block to write the data to
                        when others =>
                            cache_we <= "00";
                    end case;
                write_cycle_set_ass <= '1';
                --FIFO_flag <= cache_FIFO_flag_out;
                state <= STATE_WAITING;
            when others =>
                cache_checking <= '0';
                cache_miss <= '0';
                state <= STATE_IDLE;
        end case; --state

        if state = STATE_IDLE then    							--check if next access in cached range
            cache_address <= address_next(12 downto 2); 		--TvE: change: to 12 concatenation with 0 removed
            if address_next(30 downto 21) = "0010000000" then  	--first 2MB of DDR 
                cache_access <= '1';
                cache_we <= "00";								--TvE: no writes to tags yet!
                if byte_we_next = "0000" then     				--read cycle
                    state_next <= STATE_CHECKING;  				--need to check if match
                else                                            --TvE: Write cycle
                    if write_cycle_set_ass = '0' then
                        state_next <= STATE_SET_ASS;            --TvE: was STATE_WAITING, this state checks to which of the 2 sets it has to write the data to                        
                        cache_ram_address_next <= cache_ram_address;                   
                    else
                        state_next <= STATE_WAITING;
                    end if ;
                end if;
            else
                cache_access <= '0';
                cache_we <= "00";
                state_next <= STATE_IDLE;
            end if;
        else
            if state_reg /= STATE_SET_ASS then
                cache_address <= cpu_address(12 downto 2);  -- TvE: changed: 0 concatenation with 11 downto 2 to 12 downto 2    
            end if ;
                cache_access <= '0';
            if state = STATE_MISSED then
                    case cache_FIFO_flag_reg is           --TvE: Can also be the (un)clocked flag
                        when CACHE_0_FO =>		--"00"
                            cache_we <= "01";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "01";
                        when CACHE_1_FO =>      --"01"
                            cache_we <= "10";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "11";
                        when CACHE_0_FO2 =>     --"11"
                            cache_we <= "01";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "10";
                        when CACHE_1_FO2 =>     --"10"
                            cache_we <= "10";       --update cache tag TvE: in right tag block
                            cache_FIFO_flag_in <= "00";
                        when others =>
                            cache_we <= "00";
                    end case;
            else
                if state_reg /= STATE_SET_ASS then
                    cache_we <= "00";    
                end if ;
            end if;
            state_next <= state;
        end if;

        if byte_we_next = "0000" or byte_we_next = "1111" then  --read or 32-bit write
            cache_tag_in <= address_next(20 downto 13);   -- TvE changed to get correct tag length for 2 MB 2-way set associative
        else
            cache_tag_in <= ONES(7 downto 0);  --invalid tag
        end if;

        if reset = '1' then
            state_reg <= STATE_IDLE;
            cache_tag_reg <= ZERO(7 downto 0);  -- TvE: changed to get correct tag length
        elsif rising_edge(clk) then
            state_reg <= state_next;
            cache_ram_enable_temp <= cache_ram_enable;		--TvE: Latched enable
            cache_FIFO_flag_reg <= FIFO_flag;				--TvE: Latched fifo flag
            cache_ram_byte_we_temp <= cache_ram_byte_we;	--TvE: Latched byte_we
            cache_ram_address_reg <= cache_ram_address_next;
            if (state = STATE_IDLE and state_reg /= STATE_MISSED) or state_reg = STATE_SET_ASS then
            	cache_ram_data_w_temp <= cache_ram_data_w;	--TvE: Latched data input.
                cache_tag_reg <= cache_tag_in;
            end if;
        end if;

    end process;


    cache_tag1: RAMB16_S9  --Xilinx specific
        generic map (
            INIT => X"FFF", -- Value of output RAM registers at startup
            SRVAL => X"000", -- Ouput value upon SSR assertion
            --WRITE_MODE => "WRITE_FIRST", -- WRITE_FIRST, READ_FIRST or NO_CHANGE
            -- The following INIT_xx declarations specify the initial contents of the RAM
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
            -- TvE: Changed from FFFF to 0000 as init value.
            -- Address 0 to 511
            INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
            -- Address 512 to 1023
            INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
            -- Address 1024 to 1535
            INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
            -- Address 1536 to 2047
            INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000"
        )
        port map (
            DO   => tag_block_do(0)(7 downto 0),                --TvE: changed cache_tag_out to tag_block_do
            DOP  => cache_FIFO_flag_out(0 downto 0),
            ADDR => cache_address,             --registered
            CLK  => clk,
            DI   => cache_tag_in(7 downto 0),  --registered
            DIP  => cache_FIFO_flag_in(0 downto 0),
            EN   => '1',        
            SSR  => ZERO(0),
            WE   => cache_we(0)
        );

        cache_tag2: RAMB16_S9  --Xilinx specific
        generic map (
            INIT => X"FFF", -- Value of output RAM registers at startup
            SRVAL => X"000", -- Ouput value upon SSR assertion
            --WRITE_MODE => "WRITE_FIRST", -- WRITE_FIRST, READ_FIRST or NO_CHANGE
            -- The following INIT_xx declarations specify the initial contents of the RAM
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
            -- TvE: Changed from FFFF to 0000 as init value.
            -- Address 0 to 511
            INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
            -- Address 512 to 1023
            INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
            -- Address 1024 to 1535
            INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
            -- Address 1536 to 2047
            INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000"
        )
        port map (
            DO   => tag_block_do(1)(7 downto 0),
            DOP  => cache_FIFO_flag_out(1 downto 1),
            ADDR => cache_address,             --registered
            CLK  => clk,
            DI   => cache_tag_in(7 downto 0),  --registered
            DIP  => cache_FIFO_flag_in(1 downto 1),
            EN   => '1', 
            SSR  => ZERO(0),
            WE   => cache_we(1)
        );


    cache_data: cache_ram     -- cache data storage
        port map (
            clk               => clk,
            enable            => cache_ram_enable_temp,
            write_byte_enable => cache_ram_byte_we_temp,
            address           => cache_ram_address_temp,
            data_write        => cache_ram_data_w_temp,
            data_read 	  	  => cache_ram_data_r
        );

end; --logic