LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY control_l IS
    PorT (ir        : IN  STD_LOGIC_VECTor(15 DOWNTO 0);
			 z			  : IN  STD_LOGIC;
			 d_sys 	  : OUT  STD_LOGIC;
			 a_sys 	  : OUT  STD_LOGIC;
          op        : OUT STD_LOGIC_VECTor(2 DOWNTO 0);
			 op_simd   : OUT STD_LOGIC_VECTor(2 DOWNTO 0);
          codigo    : OUT STD_LOGIC_VECTor(3 DOWNTO 0);
			 intr_ctrl : OUT STD_LOGIC_VECTor(2 DOWNTO 0); 
			 intr_ack  : OUT STD_LOGIC; 
			 sys_state : IN STD_LOGIC; 
			 no_impl   : OUT STD_LOGIC;
			 inst_prohibida : OUT STD_LOGIC; 
			 is_calls  : OUT STd_logic;
			 
			 tlb_we    : OUT STd_LOGIC; 							-- permiso escritura
			 wr_phy    : OUT std_logic;							-- indica si escritura fisica (1) o virtual (0)
			 flush     : OUT std_logic; 							-- indica si hay que hacer flush
			 is_tlb_data: out std_LOGIC; --1 if it is tlb data
			 acces_mem : OUT STD_LOGIC; 
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
			 wrd_simd  : OUT STD_LOGIC; -- new indica permiso escritura en br simd
          addr_a    : OUT STD_LOGIC_VECTor(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTor(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTor(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTor(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTor(2 DOWNTO 0); --added 1 bit
			 in_d_simd : OUT STD_LOGIC_VECTor(1 DOWNTO 0); -- new indica la fuente del registro d simd
          immed_x2  : OUT STD_LOGIC;
			 tknbr 	  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          word_byte : OUT STD_LOGIC;
			 addr_io   : OUT std_logic_vector(7 downto 0);
			 wr_out 	  : OUT std_logic;						 
			 rd_in 	  : OUT std_logic);						 
END control_l;



ARCHITECTURE Structure OF control_l IS


constant AL   : STD_LOGIC_VECTor(3 downto 0):="0000";
constant CMPL : STD_LOGIC_VECTor(3 downto 0):="0001";
constant ADDI : STD_LOGIC_VECTor(3 downto 0):="0010";
constant LD   : STD_LOGIC_VECTor(3 downto 0):="0011";
constant ST   : STD_LOGIC_VECTor(3 downto 0):="0100";
constant MOV  : STD_LOGIC_VECTor(3 downto 0):="0101";
constant BR   : STD_LOGIC_VECTor(3 downto 0):="0110";
	constant BZ   : STD_LOGIC := '0';
	constant BNZ  : STD_LOGIC := '1';
constant IO   : STD_LOGIC_VECTor(3 downto 0):="0111";
	constant INPUT  : STD_LOGIC := '0';
	constant OUTPUT : STD_LOGIC := '1';
constant EX_AL: STD_LOGIC_VECTor(3 downto 0):="1000";
constant AL_SIMD: STD_LOGIC_VECTor(3 downto 0):="1001";
	constant ADDS: STD_LOGIC_VECTOR := "000";
	constant SUBS : STD_LOGIC_VECTOR := "001";
	constant ANDS: STD_LOGIC_VECTOR := "010";
	constant ORS: STD_LOGIC_VECTOR := "011";
	constant XORS : STD_LOGIC_VECTOR := "100";
	constant NOTS : STD_LOGIC_VECTOR := "101";
	constant MOVRS: STD_LOGIC_VECTor(2 downto 0):="110";
	constant MOVSR: STD_LOGIC_VECTor(2 downto 0):="111";
constant JXX  : STD_LOGIC_VECTor(3 downto 0):="1010";
	constant JZ   : STD_LOGIC_VECTor(2 downto 0):="000";
	constant JNZ  : STD_LOGIC_VECTor(2 downto 0):="001";
	constant JMP  : STD_LOGIC_VECTor(2 downto 0):="011";
	constant JAL  : STD_LOGIC_VECTor(2 downto 0):="100";
	constant CALLS: STD_LOGIC_VECTor(2 downto 0):="111";
constant EMPTY_2: STD_LOGIC_VECTor(3 downto 0):="1011";
constant EMPTY_3: STD_LOGIC_VECTor(3 downto 0):="1100";
constant LDB  : STD_LOGIC_VECTor(3 downto 0):="1101";
constant STB  : STD_LOGIC_VECTor(3 downto 0):="1110";
constant ESP  : STD_LOGIC_VECTOR(3 downto 0):="1111";
	constant EI   : STD_LOGIC_VECTOR(5 downto 0):="100000";
	constant DI   : STD_LOGIC_VECTOR(5 downto 0):="100001";
	constant RETI : STD_LOGIC_VECTOR(5 downto 0):="100100";
	constant GETIID : STD_LOGIC_VECTOR(5 downto 0) := "101000";
	constant RDS  : STD_LOGIC_VECTOR(5 downto 0):="101100";
	constant WRS  : STD_LOGIC_VECTOR(5 downto 0):="110000";
	constant WRPI  : STD_LOGIC_VECTOR(5 downto 0):="110100";--new
	constant WRVI  : STD_LOGIC_VECTOR(5 downto 0):="110101";--new
	constant WRPD  : STD_LOGIC_VECTOR(5 downto 0):="110110";--new
	constant WRVD  : STD_LOGIC_VECTOR(5 downto 0):="110111";--new
	constant FLUSH_I: STD_LOGIC_VECTOR(5 downto 0):="111000";--new
	constant HALT : STD_LOGIC_VECTOR(5 downto 0):="111111";
-- signals
signal codigo_op : std_LOGIC_VECTor(3 downto 0);
signal op_func : std_LOGIC_VECTor(2 downto 0);
signal s_op_simd : std_LOGIC_VECTor(2 downto 0);
signal esp_func : std_LOGIC_VECTor(5 downto 0);
signal jxx_func : std_LOGIC_VECTor(2 downto 0);
signal br_func : std_logic;
signal io_func : std_logic;

BEGIN
	 codigo_op <= JXX when sys_state = '1' else 
					  ir(15 downto 12) ;
					  
	 op_func <= ir(5 downto 3);
	 
	 s_op_simd <= ir(5 downto 3);
	 op_simd <= s_op_simd;
	 
	 esp_func <= ir(5 downto 0);
	 jxx_func <= JMP when sys_state = '1' else 
					 ir(2 downto 0);
	 br_func <= ir(8);
	 io_func <= ir(8);
	 
	 no_impl <= '1' when codigo_op = EMPTY_2 or codigo_op = EMPTY_3 else
				   '0';
	
	 inst_prohibida <= '1' when (codigo_op = ESP and esp_func /= HALT) else  --canviar a todas las esp_func
							 '0';
	 
	 is_calls <= '1' when (codigo_op= JXX and jxx_func = CALLS) else '0';
	 
	
	 addr_io   <=  x"2b" when (codigo_op = ESP and esp_func = GETIID) else --cuando es un getiid leemos puerto 2b
						ir(7 downto 0); 
	 
	 wr_out <= ir(8) when codigo_op=IO else '0';
	 
	 rd_in <= not ir(8) when codigo_op = IO else
				 '1' when(codigo_op = ESP and esp_func = GETIID) else 
				 '0';
				 
	tlb_we <= '1' when codigo_op = ESP and (esp_func = WRPI or esp_func = WRVI or esp_func = WRPD or 
														esp_func = WRVD) 						else
					'0';
	wr_phy <= '1' when codigo_op = ESP and (esp_func = WRPI or esp_func = WRPD) else 
				 '0';
	flush <= '1' when codigo_op = ESP and esp_func = FLUSH_I else 
				 '0'; 
	is_tlb_data <= '1' when codigo_op = ESP and (esp_func = WRVD or esp_func = WRPD)	else		
						'0';

				 
	 with codigo_op select
	 op		  <= "00"&ir(8) when MOV,
				     op_func when AL,
					  op_func when EX_AL,
					  op_func when CMPL,
					  "100" when others; -- stores y addi
					  
	 codigo <= codigo_op;
	 
	 d_sys <= '1' when (codigo_op=ESP and esp_func = WRS) else '0';
	 a_sys <= '1' when (codigo_op=ESP and esp_func = RDS) else '0';	
	 
	 intr_ctrl <=   "100" when sys_state = '1' else  --servimos una intr
						 "001" when (codigo_op=ESP and esp_func = EI) else  --enable interrupt
						 "010" when (codigo_op=ESP and esp_func = DI) else --disable interrupt
						 "011" when (codigo_op=ESP and esp_func = RETI) else --return from interrupt
						 "000";	--nothing
						 
	 intr_ack <= '1' when (codigo_op = ESP and esp_func = GETIID) else '0';
						 
	 ldpc 	  <= '0' when (codigo_op=ESP and esp_func = HALT) else '1'; 
	 
	 wrd 		  <= '0' when (codigo_op=ESP and (esp_func = HALT or esp_func = WRS or esp_func = EI or esp_func = DI or esp_func = RETI 
									or esp_func = WRPI  or esp_func = WRVI  or esp_func = WRPD or esp_func = WRVD  or esp_func = FLUSH_I )) or
								  codigo_op=STB or codigo_op=ST or
								  (codigo_op = JXX and (jxx_func = JZ or jxx_func = JNZ or jxx_func = JMP)) or
								  codigo_op = BR or 
								  (codigo_op = AL_SIMD and s_op_simd /= MOVSR) or --En el caso move de simd a reg permiso wrd 
								  (codigo_op = IO and io_func = OUTPUT) else
					  '1'; --Puede escribir en el banco de registros
					  
	-- Controlamos cuando se puede escribir en el banco simd
	 wrd_simd   <= '1' when (codigo_op = AL_SIMD and s_op_simd /= MOVSR) else 
						'0';
		
	 addr_a    <= ir(11 downto 9) when codigo_op=MOV else
					  ir(8 downto 6);
					  
	-- En el caso movrs y movsr indica la posicion del word en el registro simd
	 addr_b    <= ir(2 downto 0) when (codigo_op=AL or codigo_op=EX_AL or codigo_op=CMPL or codigo_op = AL_SIMD) else
					ir(11 downto 9);
	 
	 addr_d 	  <= ir(11 downto 9);
					  
	 
	 immed 	  <= std_logic_vector(resize(signed(ir(7 downto 0)),immed'length)) when codigo_op = MOV or
																												codigo_op = BR  or 
																												codigo_op = IO  else
					  std_logic_vector(resize(signed(ir(5 downto 0)),immed'length));
						
	 wr_m 	  <= '1' when codigo_op=ST or codigo_op=STB else
					  '0';
					  
	 acces_mem <= '1' when codigo_op=ST or codigo_op = LD or
								  codigo_op=STB or codigo_op=LDB else
					  '0';
					  
	 in_d 	  <= "001" when codigo_op=LD or codigo_op=LDB else
					  "010" when codigo_op = JXX and jxx_func = JAL else
					  "011" when codigo_op = IO or (codigo_op = ESP and esp_func = GETIID) else
				     "100" when codigo_op = AL_SIMD else 
					  "000";
					  
	 in_d_simd <= "01" when codigo_op = AL_SIMD and s_op_simd = MOVRS else --registro d(simd) viene de br normal
					  --"10" when op_simd = Registro d viene de memoria
						"00"; -- registro d viene de la alu (simd)
				
	 tknbr <= "10" when (codigo_op = JXX and jxx_func = JZ  and z = '1') or
							  (codigo_op = JXX and jxx_func = JNZ and z = '0') or
							  (codigo_op = JXX and jxx_func = JMP) 			   or 
							  (codigo_op = JXX and jxx_func = JAL) 				or 
							  (codigo_op = ESP and esp_func = RETI)            else
							 
				 "01" when (codigo_op = BR and br_func = BZ  and z = '1') or
							  (codigo_op = BR and br_func = BNZ and z = '0') else
							 
				 "00";

   immed_x2 	  <= '1' when 	codigo_op = LD or 
										codigo_op = ST or
										codigo_op = BR else
						  '0';
						  
	
							
	 
	word_byte<= '1' when codigo_op=LDB or codigo_op=STB else
					'0';
	 


END Structure;