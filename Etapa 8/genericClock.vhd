LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY genericClock IS
 generic(original : integer);
 PORT(clock: IN std_logic; 
   outClock: OUT STD_LOGIC);
END genericClock;
ARCHITECTURE Structure OF genericClock IS
 
BEGIN
	process (clock) 
		variable cont : integer := original;
	begin
	if falling_edge(clock) then
			if cont = 0 then
				cont := original;
				outClock <= '1';
			else
				cont := cont - 1;
				outClock <= '0';
			end if;
	end if;
	end process;

END Structure; 



