LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY controladores_IO IS
 PORT(boot : IN STD_LOGIC;
		CLOCK_50 : IN std_logic;
		addr_io : IN std_logic_vector(7 downto 0);
		wr_io  : in std_logic_vector(15 downto 0);
		rd_io  : out std_logic_vector(15 downto 0);
		wr_out : in std_logic;
		rd_in  : in std_logic;
		keys   : in std_logic_vector(3 downto 0);
		switch :in std_logic_vector(7 downto 0);
		inta	 : in STD_LOGIC;	--new
		intr	 : OUT STD_LOGIC; --new
		led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		led_rojos : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		visor0 : OUT STD_LOGIC_VECTOR(6 downto 0);
		visor1 : OUT STD_LOGIC_VECTOR(6 downto 0);
		visor2 : OUT STD_LOGIC_VECTOR(6 downto 0);
		visor3 : OUT STD_LOGIC_VECTOR(6 downto 0);
		vga_cursor        : out std_logic_vector(15 downto 0);
      vga_cursor_enable : out std_logic;
		ps2_clk : inout std_logic;
		ps2_data : inout std_logic);
END controladores_IO;
ARCHITECTURE Structure OF controladores_IO IS

	component driver7segments IS
	 PORT( input : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			 HEX : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	end component;

--******************************************--NEW
component interrupt_controller IS   
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
end component;

component timer IS
	PORT (
		boot 		: IN STD_LOGIC;
		inta 		: IN STD_LOGIC;
		CLOCK_50 : IN STD_LOGIC;
		intr		: OUT STD_LOGIC
	);
end component;

component pulsadores IS 
	PORT (
		boot 		: IN STD_LOGIC;
		clk  		: IN STD_LOGIC;
		inta 		: IN STD_LOGIC;
		keys 		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		intr		: OUT STD_LOGIC;
		read_key : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)	);
end component;

component interruptores IS 
	PORT (
		boot 		: IN STD_LOGIC;
		clk  		: IN STD_LOGIC;
		inta 		: IN STD_LOGIC;
		switches	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		intr		: OUT STD_LOGIC;
		rd_switch: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;

component keyboard_controller_intr is
Port  (clear_char : in    STD_LOGIC;
		 clk        : in    STD_LOGIC;
		 inta			: in    STD_LOGIC;
		 reset      : in    STD_LOGIC;
		 ps2_clk    : inout STD_LOGIC;
		 ps2_data   : inout STD_LOGIC;
		 data_ready : out   STD_LOGIC;
		 intr			: out	  STD_LOGIC;
		 read_char  : out   STD_LOGIC_VECTOR (7 downto 0));
END component;

--******************************************

   type MEMORIA_IO is array (255 downto 0) of std_logic_vector(15 downto 0);
	signal puertos : MEMORIA_IO;
	signal s_v0 : STD_LOGIC_VECTOR(6 downto 0);
	signal s_v1 : STD_LOGIC_VECTOR(6 downto 0);
	signal s_v2 : STD_LOGIC_VECTOR(6 downto 0);
	signal s_v3 : STD_LOGIC_VECTOR(6 downto 0);
	signal s_clear_char : STD_LOGIC;
	signal s_data_ready : STD_LOGIC;
	
	signal s_read_char : STD_LOGIC_VECTOR (7 downto 0);	
	--Para snake
	signal contador_ciclos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";		
   signal contador_milisegundos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
	
	--**********NEW*******
	signal s_key_intr		: STD_LOGIC;
	signal s_ps2_intr		: STD_LOGIC;
	signal s_switch_intr  : STD_LOGIC;
	signal s_timer_intr	: STD_LOGIC;
	
	signal s_key_inta		: STD_LOGIC;
	signal s_ps2_inta		: STD_LOGIC;
	signal s_switch_inta  : STD_LOGIC;
	signal s_timer_inta	: STD_LOGIC;
	
	signal s_keys : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal s_sw : STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal s_iid : STD_LOGIC_VECTOR (7 DOWNTO 0);

	
BEGIN
		 
	tmr:timer
   port map (boot => boot,
				inta 		=> s_timer_inta,
				CLOCK_50 => CLOCK_50,
				intr		=> s_timer_intr);
	k0:pulsadores
	port map (boot => boot,
				clk   => CLOCK_50,
				inta 	=> s_key_inta,
				keys 	=> keys,
				intr	=> s_key_intr,
				read_key => s_keys);
				
	 sw:interruptores
	 port map  (boot => boot,
					clk   => CLOCK_50,
					inta 	=> s_switch_inta,
					switches => switch,
					intr	=> s_switch_intr,
					rd_switch => s_sw);
			
	kb:keyboard_controller_intr
	port map( clear_char => s_clear_char,
				 clk => CLOCK_50,
				 inta => s_ps2_inta,
				 reset => boot,
				 ps2_clk => ps2_clk, 
				 ps2_data => ps2_data,
				 data_ready  => s_data_ready,
				 intr => s_ps2_intr,
				 read_char => s_read_char);
				 
	i_c:interrupt_controller
	PORT map (boot => boot,
				clk	=> CLOCK_50,
				inta	=> inta,
				key_intr => s_key_intr,
				ps2_intr	 => s_ps2_intr,
				switch_intr	=> s_switch_intr,
				timer_intr	=> s_timer_intr,
				intr	=> intr,		
				key_inta => s_key_inta,
				ps2_inta	 => s_ps2_inta,
				switch_inta	=> s_switch_inta,
				timer_inta	=> s_timer_inta,	
				iid	=> s_iid);	 
		 
	led_verdes <= puertos(5)(7 downto 0);
	led_rojos <= puertos(6)(7 downto 0);
	rd_io <= puertos(conv_integer(addr_io));
	visor0 <= s_v0 when puertos(9)(0) = '1' else "1111111";
	visor1 <= s_v1 when puertos(9)(1) = '1' else "1111111";
	visor2 <= s_v2 when puertos(9)(2) = '1' else "1111111";
	visor3 <= s_v3 when puertos(9)(3) = '1' else "1111111";
	
	d0:driver7segments
	port map (input => puertos(10)(3 downto 0),
				 HEX => s_v0);	 
	d1:driver7segments
	port map (input => puertos(10)(7 downto 4),
				 HEX => s_v1);
	d2:driver7segments
	port map (input => puertos(10)(11 downto 8),
				 HEX => s_v2);
	d3:driver7segments
	port map (input => puertos(10)(15 downto 12),
				 HEX => s_v3);
				
   vga_cursor <= puertos(11);
	vga_cursor_enable <= puertos(12)(0);
	
	PROCESS (CLOCK_50)	
	BEGIN
		if rising_edge(CLOCK_50) then
		   if s_clear_char = '1' then 
				s_clear_char <= '0';
			end if;
			if wr_out = '1' then
				if addr_io = X"10" then  -- si escribe en puerto 16
						s_clear_char <= '1'; --hacemos clear del teclado
				elsif addr_io = X"15" then 
					contador_milisegundos <= wr_io;
				elsif not(addr_io = X"7" or addr_io = X"8" or  addr_io = X"F" or addr_io = X"14" or addr_io = X"2B") then -- escribe cualquier puerto excepto los de solo read
					puertos(conv_integer(addr_io))<=wr_io;
				
				end if;
			end if;
			puertos(7)(3 downto 0) <= s_keys;
			puertos(8)(7 downto 0) <= switch;
			puertos(15)(7 downto 0) <= s_read_char;
			puertos(16) <= X"000" & "000" & s_data_ready;
			--GETIID
			puertos(43)(7 downto 0) <= s_iid;
			
			--para snake
			puertos(20) <= contador_ciclos;
			puertos(21) <= contador_milisegundos;
			
			if contador_ciclos=0 then
				contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
				if contador_milisegundos>0 then
					contador_milisegundos <= contador_milisegundos-1;
				end if;
			else
				contador_ciclos <= contador_ciclos-1;
			end if;
			
		end if;
	end process;
END Structure; 