LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;


ENTITY keyboard_controller_intr is
Port  (clear_char : in    STD_LOGIC;
		 clk        : in    STD_LOGIC;
		 inta			: in    STD_LOGIC;
		 reset      : in    STD_LOGIC;
		 ps2_clk    : inout STD_LOGIC;
		 ps2_data   : inout STD_LOGIC;
		 data_ready : out   STD_LOGIC;
		 intr			: out	  STD_LOGIC;
		 read_char  : out   STD_LOGIC_VECTOR (7 downto 0));
END keyboard_controller_intr;

ARCHITECTURE Structure OF keyboard_controller_intr IS

	COMPONENT keyboard_controller is
	Port (clk         : in    STD_LOGIC;
			 reset      : in    STD_LOGIC;
			 ps2_clk    : inout STD_LOGIC;
			 ps2_data   : inout STD_LOGIC;
			 read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
			 clear_char : in    STD_LOGIC;
			 data_ready : out   STD_LOGIC);
	END COMPONENT;
	
	signal s_data_ready : std_logic;
	signal s_inta : std_logic;

BEGIN

	kb : keyboard_controller
	port map(clk 			=> clk,
				reset 		=> reset,
				ps2_clk 		=> ps2_clk,
				ps2_data 	=> ps2_data,
				read_char 	=> read_char,
				clear_char	=> s_inta,
				data_ready 	=> s_data_ready);
	
	PROCESS (clk, reset)
	BEGIN

	if reset = '1' then
		intr <= '0';
	else
		if rising_edge(clk) then
			if s_data_ready = '1' then
				intr <= '1';
			end if;
			
			if s_inta = '1' then
				intr <= '0';
			end if;
		end if;
	end if;
	
	END PROCESS;
	
	s_inta <= clear_char or inta;
	data_ready <= s_data_ready;
	
END Structure;