LIBRARY IEEE;
USE     IEEE.STD_LOGIC_1164.ALL;
USE     IEEE.NUMERIC_STD.ALL;
USE     work.DigEng.ALL;
--  _____          _    _                    _    
-- |_   _|___  ___| |_ | |__  ___  _ _   __ | |_  
--   | | / -_)(_-<|  _|| '_ \/ -_)| ' \ / _|| ' \ 
--   |_| \___|/__/ \__||_.__/\___||_||_|\__||_||_|
--      
-- Self-Checking Testbench for Matrix Multiplier Project:
--     Test method includes checking a test array of matrix outputs against 
--       the output of the RAM.
--     The 'VERIFY' process tests the functions of 'Reset', 'Next', 'Hold',
--       'Shift Left' and 'Shift Right'.
--
-- Information on each function's tests are displayed in the TCL Console with 
--   any relevant data on failures.
                                                       
ENTITY Matrix_Multiplier_tb IS
    
END Matrix_Multiplier_tb;

ARCHITECTURE Behavioral OF Matrix_Multiplier_tb IS
    
    -- Generic/Constant Values
    CONSTANT data_size   : NATURAL := 5;
    CONSTANT H           : NATURAL := 4;
    CONSTANT M           : NATURAL := 3;
    CONSTANT N           : NATURAL := 5;

    -- Internal Signals
    SIGNAL   clk, rst, nxt      : STD_LOGIC; -- Clock & user inputs
    SIGNAL   Matrix_Product     : SIGNED (size(M*2**(2*(data_size-1))) DOWNTO 0);
    -- Clock Period
    CONSTANT clk_period         : TIME := 10 ns;
    

    -- Test Vector Array
    TYPE Output_Test IS ARRAY (0 TO (H * N) - 1) OF SIGNED (size(M*2**(2*(data_size-1))) DOWNTO 0);
        SIGNAL Matrix_Test: Output_Test := (
            -- Verify Computation of matrices A and B.
            0  => (B"00000001110"), 1  => (B"00001011010"), 2  => (B"11110100000"), 3  => (B"11111101101"), 4  => (B"00000000000"),
            5  => (B"00001011010"), 6  => (B"01010100011"), 7  => (B"10100110000"), 8  => (B"11101111001"), 9  => (B"00000000000"),
            10 => (B"11110100000"), 11 => (B"10100110000"), 12 => (B"01100000000"), 13 => (B"00010010000"), 14 => (B"00000000000"),
            -- Verify Testbench (Expected outputs are 1 higher than observed outputs).
            15 => (B"11111101001"), 16 => (B"11111100011"), 17 => (B"00000100001"), 18 => (B"00001001000"), 19 => (B"00000000001")
        );

BEGIN

-- Unit Under Test: Matrix_Multiplier
UUT: ENTITY work.Matrix_Multiplier
    GENERIC MAP (
        data_size => data_size,
        H         => H, 
        M         => M,  
        N         => N        
    )
    PORT MAP (
        -- Master Clock
        clk            => clk,
        -- User Inputs
        rst            => rst,
        nxt            => nxt,
        -- Outputs
        Matrix_Product => Matrix_Product
    );

-- Clock Process (Sequential)
clk_process: PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
END PROCESS;

-- Test Method (Sequential)
VERIFY: PROCESS
    BEGIN
        -- Global reset...
        WAIT FOR 100 ns;
        
        -- Sync to falling edge.
        WAIT UNTIL FALLING_EDGE(clk);
        
        -- Set internal signals to '0'.
        rst <= '0';
        nxt <= '0';
        WAIT FOR clk_period * 10;
        
        -- Reset toggle to initialise components.
        rst <= '1';
        WAIT FOR clk_period * 20;
        rst <= '0';
        WAIT FOR clk_period * 20;
        
-- TEST 1: TESTING COMPLETE MATRIX VALUES SIGNAL:

        -- Verify matrix coefficient 'i' computation.
        FOR i IN Output_Test'RANGE LOOP
        
            nxt <= '1';
            WAIT FOR clk_period * 20;

                -- Test Failed
            ASSERT (Matrix_Test(i) = Matrix_Product)
            REPORT "TEST 1: *** MATRIX MULTIPLICATION FAILED *** => Coefficient { " & INTEGER'image(i) &
		    " }, Expected Output { " & INTEGER'image(TO_INTEGER(Matrix_Test(i))) &
		    " }, Observed Output { " & INTEGER'image(TO_INTEGER(Matrix_Product)) & " }"
            SEVERITY error;
                -- Test Successful
            ASSERT (Matrix_Test(i) /= Matrix_Product)
            REPORT "TEST 1: Computation Successful for Coefficient " & INTEGER'image(i) & "!"
            SEVERITY note;
            
            nxt <= '0';
            WAIT FOR clk_period * 20; -- Wait period to imitate real user input.
            
        END LOOP;

-- TEST 2: TESTING MACC REGISTER AND COUNTER ADDRESS RESET:
        
        -- Reset.
        rst <= '1';
        WAIT FOR clk_period * 20;
        rst <= '0';
        WAIT FOR clk_period * 20;
        
        -- Check system returns to first coefficient.
        nxt <= '1';
        WAIT FOR clk_period * 20;
            -- Test Failed
        ASSERT (Matrix_Test(0) = Matrix_Product)
        REPORT "TEST 2: *** MATRIX RESET FAILED *** =>" &
		" Expected Output { " & INTEGER'image(TO_INTEGER(Matrix_Test(0))) &
	    " }, Observed Output { " & INTEGER'image(TO_INTEGER(Matrix_Product)) & " }"
        SEVERITY error;
            -- Test Successful
        ASSERT (Matrix_Test(0) /= Matrix_Product)
        REPORT "TEST 2: Reset Successful!"
        SEVERITY note;
        
        nxt <= '0';
        WAIT FOR clk_period * 20;

-- TEST 3: TESTING MID-STATE CALCULATION RESET:
        
        -- Reset.
        rst <= '1';
        WAIT FOR clk_period * 20;
        rst <= '0';
        WAIT FOR clk_period * 20;

        -- Verify first 5 matrix coefficient 'j' computation.
        FOR j IN 0 TO 4 LOOP
        
            nxt <= '1';
            WAIT FOR clk_period * 20;

                -- Test Failed
            ASSERT (Matrix_Test(j) = Matrix_Product)
            REPORT "TEST 3: *** MATRIX MULTIPLICATION FAILED *** => Coefficient { " & INTEGER'image(j) &
		    " }, Expected Output { " & INTEGER'image(TO_INTEGER(Matrix_Test(j))) &
		    " }, Observed Output { " & INTEGER'image(TO_INTEGER(Matrix_Product)) & " }"
            SEVERITY error;
                -- Test Successful
            ASSERT (Matrix_Test(j) /= Matrix_Product)
            REPORT "TEST 3: Computation Successful for Coefficient " & INTEGER'image(j) & "!"
            SEVERITY note;
            
            nxt <= '0';
            WAIT FOR clk_period * 20; -- Wait period to imitate real input.
            
        END LOOP;
                
        -- Mid-state (CALC_MACC) reset.
        nxt <= '1';
        WAIT FOR clk_period * 4;
        rst <= '1';
        WAIT FOR clk_period * 20;
        
        nxt <= '0';
        WAIT FOR clk_period * 20;
        rst <= '0';
        WAIT FOR clk_period * 20;
        
        -- Check system returns to first coefficient.
        nxt <= '1';
        WAIT FOR clk_period * 20;
            -- Test Failed
        ASSERT (Matrix_Test(0) = Matrix_Product)
        REPORT "TEST 3: *** MATRIX MID-STATE RESET FAILED *** =>" &
	    " Expected Output { " & INTEGER'image(TO_INTEGER(Matrix_Test(0))) &
	    " }, Observed Output { " & INTEGER'image(TO_INTEGER(Matrix_Product)) & " }"
        SEVERITY error;
            -- Test Successful
        ASSERT (Matrix_Test(0) /= Matrix_Product)
        REPORT "TEST 3: Mid-State Reset Successful!"
        SEVERITY note;
        
        nxt <= '0';
        WAIT FOR clk_period * 20;
        
-- TEST 4: TEST "FREEZE" BEHAVIOUR WHEN 'DONE' SIGNAL HIGH 
                
        -- Reset.
        rst <= '1';
        WAIT FOR clk_period * 20;
        rst <= '0';
        WAIT FOR clk_period * 20;

        -- Verify all matrix coefficients.
        FOR k IN Output_Test'RANGE LOOP
        
            nxt <= '1';
            WAIT FOR clk_period * 20;

                -- Test Failed
            ASSERT (Matrix_Test(k) = Matrix_Product)
            REPORT "TEST 4: *** MATRIX MULTIPLICATION FAILED *** => Coefficient { " & INTEGER'image(k) &
		    " }, Expected Output { " & INTEGER'image(TO_INTEGER(Matrix_Test(k))) &
		    " }, Observed Output { " & INTEGER'image(TO_INTEGER(Matrix_Product)) & " }"
            SEVERITY error;
                -- Test Successful
            ASSERT (Matrix_Test(k) /= Matrix_Product)
            REPORT "TEST 4: Computation Successful for Coefficient " & INTEGER'image(k) & "!"
            SEVERITY note;
            
            nxt <= '0';
            WAIT FOR clk_period * 20; -- Wait period to imitate real input.
            
        END LOOP;
        
        -- Verify 'Done' Signal
        nxt <= '1';
        WAIT FOR clk_period * 20;
        
            -- Test Failed (Coefficient '19' is 1 higher than true output, thus '- 1')
        ASSERT (TO_INTEGER(Matrix_Test(19) - 1) = TO_INTEGER(Matrix_Product))
        REPORT "TEST 4: *** MATRIX FREEZE FAILED *** => " &
		" Expected Output { " & INTEGER'image(TO_INTEGER(Matrix_Test(19) - 1)) &
	    " }, Observed Output { " & INTEGER'image(TO_INTEGER(Matrix_Product)) & " }"
        SEVERITY error;
            -- Test Successful
        ASSERT (TO_INTEGER(Matrix_Test(19) - 1) /= TO_INTEGER(Matrix_Product))
        REPORT "TEST 4: Freeze Behaviour Successful!"
        SEVERITY note;
   
        -- End Testing
        REPORT "*** TEST COMPLETE ***";
        WAIT; -- Wait forever...
        
END PROCESS;

END Behavioral;    