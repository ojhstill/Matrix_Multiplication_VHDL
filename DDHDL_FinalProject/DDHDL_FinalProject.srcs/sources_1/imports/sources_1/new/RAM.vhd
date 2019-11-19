LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;

-- Synchronous Write / Asynchrounous Read (NxH)-bit single-port RAM
    -- Memory Depth => (NxH)
    -- Memory Width => size of Matrix_out [see report documentation].
    
-- Takes Data_out from MACC after coefficient has been calculated.

ENTITY RAM IS
    GENERIC (
        data_size : NATURAL;
        H         : NATURAL;
        M         : NATURAL;
        N         : NATURAL
    );

    PORT (
        clk       : IN  STD_LOGIC;
        -- Inputs
        write_en  : IN  STD_LOGIC; -- RAM write enable
        Addr      : IN  UNSIGNED (log2(H*N) - 1 DOWNTO 0); -- RAM address
        Data_in   : IN  SIGNED (size(M*2**(2*(data_size-1))) DOWNTO 0); -- MACC data in
        -- Output
        RAM_out   : OUT SIGNED (size(M*2**(2*(data_size-1))) DOWNTO 0)
    );

END RAM;

ARCHITECTURE Behavioral OF RAM IS

    -- Internal RAM signals
        -- Internal Address Signal: 
            -- Only changes when write_en = '1' to prevent Data_out as undefined.
    SIGNAL Addr_int : UNSIGNED (log2(H*N) - 1 downto 0);
        -- RAM Array: Sets up an internal array.
    TYPE ram_type IS ARRAY (0 TO (N * H) - 1) OF SIGNED(size(M*2**(2*(data_size-1))) DOWNTO 0);
        SIGNAL ram_inst: ram_type;

BEGIN

-- Synchronous write (write enable signal)
PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN 
            IF (write_en = '1') THEN
                -- Writes 'Data_in' to memory array of index 'Addr'.
                ram_inst(TO_INTEGER(Addr)) <= Data_in;
                -- Assigns new address input to internal address signal.
                Addr_int <= Addr;
            END IF;
        END IF;
END PROCESS;

-- Asynchronous read
RAM_out <= ram_inst(TO_INTEGER(Addr_int));

END Behavioral;