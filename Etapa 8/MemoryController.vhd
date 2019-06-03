library ieee;
use ieee.std_logic_1164.all;

entity MemoryController is
    port (CLOCK_50  : in  std_logic;
	       addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
 			 simd_mem  : in STD_LOGIC; -- oussama dice que es new
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
			 --SIMD
			 simd_readed: OUT STD_LOGIC_VECTOR(127 DOWNTO 0); -- este si que es nuevo (MARC)
			 simd_toWrite: IN STD_LOGIC_VECTOR(127 DOWNTO 0); -- este tambien
			 --VGA
			 vga_addr          : out std_logic_vector(12 downto 0);
          vga_we            : out std_logic;
          vga_wr_data       : out std_logic_vector(15 downto 0);
          vga_rd_data       : in std_logic_vector(15 downto 0);
          vga_byte_m        : out std_logic);
end MemoryController;

architecture comportament of MemoryController is

component SRAMController is
    port (clk         : in    std_logic;
          -- señales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          -- señales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic;
          byte_m      : in    std_logic := '0');

end component;

component SRAM_SIMDController is
    port (clk         : in    std_logic;
          -- señales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          -- señales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(127 downto 0);
          dataToWrite : in    std_logic_vector(127 downto 0);
          WR          : in    std_logic);
end component;

-- Signals diferncia entre memoria simd y normal
signal s_SRAM_ADDR   : std_logic_vector(17 downto 0);
signal s_SRAM_DQ     : std_logic_vector(15 downto 0);
signal s_SRAM_UB_N   : std_logic;
signal s_SRAM_LB_N   : std_logic;
signal s_SRAM_CE_N   : std_logic;
signal s_SRAM_OE_N   : std_logic;
signal s_SRAM_WE_N   : std_logic;

signal simd_SRAM_ADDR   : std_logic_vector(17 downto 0);
signal simd_SRAM_DQ     : std_logic_vector(15 downto 0);
signal simd_SRAM_UB_N   : std_logic;
signal simd_SRAM_LB_N   : std_logic;
signal simd_SRAM_CE_N   : std_logic;
signal simd_SRAM_OE_N   : std_logic;
signal simd_SRAM_WE_N   : std_logic;

constant limit_mem : std_logic_vector(15 downto 0) := X"C000";
signal we_aux : std_logic;
signal simd_we : std_logic;
constant vga_min : std_logic_vector (15 downto 0) := X"A000";
constant vga_max : std_logic_vector (15 downto 0) := X"BFFF"; --b2BE"
signal aux_read : std_logic_vector(15 downto 0); 

begin
   sram_ctrl: SRAMController
	port map (clk        => CLOCK_50,
				 -- señales para la placa de desarrollo
				 SRAM_ADDR  => s_SRAM_ADDR, 
				 SRAM_DQ    => s_SRAM_DQ, 
				 SRAM_UB_N  => s_SRAM_UB_N,
				 SRAM_LB_N  => s_SRAM_LB_N,
				 SRAM_CE_N  => s_SRAM_CE_N,
				 SRAM_OE_N  => s_SRAM_OE_N,
				 SRAM_WE_N  => s_SRAM_WE_N,
				 -- señales internas del procesador
				 address    => addr,
				 dataReaded => aux_read,
				 dataToWrite=> wr_data,
				 WR         => we_aux,
				 byte_m  	=> byte_m);
				 
	simd_sram : SRAM_SIMDController
	port map (clk        => CLOCK_50,
				 -- señales para la placa de desarrollo
				 SRAM_ADDR  => simd_SRAM_ADDR, 
				 SRAM_DQ    => simd_SRAM_DQ, 
				 SRAM_UB_N  => simd_SRAM_UB_N,
				 SRAM_LB_N  => simd_SRAM_LB_N,
				 SRAM_CE_N  => simd_SRAM_CE_N,
				 SRAM_OE_N  => simd_SRAM_OE_N,
				 SRAM_WE_N  => simd_SRAM_WE_N,
				 -- señales internas del procesador
				 address    => addr,
				 dataReaded => simd_readed,
				 dataToWrite=> simd_toWrite,
				 WR         => simd_we);
				 
	we_aux <= we when addr < limit_mem  and simd_mem = '0' else
				'0';
				
	
				
	rd_data <= vga_rd_data when addr >= vga_min and 
										 addr <= vga_max else
				aux_read;
	
	--SIMD	
	simd_we <= we when simd_mem = '1' else 
			   '0';
	--sram dq para escritura			
	SRAM_DQ <= s_SRAM_DQ when we_aux='1' else 
				  simd_SRAM_DQ when simd_we = '1' else 
				  (others=>'Z');
   --sram dq para lectura
	s_SRAM_DQ <= SRAM_DQ when we_aux = '0' else (others=>'Z');	
   simd_SRAM_DQ <= SRAM_DQ when simd_we = '0' else (others=>'Z');	
	
	SRAM_ADDR <= s_SRAM_ADDR when simd_mem = '0' else simd_SRAM_ADDR;
	SRAM_UB_N <= s_SRAM_UB_N when simd_mem = '0' else simd_SRAM_UB_N;
	SRAM_LB_N <= s_SRAM_LB_N when simd_mem = '0' else simd_SRAM_LB_N;
	SRAM_CE_N <= s_SRAM_CE_N when simd_mem = '0' else simd_SRAM_CE_N;
	SRAM_OE_N <= s_SRAM_OE_N when simd_mem = '0' else simd_SRAM_OE_N;
	SRAM_WE_N <= s_SRAM_WE_N when simd_mem = '0' else simd_SRAM_WE_N;
	
	--EXCP
	mem_unaligned <= '1' when byte_m = '0' and addr(0) = '1' else --escritura de word en posicion impar
						  '0'; -- otherwise
	
	
	mem_protegida <= '0' when addr >= vga_min and  --acceso a VGA
									  addr <= vga_max else
					     '1' when addr(15) = '1' else -- acceso a zona de memoria de sistema
						  '0';
						  
	--VGA
	vga_addr <= addr(12 downto 0);
	vga_we <= we when addr >= vga_min and 
							addr <= vga_max else
				'0';
				 
	vga_wr_data <= wr_data;
	vga_byte_m  <= byte_m;	
end comportament;
