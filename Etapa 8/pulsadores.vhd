LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY pulsadores IS 
	PORT (
		boot 		: IN STD_LOGIC;
		clk  		: IN STD_LOGIC;
		inta 		: IN STD_LOGIC;
		keys 		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		intr		: OUT STD_LOGIC;
		read_key : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)	);
end pulsadores;

ARCHITECTURE Structure OF pulsadores IS
 signal old_key : STD_LOGIC_VECTOR (3 DOWNTO 0); -- guardamos estado anterior de keys
 signal s_intr : STD_LOGIC := '0';
 
 
BEGIN
	PROCESS (clk, boot)
	BEGIN
		if boot='1' then --en boot inicializamos sin intr y el valor de old_key
				s_intr <= '0';
				old_key <= keys;
		else 
			if rising_edge(clk) then
				if s_intr='0' then		-- Si no hay intr
					if keys /= old_key then --en caso que haya un cambio
						old_key <= keys;	--actualizamos valores
						s_intr <= '1';		-- generamos intr
					end if;
				else 							-- si hay una intr pendiente
					if inta='1' then 		-- al recibir el acknowledge
												--  podemos volver a generar intr
						if keys /= old_key then --en caso que haya un cambio
							old_key <= keys;	--actualizamos valores
							s_intr <= '1';		-- generamos intr
						else 					-- si no hay cambios
							s_intr <= '0';		-- desactivamos intr
						end if;
				   end if;
				end if;
			end if;
		end if;
	END PROCESS;
	
	intr	 <= s_intr;
	read_key <= keys; 

END Structure;