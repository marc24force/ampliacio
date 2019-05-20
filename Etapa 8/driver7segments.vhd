LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY driver7segments IS
 PORT( input : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 HEX : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
		 
END driver7segments;

ARCHITECTURE Structure OF driver7segments IS 
BEGIN
   with input select
		HEX <= "1000000" when "0000",  --0
				 "1111001" when "0001",  --1
				 "0100100" when "0010",  --2
				 "0110000" when "0011",  --3
				 "0011001" WHEN "0100",  --4
				 "0010010" when "0101",  --5
				 "0000010" when "0110",  --6
				 "1111000" when "0111",  --7
				 "0000000" when "1000",  --8
				 "0010000" WHEN "1001",  --9
				 "0001000" when "1010",  --A
				 "0000011" when "1011",  --b
				 "1000110" when "1100",  --C
				 "0100001" when "1101",  --d
				 "0000110" WHEN "1110",  --E
				 "0001110" WHEN  others; --F
END Structure;
