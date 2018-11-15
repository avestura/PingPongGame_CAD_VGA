----------------------------------------------------------------------------------
-- Moving Square Demonstration 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity VGA_Square is
  port ( CLK_50MHz		: in std_logic;
			RESET				: in std_logic;
			BallSpeed      : in std_logic_vector(31 downto 0) := (others => '0');
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
end VGA_Square;

architecture Behavioral of VGA_Square is

  signal randomVector : std_logic_vector(39 downto 0) := "0010110100101010010101011010110101001101";
  
  signal ColorOutput: std_logic_vector(11 downto 0);
  
  signal SquareX: std_logic_vector(9 downto 0) := "0000001110";  
  signal SquareY: std_logic_vector(9 downto 0) := "0000010111";  
  signal SquareXMoveDir, SquareYMoveDir: std_logic := '0';
  constant SquareXmin: std_logic_vector(9 downto 0) := "0000000001";
  signal SquareXmax: std_logic_vector(9 downto 0); -- := "1010000000"-SquareWidth;
  constant SquareYmin: std_logic_vector(9 downto 0) := "0000000001";
  signal SquareYmax: std_logic_vector(9 downto 0); -- := "0111100000"-SquareWidth;
  signal ColorSelect: std_logic_vector(2 downto 0) := "001";
  signal Prescaler: std_logic_vector(31 downto 0) := (others => '0');
  
  signal RandomCounter : integer range 0 to 10000000 := 0;
  
  signal CircleCenterX, CircleCenterY : integer;
  
  signal X_Minus_CenterX, Y_Minus_CenterY : integer;
  
  signal Score1 : integer := 0;
  signal Score2 : integer := 0;
  
  signal randomBit : std_logic;

begin

	randomBit <= randomVector(RandomCounter mod 40);
	
	RandomCounterProcess : process(CLK_50Mhz)
	begin
		if(rising_edge(CLK_50Mhz)) then
			if(RandomCounter = 10000000) then
				RandomCounter <= 0;
			else
				RandomCounter <= RandomCounter + 1;
			end if;
		end if;
	end process;

	PrescalerCounter: process(CLK_50Mhz, RESET)
	begin
		if RESET = '1' then
			Prescaler <= (others => '0');
			SquareX <= "0100110100";
			SquareY <= "0011100100";
			SquareXMoveDir <= randomBit;
			SquareYMoveDir <= randomBit;
			ColorSelect <= "001";
			Score1 <= 0;
			Score2 <= 0;
		elsif rising_edge(CLK_50Mhz) then
			if(PauseBall = '0') then
					Prescaler <= Prescaler + 1;	 
					if Prescaler >= BallSpeed then 
					
						if (SquareX >= Board1X - "00011000" and SquareY >= Board1Y and SquareY <= Board1Y + "01101000") then -- Check Collition with Board1
							SquareXMoveDir <= '1';
							SquareX <= SquareX - 1;
						elsif (SquareX <= Board2X + "00001111" and SquareY >= Board2Y and SquareY <= Board2Y + "01101000") then -- Check Collition with Board2
							SquareXMoveDir <= '0';
							SquareX <= SquareX + 1;
						else
						-- Y Axis Calculations
						if SquareYMoveDir = '0' then -- If ball is going down
							if SquareY < SquareYmax then -- Are we reached to the bottom end? No!
								SquareY <= SquareY + 1;
							else                      -- We are at the end of bottom screen!
								SquareYMoveDir <= '1';
								ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
							end if;
						else                        -- (Else!) Ball is going up
							if SquareY > SquareYmin then -- Are we reached to the top end? No!
								SquareY <= SquareY - 1;
							else                         -- Here we are at the end of top end!
								SquareYMoveDir <= '0'; 
								ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
							end if;	 
						end if;	
					
						-- X Axis Calculations
						if SquareXMoveDir = '0' then -- Ball is moving to the right
							if SquareX < SquareXmax then -- We are not at the right end, yet
								SquareX <= SquareX + 1;
							else -- We are at the right end
								SquareX <= "0100110100";
								SquareY <= "0011100100";
								SquareXMoveDir <= '0';
								Score2 <= Score2 + 1;
								SquareYMoveDir <= randomBit;
								ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
							end if;
						else                   -- Ball is moving to the left
							if SquareX > SquareXmin then -- we are not at the left end, yet
								SquareX <= SquareX - 1;
							else
								SquareX <= "0100110100";
								SquareY <= "0011100100";
								SquareXMoveDir <= '1';
								Score1 <= Score1 + 1;
								SquareYMoveDir <= randomBit;
								ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
							end if;	 
						end if;
				  
							  
					end if;
					
					Prescaler <= (others => '0');
				end if;
			end if;
		end if;
	end process PrescalerCounter; 


	CircleCenterX <= CONV_INTEGER(SquareX) + (CONV_INTEGER(SquareWidth) / 2);
	CircleCenterY <= CONV_INTEGER(SquareY) + (CONV_INTEGER(SquareWidth) / 2);
	
	X_Minus_CenterX <= CONV_INTEGER(ScanlineX) - CircleCenterX;
	Y_Minus_CenterY <= CONV_INTEGER(ScanlineY) - CircleCenterY;

	ColorOutput <= "111100000000"      when ColorSelect(0) = '1' and ((X_Minus_CenterX*X_Minus_CenterX) + (Y_Minus_CenterY*Y_Minus_CenterY) ) <= 144 -- 144 = 12 x 12 = r^2
						else "000011110000" when ColorSelect(1) = '1' and ((X_Minus_CenterX*X_Minus_CenterX) + (Y_Minus_CenterY*Y_Minus_CenterY) ) <= 144 -- 144 = 12 x 12 = r^2
						else "000000001111" when ColorSelect(2) = '1' and ((X_Minus_CenterX*X_Minus_CenterX) + (Y_Minus_CenterY*Y_Minus_CenterY) ) <= 144 -- 144 = 12 x 12 = r^2
						else "111111111111";

	ColorOut <= ColorOutput;
	
	UserScore1 <= Score1; UserScore2 <= Score2;
	
	SquareXmax <= "1010000000"-SquareWidth; -- (640 - SquareWidth)
	SquareYmax <= "0111100000"-SquareWidth;	-- (480 - SquareWidth)
end Behavioral;

