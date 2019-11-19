LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;

-- Datapath for the Matrix Multiplier:
    -- Acts on the instructions sent by the control logic.
    -- Ties all data lines from all memory units (2xRom & 1xRAM) 
    --   to the multiply-accumulate unit (MACC).

ENTITY Datapath IS
    GENERIC (
        data_size  : NATURAL;
        H          : NATURAL;
        M          : NATURAL;
        N          : NATURAL
    );

    PORT ( 
        clk             : IN  STD_LOGIC;
        -- Control Inputs
        macc_en         : IN  STD_LOGIC; -- Enables data to be written to the ACC register
        ram_en          : IN  STD_LOGIC; -- Enables RAM 'write_en'
        rst_reg         : IN  STD_LOGIC; -- Resets ACC register
        Addr_ROM_A      : IN  UNSIGNED (log2(H * M) - 1 DOWNTO 0); -- Address ROM A
        Addr_ROM_B      : IN  UNSIGNED (log2(N * M) - 1 DOWNTO 0); -- Address ROM B
        Addr_RAM        : IN  UNSIGNED (log2(H * N) - 1 DOWNTO 0); -- Address RAM
        -- Matrix Product Output
        Matrix_Product  : OUT SIGNED (size(M*2**(2*(data_size-1))) DOWNTO 0)
    );

END Datapath;

ARCHITECTURE Behavioral OF Datapath IS
    
    -- Internal Data Buses
    SIGNAL ROM_DataA  : SIGNED (data_size - 1 DOWNTO 0);
    SIGNAL ROM_DataB  : SIGNED (data_size - 1 DOWNTO 0);
    SIGNAL MACC_out   : SIGNED (size(M*2**(2*(data_size-1))) DOWNTO 0);

BEGIN

-- ROM A
MatrixA_ROM: ENTITY work.ROM_A
    GENERIC MAP (
        data_size => data_size,
        H         => H,
        M         => M
    )
    PORT MAP (
        Addr     => Addr_ROM_A,
        Data_out => ROM_DataA
    );

-- ROM B
MatrixB_ROM: ENTITY work.ROM_B
    GENERIC MAP (
        data_size => data_size,
        M         => M,
        N         => N
    )
    PORT MAP (
        Addr     => Addr_ROM_B,
        Data_out => ROM_DataB
    );

-- MACC
MACC: ENTITY work.MACC
    GENERIC MAP (
        data_size => data_size,
        M         => M
    )
    PORT MAP (
        clk      => clk,     
        rst_reg  => rst_reg,     
        en       => macc_en,
        DataA_in => ROM_DataA,
        DataB_in => ROM_DataB,
        MACC_out => MACC_out
    );

-- RAM
Matrix_RAM: ENTITY work.RAM
    GENERIC MAP (
        data_size => data_size,
        H         => H,
        M         => M,
        N         => N
    )
    PORT MAP (
        clk      => clk,
        write_en => ram_en,
        Data_in  => MACC_out,
        Addr     => Addr_RAM,
        RAM_out  => Matrix_Product
    );

END Behavioral;