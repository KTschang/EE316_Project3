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
signal hex_data : std_logic_vector(7 downto 0);
signal data_wr : std_logic_vector(7 downto 0);
signal byteSel : integer range 0 to 50 := 0;

begin
    reset_n <= not reset;
    
Inst_i2c_master: i2c_master
	GENERIC map(input_clk => 50_000_000,
                bus_clk   => 50_000)
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
        case byteSel is
           when 0 => hex_data <= X"38";
           when 1 => hex_data <= X"38";
           when 2 => hex_data <= X"38";
           when 3 => hex_data <= X"38";
           when 4 => hex_data <= X"01";
           when 5 => hex_data <= X"0C";
           when 6 => hex_data <= X"06";
           when 7 => hex_data <= X"80";
           when others => hex_data <= X"38";
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
          	    if byteSel < 12 then
           	        byteSel <= byteSel + 1;
        	    else	 
           	        byteSel <= 9;           
         	    end if; 		  
   	        state <= start; 
            when others => null;
            end case;   
    end if;  
    end process;

end Behavioral;
