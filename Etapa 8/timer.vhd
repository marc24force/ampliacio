LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY timer IS
	PORT (
		boot 		: IN STD_LOGIC;
		inta 		: IN STD_LOGIC;
		CLOCK_50 : IN STD_LOGIC;
		intr		: OUT STD_LOGIC
	);

end timer;

ARCHITECTURE Structure OF timer IS

	SIGNAL cont 	: STD_LOGIC_VECTOR (21 downto 0);
	constant max_50ms	: STD_LOGIC_VECTOR (23 downto 0):= X"2625A0";--X"2625A0"; --50ms/(1/50MHz) = 2500000 = 0x2625a0 
 	signal s_intr  : std_logic := '0';

BEGIN

	PROCESS (CLOCK_50) 
	BEGIN
		if boot = '1' then
			cont <= (others=>'0');
			s_intr <= '0';
		elsif rising_edge(CLOCK_50) then
			cont <= cont + 1;
			if cont = max_50ms then
				s_intr <= '1';
				cont <= (others =>'0');
			end if;
			
			if (inta = '1') then
				s_intr <= '0';
			end if;
			
		end if;
	END PROCESS;
	
	intr <= s_intr;
			  
END Structure;