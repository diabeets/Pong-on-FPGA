----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:26:55 11/28/2022 
-- Design Name: 
-- Module Name:    draw - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity draw is
	port(
		vclk : in std_logic;
		p1Top : in std_logic_vector(9 downto 0);
		p1Bot : in std_logic_vector(9 downto 0);
		p2Top : in std_logic_vector(9 downto 0);
		p2Bot : in std_logic_vector(9 downto 0);
		hPixel : in std_logic_vector(9 downto 0);
		vPixel : in std_logic_vector(9 downto 0);
--		ballTop : in std_logic_vector(9 downto 0);
--		ballBot : in std_logic_vector(9 downto 0);
--		ballLeft : in std_logic_vector(9 downto 0);
--		ballRight : in std_logic_vector(9 downto 0);
		
		vidOn : in std_logic;
		
		rout : OUT  std_logic_vector(7 downto 0);
		gout : OUT  std_logic_vector(7 downto 0);
		bout : OUT  std_logic_vector(7 downto 0)
		
	);
	
end draw;

architecture Behavioral of draw is
	signal vid_on : std_logic;

	signal reset : std_logic := '0'; 

	signal p1_top : integer ;
	signal p1_bot : integer ;
	signal p2_top : integer ;
	signal p2_bot : integer ;
	
	signal hPos : integer;
	signal vPos : integer;


begin

	p1_top <= to_integer(unsigned(p1Top));
	p1_bot <= to_integer(unsigned(p1Bot));
	p2_top <= to_integer(unsigned(p2Top));
	p2_bot <= to_integer(unsigned(p2Bot));
	
	hPos <= to_integer(unsigned(hPixel));
	vPos <= to_integer(unsigned(vPixel));
	
	vid_on <= vidOn;

	draw:process(vclk, reset, hPos, vPos, vid_on)
	begin
		if (reset = '1')then
			Red_VGA <= "00000000";
			Green_VGA <= "00000000";
			Blue_VGA <= "00000000";
			
		elsif(vclk'event and vclk = '1')then
			if(vid_on = '1')then
			
				-- top and bottom boarders
				if((hPos >= 59 and hPos <= (hAct - 60) ) and ((vPos >= 30 and vPos <= 49) or
								(vPos >= 430 and vPos <= 449))) then
					gout <= "11111111";
					rout <= "11111111";
					bout <= "11111111";
					
				-- left and right boarders
				elsif(((hPos >= 49 and hPos <= 69) or (hPos >= 560 and hPos <= 579 )) 
						and ((vPos >= 30 and vPos <= 159) or (vPos >= 330 and vPos <= 449))) then 
						
					gout <= "11111111";
					rout <= "11111111";
					bout <= "11111111";
				
				
				else
					Red_VGA <= "00000000";
					Green_VGA <= "11111111";
					Blue_VGA <= "00000000";
				end if;
			
			else
				Red_VGA <= "00000000";
				Green_VGA <= "00000000";
				Blue_VGA <= "00000000";
			end if;
		end if;
	
	end process;



end Behavioral;

