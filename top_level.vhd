library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_level is
		--generic(N: integer := 4);
	port( 	
			clk     		: in std_LOGIC;  --20ns 50MHz
			PWMo			: out std_LOGIC;
			SCL			: inout std_logic;
			SDA			: inout std_logic
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





	begin
	
	process(clk)
	begin
	
	end process;
end Structural;