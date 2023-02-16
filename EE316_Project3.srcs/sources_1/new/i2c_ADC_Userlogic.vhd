----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/16/2023 12:27:01 PM
-- Design Name: 
-- Module Name: i2c_ADC_Userlogic - Behavioral
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

entity i2c_ADC_Userlogic is
    Port ( 
        clk : in STD_LOGIC;
        adc_data : out std_logic_vector(7 downto 0);
        sda, scl: inout std_logic
    );
end i2c_ADC_Userlogic;

architecture Behavioral of i2c_ADC_Userlogic is
signal reset_n, ena, rw, busy : std_logic;
signal addr_master : std_logic_vector(6 downto 0) := "1001111";
signal data_wr : std_logic_vector(7 downto 0);

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

begin
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

end Behavioral;
