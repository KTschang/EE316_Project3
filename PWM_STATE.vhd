library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PWM_STATE is
    Port ( BTN0 : in STD_LOGIC;
           BTN1 : in STD_LOGIC;
           CLK : in std_logic;
           STATE : out STD_LOGIC_VECTOR (0 to 1));
end PWM_STATE;

architecture Behavioral of PWM_STATE is

type stateType is (PWM0, PWM1, PWM2, PWM3);
signal PWMState : stateType := PWM0;

begin
process(BTN0, BTN1, CLK)
begin
    if rising_edge(clk) and BTN1 = '1' then 
        case PWMState is 
            when PWM0 => 
                PWMState <= PWM1;
                STATE <= "00";  
            when PWM1 => 
                PWMState <= PWM2;
                STATE <= "01";  
            when PWM2 => 
                PWMState <= PWM3;
                STATE <= "10";  
            when PWM3 => 
                PWMState <= PWM0;
                STATE <= "11";  
            when others => 
                PWMState <= PWM1;
                STATE <= "00";  
        end case;
    elsif(rising_edge(clk) and BTN0 = '1') then 
        PWMState <= PWM1;
    end if;
end process;
end Behavioral;
