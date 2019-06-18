LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY regfileSIMD IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 boot   : IN  STD_LOGIC;
          a      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			 b      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0));
END regfileSIMD;


ARCHITECTURE Structure OF regfileSIMD IS
   type BANCO_REG_SIMD is array (7 downto 0) of std_logic_vector(127 downto 0);
	signal registres      : BANCO_REG_SIMD;
	
   
BEGIN
	PROCESS (clk,boot)	BEGIN
	   if boot = '1' then 
		
		elsif rising_edge(clk) then
			if wrd = '1' then
				registres(conv_integer(addr_d))<=d;
			end if;
		end if;
	end process;
	 
	a <= registres(conv_integer(addr_a));
	b <= registres(conv_integer(addr_b));

END Structure;