LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;

-- Asynchronous Read single-port ROM
    -- Memory Depth => (NxM)
    -- Memory Width => data_size
    -- Data_out signal is respectively Data_B.

ENTITY ROM_B IS
    GENERIC (
        data_size : NATURAL;
        M         : NATURAL;
        N         : NATURAL
    );

    PORT (  
        -- Address Input
        Addr     : IN    UNSIGNED (log2(M * N) - 1 DOWNTO 0);
        -- Data Output
        Data_out : OUT   SIGNED (data_size - 1 DOWNTO 0)
    );

END ROM_B;

ARCHITECTURE Behavioral OF ROM_B IS

    TYPE rom_type IS ARRAY (0 TO (M * N) - 1) OF SIGNED(data_size - 1 DOWNTO 0);
        CONSTANT ROM_Matrix: rom_type := (
        
        -- Simple Comp.  Max +ve Values  Max -ve Values   Complex Comp.   Force Zeros
        --       1               15              -16             3               0
        0  => B"00001", 1  => B"01111", 2  => B"10000", 3  => B"00011", 4  => B"00000",
        --       2               15              -16             -14             0
        5  => B"00010", 6  => B"01111", 7  => B"10000", 8  => B"10010", 9  => B"00000",
        --       3               15              -16             2               0
        10 => B"00011", 11 => B"01111", 12 => B"10000", 13 => B"00010", 14 => B"00000",

        -- Catch all
        OTHERS => B"00000"
        );

BEGIN

-- Asynchronous read
Data_out <= ROM_Matrix(TO_INTEGER(Addr)); 

END Behavioral;