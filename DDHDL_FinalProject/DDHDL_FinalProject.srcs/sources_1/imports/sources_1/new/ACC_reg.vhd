LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;

USE     work.DigEng.ALL;

-- N-bit D-Type flip flop with synchronous 'reset' and 'enable'.
    -- Used within the MACC to hold the products of coefficients for summing.
    
ENTITY param_register IS
    GENERIC (
        data_size : NATURAL
    );

    PORT (  
        clk       : IN  STD_LOGIC;
        -- Inputs
        rst_reg   : IN  STD_LOGIC; -- Register reset
        en        : IN  STD_LOGIC; -- Register enable
        Data_in   : IN  STD_LOGIC_VECTOR(data_size - 1 DOWNTO 0);
        -- Output
        Data_out  : OUT STD_LOGIC_VECTOR(data_size - 1 DOWNTO 0)
    );

END param_register;

ARCHITECTURE Behavioral OF param_register IS

BEGIN

Reg: PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (rst_reg = '1') THEN
                Data_out <= (OTHERS => '0');
            ELSIF (en = '1') THEN
                Data_out <= Data_in;        
            END IF;
        END IF;
END PROCESS Reg;

END Behavioral;