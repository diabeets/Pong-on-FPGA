----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:24:36 11/16/2022 
-- Design Name: 
-- Module Name:    pong - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pong is
	port (
		clk : IN  std_logic;
		p1_Up : IN  std_logic;
		p1_Down : IN  std_logic;
		p2_Up : IN  std_logic;
		p2_Down : IN  std_logic;
		H_sync_VGA : OUT  std_logic;
		V_sync_VGA : OUT  std_logic;
		DAC_CLK : out std_logic;
		--reset : in std_logic;
		
		Red_VGA : OUT  std_logic_vector(7 downto 0);
		Green_VGA : OUT  std_logic_vector(7 downto 0);
		Blue_VGA : OUT  std_logic_vector(7 downto 0)
	);

end pong;


architecture Behavioral of pong is

-- vga signals
	signal vclk : std_logic := '0';
	signal reset : std_logic := '0';
	signal vid_on : std_logic := '0' ;
	
	constant hAct : integer := 639;
	constant hFp : integer := 16;
	constant hSyncP : integer := 96;
	constant hBp : integer := 48;
	constant hTotal : integer := 799;

	constant vAct : integer := 479;
	constant vFp : integer:= 10;
	constant vSyncP : integer := 2;
	constant vBp : integer := 33;
	constant vTotal : integer := 524;
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
	-- paddle signals
	signal p1Top : integer := 200;
	signal p1Bot : integer := 279;
	signal p2Top : integer := 200;
	signal p2Bot : integer := 279;
	
	
	signal p_counter : integer := 0;
	constant p_counterMax : integer := 250000;
	
	signal b_count : integer := 0;
	constant b_countMax : integer := 125000;
	
	
	-- ball signals
	signal bLeft : integer := 310;
	signal bRight : integer := 330;
	signal bTop : integer := 230;
	signal bBot : integer := 250;
	
	signal bMove : std_logic_vector(1 downto 0);
	
begin
	
	
----------------------------------------------------------------------------------------------------------------	
--Vga Controller
----------------------------------------------------------------------------------------------------------------	
		
	-- 25Mhz clk
	video_clk :process(clk)
	begin
		if(clk'event and clk = '1')then
			DAC_CLK <= not vclk;
			vclk <= not vclk;
		end if;
	end process;
	
	hori_counter : process(vclk, reset)
	begin	
		if(reset = '1')then
			hPos <=  0;
		elsif(vclk'event and vclk ='1')then
			if (hPos = hTotal)then
				hPos <= 0;
			else
				hPos <= hPos + 1;
			end if;
		end if;
	end process;
	
	verti_counter : process(vclk, reset, hPos)
	begin
		if(reset = '1')then
			vPos <= 0;
		elsif(vclk'event and vclk = '1')then
			if(hPos = hTotal) then
				if(vPos = vTotal)then
					vPos <= 0;
				else
					vPos <= vPos + 1;
				end if;
			end if;
		end if;
	end process;
	
	h_sync : process(vclk, reset, hPos)
	begin
		if(reset = '1')then
			H_sync_VGA <= '0';
		elsif(vclk'event and vclk = '1')then
			if((hPos <= (hAct + hFp)) or (hPos >= (hAct + hFp + hSyncP))) then
				H_sync_VGA <= '1';
			else
				H_sync_VGA <= '0';
			end if;
		end if;
	 end process;
	 
	v_sync : process(vclk, reset, vPos)
	begin
		if(reset = '1')then
			V_sync_VGA <= '0';
		elsif(vclk'event and vclk = '1')then
			if((vPos <= (vAct + vFp)) or (vPos > (vAct + vFp + vSyncP))) then
				V_sync_VGA <= '1';
			else
				V_sync_VGA <= '0';
			end if;
		end if;
	end process;
	 
	video_on:process(vclk, reset, hPos, vPos)
	begin
		if(reset = '1')then
			vid_on <= '0';
		elsif(vclk'event and vclk = '1')then
			if((hPos <= hAct) and (vPos <= vAct) )then
				vid_on <= '1';
			else 
				vid_on <= '0';
			end if;
		end if;
		
	end process;
	
	
----------------------------------------------------------------------------------------------------------------	
--PADDLE CONTROLS
----------------------------------------------------------------------------------------------------------------
	-- paddle counter
	paddle_counter : process(reset, p_counter, vclk)
	begin
		if (reset = '1')then
			p_counter <= 0;
			
		elsif(vclk'event and vclk = '1')then
			if (p_counter = p_counterMax )then
				p_counter <= 0;
			else
				p_counter <= p_counter + 1;
			end if;
		end if;
		
	end process;
	
	
	-- player 1 movement
	player1Move : process(reset, p1_Up, p1_Down, vclk)
	begin
		if( reset = '1')then
			p1Top <= 200;
			p1Bot <= 279;
			
		elsif(vclk'event and vclk = '1')then
			if(p_counter = p_counterMax)then
				if ((p1_Up = '1' and p1_Down = '0') and (p1Top >= 50)) then
				
					p1Top <= p1Top - 1;
					p1Bot <= p1Bot - 1;
				
				elsif ((p1_Up = '0' and p1_Down = '1') and (p1Bot <= 430)) then
					p1Top <= p1Top + 1;
					p1Bot <= p1Bot + 1;
					
				else
					p1Top <= p1Top;
					p1Bot <= P1Bot;
				end if;
			else
				p1Top <= p1Top;
				p1Bot <= P1Bot;
			end if;
		end if;
	end process;
		
	-- p2 movement	
		
	player2Move : process(reset, p2_Up, p2_Down, vclk)
	begin
		if( reset = '1')then
			p2Top <= 200;
			p2Bot <= 279;
			
		elsif(vclk'event and vclk = '1')then
			if(p_counter = p_counterMax)then
				if ((p2_Up = '1' and p2_Down = '0') and (p2Top >= 50)) then
					p2Top <= p2Top - 1;
					p2Bot <= p2Bot - 1;
				
				elsif ((p2_Up = '0' and p2_Down = '1') and (p2Bot <= 430)) then
					p2Top <= p2Top + 1;
					p2Bot <= p2Bot + 1;
					
				else
					p2Top <= p2Top;
					p2Bot <= p2Bot;
				end if;
			else
				p2Top <= p2Top;
				p2Bot <= p2Bot;
			
			end if;
		end if;
	end process;
	
	
	
	
----------------------------------------------------------------------------------------------------------------	
--BALL CONTROLS
----------------------------------------------------------------------------------------------------------------	

	ball_counter : process(reset, b_count, vclk)
	begin
		if (reset = '1')then
			b_count <= 0;
			
		elsif(vclk'event and vclk = '1')then
			if (b_count = b_countMax )then
				b_count <= 0;
			else
				b_count <= b_count + 1;
			end if;
		end if;
		
	end process;

	ball_movement : process(vclk, bMove)
	begin
		if (reset = '1') then
			bLeft <= 310;
			bTop <= 230;
		
		elsif (vclk'event and vclk = '1')then
			if(bLeft = 0 or bRight = 639)then
				bLeft <= 310;
				bTop <= 230;
		
			elsif(b_count = b_countMax)then
				
				case bMove is
					when "00" =>
						bLeft <= bLeft - 1;
						bTop <= bTop - 1;
					when "01" =>
						bLeft <= bLeft - 1;
						bTop <= bTop + 1;
					when "10" =>
						bLeft <= bLeft + 1;
						bTop <= bTop - 1;
					when "11" =>
						bLeft <= bLeft + 1;
						bTop <= bTop + 1;
					when others =>
						bLeft <= bLeft;
						bTop <= bTop;
					end case;
			end if;	
		end if;
	end process;
		
	bBot <= bTop + 20;
	bRight <= bLeft + 20;
	
	collision_detec : process(vclk, bLeft, bTop, bRight, bBot, bMove)
	begin
		if (reset = '1') then
			bMove <= "00";
		
		elsif (vclk'event and vclk = '1')then
	
			-- check for top boarder collision collision
			if(bTop = 50 and bMove(0) = '0' ) then
				bMove(0) <= '1';
			end if;
			-- check for bottom boarder collision
			if(bBot = 429 and bMove(0) = '1' ) then
				bMove(0) <= '0';
			end if;
			
			-- check left boarder collision
			if((bLeft = 70 and (bTop < 160 or bBot > 330)) and (bMove(1) = '0' )) then
				bMove(1) <= '1';
			end if;
			
			-- check right boarder collision
			if((bRight = 559 and (bTop < 160 or bBot > 330)) and (bMove(1) = '1' )) then
				bMove(1) <= '0';
			end if;
			
			-- check left right paddle collision
			
			if(((bLeft = 110) and ((bBot > p1Top and bBot < p1Bot) or (bTop > p1Top and bTop < p1Bot))) and (bMove(1) = '0' )) then
				bMove(1) <= '1';
			end if;
			
			if((bRight = 529 and ((bBot > p2Top and bBot < p2Bot) or (bTop > p2Top and bTop < p2Bot))) and (bMove(1) = '1' )) then
				bMove(1) <= '0';
			end if;
		end if;
		
	end process;
	
	

	
----------------------------------------------------------------------------------------------------------------	
--Drawing
----------------------------------------------------------------------------------------------------------------
	 
	draw:process(vclk, reset, hPos, vPos, vid_on)
	begin
		if (reset = '1')then
			Red_VGA <= "00000000";
			Green_VGA <= "00000000";
			Blue_VGA <= "00000000";
			
		elsif(vclk'event and vclk = '1')then
			if(vid_on = '1')then
		
				if((hPos >= bLeft and hPos <= bRight ) and (vPos >= bTop and vPos <= bBot ))then
					if(bLeft < 48 or bRight > 580)then
						Green_VGA <= "00000000";
						Red_VGA <= "11111111";
						Blue_VGA <= "00000000";
					else 
						Green_VGA <= "11111111";
						Red_VGA <= "11111111";
						Blue_VGA <= "00000000";
					end if;
			
				-- top and bottom boarders
				elsif((hPos >= 59 and hPos <= (hAct - 60) ) and ((vPos >= 30 and vPos <= 49) or
								(vPos >= 430 and vPos <= 449))) then
					Green_VGA <= "11111111";
					Red_VGA <= "11111111";
					Blue_VGA <= "11111111";
					
					
					
				-- left and right boarders
				elsif(((hPos >= 49 and hPos <= 69) or (hPos >= 560 and hPos <= 579 )) 
						and ((vPos >= 30 and vPos <= 159) or (vPos >= 330 and vPos <= 449))) then 
						
					Green_VGA <= "11111111";
					Red_VGA <= "11111111";
					Blue_VGA <= "11111111";
					
					
					
				-- p1 paddle
				elsif((hPos >= 100 and hPos <= 109) and (vPos >= p1Top and vPos <= p1Bot)) then
					Green_VGA <= "00000000";
					Red_VGA <= "00000000";
					Blue_VGA <= "11111111";
				
				
				--p2 paddle
				elsif((hPos >= 530 and hPos <= 539) and (vPos >= p2Top and vPos <= p2Bot)) then
				
					Red_VGA <= "11111111";
					Green_VGA <= "00000000";
					Blue_VGA <= "11111111";
					
				-- green back ground
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

