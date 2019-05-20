LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY interruptores IS 
	PORT (
		boot 		: IN STD_LOGIC;
		clk  		: IN STD_LOGIC;
		inta 		: IN STD_LOGIC;
		switches	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		intr		: OUT STD_LOGIC;
		rd_switch: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end interruptores;

ARCHITECTURE Structure OF interruptores IS

 signal old_sw : STD_LOGIC_VECTOR (7 DOWNTO 0); -- guardamos estado anterior de switches
 signal s_intr: STD_LOGIC := '0';
  
BEGIN
	
	PROCESS (clk, boot)
	BEGIN
		IF boot='1' THEN
				s_intr <= '0';
				old_sw <= switches;
		else 
			IF rising_edge(clk) THEN
				if inta='0' then
					if switches /= old_sw then
						s_intr <= '1';
		  			   old_sw <= switches;
					else
						s_intr <= s_intr;
					end if;
				else
					s_intr <= '0';
				end if;
			END IF;
		end if;
	END PROCESS;
	
	intr	 <= s_intr;
	rd_switch  <= switches; 

END Structure;