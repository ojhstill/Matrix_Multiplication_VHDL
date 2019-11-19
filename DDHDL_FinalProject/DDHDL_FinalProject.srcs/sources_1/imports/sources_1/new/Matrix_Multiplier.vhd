LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     WORK.DigEng.ALL;

--  __  __        _         _      
-- |  \/  | __ _ | |_  _ _ (_)__ __
-- | |\/| |/ _` ||  _|| '_|| |\ \ /
-- |_|  |_|\__,_| \__||_|  |_|/_\_\
--     __  __        _  _    _        _  _           
--    |  \/  | _  _ | || |_ (_) _ __ | |(_) ___  _ _ 
--    | |\/| || || || ||  _|| || '_ \| || |/ -_)| '_|
--    |_|  |_| \_,_||_| \__||_|| .__/|_||_|\___||_|  
--                             |_|                                                    
--
-- Top Level Source for Matrix Multiplier:
--      Inputs two matrices of sizes [HxM] and [MxN] and outputs 
--        the resulting matrix of size [HxN].
--      The next incremental coefficient product is displayed on 
--        each user 'nxt' input.
--      Component ties together the user inputs to the 
--        Control Logic and Datapath.
--
-- STD_LOGIC singals are expressed as lower case 
--    while vector/bus signals are capitalised.

ENTITY Matrix_Multiplier IS
    GENERIC (
        data_size  : NATURAL := 5;
        H          : NATURAL := 4;
        M          : NATURAL := 3;
        N          : NATURAL := 5
    );

    PORT (
        -- Master Clock
        clk             : in  STD_LOGIC;
        -- User Inputs
        rst             : in  STD_LOGIC;
        nxt             : in  STD_LOGIC;
        -- Coefficient Output
        Matrix_Product  : out SIGNED (size(M*2**(2*(data_size-1))) downto 0)
    );
           
END Matrix_Multiplier;

ARCHITECTURE Behavioral OF Matrix_Multiplier IS

    SIGNAL deb_rst, deb_nxt  : STD_LOGIC;  -- Debounced "reset" and "next" signals.
    SIGNAL macc_en, ram_en, rst_reg   : STD_LOGIC; -- Control/Datapath signal links.
    SIGNAL Addr_ROM_A  : UNSIGNED (log2(H * M) - 1 downto 0); -- Datapath ROM_A address.
    SIGNAL Addr_ROM_B  : UNSIGNED (log2(M * N) - 1 downto 0); -- Datapath ROM_B address.
    SIGNAL Addr_RAM    : UNSIGNED (log2(H * N) - 1 downto 0); -- Datapath RAM address.

BEGIN

-- Debouncer for 'RST' signal
Rst_Debouncer: ENTITY work.Debouncer
    PORT MAP (
        clk     => clk,
        Sig     => rst,
        Deb_Sig => deb_rst
    );

-- Debouncer for 'NXT' signal
Next_Debouncer: ENTITY work.Debouncer
    PORT MAP (
        clk     => clk,
        Sig     => nxt,
        Deb_Sig => deb_nxt
    );

-- Control Logic
Control_Logic: ENTITY work.Control_Logic
    GENERIC MAP (
        data_size  => data_size,
        H          => H,
        M          => M,
        N          => N
    )
    PORT MAP (
        CLK        => CLK,
        RST        => deb_rst,
        NXT        => deb_nxt,
        macc_en    => macc_en,
        ram_en     => ram_en,
        rst_reg    => rst_reg,
        Addr_ROM_A => Addr_ROM_A,
        Addr_ROM_B => Addr_ROM_B,
        Addr_RAM   => Addr_RAM
    );

-- Datapath
Datapath: ENTITY work.Datapath
    GENERIC MAP (
        data_size => data_size,
        H         => H,
        M         => M,
        N         => N
    )
    PORT MAP (
        CLK            => CLK,     
        macc_en        => macc_en,
        ram_en         => ram_en,
        rst_reg        => rst_reg,
        Addr_ROM_A     => Addr_ROM_A,
        Addr_ROM_B     => Addr_ROM_B,
        Addr_RAM       => Addr_RAM,
        Matrix_Product => Matrix_Product
    );

END Behavioral;