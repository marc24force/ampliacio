LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY datapath IS
 PORT (	 boot     : IN  STD_LOGIC;
			 clk      : IN  STD_LOGIC;
          op       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 codigo	 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			 intr_ctrl : IN STD_LOGIC_VECTor(2 DOWNTO 0); 
          wrd      : IN  STD_LOGIC;
          addr_a   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          immed_x2 : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad  : IN  STD_LOGIC;
			 pcup		 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
          pc       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          in_d     : IN  STD_LOGIC_VECTOR (2 DOWNTO 0); 
		    rd_io 	  : IN std_logic_vector(15 downto 0);
			 out_simd : IN std_logic_vector(15 downto 0);
			 d_sys  : IN  STD_LOGIC;
			 a_sys  : IN  STD_LOGIC;
			 inter  : IN  STD_LOGIC;
			 --EXCEPCIONS
			 code_excep	: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 div_zero : OUT STD_LOGIC; 
			 sys_mode : OUT STD_LOGIC; 
			 ---
			 intr_enabled: OUT STD_LOGIC; 
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 aluout	 : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 a        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 z        : OUT STD_LOGIC;								
          data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_io 	  : OUT std_logic_vector(15 downto 0));
END datapath;


ARCHITECTURE Structure OF datapath IS

 component regfile is 
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
			 sys_mode : OUT STD_LOGIC;
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END component;

component alu IS
    PORT (x  		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 op 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
			 codigo	: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 intr_ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
			 z  		: OUT STD_LOGIC;
			 w  		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 div_zero: OUT STD_LOGIC); 
END component;
--op_codes que NO tenen immed
constant AL   : STD_LOGIC_VECTOR(3 downto 0):="0000";
constant CMPL : STD_LOGIC_VECTOR(3 downto 0):="0001";
constant BR   : STD_LOGIC_VECTOR(3 downto 0):="0110";
constant IO   : STD_LOGIC_VECTOR(3 downto 0):="0111";
constant EX_AL: STD_LOGIC_VECTOR(3 downto 0):="1000";
constant JXX  : STD_LOGIC_VECTOR(3 downto 0):="1010";
constant ESP  : STD_LOGIC_VECTOR(3 downto 0):="1111";
	constant RDS  : STD_LOGIC_VECTOR(5 downto 0):="101100";
	constant WRS  : STD_LOGIC_VECTOR(5 downto 0):="110000";
	constant DI   : STD_LOGIC_VECTOR(5 downto 0):="100001";
	constant EI   : STD_LOGIC_VECTOR(5 downto 0):="100000";
	constant RETI : STD_LOGIC_VECTOR(5 downto 0):="100100";

--signal 
signal x 				: std_LOGIC_VECTOR(15 downto 0);
signal y 				: std_LOGIC_VECTOR(15 downto 0);
signal w 		   	: std_LOGIC_VECTOR(15 downto 0);
signal sig_immed		: std_LOGIC_VECTOR(15 downto 0);
signal input_REG 		: std_LOGIC_VECTOR(15 downto 0);
signal output_REG_b  : std_LOGIC_VECTOR(15 downto 0);
signal s_addr_m : std_LOGIC_VECTOR(15 downto 0);

BEGIN

    with in_d select
	 input_REG <= w        when "000",
					  datard_m when "001",
					  pcup     when "010",
					  rd_io	  when "011",
					  out_simd when "100",
					  x"DEAD" when others;
					 
    
    sig_immed <= immed when immed_x2 = '0' else
			std_logic_vector(shift_left(unsigned(immed),1));
	
	with codigo select		
	y <= output_REG_b when AL,
		  output_REG_b when EX_AL,
		  output_REG_b when CMPL,
		  output_REG_b when BR,
		  output_REG_b when JXX,
		  output_REG_b when ESP,
		  sig_immed when others;
		  
		  
	 s_addr_m <= pc when ins_dad = '0' else
				  w;
				  
	 addr_m <= s_addr_m;
	 a <= x;
	 b <= output_REG_b;
	banco_registros: regfile
		PORT map (clk    => clk,
					 wrd    => wrd,
					 d      => input_REG,
					 addr_a => addr_a,
					 addr_b => addr_b,
					 addr_d => addr_d,
					 d_sys  => d_sys,
					 a_sys => a_sys,
					 inter => inter,
					 boot  => boot,
					 PCup => pcup,
					 PC_miss => pc,
				    intr_ctrl => intr_ctrl,
					 addr_m => s_addr_m,
					 code_excep => code_excep,
					 intr_enabled => intr_enabled,
					 sys_mode => sys_mode,
					 a      => x,
					 b      => output_REG_b);
	
	data_wr<=output_REG_b;			 
	
	aluout <= w;
	 alu0 : alu
		PORT map (x  		=> x,
					 y 		=> y, 
					 op 		=> op,
					 codigo  => codigo,
					 intr_ctrl => intr_ctrl,
					 z 		=> z,
					 w  		=> w,
					 div_zero=> div_zero);
    

END Structure;