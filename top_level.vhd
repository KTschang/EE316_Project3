library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_level is
		--generic(N: integer := 4);
	port( 	
			clk     		: in std_LOGIC;  --20ns 50MHz
			key2			: in std_logic;
			key1			: in std_logic;
			PWMo			: out std_LOGIC;
			CLKo			: out std_LOGIC;
			SCL0			: inout std_logic;
			SDA0			: inout std_logic;
			SCL1			: inout std_logic;
			SDA1			: inout std_logic
		);
end top_level;

architecture Structural of top_level is 

component clk_enabler is
		 GENERIC (
			 CONSTANT cnt_max : integer := 49999999);      --  1.0 Hz 	
		 PORT(	
			clock						: in std_logic;	 
			clk_en					: out std_logic
		);
	end component;

component Reset_Delay IS
	    generic(MAX: integer 	:= 15);	
		 PORT (
			  iCLK 					: IN std_logic;	
			  oRESET 				: OUT std_logic
				);	
	end component;

component debounce is
	GENERIC (
	CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
    Port ( 
		   BTN_I 	: in  STD_LOGIC;
           CLK 		: in  STD_LOGIC;
           BTN_O 	: out  STD_LOGIC;
           TOGGLE_O : out  STD_LOGIC;
		   PULSE_O  : out STD_LOGIC);
	end component;

component PWM_Manager is
	port(
		clk : in std_logic;
		count : in std_logic_vector(7 downto 0);
		PWM_out : out std_logic
	);
	end component;

	TYPE STATE_TYPE is (init, AIN0, AIN0_clk, AIN1, AIN1_clk, AIN2, AIN2_clk, AIN3, AIN3_clk);
	signal state : STATE_TYPE:= init;	


	signal key0_db : std_logic;
	signal key1_db : std_logic;

	Inst_key2_db: debounce
	GENERIC map(
	CNTR_MAX => X"FFFF")  
    Port map ( 
		   BTN_I 	=> key2,
           CLK 	=> clk,
           BTN_O 	=> open,
           TOGGLE_O => open,
		   PULSE_O  => key2_db
			);
	
	Inst_key1_db: debounce
	GENERIC map(
	CNTR_MAX => X"FFFF")  
    Port map ( 
		   BTN_I 	=> key1,
           CLK 	=> clk,
           BTN_O 	=> open,
           TOGGLE_O => open,
		   PULSE_O  => key1_db
			);

	begin
	
	kp <= key1_db or key2_db;
	
	process(clk)
	begin
	if(clk'event and clk = '1') then
	
		if reset_sig = '1' then
		state <= init;
		end if;
	
		case state is
			when init =>
			state <= AIN0;
		
			when AIN0 =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
					state <= AIN1;
			
					elsif(key2_db = '1') then
			
					state <= AIN0_clk;
			
					else
			
					state <= AIN0;
			
				end if;
				
			end if;
			
			when AIN0_clk =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
					state <= AIN1_clk;
			
					elsif(key2_db = '1') then
			
					state <= AIN0;
			
					else
			
					state <= AIN0_clk;
			
				end if;
					
			end if;					
	
	--------------------------------------------------
			
			when AIN1 =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
					state <= AIN2;
			
					elsif(key2_db = '1') then
			
					state <= AIN1_clk;
			
					else
			
					state <= AIN1;
			
				end if;
				
			end if;
			
			when AIN1_clk =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
					state <= AIN2_clk;
			
					elsif(key2_db = '1') then
			
					state <= AIN1;
			
					else
			
					state <= AIN1_clk;
			
				end if;
					
			end if;					
	
	--------------------------------------------------
			
			when AIN2 =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
					state <= AIN3;
			
					elsif(key2_db = '1') then
			
					state <= AIN2_clk;
			
					else
			
					state <= AIN2;
			
				end if;
				
			end if;
			
			when AIN2_clk =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
					state <= AIN3_clk;
			
					elsif(key2_db = '1') then
			
					state <= AIN2;
			
					else
			
					state <= AIN2_clk;
			
				end if;
					
			end if;					
	
	--------------------------------------------------
	
			when AIN3 =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
				state <= AIN0;
			
				elsif(key2_db = '1') then
			
				state <= AIN3_clk;
			
				else
			
				state <= AIN3;
			
				end if;
				
			end if;
			
			when AIN3_clk =>
			
			if(kp = '1') then
			
				if(key1_db = '1') then
			
					state <= AIN0_clk;
			
					elsif(key2_db = '1') then
			
					state <= AIN3;
			
					else
			
					state <= AIN3_clk;
			
				end if;
					
			end if;					
	
	--------------------------------------------------
	
		end if;
	end process;
end Structural;