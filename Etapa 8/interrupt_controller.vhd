LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY interrupt_controller IS
	PORT (
		boot 			: IN STD_LOGIC;
		clk			: IN STD_LOGIC;
		inta			: IN STD_LOGIC;
		key_intr 	: IN STD_LOGIC;
		ps2_intr		: IN STD_LOGIC;
		switch_intr	: IN STD_LOGIC;
		timer_intr	: IN STD_LOGIC;
		intr			: OUT STD_LOGIC;
		key_inta		: OUT STD_LOGIC;
		ps2_inta		: OUT STD_LOGIC;
		switch_inta : OUT STD_LOGIC;
		timer_inta	: OUT STD_LOGIC;
		iid			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END interrupt_controller;

ARCHITECTURE Structure OF interrupt_controller IS

	constant TIMER 	: STD_LOGIC_VECTOR := X"00";
	constant KEYS		: STD_LOGIC_VECTOR := X"01";
	constant SWITCHES : STD_LOGIC_VECTOR := X"02";
	constant PS2	 	: STD_LOGIC_VECTOR := X"03";
	
	signal  s_timer_inta : STD_LOGIC := '0';
	signal  s_key_inta : STD_LOGIC := '0';
	signal  s_switch_inta : STD_LOGIC := '0';
	signal  s_ps2_inta : STD_LOGIC := '0';
	
	signal s_group_intr : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	
BEGIN
	

	 s_timer_inta 	<= inta when s_group_intr(3) = '1'  else '0';
	 s_key_inta	  	<= inta when s_group_intr(3 downto 2) = "01"  else '0';
	 s_switch_inta	<= inta when s_group_intr(3 downto 1) = "001"   else '0';
	 s_ps2_inta	  	<= inta when s_group_intr(3 downto 0) = "0001"   else '0';


	intr <=  (timer_intr OR key_intr OR switch_intr OR ps2_intr); -- AND NOT inta;
	
	timer_inta 	<=  s_timer_inta;
	key_inta 	<=  s_key_inta;
	switch_inta <=  s_switch_inta;
	ps2_inta 	<=  s_ps2_inta;
	
	iid <= TIMER 	 when s_group_intr(3) = '1'	else
			 KEYS  	 when s_group_intr(2) = '1'   else
			 SWITCHES when s_group_intr(1) = '1'   else
			 PS2		 when s_group_intr(0) = '1';

	
	PROCESS (inta)
	BEGIN
		 if rising_edge(inta) then
			s_group_intr <= timer_intr & key_intr & switch_intr & ps2_intr; -- Control iid
		end if;
	
	END PROCESS;
	
END Structure;