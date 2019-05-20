LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 d_sys  : IN  STD_LOGIC;
			 a_sys  : IN  STD_LOGIC;
			 inter  : IN  STD_LOGIC;
			 boot   : IN  STD_LOGIC;
			 PCup   : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
			 PC_miss   : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
			 intr_ctrl  : IN STD_LOGIC_VECTor(2 DOWNTO 0);
			 addr_m 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
			 code_excep	: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 intr_enabled : OUT STD_LOGIC;
 			 sys_mode : OUT STD_LOGIC; --new
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END regfile;


ARCHITECTURE Structure OF regfile IS
   type BANCO_REG is array (7 downto 0) of std_logic_vector(15 downto 0);
	signal registres      : BANCO_REG;
	signal sys_registres  : BANCO_REG;
	signal a_sys_reg : std_logic_vector(15 downto 0);
	constant S0 : integer := 0;
	constant S1 : integer := 1;
	constant S2 : integer := 2;
	constant S3 : integer := 3;
	constant S5 : integer := 5;
	constant S7 : integer := 7;
	constant MEMORIA_NO_ALINIADA : STD_LOGIC_VECTOR(3 downto 0):= "0001";
	constant MISS_TLB_INS		  : STD_LOGIC_VECTOR (3 downto 0) := "0110";
	constant MISS_TLB_DATOS		  : STD_LOGIC_VECTOR (3 downto 0) := "0111";
	constant CALLS : STD_LOGIC_VECTOR(3 downto 0):= "1110";

   
	signal s_pc : std_logic_vector(15 downto 0);
	signal s_addr_m : std_logic_vector(15 downto 0);
BEGIN
	PROCESS (clk,boot)	BEGIN
	   if boot = '1' then 
			sys_registres <= ((others => (others => '0')));
			 sys_registres(S7)(0) <= '1';
		elsif rising_edge(clk) then
			if wrd = '1' then
				registres(conv_integer(addr_d))<=d;
			end if;
			if d_sys = '1' then 
				sys_registres(conv_integer(addr_d))<=d;
			end if;
			--el primer bit indica que servimos intr
			if intr_ctrl = "100" then
	--			 S0 < S7 (se copia la palabra de estado PSW)
	--			 S1 < PCup (hace un backup del PC de retorno)
	--			 S2 < 0x000 & code_excep 
	--			 PC < S5 (rutina de sistema a la que se llama) *fuera del process
	--			 S7<1> < 0 (se cambia la PSW inhibiendo las interrupciones)
	--			 S7<0> < 1 (se cambia a modo sistema)	
	--			 S6 Contendrá el puntero a la pila de sistema, SSP, System Stack Pointer 
				 sys_registres(S0) 	<= sys_registres(S7);
				 sys_registres(S1)	<= PCup;
				 sys_registres(S2) 	<= X"000" & code_excep;
				 sys_registres(S7)(1) <= '0';
				 sys_registres(S7)(0) <= '1';
				 if code_excep = MEMORIA_NO_ALINIADA then
						sys_registres(S3)<= addr_m;
				 elsif code_excep = CALLS then
					   sys_registres(S3)<=registres(conv_integer(addr_a));
				 elsif code_excep = MISS_TLB_DATOS then
						sys_registres(S3) <= s_addr_m;
				 elsif  code_excep = MISS_TLB_INS then
						sys_registres(S3) <= PC_miss;
				 end if;
				 
			elsif intr_ctrl = "001" then sys_registres(S7)(1) <= '1';	
			elsif intr_ctrl = "010" then sys_registres(S7)(1) <= '0';	
			elsif intr_ctrl = "011" then --reti
				 sys_registres(S7) 	<= sys_registres(S0);
			end if;
		end if;
	end process;
	 
	a_sys_reg<=registres(conv_integer(addr_a)) when a_sys = '0' else
				  sys_registres(conv_integer(addr_a));
				  
	a <= a_sys_reg when inter = '0' else 
		  sys_registres(S5);
		  
	s_pc	<= sys_registres(S1);
	b<= s_pc when intr_ctrl = "011" else
		 registres(conv_integer(addr_b)) ;
		 
	intr_enabled <= sys_registres(S7)(1);
	sys_mode <= sys_registres(S7)(0);

END Structure;