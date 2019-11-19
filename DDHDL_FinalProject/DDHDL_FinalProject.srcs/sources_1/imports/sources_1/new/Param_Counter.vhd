----------------------------------------------------------------------------------
-- Company: University of York
-- Engineer: Gianluca Tempesti
-- 
-- Create Date:    12/14/2015 
-- Design Name:    Parameterizable Counter
-- Module Name:    Param_Counter - Behavioral 
-- Project Name:   FDE_Final
-- Target Devices: Any (tested on xc6slx45-3csg324)
-- Tool versions:  Any (tested on ISE 14.2)
-- Description: 
--   A fully parameterizable counter to LIMIT (counts from 0 to LIMIT-1,
--   then cycles back to 0). Synchronous reset and enable.
-- Dependencies: 
--   Requires DigEng.vhd package
-- Revision: 
--   Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL; -- Library required for log2 function

-- See above for circuit description.

ENTITY Param_Counter IS
    GENERIC (
        LIMIT : NATURAL
    );  

    PORT ( 
        clk : IN  STD_LOGIC;
        -- Inputs
        rst : IN  STD_LOGIC;  -- Synchronous reset
        en  : IN  STD_LOGIC;
        -- Counter output - bus size depends on limit (5 bits for default size)
        --  Size is computed using the log2 function. 
        --  Refer to library for full function description.
        count_out : OUT UNSIGNED (log2(LIMIT) - 1 DOWNTO 0)
    );

END Param_Counter;
    
ARCHITECTURE Behavioral OF Param_Counter IS
    -- Internal bus for counter output
    SIGNAL count_int : UNSIGNED (log2(LIMIT) - 1 DOWNTO 0);

BEGIN

-- Counter to LIMIT (0 to LIMIT-1) with synchronous reset and enable
counter: PROCESS (clk)
    BEGIN
        IF RISING_EDGE(clk) THEN 
            IF (rst = '1') THEN 
                count_int <= (others => '0');
            ELSIF (en = '1') THEN
                IF (count_int = LIMIT-1) THEN
                    count_int <= (others => '0');
                ELSE
                    count_int <= count_int + 1;
                END IF;
            END IF;
        END IF;
END PROCESS counter;

-- Map internal counter value to output
count_out <= count_int;

END Behavioral;