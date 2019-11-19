LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;

-- Asynchronous Read single-port ROM
    -- Memory Depth => (HxM)
    -- Memory Width => data_size
    -- Data_out signal is respectively Data_A.

ENTITY ROM_A IS
    GENERIC (
        data_size : NATURAL;
        H         : NATURAL;
        M         : NATURAL
    );

    PORT ( 
        -- Address Input
        Addr     : IN    UNSIGNED (log2(H * M) - 1 DOWNTO 0);
        -- Data Output
        Data_out : OUT   SIGNED (data_size - 1 DOWNTO 0)
    );

END ROM_A;

ARCHITECTURE Behavioral OF ROM_A IS

    TYPE rom_type IS ARRAY (0 TO (H * M) - 1) OF SIGNED(data_size - 1 DOWNTO 0);
        CONSTANT ROM_Matrix: rom_type := (
        
        -- Simple Computation
        --      1               2               3
        0 => B"00001", 1  => B"00010", 2  => B"00011",
        
        -- Max positive value
        --      15              15              15
        3 => B"01111", 4  => B"01111", 5  => B"01111",
        
        -- Max negative value
        --      -16             -16             -16
        6 => B"10000", 7  => B"10000", 8  => B"10000",
        
        -- Complex Computation
        --      11              -4              -9
        9 => B"01011", 10 => B"11100", 11 => B"10111",

        -- Catch all
        OTHERS => B"00000"
        );

BEGIN

-- Asynchronous read
Data_out <= ROM_Matrix(TO_INTEGER(Addr)); 

END Behavioral;