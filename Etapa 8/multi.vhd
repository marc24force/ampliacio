library ieee;
USE ieee.std_logic_1164.all;

entity multi is
    port(clk       : IN  STD_LOGIC;
         boot      : IN  STD_LOGIC;
         ldpc_l    : IN  STD_LOGIC;
         wrd_l     : IN  STD_LOGIC;
			wrd_simd_l: IN  STD_LOGIC;
			simd_mem_l: IN  STD_LOGIC;
         wr_m_l    : IN  STD_LOGIC;
         w_b       : IN  STD_LOGIC;
			intr_enabled :IN  STD_LOGIC;
			intr_l	 :IN  STD_LOGIC;
			d_sys_l		:IN  STD_LOGIC;
			a_sys_l		:IN  STD_LOGIC;
			sys_state : OUT STD_LOGIC; 
         ldpc      : OUT STD_LOGIC;
         wrd       : OUT STD_LOGIC;
			wrd_simd  : OUT STD_LOGIC;
			simd_mem  : OUT STD_LOGIC;
 			second_acces: out    std_logic; --es new
         wr_m      : OUT STD_LOGIC;
         ldir      : OUT STD_LOGIC;
         ins_dad   : OUT STD_LOGIC;
			d_sys		:OUT  STD_LOGIC;
			a_sys		:OUT  STD_LOGIC;
         word_byte : OUT STD_LOGIC);
end entity;

architecture Structure of multi is
	 type state_type is (F, DEMW, SYSTEM, SIMD_SEC_ACCS);
	 signal state   : state_type;


begin
	-- Logic to advance to the next state
	process (clk, boot)
	begin
		if boot = '1' then
			state <= F;
		elsif (rising_edge(clk)) then
			case state is
				when F => 
					state <= DEMW;
				when DEMW =>
				   if intr_l = '1' then
						state <= SYSTEM;
					elsif simd_mem_l = '1' then
					   state <= SIMD_SEC_ACCS;
				   else
						state <= F;
					end if;
				when SIMD_SEC_ACCS =>
				   if intr_l = '1' then
						state <= SYSTEM;
					else 
						state <= F;
					end if;
				when others =>
				      state <= F;
			end case;
		end if;
	end process;

	ldpc <= ldpc_l when state=DEMW or state = SYSTEM else 
			 '0';
			 
	wrd  <= wrd_l when state=DEMW else 
			 '0';
	
	wrd_simd  <= wrd_simd_l when state=DEMW or state = SIMD_SEC_ACCS else 
			 '0';
	
	simd_mem <= simd_mem_l when state = DEMW or state = SIMD_SEC_ACCS else
			  '0';
			 
	d_sys  <= d_sys_l when state=DEMW else 
			 '0';
			 
	a_sys  <= a_sys_l when state=DEMW else 
			 '0';
			 
	wr_m <= wr_m_l when state=DEMW or state = SIMD_SEC_ACCS else 
			 '0';
	
	ldir  <= '0' when state=DEMW  or state = SYSTEM or state = SIMD_SEC_ACCS else 
			   '1';
	
	ins_dad  <= '1' when state=DEMW or state = SIMD_SEC_ACCS else 
			      '0';
	
	word_byte  <= w_b when state=DEMW else 
					 '0';
	
	sys_state <= '1' when state=SYSTEM else 
					 '0';

	second_acces <= '1' when state = SIMD_SEC_ACCS else 
						 '0';
end Structure;
