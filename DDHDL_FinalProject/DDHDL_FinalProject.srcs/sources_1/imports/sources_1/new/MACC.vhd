LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;

-- Multiply-Accumulate Unit (MACC) for Matrix Multiplication.
    -- Consists of a multiplier coupled with an adder.
    -- Calculates the product-sum of the matrix coefficient as 
    --   'Count_M' cycles through.
    -- Computation is complete when 'Count_M' reaches it's max value.


ENTITY MACC IS
    GENERIC (
        data_size : NATURAL;
        M         : NATURAL
    );

    PORT ( 
        clk      : IN  STD_LOGIC;
        -- Control Inputs
        rst_reg  : IN  STD_LOGIC; -- Register reset
        en       : IN  STD_LOGIC; -- MACC enable
        DataA_in : IN  SIGNED (data_size - 1 DOWNTO 0); -- ROM A data input
        DataB_in : IN  SIGNED (data_size - 1 DOWNTO 0); -- ROM B data input
        -- MACC Data Output
        MACC_out : OUT SIGNED (size(M*2**(2*(data_size-1))) DOWNTO 0)
    );

END MACC;

ARCHITECTURE Behavioral OF MACC IS
    
    -- Register I/O
    SIGNAL ACC_in  : STD_LOGIC_VECTOR(size(M*2**(2*(data_size-1))) DOWNTO 0);
    SIGNAL ACC_out : STD_LOGIC_VECTOR(size(M*2**(2*(data_size-1))) DOWNTO 0);

BEGIN

-- Parameterizable Register
ACC_reg: ENTITY work.param_register
    GENERIC MAP (
        data_size => size(M*2**(2*(data_size-1))) + 1
    )
    PORT MAP (
        clk      => clk,
        rst_reg  => rst_reg,
        en       => en,
        Data_in  => ACC_in,
        Data_out => ACC_out
    );

-- Product-Sum Operation
ACC_in   <= STD_LOGIC_VECTOR((DataA_in * DataB_in) + SIGNED(ACC_out));

MACC_out <= SIGNED(ACC_out);

END Behavioral;