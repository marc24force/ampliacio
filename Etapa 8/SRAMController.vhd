library ieee;
use ieee.std_logic_1164.all;

entity SRAMController is
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
end SRAMController;

architecture comportament of SRAMController is
signal aux_read : std_logic_vector(15 downto 0); 
signal extensio_signe : std_logic_vector(7 downto 0);
signal data2write : std_logic_vector(15 downto 0);

type state_type is (e0,e1,e2,e3,e4,e5,e6,e7);
signal estat   : state_type := e0;

begin
--read
	SRAM_ADDR <= "000"&address(15 downto 1);
	SRAM_CE_N <= '0';  
	SRAM_OE_N <= '0'; -- output enabled

	extensio_signe <= (others=>SRAM_DQ(7)) when address(0)='0' else
							(others=>SRAM_DQ(15));
							
	dataReaded <=  extensio_signe&SRAM_DQ(7 downto 0) when (byte_m='1' and address(0)='0') else  -- byte parell
						extensio_signe&SRAM_DQ(15 downto 8)  when (byte_m='1' and address(0)='1') else -- byte imparell
						SRAM_DQ;	-- word
	
	--upper + lower
	data2write <=  "ZZZZZZZZ"&dataToWrite(7 downto 0) when byte_m = '1' and address(0) = '0' else --escribimos Z+Din 
						dataToWrite(7 downto 0)&"ZZZZZZZZ" when byte_m = '1' and address(0) = '1' else --escribimos Din+Z PREGUNTAR!!!!
						dataToWrite; -- Escribimos Din+Din 
	
   SRAM_DQ <= data2write when WR = '1' else -- escritura
				  (others=>'Z');					  -- lectura
				  
	SRAM_UB_N <= not address(0) and WR and byte_m; -- si escritura de byte: bit inpar; else 0
	SRAM_LB_N <= address(0) and WR and byte_m;	   -- si escritura: bit par; else 0

--write
	process (clk)
	begin
	if rising_edge(clk) then
		case estat is
			when e0 =>
			    estat<=e1;
			when e1 =>
			    SRAM_WE_N <= not WR; -- si escritura write_enable_neg = 0			 
				 estat <=e2;
		   when e2 =>
				 estat <= e3;
		   when e3 =>
				 estat <= e4;
			when e4 =>
				 estat <= e5; --desactiva la escritura
				 SRAM_WE_N <= '1';
			when e5 =>
				 estat <= e6;
			when e6 =>
				 estat <= e7;
			when others => 
			    estat <= e0;
		end case;
	end if;
end process;

--	dataReaded <= aux_read when byte_m = '0' else 
--					  std_logic_vector(resize(signed(aux_read(7 downto 0)),dataReaded'length)) when address(0) = '0' else
--					  std_logic_vector(resize(signed(aux_read(15 downto 8)),dataReaded'length));

end comportament;
