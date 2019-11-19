LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;

-- Control Logic for Matrix Multiplier:
    -- Sets the instructions to be sent to the Datapath.
    -- Contains finite-state-machine, parameter counters, and output assignments.

ENTITY Control_Logic IS
    GENERIC (
        data_size  : NATURAL;
        H          : NATURAL;
        M          : NATURAL;
        N          : NATURAL
    );

    PORT ( 
        clk        : IN    STD_LOGIC;
        -- User Inputs
        rst        : IN    STD_LOGIC;
        nxt        : IN    STD_LOGIC;
        -- Control Outputs
        macc_en    : OUT   STD_LOGIC; -- MACC register enable
        rst_reg    : OUT   STD_LOGIC; -- MACC register reset
        ram_en     : OUT   STD_LOGIC; -- RAM write enable
        -- Address Outputs
            -- Size is computed using the log2 function. 
        Addr_ROM_A : OUT   UNSIGNED (log2(H * M) - 1 DOWNTO 0);
        Addr_ROM_B : OUT   UNSIGNED (log2(N * M) - 1 DOWNTO 0);
        Addr_RAM   : OUT   UNSIGNED (log2(H * N) - 1 DOWNTO 0)
    );

END Control_Logic;

ARCHITECTURE Behavioral OF Control_Logic IS

    -- FSM State Definitions
    TYPE Control_states IS ( 
		WAIT_ST,    -- Wait State: Wait and hold until 'nxt' signal.
		COUNT_ADDR, -- Count Address: Sets the matrix to the next address.
		CALC_MACC,  -- Calculate: MACC computation for product sum.
		STORE_RAM   -- Store State: Stores data_out from MACC to RAM.
		);
		
    -- State Type Signals
    SIGNAL state, next_state : Control_states;
    
    -- Control Signals
    SIGNAL done : STD_LOGIC; -- State "Freeze"
    SIGNAL M_en, H_en, N_en : STD_LOGIC; -- Counter enables
    
    -- Count Signals
    SIGNAL Count_M : UNSIGNED (log2(M) - 1 DOWNTO 0);
    SIGNAL Count_H : UNSIGNED (log2(H) - 1 DOWNTO 0);
    SIGNAL Count_N : UNSIGNED (log2(N) - 1 DOWNTO 0);

BEGIN

-- State Reset Process
    -- Resets FSM to state = CALC_MACC to compute first coefficient.
state_rst: PROCESS (clk) IS
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF (rst = '1') THEN
                state <= CALC_MACC;
            ELSE
                state <= next_state;
            END IF;
        END IF;
END PROCESS state_rst;


-- Counter Entities
    -- Counter Address M
AddrM_Counter: ENTITY work.Param_counter
    GENERIC MAP (
        LIMIT => M )
    PORT MAP (
        clk => clk,
        rst => rst,
        en  => M_en,
        count_out => Count_M
    );

    -- Counter Address H
AddrH_Counter: ENTITY work.Param_counter
    GENERIC MAP (
        LIMIT => H )
    PORT MAP (
        clk => clk,
        rst => rst,
        en  => H_en,
        count_out => Count_H
    );

    -- Counter Address N
AddrN_Counter: ENTITY work.Param_counter
    GENERIC MAP (
        LIMIT => N )
    PORT MAP (
        clk => clk,
        rst => rst,
        en  => N_en,
        count_out => Count_N
    );

-- Transition parameters between FSM states.
    -- Coefficient is calculated on each 'nxt' button press 
    --  and freezes in 'WAIT_ST' when matrix is complete.
state_transitions: PROCESS (state, nxt, Count_M) IS
    BEGIN
        CASE state IS
            WHEN WAIT_ST =>
                IF (nxt = '1') THEN 
                    next_state <= STORE_RAM;
                ELSE
                    next_state <= state;
                END IF;
                
            WHEN STORE_RAM =>
                IF (done = '0') THEN 
                    next_state <= COUNT_ADDR;
                ELSE -- ELSE IF done = '1', go back to WAIT_ST
                    next_state <= WAIT_ST;
                END IF;

            WHEN COUNT_ADDR =>
                next_state <= CALC_MACC;

            WHEN CALC_MACC =>
                IF (Count_M = M - 1) THEN
                    next_state <= WAIT_ST;
                ELSE
                    next_state <= state;
                END IF;
                
        END CASE;
END PROCESS state_transitions;

-- OUTPUT ASSIGNMENTS

-- M_Counter Enable
M_en    <=  '0' WHEN state = WAIT_ST    ELSE
            '0' WHEN state = STORE_RAM  ELSE
            '0' WHEN state = COUNT_ADDR ELSE
            '1' WHEN state = CALC_MACC  ELSE
            'U';

-- H_Counter Enable
		-- Count_H increments with Count_N reaches limit.
H_en    <=  '0' WHEN state = WAIT_ST    ELSE
            '0' WHEN state = STORE_RAM  ELSE
            '1' WHEN state = COUNT_ADDR AND 
                     Count_N  = (N - 1) ELSE
            '0' WHEN state = COUNT_ADDR AND 
                     Count_N /= (N - 1) ELSE
            '0' WHEN state = CALC_MACC  ELSE
            'U';
            
-- N_Counter Enable
N_en    <=  '0' WHEN state = WAIT_ST    ELSE
            '0' WHEN state = STORE_RAM  ELSE
            '1' WHEN state = COUNT_ADDR ELSE
            '0' WHEN state = CALC_MACC  ELSE
            'U';

-- Done/Freeze Signal
	-- Dependent on count limits of Count_H and Count_N.
done    <=  '1' WHEN Count_H = (H - 1)  AND 
                     Count_N = (N - 1)  ELSE
            '0';

-- MACC Calculation Enable
macc_en <=  '0' WHEN state = WAIT_ST    ELSE
            '0' WHEN state = STORE_RAM  ELSE
            '0' WHEN state = COUNT_ADDR ELSE
            '1' WHEN state = CALC_MACC  ELSE
            'U';

-- Register Reset
	-- On 'rst' button press and after computation is complete.
rst_reg <=  rst WHEN state = WAIT_ST    ELSE  
            rst WHEN state = STORE_RAM  ELSE   
            '1' WHEN state = COUNT_ADDR ELSE   
            rst WHEN state = CALC_MACC  ELSE   
            'U';                               

-- RAM Write Enable
ram_en  <=  '0' WHEN state = WAIT_ST    ELSE
            '1' WHEN state = STORE_RAM  ELSE
            '0' WHEN state = COUNT_ADDR ELSE
            '0' WHEN state = CALC_MACC  ELSE
            'U';

-- Address Combinational Logic
Addr_ROM_A <= RESIZE((Count_H * TO_UNSIGNED(M, log2(M))) + Count_M, log2(M * H));
Addr_ROM_B <= RESIZE((Count_M * TO_UNSIGNED(N, log2(N))) + Count_N, log2(M * N));
Addr_RAM   <= RESIZE((Count_H * TO_UNSIGNED(N, log2(N))) + Count_N, log2(N * H));

END Behavioral;