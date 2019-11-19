LIBRARY     IEEE;
USE         IEEE.STD_LOGIC_1164.ALL;
USE         IEEE.STD_LOGIC_ARITH.ALL;

-- Takes a user input logic signal and converts 
--   it to a singal pulse of one clock cycle.

ENTITY Debouncer IS
    PORT (
        -- Inputs
        clk     : IN   STD_LOGIC;
        Sig     : IN   STD_LOGIC;
        -- Debounced Output
        Deb_Sig : OUT  STD_LOGIC
    );
END Debouncer;

ARCHITECTURE Behavioral OF Debouncer IS

    -- Internal Signals
    SIGNAL Q0, Q1, Q2 : STD_LOGIC := '0';

BEGIN

PROCESS (clk) IS
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN 
            Q0 <= Sig;
            Q1 <= Q0;
            Q2 <= Q1;
        END IF;
END PROCESS;

Deb_Sig <= Q0 AND Q1 AND (NOT Q2);

END Behavioral;