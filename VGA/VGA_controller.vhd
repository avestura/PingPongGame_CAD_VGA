----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:39:44 09/13/2010 
-- Design Name: 
-- Module Name:    OwnVGA - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_controller is
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
end VGA_controller;

architecture Behavioral of VGA_controller is
  -- VGA Definitions
  constant HDisplayArea: integer:= 640; -- horizontal display area
  constant HLimit: integer:= 800; -- maximum horizontal amount (limit)
  constant HFrontPorch: integer:= 16; -- h. front porch
  constant HBackPorch: integer:= 48;	-- h. back porch
  constant HSyncWidth: integer:= 96;	-- h. pulse width
  constant VDisplayArea: integer:= 480; -- vertical display area
  constant VLimit: integer:= 525; -- maximum vertical amount (limit)
  constant VFrontPorch: integer:= 10;	-- v. front porch
  constant VBackPorch: integer:= 33;	-- v. back porch
  constant VSyncWidth: integer:= 2;	-- v. pulse width      
  
  signal Clk_25MHz: std_logic := '0';  
  signal HBlank, VBlank, Blank: std_logic := '0';
    
  signal CurrentHPos: std_logic_vector(10 downto 0) := (others => '0'); -- goes to 1100100000 = 800
  signal CurrentVPos: std_logic_vector(10 downto 0) := (others => '0'); -- goes to 1000001101 = 525
    
begin

  Generate25MHz: process (CLK_50MHz)
  begin
    if rising_edge(CLK_50MHz) then
	   Clk_25MHz <= not Clk_25MHz;
	 end if;
  end process Generate25MHz;
  
  VGAPosition: process (Clk_25MHz, RESET)
  begin
    if RESET = '1' then
	   CurrentHPos <= (others => '0');
		CurrentVPos <= (others => '0');
    elsif rising_edge(CLK_25MHz) then
	   if CurrentHPos < HLimit-1 then
		  CurrentHPos <= CurrentHPos + 1;
		else
		  if CurrentVPos < VLimit-1 then
		    CurrentVPos <= CurrentVPos + 1;
		  else
		    CurrentVPos <= (others => '0'); -- reset Vertical Position
		  end if;
		  CurrentHPos <= (others => '0'); -- reset Horizontal Position
		end if;
	 end if;
  end process VGAPosition;

  -- Timing definition for HSync, VSync and Blank (http://tinyvga.com/vga-timing/640x480@60Hz)
     HS <= '0' when CurrentHPos < HSyncWidth else
	        '1';
	  
	  VS <= '0' when CurrentVPos < VSyncWidth else
	        '1';
	  
	  HBlank <= '0' when (CurrentHPos >= HSyncWidth + HFrontPorch) and (CurrentHPos < HSyncWidth + HFrontPorch + HDisplayArea) else
	           '1';
				  
	  VBlank <= '0' when (CurrentVPos >= VSyncWidth + VFrontPorch) and (CurrentVPos < VSyncWidth + VFrontPorch + VDisplayArea) else
	           '1';				  
	  
	  Blank <= '1' when HBlank = '1' or VBlank = '1' else
	           '0';
	  
	  ScanlineX <= CurrentHPos - HSyncWidth - HFrontPorch when Blank = '0' else
	               (others => '0');

	  ScanlineY <= CurrentVPos - VSyncWidth - VFrontPorch when Blank = '0' else
	               (others => '0');	

     RED		<= ColorIN(11 downto 8) when Blank = '0' else "0000";	  
	  
     GREEN	<= ColorIN(7 downto 4) when Blank = '0' else "0000";				
	  
     BLUE	<= ColorIN(3 downto 0) when Blank = '0' else "0000";								
  
end Behavioral;

