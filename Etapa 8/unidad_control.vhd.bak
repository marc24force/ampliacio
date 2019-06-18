LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY unidad_control IS
    PORT (boot     : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 z		     : IN  STD_LOGIC; 						   
			 aluout	  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 inter 	  : IN  STD_LOGIC;
          intr_enabled :IN  STD_LOGIC;
			 no_impl   : OUT STD_LOGIC;
			 inst_prohibida : OUT STD_LOGIC;
			 is_calls  : OUT STd_logic; 
			 tlb_we    : OUT STd_LOGIC;-- permiso escritura
			 wr_phy    : OUT std_logic;-- indica si escritura fisica (1) o virtual (0)
			 flush     : OUT std_logic;-- indica si hay que hacer flush
			 is_tlb_data: out std_LOGIC; --1 if it is tlb data
			 acces_mem : OUT STD_LOGIC;
			 mem_ld_st : OUT STD_LOGIC;
			 sys_state : OUT STD_Logic; 
			 intr_ack  : OUT STD_LOGIC; 
			 d_sys 	  : OUT  STD_LOGIC;
			 a_sys 	  : OUT  STD_LOGIC;
          op        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 codigo    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 intr_ctrl : OUT STD_LOGIC_VECTor(2 DOWNTO 0); 
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 pcup		  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad   : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);  
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 addr_io   : OUT std_logic_vector(7 downto 0);
			 wr_out 	  : OUT std_logic;							
			 rd_in 	  : OUT std_logic);
END unidad_control;


ARCHITECTURE Structure OF unidad_control IS

component control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
	 		 z			  : IN  STD_LOGIC;
			 d_sys 	  : OUT  STD_LOGIC;
			 a_sys 	  : OUT  STD_LOGIC;
          op        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 codigo    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 intr_ctrl : OUT STD_LOGIC_VECTor(2 DOWNTO 0); 
			 intr_ack  : OUT STD_LOGIC; 
			 sys_state : IN STD_LOGIC; 
			 no_impl   : OUT STD_LOGIC;
			 inst_prohibida : OUT STD_LOGIC; 
			 is_calls  : OUT STd_logic;
			 tlb_we    : OUT STd_LOGIC;-- permiso escritura
			 wr_phy    : OUT std_logic;-- indica si escritura fisica (1) o virtual (0)
			 flush     : OUT std_logic;-- indica si hay que hacer flush
			 is_tlb_data: out std_LOGIC; --1 if it is tlb data
			 acces_mem : OUT STD_LOGIC; 
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTor(1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
			 tknbr 	  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          word_byte : OUT STD_LOGIC;
			 addr_io   : OUT std_logic_vector(7 downto 0);
			 wr_out 	  : OUT std_logic;							
			 rd_in 	  : OUT std_logic);
END component;

component multi is
    port(clk       : IN  STD_LOGIC;
         boot      : IN  STD_LOGIC;
         ldpc_l    : IN  STD_LOGIC;
         wrd_l     : IN  STD_LOGIC;
         wr_m_l    : IN  STD_LOGIC;
         w_b       : IN  STD_LOGIC;
			intr_enabled :IN  STD_LOGIC;
			intr_l	 :IN  STD_LOGIC;
			d_sys_l		:IN  STD_LOGIC;
			a_sys_l		:IN  STD_LOGIC;
			sys_state : OUT STD_LOGIC; 
         ldpc      : OUT STD_LOGIC;
         wrd       : OUT STD_LOGIC;
         wr_m      : OUT STD_LOGIC;
         ldir      : OUT STD_LOGIC;
         ins_dad   : OUT STD_LOGIC;
			d_sys		:OUT  STD_LOGIC;
			a_sys		:OUT  STD_LOGIC;
         word_byte : OUT STD_LOGIC);
end component;
 
signal ld_pc :std_logic;
signal next_pc :STD_LOGIC_VECTOR(15 DOWNTO 0) := x"C000";
signal previous_ir : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
 
signal immed_m       : STD_LOGIC_VECTOR(15 DOWNTO 0); -- immed salido de control_l
signal ldpc_m      : STD_LOGIC;
signal wrd_m       : STD_LOGIC;
signal wr_m_m      : STD_LOGIC;
signal w_b_m       : STD_LOGIC;
signal ldir_m_out  : std_LOGIC;
signal tknbr 	  	 : STD_LOGIC_VECTOR (1 DOWNTO 0);
signal immed_shift : STD_LOGIC_VECTOR (15 DOWNTO 0);
signal s_d_sys		 : STD_LOGIC;
signal s_a_sys		 : STD_LOGIC;
signal s_sys_state : std_logic;
signal real_new_pc : STD_LOGIC_VECTOR(15 DOWNTO 0); -- pc real saliendo del mux tknbr
signal s_acces_mem : std_logic;

BEGIN
	logica_control:control_l
	port map( ir 	  => previous_ir,
			    z		  => z,
				 d_sys  => s_d_sys,
				 a_sys  => s_a_sys,
				 op	  => op,
				 codigo => codigo,
				 intr_ctrl => intr_ctrl,
				 intr_ack  => intr_ack,
				 sys_state => s_sys_state,
				 no_impl => no_impl,
				 inst_prohibida => inst_prohibida,
				 is_calls => is_calls,
				 tlb_we  => tlb_we,
				 wr_phy   => wr_phy,
				 flush    => flush,
				 is_tlb_data => is_tlb_data,
				 acces_mem => s_acces_mem,
				 ldpc   => ldpc_m,
				 wrd    => wrd_m,
				 addr_a => addr_a,
				 addr_b => addr_b,
				 addr_d => addr_d,
				 immed  => immed_m,
				 wr_m   => wr_m_m,
				 in_d   => in_d,
				 immed_x2  => immed_x2,
				 tknbr  => tknbr,
				 word_byte => w_b_m,
				 addr_io => addr_io,
				 wr_out 	=> wr_out,
			    rd_in   => rd_in);
				 
	multi_0:multi
	port map( clk => clk,
				 boot => boot,
				 ldpc_l => ldpc_m,
				 wrd_l  => wrd_m,
				 wr_m_l => wr_m_m,
				 w_b    => w_b_m,
				 intr_enabled => intr_enabled, 
				 intr_l => inter,
				 d_sys_l => s_d_sys,
				 a_sys_l => s_a_sys,
				 sys_state => s_sys_state,
				 ldpc   => ld_pc,
				 wrd    => wrd,
				 wr_m   => wr_m,
				 ldir   => ldir_m_out,
				 ins_dad  => ins_dad,
				 d_sys => d_sys,
				 a_sys => a_sys,
				 word_byte => word_byte);

	sys_state <= s_sys_state;
								
	with tknbr select
		real_new_pc	<= 	  next_pc + 2 						when "00", -- pc +2
								  next_pc + 2 + immed_shift 	when "01", -- bz or bnz
								  aluout		 						when "10", -- jxx and reti
								  next_pc + 2						when others; --caso default para futuras ampl.

							
							
	process (clk, boot) begin
		if rising_edge(clk) then
			if boot='1' then
				next_pc <= x"C000";
				previous_ir <= x"0000";
			else
				if ld_pc='1'then
					next_pc <= real_new_pc;
				end if;
			   if ldir_m_out = '1' then 	
					previous_ir <= datard_m;
				end if;

			end if;
		end if;
	end process;
	
	acces_mem <= s_acces_mem or ldir_m_out;
	mem_ld_st <= s_acces_mem and (not ldir_m_out);
	
	immed 		<= immed_m;		
	immed_shift	<= STD_LOGIC_VECTOR(shift_left(unsigned(immed_m), 1));
	
	pc 	<= next_pc;
	pcup 	<= next_pc + 2 when s_sys_state = '0' else
				next_pc; 
  
END Structure;	
	
	