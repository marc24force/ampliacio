LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY unidadSIMD IS
 PORT    (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 reg_16 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 boot   : IN  STD_LOGIC;
			 op_simd: IN STD_LOGIC_VECTor(2 DOWNTO 0);
			 out_simd: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)); -- indica la op
END unidadSIMD;

ARCHITECTURE Structure OF unidadSIMD IS

component regfileSIMD IS 
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 boot   : IN  STD_LOGIC;
			 b16   : IN  STD_LOGIC; -- Indica acceso 16b
          a      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			 b      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0));
END component;
signal s_input_REG : STD_LOGIC_VECTOR(127 DOWNTO 0);
signal s_16b : STD_LOGIC;
signal s_output_a : STD_LOGIC_VECTOR(127 DOWNTO 0);
signal s_output_b : STD_LOGIC_VECTOR(127 DOWNTO 0);

BEGIN

		s_16b <= '1' when op_simd = "110" or op_simd = "111" else 
					'0';
		out_simd <= s_output_a(15 downto 0);-- en movsr sacamos por a 16 bits
		
		s_input_REG(15 downto 0) <= reg_16 when op_simd = "110";
					
	   banco_SIMD: regfileSIMD
		PORT map (clk    => clk,
					 wrd    => wrd,
					 d      => s_input_REG,
					 addr_a => addr_a,
					 addr_b => addr_b,
					 addr_d => addr_d,
					 boot   => boot,
					 b16   => s_16b,
					 a      => s_output_a,
					 b      => s_output_b);

END Structure;