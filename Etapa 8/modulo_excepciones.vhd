LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY modulo_excepciones IS
	PORT (
		clk : IN STD_LOGIC;
		intr_enabled      : IN STD_LOGIC;
		no_impl 		: IN STD_LOGIC;
		acces_mem			: IN STD_LOGIC;
		mem_ld_st     : IN STD_LOGIC; 
		mem_unaligned 	: IN STD_LOGIC;
		mem_protegida : IN std_logic; --new
		intr					: IN STD_LOGIC;
		div_zero				: IN STD_LOGIC;
		inst_prohibida : IN STD_LOGIC; 
		is_calls  : IN STd_logic;
		miss_tlbd  : IN STd_logic; --n
		miss_tlbi  : IN STd_logic;--n
		pag_inv_d  : IN STd_logic;--n
		pag_inv_i  : IN STd_logic;--n
		pag_read_only  : IN STd_logic;--n
		sys_mode : IN STD_LOGIC;
		code_excep	: OUT STD_LOGIC_VECTOR (3 downto 0);
		excep : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE Structure OF modulo_excepciones IS


	constant INSTR_NO_IMPLEMENTADA: STD_LOGIC_VECTOR (3 downto 0) := "0000";
	constant MEMORIA_NO_ALINIADA	: STD_LOGIC_VECTOR (3 downto 0) := "0001";
	constant DIVISION_BY_ZERO		: STD_LOGIC_VECTOR (3 downto 0) := "0100";
	constant MISS_TLB_INS		   : STD_LOGIC_VECTOR (3 downto 0) := "0110";
	constant MISS_TLB_DATOS		   : STD_LOGIC_VECTOR (3 downto 0) := "0111";
	constant INV_PAG_TLB_INS		   : STD_LOGIC_VECTOR (3 downto 0) := "1000";
	constant INV_PAG_TLB_DATOS		   : STD_LOGIC_VECTOR (3 downto 0) := "1001";
	constant MEMORIA_PROTEGIDA_INS   : STD_LOGIC_VECTOR (3 downto 0) := "1010";
	constant MEMORIA_PROTEGIDA    : STD_LOGIC_VECTOR (3 downto 0) := "1011";
	constant READ_ONLY_PAG		   : STD_LOGIC_VECTOR (3 downto 0) := "1100";
	constant INSTR_PROTEGIDA      : STD_LOGIC_VECTOR (3 downto 0) := "1101";
	constant CALLS                : STD_LOGIC_VECTOR (3 downto 0) := "1110";
	constant INTERRUPT				: STD_LOGIC_VECTOR (3 downto 0) := "1111";

	signal unalignment : STD_LOGIC := '0';
	signal inter : STD_LOGIC := '0';
	signal s_MEMORIA_PROTEGIDA    : STD_LOGIC:= '0';
	signal s_INSTR_PROTEGIDA      : STD_LOGIC:= '0';
	
	signal s_MISS_TLB_INS		   : STD_LOGIC:= '0';
	signal s_MISS_TLB_DATOS		   : STD_LOGIC:= '0';
	signal s_INV_PAG_TLB_INS		   : STD_LOGIC:= '0';
	signal s_INV_PAG_TLB_DATOS		   : STD_LOGIC:= '0';
	signal s_MEMORIA_PROTEGIDA_INS   : STD_LOGIC:= '0';
	signal s_READ_ONLY_PAG  : STD_LOGIC;
	
	signal reg_excep : STD_LOGIC_VECTOR (12 downto 0):="0000000000000";


BEGIN

	inter <= (intr and intr_enabled);

	unalignment <= '0'; --(mem_unaligned and acces_mem);
	
	
	s_MEMORIA_PROTEGIDA <= ((not sys_mode) and mem_protegida and mem_ld_st );
	s_MEMORIA_PROTEGIDA_INS <= '0'; --((not sys_mode) and mem_protegida and (not mem_ld_st));
	s_INSTR_PROTEGIDA  <= '0'; --((not sys_mode) and inst_prohibida);
	
	s_MISS_TLB_INS <= '0'; --miss_tlbi;
	s_MISS_TLB_DATOS <= '0'; --miss_tlbd;
	s_INV_PAG_TLB_INS <= '0'; --pag_inv_i;
	s_INV_PAG_TLB_DATOS <= '0'; --pag_inv_d;
	s_READ_ONLY_PAG <= '0'; --pag_read_only;
	
	excep <= no_impl or unalignment or inter or div_zero or 
				s_MEMORIA_PROTEGIDA or s_INSTR_PROTEGIDA or is_calls or
				s_MEMORIA_PROTEGIDA_INS or s_MISS_TLB_INS or s_MISS_TLB_DATOS or
				s_INV_PAG_TLB_INS or s_INV_PAG_TLB_DATOS	or s_READ_ONLY_PAG;

	code_excep <= 		 MISS_TLB_INS          when reg_excep(12) = '1' else
							 MISS_TLB_DATOS        when reg_excep(11) = '1' else
							 INV_PAG_TLB_INS       when reg_excep(10) = '1' else
							 INV_PAG_TLB_DATOS     when reg_excep(9) = '1' else
							 READ_ONLY_PAG         when reg_excep(8) = '1' else
							 MEMORIA_PROTEGIDA_INS when reg_excep(7) = '1' else
							 MEMORIA_PROTEGIDA     when reg_excep(6) = '1' else
					       INSTR_PROTEGIDA       when reg_excep(5) = '1' else
							 CALLS                 when reg_excep(4) = '1' else
							 INSTR_NO_IMPLEMENTADA when reg_excep(3) = '1' else
							 MEMORIA_NO_ALINIADA	  when reg_excep(2) = '1' else
							 INTERRUPT			     when reg_excep(1) = '1' else
							 DIVISION_BY_ZERO		  when reg_excep(0) = '1' else
							 "0010";
							   
							 

	PROCESS (clk)
	BEGIN
	
		if rising_edge(clk) then 
			reg_excep <= s_MISS_TLB_INS & s_MISS_TLB_DATOS & s_INV_PAG_TLB_INS & s_INV_PAG_TLB_DATOS & 
							 s_READ_ONLY_PAG & s_MEMORIA_PROTEGIDA_INS & s_MEMORIA_PROTEGIDA & 
							 s_INSTR_PROTEGIDA & is_calls & no_impl & unalignment & inter & div_zero;
		end if;
	
	END PROCESS;
END Structure;