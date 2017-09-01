
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.mlite_pack.all;


entity mult_csa_level is
    generic(
        N_NEEDED_INPUTS : positive := 32;
        WIDTH_CSA       : positive := 32
    );

    port(
        imula, imult    : in  std_logic_vector(WIDTH_CSA-1 downto 0);
        os, oc          : out std_logic_vector(WIDTH_CSA*2   downto 0)
    );
end; --entity mult


architecture logic of mult_csa_level is
    constant NUM_CSA : positive := (N_NEEDED_INPUTS/3) +1;
	subtype ivec is std_logic_vector(imula'range);
	subtype ovec is std_logic_vector(os'range);
	type ibun is array (NUM_CSA-1 downto 0) of ivec;
	type obun is array (NUM_CSA-1 downto 0) of ovec;
	signal a,b,c 	: ibun;
	signal sum, car : obun;
    
begin
    -- generate 32 CSAs - first level
    G1: for index in 0 to NUM_CSA-1 generate -- MS: 32/3 = 10.xxx = 10

        a(index)    <= imula when   imult(index)    = '1' else (others => '0');
        b(index)    <= imula when   imult(index+1)  = '1' else (others => '0');
        c(index)    <= imula when   imult(index+2)  = '1' else (others => '0');

    	LB_CSA_FIRST: entity work.csa_adder 
        generic map( CSA_SIZE => imula'length)
        port map(
    		ia =>		a(index), 
    		ib => 		b(index), 
    		ic => 		c(index), 
    		osum => 	sum(index),
    		ocarry => 	car(index)
    		);
    end generate;

    -- MS : connect the remaining, outside of the loop, signals
    a(NUM_CSA)<= imula when   imult(30)    = '1' else (others => '0'); 
    b(NUM_CSA)<= imula when   imult(31)    = '1' else (others => '0');
    c(NUM_CSA)<= (others => '0');

    LB_CSA_FIRST_LST: entity work.csa_adder 
        generic map( CSA_SIZE => imula'length)
        port map(
            ia =>       a(NUM_CSA), 
            ib =>       b(NUM_CSA), 
            ic =>       c(NUM_CSA), 
            osum =>     sum(NUM_CSA),
            ocarry =>   car(NUM_CSA)
            );

 

end; --architecture logic
