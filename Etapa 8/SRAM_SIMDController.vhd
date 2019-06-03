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
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(127 downto 0);
          dataToWrite : in    std_logic_vector(127 downto 0);
          WR          : in    std_logic);
end SRAM_SIMDController;

architecture comportament of SRAM_SIMDController is


signal s_address : std_logic_vector(17 downto 0);

signal estat   : integer := 0;

begin
--read
	SRAM_ADDR <=  std_logic_vector(unsigned("000"&address(15 downto 1)) + estat);
	SRAM_CE_N <= '0';  
	SRAM_OE_N <= '0'; -- output enabled
	SRAM_UB_N <= '0'; -- siempre sera acceso a word
	SRAM_LB_N <= '0';	-- siempre sera acceso a word
   
	dataReaded(estat*16+15 downto estat*16) <= SRAM_DQ;
	SRAM_DQ <= dataToWrite(estat*16+15 downto estat*16) when WR = '1' else
	           (others => 'Z');

--write
	process (clk)
	begin
	if rising_edge(clk) then 
		SRAM_WE_N <= not WR; -- si escritura write_enable_neg = 0
		case estat is
			when 0 =>
--				s_address <= "000"&address(15 downto 1);
			    estat<=1;
			when 1 =>
				-- s_address <= std_logic_vector(unsigned(s_address)+1);
				 estat <=2;
		   when 2 =>
				 estat <= 3;
		   when 3 =>
				 estat <= 4;
			when 4 =>
				 estat <= 5;
			when 5 =>
				 estat <= 6;
			when 6 =>
				 estat <= 7;
			when others => 
				 SRAM_WE_N <= '1';
			    estat <= 0;
		end case;
	end if;
end process;

end comportament;
