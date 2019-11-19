LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;

ENTITY MACC_tb IS
    GENERIC (
        data_size   : natural := 5;
        H           : natural := 3;
        M           : natural := 2;
        N           : natural := 3
    );

END MACC_tb;

ARCHITECTURE Behavioral OF MACC_tb IS

    SIGNAL   CLK, RST, EN       : STD_LOGIC;
    SIGNAL   DataA_in, DataB_in : SIGNED (data_size - 1 downto 0);
    SIGNAL   MACC_out           : SIGNED (size(M*2**(2*(data_size-1))) downto 0);
    CONSTANT CLK_period         : time := 10 ns;
    
    
BEGIN

UUT: ENTITY work.MACC
    GENERIC MAP (
        data_size => data_size,
        M         => M
    )
    PORT MAP (
        -- Inputs
        clk      => clk,
        rst_reg  => rst,
        en       => en,
        DataA_in => DataA_in,
        DataB_in => DataB_in,
        -- Outputs
        MACC_out => MACC_out
    );

-- Clock Process
clk_process: PROCESS
    BEGIN
        clk <= '1';
        wait for CLK_period/2;
        clk <= '0';
        wait for CLK_period/2;
    END PROCESS;
    
TEST: PROCESS
    BEGIN
        -- Global Reset
        wait for 100 ns;
        
        wait until falling_edge(clk);
        
        -- 'RST' toggle to '0'
        rst  <= '0';
        wait for clk_period * 2;
        rst  <= '1';
        wait for clk_period * 2;
        rst  <= '0';
        wait for clk_period * 2;
        
        en <= '0';
        wait for clk_period * 2;
        en <= '0';
        wait for clk_period * 2;
        
        en <= '1';
        DataA_in <= "00100";
        DataB_in <= "00011";
        wait for clk_period;
        
        en <= '1';
        DataA_in <= "00111";
        DataB_in <= "00100";
        wait for clk_period;
        en <= '0';
        wait for clk_period * 2;
        
        -- Wait Forever
        wait;

    END PROCESS;

END Behavioral;
