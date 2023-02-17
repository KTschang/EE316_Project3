----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/16/2023 12:24:43 PM
-- Design Name: 
-- Module Name: i2c_lcd_userlogic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_lcd_userlogic is
    GENERIC(
        input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
        bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
    Port ( 
        clk, clk_gen_en, reset : in STD_LOGIC;
        pwm_sig         : in std_logic_vector(1 downto 0);
        sda, scl        : inout std_logic
    );
end i2c_lcd_userlogic;

architecture Behavioral of i2c_lcd_userlogic is

component i2c_master IS
  GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END component;

TYPE state_type IS (start, ready, data_valid, busy_high, repeat);
signal state : state_type := start;
signal reset_n, ena, rw, busy : std_logic;
signal addr_master : std_logic_vector(6 downto 0) := "0100111";
signal data_wr : std_logic_vector(7 downto 0);
signal pwm_byte : std_logic_vector(7 downto 0); -- Final byte to display AIN#
signal byteSel : integer range 0 to 1000 := 0;


begin
    reset_n <= not reset;
    
Inst_i2c_master: i2c_master
	GENERIC map(input_clk => input_clk,
                bus_clk   => bus_clk)
	port map(
		    clk       => clk,               
            reset_n   => reset_n,              
            ena       => ena,         
            addr      => addr_master,
            rw        => rw,      
            data_wr   => data_wr,
            busy      => busy,           
            data_rd   => open,
            ack_error => open,
            sda       => sda,                 
            scl       => scl
		); 
		
    process(byteSel)
     begin
        case pwm_sig is
            when "00" => pwm_byte <= X"30"; -- ASCII = 0
            when "01" => pwm_byte <= X"31"; -- ASCII = 1
            when "10" => pwm_byte <= X"32"; -- ASCII = 2
            when "11" => pwm_byte <= X"33"; -- ASCII = 3
            when others => null;
        end case;
           
        case byteSel is
           when 0 => data_wr <= X"20"; -- set in 4-bit mode
           when 1 => data_wr <= X"38"; -- 0x38 2 lines and 5x7 matrix command
           when 2 => data_wr <= X"3C";
           when 3 => data_wr <= X"38";
           when 4 => data_wr <= X"88";
           when 5 => data_wr <= X"8C";
           when 6 => data_wr <= X"88";
           when 7 => data_wr <= X"38"; -- 0x38
           when 8 => data_wr <= X"3C";
           when 9 => data_wr <= X"38";
           when 10 => data_wr <= X"88";
           when 11 => data_wr <= X"8C";
           when 12 => data_wr <= X"88";
           when 13 => data_wr <= X"38"; -- 0x38
           when 14 => data_wr <= X"3C";
           when 15 => data_wr <= X"38";
           when 16 => data_wr <= X"88";
           when 17 => data_wr <= X"8C";
           when 18 => data_wr <= X"88";
           when 19 => data_wr <= X"08"; -- 0x01 Clear display screen command
           when 20 => data_wr <= X"0C";
           when 21 => data_wr <= X"08";
           when 22 => data_wr <= X"18";
           when 23 => data_wr <= X"1C";
           when 24 => data_wr <= X"18";
           when 25 => data_wr <= X"08"; -- 0x0C Display on, cursor off command 
           when 26 => data_wr <= X"0C";
           when 27 => data_wr <= X"08";
           when 28 => data_wr <= X"C8";
           when 29 => data_wr <= X"CC";
           when 30 => data_wr <= X"C8";
           when 31 => data_wr <= X"08"; -- 0x06 Increment cursor command
           when 32 => data_wr <= X"0C";
           when 33 => data_wr <= X"08";
           when 34 => data_wr <= X"68";
           when 35 => data_wr <= X"6C";
           when 36 => data_wr <= X"68";
           when 37 => data_wr <= X"88"; -- 0x80 1st line command
           when 38 => data_wr <= X"8C";
           when 39 => data_wr <= X"88";
           when 40 => data_wr <= X"08";
           when 41 => data_wr <= X"0C";
           when 42 => data_wr <= X"08";
           when 43 => data_wr <= X"49"; -- 0x41 'A' ASCII Data
           when 44 => data_wr <= X"4D";
           when 45 => data_wr <= X"49";
           when 46 => data_wr <= X"19";
           when 47 => data_wr <= X"1D";
           when 48 => data_wr <= X"19";
           when 49 => data_wr <= X"49"; -- 0x49 'I' ASCII Data
           when 50 => data_wr <= X"4D";
           when 51 => data_wr <= X"49";
           when 52 => data_wr <= X"99";
           when 53 => data_wr <= X"9D";
           when 54 => data_wr <= X"99";
           when 55 => data_wr <= X"49"; -- 0x4E 'N' ASCII Data
           when 56 => data_wr <= X"4D";
           when 57 => data_wr <= X"49";
           when 58 => data_wr <= X"E9";
           when 59 => data_wr <= X"ED";
           when 60 => data_wr <= X"E9";
           when 61 => data_wr <= pwm_byte(7 downto 4)&X"9"; -- Source # ASCII Data
           when 62 => data_wr <= pwm_byte(7 downto 4)&X"D";
           when 63 => data_wr <= pwm_byte(7 downto 4)&X"9";
           when 64 => data_wr <= pwm_byte(3 downto 0)&X"9";
           when 65 => data_wr <= pwm_byte(3 downto 0)&X"D";
           when 66 => data_wr <= pwm_byte(3 downto 0)&X"9";
           when 67 => data_wr <= X"C8"; -- 0xC0 2nd line command
           when 68 => data_wr <= X"CC";
           when 69 => data_wr <= X"C8";
           when 70 => data_wr <= X"08";
           when 71 => data_wr <= X"0C";
           when 72 => data_wr <= X"08";
           when 73 => data_wr <= X"49"; -- 0x43 'C' ASCII Data
           when 74 => data_wr <= X"4D";
           when 75 => data_wr <= X"49";
           when 76 => data_wr <= X"39";
           when 77 => data_wr <= X"3D";
           when 78 => data_wr <= X"39";
           when 79 => data_wr <= X"69"; -- 0x6C 'l' ASCII Data
           when 80 => data_wr <= X"6D";
           when 81 => data_wr <= X"69";
           when 82 => data_wr <= X"C9";
           when 83 => data_wr <= X"CD";
           when 84 => data_wr <= X"C9";
           when 85 => data_wr <= X"69"; -- 0x6C 'o' ASCII Data
           when 86 => data_wr <= X"6D";
           when 87 => data_wr <= X"69";
           when 88 => data_wr <= X"C9";
           when 89 => data_wr <= X"CD";
           when 90 => data_wr <= X"C9";
           when 91 => data_wr <= X"69"; -- 0x63 'c' ASCII Data
           when 92 => data_wr <= X"6D";
           when 93 => data_wr <= X"69";
           when 94 => data_wr <= X"39";
           when 95 => data_wr <= X"3D";
           when 96 => data_wr <= X"39";
           when 97 => data_wr <= X"69"; -- 0x6B 'k' ASCII Data
           when 98 => data_wr <= X"6D";
           when 99 => data_wr <= X"69";
           when 100 => data_wr <= X"B9";
           when 101 => data_wr <= X"BD";
           when 102 => data_wr <= X"B9";
           when 103 => data_wr <= X"29"; -- 0x20 ' ' ASCII Data
           when 104 => data_wr <= X"2D";
           when 105 => data_wr <= X"29";
           when 106 => data_wr <= X"09";
           when 107 => data_wr <= X"0D";
           when 108 => data_wr <= X"09";
           when 109 => data_wr <= X"49"; -- 0x4F 'O' ASCII Data
           when 110 => data_wr <= X"4D";
           when 111 => data_wr <= X"49";
           when 112 => data_wr <= X"F9";
           when 113 => data_wr <= X"FD";
           when 114 => data_wr <= X"F9";
           when 115 => data_wr <= X"79"; -- 0x75 'u' ASCII Data
           when 116 => data_wr <= X"7D";
           when 117 => data_wr <= X"79";
           when 118 => data_wr <= X"59";
           when 119 => data_wr <= X"5D";
           when 120 => data_wr <= X"59";
           when 121 => data_wr <= X"79"; -- 0x74 't' ASCII Data
           when 122 => data_wr <= X"7D";
           when 123 => data_wr <= X"79";
           when 124 => data_wr <= X"49";
           when 125 => data_wr <= X"4D";
           when 126 => data_wr <= X"49";
           when 127 => data_wr <= X"79"; -- 0x70 'p' ASCII Data
           when 128 => data_wr <= X"7D";
           when 129 => data_wr <= X"79";
           when 130 => data_wr <= X"09";
           when 131 => data_wr <= X"0D";
           when 132 => data_wr <= X"09";
           when 133 => data_wr <= X"79"; -- 0x75 'u' ASCII Data
           when 134 => data_wr <= X"7D";
           when 135 => data_wr <= X"79";
           when 136 => data_wr <= X"59";
           when 137 => data_wr <= X"5D";
           when 138 => data_wr <= X"59";
           when 139 => data_wr <= X"79"; -- 0x74 't' ASCII Data
           when 140 => data_wr <= X"7D";
           when 141 => data_wr <= X"79";
           when 142 => data_wr <= X"49";
           when 143 => data_wr <= X"4D";
           when 144 => data_wr <= X"49";
           when others => data_wr <= X"00";
       end case; 
    end process;
		
    process(clk)
    begin
    if(clk'event and clk = '1') then
        case state is 
            when start =>
	            if reset = '1' then	
		            byteSel <= 0;	
		            ena 	<= '0'; 
                    state   <= start; 
	            else
                    ena <= '1';  -- enable for communication with master
                    rw <= '0';   -- write
                    data_wr <= data_wr;   --data to be written 
   	                state   <= ready;  -- ready to write           
                end if;

            when ready =>		
	            if busy = '0' then                      -- state to signal ready for transaction
	      	        ena     <= '1';
	      	        state   <= data_valid;
	            end if;

            when data_valid =>                              --state for conducting this transaction
                if busy = '1' then  
        	        ena     <= '0';
        	        state   <= busy_high;
                end if;

            when busy_high => 
                if busy = '0' then                -- busy just went low 
		            state <= repeat;
   	            end if;		     
            when repeat => 
          	    if byteSel < 66 or ((byteSel < 144) and (clk_gen_en = '1'))then
           	        byteSel <= byteSel + 1;
        	    else	 
           	        byteSel <= 25;        
         	    end if; 		  
   	            state <= start; 
            when others => null;
            end case;   
    end if;  
    end process;

end Behavioral;
