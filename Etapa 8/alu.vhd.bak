LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu IS
    PORT (x  		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 op 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
			 codigo	: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 intr_ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
			 z  		: OUT STD_LOGIC;
			 w  		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 div_zero: OUT STD_LOGIC); --new
END alu;


ARCHITECTURE Structure OF alu IS
	--movs
	constant MOV : STD_LOGIC_VECTOR := "0101";
	constant MOVI:STD_LOGIC_VECTOR := "000";
	constant MOVHI: STD_LOGIC_VECTOR := "001";
   --aritmeticologicas
	constant AL  : STD_LOGIC_VECTOR := "0000";
	constant AAND: STD_LOGIC_VECTOR := "000";
	constant AOR : STD_LOGIC_VECTOR := "001";
	constant AXOR: STD_LOGIC_VECTOR := "010";
	constant ANOT: STD_LOGIC_VECTOR := "011";
	constant ADD : STD_LOGIC_VECTOR := "100";
	constant SUB : STD_LOGIC_VECTOR := "101";
	constant SHA : STD_LOGIC_VECTOR := "110";
	constant SHL : STD_LOGIC_VECTOR := "111";
	--comparaciones
	constant CMPL : STD_LOGIC_VECTOR  := "0001";
	constant CMPLT: STD_LOGIC_VECTOR  := "000";
	constant CMPLE: STD_LOGIC_VECTOR  := "001";
	constant CMPLEQ: STD_LOGIC_VECTOR := "011";
	constant CMPLTU: STD_LOGIC_VECTOR := "100";
	constant CMPLEU: STD_LOGIC_VECTOR := "101";
	--addi
	constant ADDI  : STD_LOGIC_VECTOR := "0010";
   --extensiones aritmeticas
	constant EX_AL : STD_LOGIC_VECTOR  := "1000";
	constant MUL   : STD_LOGIC_VECTOR  := "000";
	constant MULH  : STD_LOGIC_VECTOR  := "001";
	constant MULHU : STD_LOGIC_VECTOR := "010";
	constant DIV   : STD_LOGIC_VECTOR := "100";
	constant DIVU  : STD_LOGIC_VECTOR := "101";
	--operaciones de memoria
	constant LD   : STD_LOGIC_VECTOR :="0011";
	constant ST   : STD_LOGIC_VECTOR :="0100";
	constant LDB  : STD_LOGIC_VECTOR :="1101";
	constant STB  : STD_LOGIC_VECTOR :="1110";
	--jump
	constant JXX : STD_LOGIC_VECTOR := "1010";
	constant ESP : STD_LOGIC_VECTOR := "1111";

	--signals
	signal al_res :STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal mov_res :STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal ex_al_res  :STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal cmpl_res :STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal esp_res : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	--aux
	signal pos_mem :STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal aux_cmp : boolean;
	signal sh_res  :STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal mul_res :STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal w_aux :STD_LOGIC_VECTOR(15 downto 0);
BEGIN

   -- select op
   with op select
	mov_res <= std_logic_vector(resize(signed(y(7 downto 0)),w'length)) when MOVI,
				  y(7 downto 0) & x(7 downto 0) when MOVHI,
			     X"DEAD" 						  	  when others;
				  
	with op select
	aux_cmp <= signed(x)<signed(y) when CMPLT,
				  signed(x)<=signed(y) when CMPLE,
				  signed(x)=signed(y) when CMPLEQ,
				  unsigned(x)<unsigned(y) when CMPLTU,
				  unsigned(x)<=unsigned(y) when others;
					
	cmpl_res <= "0000000000000001" when aux_cmp else (others=>'0');
					
					
	with op select
	al_res<=   x and y when AAND,
				   x or y  when AOR,
					x xor y when AXOR,
					not x   when ANOT,
				   std_logic_vector(signed(x)+signed(y))	when ADD,
					std_logic_vector(signed(x)-signed(y))	when SUB,
					sh_res when SHA,
					sh_res when SHL,
					X"DEAD" when others;
					
	pos_mem <=  std_logic_vector(signed(x)+signed(y));

	
	mul_res <=	std_logic_vector(signed(x)*signed(y))	when (op = MULH or op = MUL) else
				   std_logic_vector(unsigned(x)*unsigned(y)) when op = MULHU else
					X"DEADDEAD";
					
	with op select
	ex_al_res <= mul_res(15 downto 0) when MUL,
				    mul_res(31 downto 16) when MULH,
				    mul_res(31 downto 16) when MULHU,
					 std_logic_vector(signed(x)/signed(y)) when DIV,
					 std_logic_vector(unsigned(x)/unsigned(y)) when DIVU,
					 X"DEAD" when others;
					
	sh_res <= std_logic_vector(shift_right (signed(x), to_integer( unsigned (not y(4 downto 0))+1))) -- sha negativo
							when y(4) = '1' and op = SHA else 
				 std_logic_vector(shift_left (signed(x),  to_integer(unsigned (y(4 downto 0))))) --sha pos
							when y(4) = '0' and op = SHA else 	
				 std_logic_vector(shift_right (unsigned(x), to_integer( unsigned (not y(4 downto 0))+1))) --shl neg
							when y(4) = '1' and op = SHL else
				 std_logic_vector(shift_left (unsigned(x), to_integer(unsigned (y(4 downto 0))))) --shl pos
						   when y(4) = '0' and op = SHL else 
				 X"DEAD";
				 
	esp_res <= x when intr_ctrl = "000" else
				  y when intr_ctrl = "011" else 
				  x"DEAD";
	
	--select  opcode
	with codigo select
	w_aux <= al_res when AL,
				al_res when ADDI,
		      mov_res when MOV,
	         cmpl_res when CMPL,
		      ex_al_res when EX_AL,
				pos_mem when LD,
				pos_mem when LDB,
				pos_mem when ST,
				pos_mem when STB,
				x when JXX,
				esp_res when ESP,
		      X"DEAD"  when others;
			  
	z <= '1' when y = X"0000" else
		  '0';
	w<= w_aux;
	div_zero <= '1' when codigo=EX_AL and (op = DIV or op = DIVU) and y = x"0000" else
				  '0';
END Structure;