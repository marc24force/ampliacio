LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY regfileSIMD IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); --registro b o posicion en caso de acceso 16bits
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 boot   : IN  STD_LOGIC;
			 b16   : IN  STD_LOGIC; -- Indica acceso 16b
          a      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			 b      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0));
END regfileSIMD;


ARCHITECTURE Structure OF regfileSIMD IS
   type BANCO_REG_SIMD is array (7 downto 0) of std_logic_vector(127 downto 0);
	signal registres      : BANCO_REG_SIMD;
	
   
BEGIN
	PROCESS (clk,boot)	BEGIN
	   if boot = '1' then 
			registres(0) <= (others => '0');
		elsif rising_edge(clk) then
			if wrd = '1' and addr_d /= "000" then
			   if b16 = '1' then 
					registres(conv_integer(addr_d))(conv_integer(addr_b)*16+15 downto conv_integer(addr_b)*16) <= d(15 downto 0);
			   else 
					registres(conv_integer(addr_d))<=d;
				end if;
			end if;
		end if;
	end process;
	 
	 
	b <= registres(conv_integer(addr_b));
	a(127 downto 16) <= registres(conv_integer(addr_a))(127 downto 16);
	a(15 downto 0) <=  registres(conv_integer(addr_a))(15 downto 0) when b16 = '0' else 
							 registres(conv_integer(addr_a))(conv_integer(addr_b)*16+15 downto conv_integer(addr_b)*16);
 
END Structure;