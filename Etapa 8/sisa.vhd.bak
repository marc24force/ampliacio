LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
			 SW        : in std_logic_vector(9 downto 0);
			 KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
			 PS2_CLK : inout std_logic;
			 PS2_DAT : inout std_logic;
			 SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
        	 SRAM_WE_N : out   std_logic := '1';
			 HEX0 	  : OUT std_logic_vector(6 downto 0);
			 HEX1 	  : OUT std_logic_vector(6 downto 0);
			 HEX2 	  : OUT std_logic_vector(6 downto 0);
			 HEX3  	  : OUT std_logic_vector(6 downto 0);
			 LEDG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 LEDR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 VGA_R  : OUT STD_LOGIC_VECTOR (7 downto 0);
			 VGA_G  : OUT STD_LOGIC_VECTOR (7 downto 0);
			 VGA_B  : OUT STD_LOGIC_VECTOR (7 downto 0);
			 VGA_HS : OUT STD_LOGIC;
			 VGA_VS : OUT STD_LOGIC);
END sisa;

ARCHITECTURE Structure OF sisa IS

component MemoryController is
    port (CLOCK_50  : in  std_logic;
	      addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
          byte_m    : in  std_logic;
          -- señales para la placa de desarrollo
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
			 mem_unaligned : out std_logic;
			 mem_protegida : out std_logic; --new
			 --VGA
			 vga_addr          : out std_logic_vector(12 downto 0);
          vga_we            : out std_logic;
          vga_wr_data       : out std_logic_vector(15 downto 0);
          vga_rd_data       : in std_logic_vector(15 downto 0);
          vga_byte_m        : out std_logic);
end component;

component proc IS
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
          intr_enabled :OUT  STD_LOGIC; --
			 no_impl   : OUT STD_LOGIC;--
			 acces_mem : OUT STD_LOGIC; 
			 mem_ld_st : OUT STD_LOGIC; --
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
END component;

component controladores_IO IS
	PORT(boot : IN STD_LOGIC;
		CLOCK_50 : IN std_logic;
		addr_io : IN std_logic_vector(7 downto 0);
		wr_io : in std_logic_vector(15 downto 0);
		rd_io : out std_logic_vector(15 downto 0);
		wr_out : in std_logic;
		rd_in : in std_logic;
		keys : in std_logic_vector(3 downto 0);
		switch :in std_logic_vector(7 downto 0);
		inta	 : in STD_LOGIC;	
		intr	 : OUT STD_LOGIC; 
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
END component;

component modulo_excepciones IS
	PORT (clk 			  : IN STD_LOGIC;
			intr_enabled  : IN STD_LOGIC;
			no_impl 		  : IN STD_LOGIC;
			acces_mem	  : IN STD_LOGIC;
			mem_ld_st     : IN STD_LOGIC; 
			mem_unaligned : IN STD_LOGIC;
			mem_protegida : IN std_logic; 
			intr			  : IN STD_LOGIC;
			div_zero		  : IN STD_LOGIC;
			inst_prohibida : IN STD_LOGIC; 
			is_calls      : IN STd_logic; 
			miss_tlbd  : IN STd_logic; --n
			miss_tlbi  : IN STd_logic;--n
			pag_inv_d  : IN STd_logic;--n
		   pag_inv_i  : IN STd_logic;--n
			pag_read_only  : IN STd_logic;--n
			sys_mode      : IN STD_LOGIC; 
			code_excep	  : OUT STD_LOGIC_VECTOR (3 downto 0);
			excep 		  : OUT STD_LOGIC);
END component;

component vga_controller is
    port(clk_50mhz      : in  std_logic; -- system clock 				
         reset          : in  std_logic; -- system reset
         red_out        : out std_logic_vector(7 downto 0); -- vga red pixel value
         green_out      : out std_logic_vector(7 downto 0); -- vga green pixel value
         blue_out       : out std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_out : out std_logic; -- vga control 				
         vert_sync_out  : out std_logic; -- vga control 				
         --
         addr_vga          : in std_logic_vector(12 downto 0);
         we                : in std_logic;
         wr_data           : in std_logic_vector(15 downto 0);
         rd_data           : out std_logic_vector(15 downto 0);
         byte_m            : in std_logic;
         vga_cursor        : in std_logic_vector(15 downto 0);  -- simplemente lo ignoramos, este controlador no lo tiene implementado
         vga_cursor_enable : in std_logic);                     -- simplemente lo ignoramos, este controlador no lo tiene implementado
end component;



component genericClock IS
	 generic(original : integer);
	 PORT(clock: IN std_logic; 
			outClock: OUT STD_LOGIC);
END component;

signal s_pc       :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal clock625 : STD_LOGIC;
signal rd_mem : std_logic_vector(15 downto 0);
signal byte_w : std_logic;
signal wr_enable: std_logic;
signal addr_m_m :std_logic_vector(15 downto 0);
signal data_wr_m :std_logic_vector(15 downto 0);
signal s_addr_io : std_logic_vector(7 downto 0);
signal s_wr_io : std_logic_vector(15 downto 0);
signal s_rd_io : std_logic_vector(15 downto 0);
signal s_wr_out : std_logic;
signal s_rd_in : std_logic;
----
signal s_red_out        : std_logic_vector(7 downto 0);
signal s_green_out      : std_logic_vector(7 downto 0);
signal s_blue_out       : std_logic_vector(7 downto 0);
signal s_addr_vga       : std_logic_vector(12 downto 0);      
signal s_we             : std_logic;     
signal s_wr_data        : std_logic_vector(15 downto 0);
signal s_rd_data        : std_logic_vector(15 downto 0);
signal s_byte_m         : std_logic;
signal s_vga_cursor     : std_logic_vector(15 downto 0);
signal s_vga_cursor_enable : std_logic;
signal s_intr: STD_LOGIC :='0';
signal s_inta: STD_LOGIC :='0';

signal s_intr_enabled  :  STD_LOGIC;
signal s_no_impl 		  :  STD_LOGIC;
signal s_acces_mem	  :  STD_LOGIC;
signal s_mem_ld_st     :  STD_LOGIC;
signal s_mem_unaligned :  STD_LOGIC;
signal s_div_zero		  :  STD_LOGIC;
signal s_code_excep	  :  STD_LOGIC_VECTOR (3 downto 0);
signal s_excep 		  :  STD_LOGIC;
signal s_inst_prohibida : STD_LOGIC;
signal s_is_calls  :      STd_logic; 
signal s_mem_protegida : std_logic;--new 
signal s_sys_mode : STD_LOGIC; 

signal s_miss_tlbd  : STd_logic; --n
signal s_miss_tlbi  : STd_logic;--n
signal s_pag_inv_d  : STd_logic;--n
signal s_pag_inv_i  : STd_logic;--n
signal s_pag_read_only  : STd_logic;--n


BEGIN


clock : genericClock
	GENERIC MAP(original => 7)
	PORT MAP(clock => CLOCK_50,
				outClock => clock625);
				
	processador:proc
	PORT map (clk       => clock625,
				 boot      => SW(9),
				 datard_m  => rd_mem,
				 rd_io 	  => s_rd_io,
				 inter     => s_excep,
				 code_excep	=> s_code_excep,
				 inst_prohibida => s_inst_prohibida, 
				 is_calls  => s_is_calls, 
				 miss_tlbd => s_miss_tlbd,--new
				 miss_tlbi => s_miss_tlbi ,--new
				 pag_inv_d => s_pag_inv_d ,--new
				 pag_inv_i => s_pag_inv_i ,--new
				 pag_read_only => s_pag_read_only,--new
				 div_zero => s_div_zero,
				 sys_mode => s_sys_mode, 
				 intr_enabled => s_intr_enabled,
				 no_impl   => s_no_impl,
				 acces_mem => s_acces_mem,
				 mem_ld_st => s_mem_ld_st,
				 intr_ack  => s_inta,
				 addr_m    => addr_m_m,
				 addr_io   => s_addr_io,
				 wr_io 	  => s_wr_io,
				 wr_out 	  => s_wr_out,
				 rd_in 	  => s_rd_in,
				 data_wr   => data_wr_m,
				 wr_m      => wr_enable,
				 pc        => s_pc,
				 word_byte => byte_w);
				 
				 
	control_mem:MemoryController
port map (CLOCK_50  => CLOCK_50,
	       addr      => addr_m_m,
          wr_data   => data_wr_m,
          rd_data   => rd_mem,
          we        => wr_enable,
          byte_m    => byte_w,
          -- señales para la placa de desarrollo
          SRAM_ADDR  => SRAM_ADDR,
          SRAM_DQ    => SRAM_DQ,
          SRAM_UB_N  => SRAM_UB_N,
          SRAM_LB_N  => SRAM_LB_N,
          SRAM_CE_N  => SRAM_CE_N,
          SRAM_OE_N  => SRAM_OE_N,
          SRAM_WE_N  => SRAM_WE_N,
			 mem_unaligned => s_mem_unaligned,
			 mem_protegida => s_mem_protegida, --new
			 vga_addr => s_addr_vga,      
			 vga_we    =>   s_we,       
			 vga_wr_data =>  s_wr_data ,    
			 vga_rd_data => s_rd_data ,      
			 vga_byte_m =>   s_byte_m );
			 
	controlador_IO:controladores_IO
   PORT map(boot    => SW(9),
				CLOCK_50 => CLOCK_50,
				addr_io => s_addr_io,
				rd_io   => s_rd_io,
				wr_io   => data_wr_m,
				wr_out  => s_wr_out,
				rd_in   => s_rd_in,
				keys => KEY,
				switch => SW(7 downto 0),
				inta=> s_inta,
				intr=> s_intr,
				led_verdes => LEDG,
				led_rojos  => LEDR,
				visor0 => HEX0,
				visor1 => HEX1,
				visor2 => HEX2,
				visor3 => HEX3,
				vga_cursor => s_vga_cursor,   
				vga_cursor_enable => s_vga_cursor_enable,
				ps2_clk => PS2_CLK,
				ps2_data => PS2_DAT);
				
	excep_module:modulo_excepciones
	port map(clk => clock625,
			   intr_enabled  => s_intr_enabled,
				no_impl => s_no_impl,
				acces_mem => s_acces_mem,
				mem_ld_st => s_mem_ld_st,
				mem_unaligned => s_mem_unaligned,
				mem_protegida => s_mem_protegida, --new
				intr		=> s_intr,
				div_zero	=> s_div_zero,
				inst_prohibida => s_inst_prohibida,
				is_calls  => s_is_calls, 
				miss_tlbd => s_miss_tlbd, --new
				miss_tlbi => s_miss_tlbi ,--new
				pag_inv_d => s_pag_inv_d ,--new
				pag_inv_i => s_pag_inv_i ,--new
				pag_read_only => s_pag_read_only,--new
				sys_mode => s_sys_mode,
				code_excep	=> s_code_excep,
				excep =>s_excep);
	
	vga:vga_controller
	PORT map(clk_50mhz => CLOCK_50,   
				reset => SW(9),         
				red_out  =>   s_red_out,    
				green_out  =>   s_green_out ,
				blue_out  =>     s_blue_out,
				horiz_sync_out => VGA_HS,
		      vert_sync_out  => VGA_VS,
				addr_vga => s_addr_vga,      
				we    =>   s_we,       
				wr_data =>  s_wr_data ,    
				rd_data => s_rd_data ,      
				byte_m =>   s_byte_m ,    
				vga_cursor => s_vga_cursor,   
				vga_cursor_enable => s_vga_cursor_enable);
				
	VGA_R <= "0000" & s_red_out(3 downto 0);
	VGA_G <= "0000" & s_green_out(3 downto 0);
	VGA_B <= "0000" & s_blue_out(3 downto 0);
END Structure;