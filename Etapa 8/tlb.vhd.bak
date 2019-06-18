
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY tlb IS
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
			 
END tlb;

ARCHITECTURE Structure OF tlb IS
	type TAG_M is array (7 downto 0) of std_logic_vector(3 downto 0); -- estructura de alamcenamiento 
	
	signal virtual   : TAG_M;
	signal fisica    : TAG_M;
	signal valid     : std_logic_vector(7 downto 0); -- bit v
	signal read_only : std_logic_vector(7 downto 0); -- bit r
	
	signal ret : std_logic_vector (5 downto 0):="000000";
	signal hit : std_logic;
	
BEGIN

	write_tlb:process(clk,boot) is
	begin
		if boot = '1' then 
		      valid <= X"FF";
				read_only <= X"00";
				
				fisica(0) <= "0000";
				virtual(0) <= "0000";
				
				fisica(1) <= "0001";
				virtual(1) <= "0001";
				
				fisica(2) <= "0010";
				virtual(2) <= "0010";
				
				fisica(3) <= "1000";
				virtual(3) <= "1000";
				
				fisica(4) <= "1100";
				virtual(4) <= "1100";
				
				fisica(5) <= "1101";
				virtual(5) <= "1101";
				
				fisica(6) <= "1110";
				virtual(6) <= "1110";
				
				fisica(7) <= "1111";
				virtual(7) <= "1111";
				
		elsif rising_edge(clk) then
			
			if flush = '1' then 
				for i in 0 to 7 loop
					fisica(i) <= "0000";
					virtual(i) <= "0000";
					valid(i) <= '0';
				end loop;
			elsif tlb_we = '1' then
				if wr_phy = '1' then 
					fisica(conv_integer(entrada))    <= data_in;
					valid(conv_integer(entrada))     <= v_in; 
					read_only(conv_integer(entrada)) <= r_in; 
				else 
					virtual(conv_integer(entrada))   <= data_in;
				end if;
			end if;
		end if;
	end process write_tlb;
			
			
	read_tlb: process(tag_in,valid,virtual,fisica) is
	begin
		hit <= '0';
		for i in 0 to 7 loop
			if virtual(i) = tag_in then
				ret <= valid(i) & read_only(i) & fisica(i);
				hit <= '1';
				exit;	
			end if;
		end loop;
	end process read_tlb;
		
	tlb_hit <= hit;
	v_out <= ret(5);
	r_out <= ret(4);
	tag_out <= ret(3 downto 0);
	
	
END Structure;