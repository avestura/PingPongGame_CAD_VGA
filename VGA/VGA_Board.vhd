----------------------------------------------------------------------------------
-- Moving Board Demonstration 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_Board is
  port ( CLK_50MHz		: in std_logic;
			RESET				: in std_logic;
			Input_GoUp     : in std_logic;
			Input_GoDown   : in std_logic;
			XPos           : in std_logic_vector(9 downto 0); -- Default value for X (Reset State)
			YPos           : in std_logic_vector(9 downto 0); -- Default value for X (Reset State)
			ColorOut			: out std_logic_vector(11 downto 0); -- RED & GREEN & BLUE
			BoardWidth		: in std_logic_vector(7 downto 0);
			BoardHeight    : in std_logic_vector(7 downto 0);
			BoardColor     : in std_logic_vector(11 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			BoardCurrentX  : out std_logic_vector(9 downto 0);
			BoardCurrentY  : out std_logic_vector(9 downto 0);
			PauseBoard     : in std_logic
  );
end VGA_Board;

architecture Behavioral of VGA_Board is
  
  signal ColorOutput: std_logic_vector(11 downto 0);
  
  signal BoardX: std_logic_vector(9 downto 0) := "0000001110";  
  signal BoardY: std_logic_vector(9 downto 0) := "0000010111";  
  constant BoardXmin: std_logic_vector(9 downto 0) := "0000000001";
  signal BoardXmax: std_logic_vector(9 downto 0); -- := "1010000000"-SquareWidth;
  constant BoardYmin: std_logic_vector(9 downto 0) := "0000000001";
  signal BoardYmax: std_logic_vector(9 downto 0); -- := "0111100000"-SquareWidth;
  signal Prescaler: std_logic_vector(30 downto 0) := (others => '0');

begin

	PrescalerCounter: process(CLK_50Mhz, RESET)
	begin
		if RESET = '1' then
			Prescaler <= (others => '0');
			BoardX <= XPos;
			BoardY <= YPos;
		elsif rising_edge(CLK_50Mhz) then
			if(PauseBoard = '0') then
				Prescaler <= Prescaler + 1;	 
				if Prescaler = "11000011010100000" then  -- Activated every 0,002 sec (2 msec)
					
					if Input_GoDown = '1' then
						if BoardY < BoardYmax then
							BoardY <= BoardY + 1;
						end if;
					end if;
					if Input_GoUp = '1' then
						if BoardY > BoardYmin then
							BoardY <= BoardY - 1;
						end if;	 
					end if;		

					Prescaler <= (others => '0');
				end if;
			end if;
		end if;
	end process PrescalerCounter;

	ColorOutput <=		BoardColor when ScanlineX >= BoardX AND ScanlineY >= BoardY AND ScanlineX < BoardX+BoardWidth AND ScanlineY < BoardY+BoardHeight 
					else	"111111111111";

	ColorOut <= ColorOutput;
	
	BoardCurrentX <= BoardX;
	BoardCurrentY <= BoardY;
	
	BoardXmax <= "1010000000"-BoardWidth; -- (640 - SquareWidth)
	BoardYmax <= "0111100000"-BoardHeight;	-- (480 - SquareWidth)
end Behavioral;

