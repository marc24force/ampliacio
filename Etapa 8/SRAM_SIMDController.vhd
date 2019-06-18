library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity SRAM_SIMDController is
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
			 second_acces: in    std_logic;
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(127 downto 0);
          dataToWrite : in    std_logic_vector(127 downto 0);
          WR          : in    std_logic);
end SRAM_SIMDController;

architecture comportament of SRAM_SIMDController is


signal s_address : std_logic_vector(17 downto 0);
signal second_add : integer:= 0;
signal x   : integer := 0;

type state_type is (e0,e1,e2,e3,e4,e5,e6,e7);
signal estat   : state_type := e0;


begin
--read
	SRAM_ADDR <=  std_logic_vector(unsigned("000"&address(15 downto 1)) + x);
	SRAM_CE_N <= '0';  
	SRAM_OE_N <= '0'; -- output enabled
	SRAM_UB_N <= '0'; -- siempre sera acceso a word
	SRAM_LB_N <= '0';	-- siempre sera acceso a word
   
	second_add <= 4 when second_acces = '1' else 0;
	dataReaded(x*16+15 downto x*16) <= SRAM_DQ;
	SRAM_DQ <= dataToWrite(x*16+15 downto x*16) when WR = '1' else 
				  (others => 'Z');

--write
	process (clk)
	begin
	if rising_edge(clk) then 
		case estat is
			when e0 =>
			    estat<=e1;
			when e1 => 
			    x<=0+second_add;
				 SRAM_WE_N <= not WR; -- si escritura write_enable_neg = 0
				 estat <=e2;
		   when e2 =>
			    x<=1+second_add;
				 estat <= e3;
		   when e3 =>
			    x<=2+second_add;
				 estat <= e4;
			when e4 =>
			    x<=3+second_add;
				 estat <= e5;
			when e5 =>
			    x<=0+second_add;
				 SRAM_WE_N <= '1';
				 estat <= e6;
			when e6 =>
				 estat <= e7;
			when others => 
			    estat <= e0;
		end case;
	end if;
end process;

end comportament;
