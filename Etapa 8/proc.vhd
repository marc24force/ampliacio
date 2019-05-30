LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (clk       : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io 	  : IN std_logic_vector(15 downto 0); 
			 inter     : IN  STD_LOGIC; 
			 code_excep	: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 inst_prohibida : OUT STD_LOGIC; 
			 is_calls  : OUT STd_logic;
			 miss_tlbd : OUT STd_logic; --n
			 miss_tlbi  : OUT STd_logic;--n
			 pag_inv_d  : OUT STd_logic;--n
		    pag_inv_i  : OUT STd_logic;--n
			 pag_read_only  : OUT STd_logic;--n
			 sys_mode : OUT STD_LOGIC; 
			 div_zero : OUT STD_LOGIC;
          intr_enabled :OUT  STD_LOGIC; 
			 no_impl   : OUT STD_LOGIC;
			 acces_mem : OUT STD_LOGIC; 
			 mem_ld_st : OUT STD_LOGIC; 
			 intr_ack  : OUT  STD_LOGIC;
          addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_io   : OUT std_logic_vector(7 downto 0); 
			 wr_io 	  : OUT std_logic_vector(15 downto 0); 
			 wr_out 	  : OUT std_logic;							
			 rd_in 	  : OUT std_logic;							
          data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
			 pc        : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
          word_byte : OUT STD_LOGIC);
END proc;


ARCHITECTURE Structure OF proc IS

component datapath IS
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
			 sys_mode : OUT STD_LOGIC; --new
			 ---
			 intr_enabled: OUT STD_LOGIC; 
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 aluout	 : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 a        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 z        : OUT STD_LOGIC;								
          data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_io 	  : OUT std_logic_vector(15 downto 0));
END component;

component unidadSIMD IS
 PORT    (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 reg_16 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 boot   : IN  STD_LOGIC;
			 in_d   : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --nou
			 op_simd: IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- indica la operacion
			 out_simd: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)); --de momento solo saca los movsr (16b)
END component;

component unidad_control is
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
			 op_simd   : OUT STD_LOGIC_VECTor(2 DOWNTO 0); --new
			 codigo    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 intr_ctrl : OUT STD_LOGIC_VECTor(2 DOWNTO 0); 
          wrd       : OUT STD_LOGIC;
			 wrd_simd  : OUT STD_LOGIC; -- new indica permiso escritura en br simd
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 pcup		  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad   : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- +1 bit 
			 in_d_simd : OUT STD_LOGIC_VECTor(1 DOWNTO 0); -- new indica la fuente del registro d simd  
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 addr_io   : OUT std_logic_vector(7 downto 0);
			 wr_out 	  : OUT std_logic;							
			 rd_in 	  : OUT std_logic);
END component;

component tlb is --new
     PORT (clk       : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          
			 tag_in    : IN STD_LOGIC_vector (3 downto 0) ; -- tag virtual
			 tlb_we    : IN STd_LOGIC; 							-- permiso escritura
			 entrada   : IN STD_LOGIC_vector (3 downto 0);  -- entrada a modificar
			 data_in   : IN STD_LOGIC_vector (3 downto 0);  -- valor escrito en entrada en caso escritura
			 wr_phy    : in std_logic;								-- indica si escritura fisica (1) o virtual (0)
			 v_in      : in std_LOGIC; 							-- bit v en caso escritura fisica
			 r_in      : in std_LOGIC; 							-- bit r en caso escritura fisica
			 flush     : in std_logic; 							-- indica si hay que hacer flush
			 
			 tag_out   : out std_logic_vector (3 downto 0); -- tag fisico
			 v_out     : out std_logic;							-- bit v en lectura
			 r_out     : out std_logic; 							-- bit r en lectura
			 tlb_hit   : out std_logic);  						-- hit or miss 
END component;

signal s_op     :  STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_op_simd:  STD_LOGIC_VECTOR(2 DOWNTO 0); --new
signal s_codigo :  STD_LOGIC_VECTOR(3 DOWNTO 0);
signal s_wrd    :  STD_LOGIC;
signal s_wrd_simd:  STD_LOGIC; --new
signal s_addr_a :  STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_addr_b :  STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_addr_d :  STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_immed  :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal s_pc        : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal s_ins_dad   : STD_LOGIC;
signal s_in_d      : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_in_d_simd : STD_LOGIC_VECTOR(1 DOWNTO 0); --new
signal s_immed_x2  : STD_LOGIC;
signal s_z		    : STD_LOGIC; 	
signal s_aluout	 : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal s_pcup		 : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal s_out_simd_16: std_logic_vector(15 downto 0);

signal s_intr_ctrl : STD_LOGIC_VECTor(2 DOWNTO 0); 
signal s_intr_enabled : STD_LOGIC; 

signal s_d_sys : STD_LOGIC;
signal s_a_sys : STD_LOGIC;
signal s_sys_state : STD_Logic; 

signal s_tag_in_i   : std_logic_vector (3 downto 0);
signal s_tag_out_i   : std_logic_vector (3 downto 0);
signal s_tlb_we_i    :  STd_LOGIC; 							-- permiso escritura
signal s_entrada_i  :  STD_LOGIC_vector (3 downto 0);  -- entrada a modificar
signal s_data_in_i   :  STD_LOGIC_vector (3 downto 0);  -- valor escrito en entrada en caso escritura
signal s_wr_phy_i    :  std_logic;								-- indica si escritura fisica (1) o virtual (0)
signal s_v_in_i      :  std_LOGIC; 							-- bit v en caso escritura fisica
signal s_r_in_i     :  std_LOGIC; 							-- bit r en caso escritura fisica
signal s_flush_i     :  std_logic; 

signal s_v_out_i     :  std_logic;							-- bit v en lectura
signal s_r_out_i     :  std_logic; 							-- bit r en lectura
signal s_tlb_hit_i   :  std_logic;

signal s_tag_in_d   : std_logic_vector (3 downto 0);
signal s_tag_out_d   : std_logic_vector (3 downto 0);
signal s_tlb_we_d    :  STd_LOGIC; 							-- permiso escritura
signal s_entrada_d  :  STD_LOGIC_vector (3 downto 0);  -- entrada a modificar
signal s_data_in_d   :  STD_LOGIC_vector (3 downto 0);  -- valor escrito en entrada en caso escritura
signal s_wr_phy_d    :  std_logic;								-- indica si escritura fisica (1) o virtual (0)
signal s_v_in_d      :  std_LOGIC; 							-- bit v en caso escritura fisica
signal s_r_in_d     :  std_LOGIC; 							-- bit r en caso escritura fisica
signal s_flush_d     :  std_logic; 

signal s_v_out_d     :  std_logic;							-- bit v en lectura
signal s_r_out_d     :  std_logic; 							-- bit r en lectura
signal s_tlb_hit_d   :  std_logic;

signal s_addr_m_in  : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal s_addr_m_out  : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal s_wr_m : std_logic;
signal s_mem_ld_st : std_logic;

signal s_tlb_we    : STd_LOGIC;-- permiso escritura
signal s_wr_phy    :  std_logic;-- indica si escritura fisica (1) o virtual (0)
signal s_flush     :  std_logic;-- indica si hay que hacer flush
signal s_is_tlb_data:  std_LOGIC; --1 if it is tlb data

signal s_reg_a   :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal s_reg_b   :  STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN


	tlbi:tlb
	port map (boot   => boot,
				 clk    => clk,
				 
				 tag_in  => s_tag_in_i,
			    tlb_we  => s_tlb_we_i,
				 entrada   => s_entrada_i,
				 data_in   => s_data_in_i,
				 wr_phy   => s_wr_phy_i,
				 v_in     => s_v_in_i,
				 r_in     => s_r_in_i,
				 flush    => s_flush_i,
				 
				 tag_out  => s_tag_out_i,
				 v_out    => s_v_out_i,
				 r_out    => s_r_out_i,
				 tlb_hit  => s_tlb_hit_i
	);
	
	s_tlb_we_i <= s_tlb_we when s_is_tlb_data = '0' else '0';
	s_entrada_i <= s_reg_a(3 downto 0);
	s_data_in_i  <= s_reg_b(3 downto 0);
	s_wr_phy_i <= s_wr_phy;
	s_v_in_i <= s_reg_b(5);
	s_r_in_i <= s_reg_b(4);
	s_flush_i <= s_flush when s_is_tlb_data = '0' else '0';
	 
	 
	
	tlbd:tlb
	port map (boot   => boot,
				 clk    => clk,
				 
				 tag_in  => s_tag_in_d,
			    tlb_we  => s_tlb_we_d,
				 entrada   => s_entrada_d,
				 data_in   => s_data_in_d,
				 wr_phy   => s_wr_phy_d,
				 v_in     => s_v_in_d,
				 r_in     => s_r_in_d,
				 flush    => s_flush_d,
				 
				 tag_out  => s_tag_out_d,
				 v_out    => s_v_out_d,
				 r_out    => s_r_out_d,
				 tlb_hit  => s_tlb_hit_d
	);
	
	s_tlb_we_d <= s_tlb_we when s_is_tlb_data = '1' else '0';
	s_entrada_d <= s_reg_a(3 downto 0);
	s_data_in_d  <= s_reg_b(3 downto 0);
	s_wr_phy_d <= s_wr_phy;
	s_v_in_d <= s_reg_b(5);
	s_r_in_d <= s_reg_b(4);
	s_flush_d <= s_flush when s_is_tlb_data = '1' else '0';
	
	
	s_tag_in_d <= s_addr_m_in(15 downto 12);
	s_tag_in_i <= s_addr_m_in(15 downto 12);
	
   addr_m <= s_tag_out_d & s_addr_m_in(11 downto 0) when s_ins_dad = '1' else
				 s_tag_out_i & s_addr_m_in(11 downto 0);
									
	miss_tlbd <= (not s_tlb_hit_d) and s_ins_dad and s_mem_ld_st; 
   miss_tlbi <= (not s_tlb_hit_i) and (not s_ins_dad);
	pag_inv_d <= (not s_v_out_d) and s_ins_dad and s_mem_ld_st;
	pag_inv_i <= (not s_v_out_i) and (not s_ins_dad);
	
	pag_read_only <= s_r_out_d and s_ins_dad and s_wr_m and s_mem_ld_st;
	
	mem_ld_st <= s_mem_ld_st;
	wr_m <= s_wr_m;
	
-- la unidad de control le hemos llamado c0
	c0:unidad_control
	port map (boot   => boot,
				 clk    => clk,
				 datard_m => datard_m,
				 z		  => s_z,
				 aluout => s_aluout,
				 d_sys  => s_d_sys,
				 a_sys  => s_a_sys,
				 inter	=> inter,
				 intr_enabled => s_intr_enabled,
				 no_impl => no_impl,
				 inst_prohibida => inst_prohibida,
			    is_calls => is_calls,
				 tlb_we   => s_tlb_we,
			    wr_phy   => s_wr_phy,
			    flush    => s_flush,
			    is_tlb_data => s_is_tlb_data,
				 acces_mem => acces_mem,
				 mem_ld_st => s_mem_ld_st,
				 sys_state => s_sys_state,
				 intr_ack => intr_ack,
				 op     => s_op,
				 op_simd => s_op_simd,
				 codigo => s_codigo,
				 intr_ctrl => s_intr_ctrl,
				 wrd    => s_wrd,
				 wrd_simd => s_wrd_simd,
				 addr_a => s_addr_a,
				 addr_b => s_addr_b,
				 addr_d => s_addr_d,
				 immed  => s_immed,
				 pcup   => s_pcup,
				 pc     => s_pc,
				 ins_dad => s_ins_dad,
				 in_d      => s_in_d,
				 in_d_simd => s_in_d_simd,
				 immed_x2  => s_immed_x2,
				 wr_m      => s_wr_m,
				 word_byte => word_byte,
				 addr_io   => addr_io,
				 wr_out 	  => wr_out,
				 rd_in 	  => rd_in);
				 
	intr_enabled <= s_intr_enabled;
	
	simd:unidadSIMD
	PORT  map(clk => clk,
				 wrd => s_wrd_simd,
				 addr_a => s_addr_a,
				 addr_b => s_addr_b,
				 addr_d => s_addr_d,
				 reg_16 => s_reg_a,
				 boot => boot,
				 op_simd => s_op_simd,
				 in_d => s_in_d_simd,
				 out_simd => s_out_simd_16);
	
	-- En los esquemas de la documentacion a la instancia del DATAPATH le hemos llamado e0
	e0:datapath
	 port map(boot   => boot,
				 clk    => clk,
				 op     => s_op,
				 codigo => s_codigo,
				 intr_ctrl => s_intr_ctrl,
				 wrd    => s_wrd,
				 addr_a => s_addr_a,
				 addr_b => s_addr_b,
				 addr_d => s_addr_d,
				 immed  => s_immed,
				 immed_x2 => s_immed_x2,
				 datard_m => datard_m,
				 ins_dad  => s_ins_dad,
				 pcup     => s_pcup,
				 pc       => s_pc,
				 in_d     => s_in_d,
				 rd_io 	 => rd_io,
				 out_simd => s_out_simd_16,
				 d_sys  => s_d_sys,
				 a_sys  => s_a_sys,
				 inter	=> s_sys_state,
				 code_excep => code_excep,
				 div_zero => div_zero,
				 sys_mode => sys_mode,
				 intr_enabled => s_intr_enabled,
				 addr_m   => s_addr_m_in,
				 aluout => s_aluout,
				 a => s_reg_a,
				 b => s_reg_b,
				 z		  => s_z,
				 data_wr  => data_wr,
				 wr_io 	  => wr_io);

   pc<=s_pc;
    
	 

END Structure;