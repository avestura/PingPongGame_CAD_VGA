-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity CAD961Test is
	Port(
		--//////////// CLOCK //////////
		CLOCK_50 	: in std_logic;
		CLOCK2_50	: in std_logic;
		CLOCK3_50	: in std_logic;
		CLOCK4_50	: inout std_logic;
		
		--//////////// KEY //////////
		RESET_N	: in std_logic;
		Key 		: in std_logic_vector(3 downto 0);
	
		--//////////// SEG7 //////////
		HEX0	: out std_logic_vector(6 downto 0);
		HEX1	: out std_logic_vector(6 downto 0);
		HEX2	: out std_logic_vector(6 downto 0);
		HEX3	: out std_logic_vector(6 downto 0);
		HEX4	: out std_logic_vector(6 downto 0);
		HEX5	: out std_logic_vector(6 downto 0);
	
		--//////////// LED //////////
		LEDR	: out std_logic_vector(9 downto 0);
	
		--//////////// SW //////////
		SW : in std_logic_vector(9 downto 0);
		
		--//////////// SDRAM //////////
		DRAM_ADDR	: out std_logic_vector (12 downto 0);
		DRAM_BA		: out std_logic_vector (1 downto 0); 
		DRAM_CAS_N	: out std_logic;
		DRAM_CKE		: out std_logic;
		DRAM_CLK		: out std_logic;
		DRAM_CS_N	: out std_logic;
		DRAM_DQ		: inout std_logic_vector(15 downto 0);
		DRAM_LDQM	: out std_logic;
		DRAM_RAS_N	: out std_logic;
		DRAM_UDQM	: out std_logic;
		DRAM_WE_N	: out std_logic;
		
		--//////////// microSD Card //////////
		SD_CLK	: out std_logic;
		SD_CMD	: inout std_logic;
		SD_DATA	: inout std_logic_vector(3 downto 0);
		
		--//////////// VGA //////////
		VGA_B		: out std_logic_vector(3 downto 0);
		VGA_G		: out std_logic_vector(3 downto 0);
		VGA_HS	: out std_logic;
		VGA_R		: out std_logic_vector(3 downto 0);
		VGA_VS	: out std_logic;
		
		--//////////// GPIO_1, GPIO_1 connect to LT24 - 2.4" LCD and Touch //////////
		MyLCDLT24_ADC_BUSY		: in std_logic;
		MyLCDLT24_ADC_CS_N		: out std_logic;
		MyLCDLT24_ADC_DCLK		: out std_logic;
		MyLCDLT24_ADC_DIN			: out std_logic;
		MyLCDLT24_ADC_DOUT		: in std_logic;
		MyLCDLT24_ADC_PENIRQ_N	: in std_logic;
		MyLCDLT24_CS_N				: out std_logic;
		MyLCDLT24_D					: out std_logic_vector(15 downto 0);
		MyLCDLT24_LCD_ON			: out std_logic;
		MyLCDLT24_RD_N				: out std_logic;
		MyLCDLT24_RESET_N			: out std_logic;
		MyLCDLT24_RS				: out std_logic;
		MyLCDLT24_WR_N				: out std_logic;
		
		--///// Android Client GPIO pins
		GPIO_0_D1               : in std_logic;
		GPIO_0_D3               : in std_logic;
		GPIO_0_D5               : in std_logic;
		GPIO_0_D7               : in std_logic
	);
end CAD961Test;

--}} End of automatically maintained section

architecture CAD961Test of CAD961Test is

Component VGA_controller
	port ( CLK_50MHz		: in std_logic;
         VS					: out std_logic;
			HS					: out std_logic;
			RED				: out std_logic_vector(3 downto 0);
			GREEN				: out std_logic_vector(3 downto 0);
			BLUE				: out std_logic_vector(3 downto 0);
			RESET				: in std_logic;
			ColorIN			: in std_logic_vector(11 downto 0);
			ScanlineX		: out std_logic_vector(10 downto 0);
			ScanlineY		: out std_logic_vector(10 downto 0)
  );
end component;

Component VGA_Square
	port ( CLK_50MHz		: in std_logic;
			RESET				: in std_logic;
			BallSpeed      : in std_logic_vector(31 downto 0);
			ColorOut			: out std_logic_vector(11 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			Board1X        : in std_logic_vector(9 downto 0);
			Board2X        : in std_logic_vector(9 downto 0);
			Board1Y        : in std_logic_vector(9 downto 0);
			Board2Y        : in std_logic_vector(9 downto 0);
			
			UserScore1     : out integer;
			UserScore2     : out integer;
			
			PauseBall      : in std_logic
  );
end component;

Component VGA_Board
	port ( CLK_50MHz		: in std_logic;
			RESET				: in std_logic;
			Input_GoUp     : in std_logic;
			Input_GoDown   : in std_logic;
			XPos           : in std_logic_vector(9 downto 0);
			YPos           : in std_logic_vector(9 downto 0);
			ColorOut			: out std_logic_vector(11 downto 0); -- RED & GREEN & BLUE
			BoardWidth		: in std_logic_vector(7 downto 0);
			BoardHeight		: in std_logic_vector(7 downto 0);
			BoardColor     : in std_logic_vector(11 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			BoardCurrentX  : out std_logic_vector(9 downto 0);
			BoardCurrentY  : out std_logic_vector(9 downto 0);
			PauseBoard     : in std_logic
  );
end component;

-- Function that gets Ones of an integer
function onesOf(N : integer) return std_logic_vector is
begin
	return std_logic_vector(to_unsigned(N mod 10, 4));
end function;

-- Function that gets Tens of an integer
function tensOf(N : integer) return std_logic_vector is
begin
	return std_logic_vector(to_unsigned(N / 10, 4));
end function;

function convSEG (N : std_logic_vector(3 downto 0)) return std_logic_vector is
		variable ans:std_logic_vector(6 downto 0);
begin
	Case N is
		when "0000" => ans:="1000000";	 
		when "0001" => ans:="1111001";
		when "0010" => ans:="0100100";
		when "0011" => ans:="0110000";
		when "0100" => ans:="0011001";
		when "0101" => ans:="0010010";
		when "0110" => ans:="0000010";
		when "0111" => ans:="1111000";
		when "1000" => ans:="0000000";
		when "1001" => ans:="0010000";	   
		when "1010" => ans:="0001000";
		when "1011" => ans:="0000011";
		when "1100" => ans:="1000110";
		when "1101" => ans:="0100001";
		when "1110" => ans:="0000110";
		when "1111" => ans:="0001110";				
		when others=> ans:="1111111";
	end case;	
	return ans;
end function convSEG;

signal Counter : integer;
signal GameTime : integer := 0;
signal ScanlineX,ScanlineY	: std_logic_vector(10 downto 0);
signal ColorTable_Ball	: std_logic_vector(11 downto 0);
signal ColorTable_Board1	: std_logic_vector(11 downto 0);
signal ColorTable_Board2	: std_logic_vector(11 downto 0);
signal ColorTable_VGA	: std_logic_vector(11 downto 0);

signal MiddleLine : std_logic_vector(11 downto 0);
signal BallSpeed  : std_logic_vector(31 downto 0);

signal Score1 : integer;
signal Score2 : integer;

signal Board1X : std_logic_vector(9 downto 0);
signal Board1Y : std_logic_vector(9 downto 0);
signal Board2X : std_logic_vector(9 downto 0);
signal Board2Y : std_logic_vector(9 downto 0);

signal PauseGame : std_logic;

signal P1Up_Controller : std_logic;
signal P1Down_Controller : std_logic;
signal P2Up_Controller : std_logic;
signal P2Down_Controller : std_logic;

begin

	 --------- VGA Controller -----------
	 VGA_Control: vga_controller
			port map(
				CLK_50MHz	=> CLOCK3_50,
				VS				=> VGA_VS,
				HS				=> VGA_HS,
				RED			=> VGA_R,
				GREEN			=> VGA_G,
				BLUE			=> VGA_B,
				RESET			=> not RESET_N,
				ColorIN		=> ColorTable_VGA,
				ScanlineX	=> ScanlineX,
				ScanlineY	=> ScanlineY
			);
		
		--------- Moving Square -----------
		VGA_SQ: VGA_Square
			port map(
				CLK_50MHz		=> CLOCK3_50,
				RESET				=> not RESET_N,
				BallSpeed      => BallSpeed,
				ColorOut			=> ColorTable_Ball,
				SQUAREWIDTH		=> "00011000",
				ScanlineX		=> ScanlineX,
				ScanlineY		=> ScanlineY,
				Board1X        => Board1X,
				Board2X        => Board2X,
				Board1Y        => Board1Y,
				Board2Y        => Board2Y,
			
				UserScore1     => Score1,
				UserScore2     => Score2,
				
				PauseBall      => PauseGame
			);
			
		--------- Board for Player 1 -----------
		VGA_B1: VGA_Board
			port map(
				CLK_50MHz		=> CLOCK3_50,
				RESET				=> not RESET_N,
				Input_GoUp     => not P1Up_Controller,
			   Input_GoDown   => not P1Down_Controller,
			   XPos           => "1001101111",
			   YPos           => "0010111110",
				ColorOut			=> ColorTable_Board1,
				BoardWidth		=> "00001111",
				BoardHeight    => "01101000",
				BoardColor     => "111001101110",
				ScanlineX		=> ScanlineX,
				ScanlineY		=> ScanlineY,
				BoardCurrentX  => Board1X,
			   BoardCurrentY  => Board1Y,
				PauseBoard     => PauseGame
			);
			
			--------- Board for Player 2 -----------
			VGA_B2: VGA_Board
			port map(
				CLK_50MHz		=> CLOCK3_50,
				RESET				=> not RESET_N,
				Input_GoUp     => not P2Up_Controller,
			   Input_GoDown   => not P2Down_Controller,
			   XPos           => "0000011001",
			   YPos           => "0010111110",
				ColorOut			=> ColorTable_Board2,
				BoardWidth		=> "00001111",
				BoardHeight    => "01101000",
				BoardColor     => "111100001111",
				ScanlineX		=> ScanlineX,
				ScanlineY		=> ScanlineY,
				BoardCurrentX  => Board2X,
			   BoardCurrentY  => Board2Y,
				PauseBoard     => PauseGame
			);
			

	 
	 --------- 7Segment Show ------------
	 Process(CLOCK_50, RESET_N)
	 begin
		if (RESET_N='0') then
			Counter <= 0;
			GameTime <= 0;
		elsif (rising_edge(CLOCK_50)) then
			if(PauseGame = '0') then
				if (Counter = 50000000) then
					Counter <= 0;
					GameTime <= GameTime + 1;
				else
					Counter <= Counter + 1;
					GameTime <= GameTime;
				end if;
			end if;
		end if;
	 end process;

	 
	 
	 SevenSegController : process(CLOCK_50, RESET_N)
	 begin
		if (SW(0) = '0') then
			HEX0 <= convSEG("1000");
			HEX1 <= convSEG("0000");
			
			HEX2 <= convSEG("1001");
			HEX3 <= convSEG("0001");
			
			HEX4 <= convSEG("0000");
			HEX5 <= convSEG("0000");
		else
			HEX0 <= convSEG(onesOf(Score1));
			HEX1 <= convSEG(tensOf(Score1));
			
			HEX2 <= convSEG(onesOf(GameTime));
			HEX3 <= convSEG(tensOf(GameTime));
			
			HEX4 <= convSEG(onesOf(Score2));
			HEX5 <= convSEG(tensOf(Score2));
		end if;
	 end process;
	 
	 LEDController : process(CLOCK_50, RESET_N)
	 begin
		if (RESET_N='0') then
			LEDR <= "0000000000";
		elsif (rising_edge(CLOCK_50)) then
			if(GameTime = 75 or Score1 = 11 or Score2 = 11) then
				LEDR <= "1111111111";
			else
				LEDR <= "0000000000";
			end if;
			
		end if;
	 end process;
	 
	 BallSpeed <= x"0002AB98" when GameTime < 15 else
					  x"000249F0" when GameTime >= 15 and GameTime < 30 else
					  x"0001E848" when GameTime >= 30 and GameTime < 45 else
					  x"000186A0" when GameTime >= 45 and GameTime < 60 else
					  x"0000C350";
	 
    MiddleLine <= "111111110000" when ScanlineX >= "00100111101" and ScanlineX <= "00101000011" else "111111111111";
	 
	 ColorTable_VGA <= ColorTable_Ball and ColorTable_Board1 and ColorTable_Board2 and MiddleLine;

	 PauseGame <= '1' when GameTime = 75 or Score1 = 11 or Score2 = 11 or SW(0) = '0' else
					  '0';
	
	 P1Up_Controller   <= Key(0) when SW(1) = '0' else GPIO_0_D1;
	 P1Down_Controller <= Key(1) when SW(1) = '0' else GPIO_0_D3;
	 P2Up_Controller   <= Key(2) when SW(1) = '0' else GPIO_0_D5;
	 P2Down_Controller <= Key(3) when SW(1) = '0' else GPIO_0_D7;
	 
end CAD961Test;
