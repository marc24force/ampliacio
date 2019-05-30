LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY aluSIMD IS
    PORT (x  		: IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
          y  		: IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
			 op 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
			 w  		: OUT STD_LOGIC_VECTOR(127 DOWNTO 0)); 
END aluSIMD;

ARCHITECTURE Structure OF aluSIMD IS
constant ADDS: STD_LOGIC_VECTOR := "000";
constant SUBS : STD_LOGIC_VECTOR := "001";
constant ANDS: STD_LOGIC_VECTOR := "010";
constant ORS: STD_LOGIC_VECTOR := "011";
constant XORS : STD_LOGIC_VECTOR := "100";
constant NOTS : STD_LOGIC_VECTOR := "101";

	BEGIN
	with op select
	w      <=   x and y when ANDS,
				   x or y  when ORS,
					x xor y when XORS,
					not x   when NOTS,
				   std_logic_vector(signed(x)+signed(y))	when ADDS,
					std_logic_vector(signed(x)-signed(y))	when SUBS,
					X"BABEFEEDDEADBEEFBEBEBEEFBEBECAFE" when others;
					
END Structure;