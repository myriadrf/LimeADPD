-- ----------------------------------------------------------------------------	
-- FILE: 	phequfe.vhd
-- DESCRIPTION:	Filtering engine of the phase equaliser.
-- DATE:	Sep 04, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.mem_package.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
ENTITY phequfehf_bj4 IS
    PORT (
        x : IN std_logic_vector(24 DOWNTO 0); -- Input signal
        n : IN std_logic_vector(7 DOWNTO 0);

        -- Filter configuration
        h0, h1, h2, h3, h4 : IN std_logic_vector(15 DOWNTO 0);
        a : IN std_logic_vector(1 DOWNTO 0); 
        xen, ien, odd, half : IN std_logic;

        -- Clock related inputs
        sleep : IN std_logic; -- Sleep signal
        clk : IN std_logic; -- Clock
        reset : IN std_logic; -- Reset

        y : OUT std_logic_vector(24 DOWNTO 0); -- Filter output
        xo : OUT std_logic_vector(24 DOWNTO 0) -- DRAM output
    );
END phequfehf_bj4;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE phequfehf_arch_bj OF phequfehf_bj4 IS

    -- Signals
    SIGNAL x0, x1, x2, x3, x4, x5, x6, x7, x8, x9 : std_logic_vector(24 DOWNTO 0);
    SIGNAL xc5, xc6, xc7, xc8, xc9 : std_logic_vector(24 DOWNTO 0);
    SIGNAL x00, x11, x22, x33, x44 : std_logic_vector(25 DOWNTO 0);

    SIGNAL y1 : std_logic_vector(25 DOWNTO 0);
    SIGNAL en : std_logic;

    -- Logic constants
    SIGNAL zero : std_logic;

    -- Component declarations
    USE work.components.dmem4x25;
    USE work.components.accu10x26mac;

    FOR ALL : dmem4x25 USE ENTITY work.dmem4x25(dmem4x25_arch); 	
    FOR ALL : accu10x26mac USE ENTITY work.accu10x26mac(accu10x26mac_arch);

    COMPONENT Multiplier2 IS
        PORT (
            dataa : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
            datab : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
        );
    END COMPONENT Multiplier2;

    COMPONENT dmem4x25_modified IS
        PORT (
            SIGNAL N: IN std_logic_vector(1 downto 0);
            SIGNAL x : IN std_logic_vector(24 DOWNTO 0); -- Data input
            SIGNAL clk, reset, en, odd : IN std_logic;
            SIGNAL a1, a2 : IN std_logic_vector(1 DOWNTO 0); -- Address  
            SIGNAL d1, d2 : OUT mword25 -- Data output
        );
    END COMPONENT dmem4x25_modified;

    COMPONENT adder IS
        GENERIC (
            res_n : NATURAL := 18; 
            op_n : NATURAL := 18; 
            addi : NATURAL := 1); 
        PORT (
            dataa : IN std_logic_vector (op_n - 1 DOWNTO 0);
            datab : IN std_logic_vector (op_n - 1 DOWNTO 0);
            res : OUT std_logic_vector (res_n - 1 DOWNTO 0)
        );
    END COMPONENT Adder;

    SIGNAL h0prim, h1prim, h2prim, h3prim, h4prim : std_logic_vector(17 DOWNTO 0); 
    SIGNAL x0prim, x1prim, x2prim, x3prim, x4prim : std_logic_vector(17 DOWNTO 0); 
    SIGNAL res0, res1, res2, res3, res4 : std_logic_vector(35 DOWNTO 0); 
    SIGNAL res0prim, res1prim, res2prim, res3prim, res4prim : std_logic_vector(25 DOWNTO 0); 
    SIGNAL res0sec, res1sec, res2sec, res3sec, res4sec, res0ter, res1ter : std_logic_vector(25 DOWNTO 0); 
    SIGNAL xensec, xenter, xenquad : std_logic;

    SIGNAL nega, n1 : std_logic_vector(1 DOWNTO 0);
    SIGNAL zeroes, temp : std_logic_vector(25 DOWNTO 0);

BEGIN

    zero <= '0';
    en <= NOT sleep;
    n1 <= n(1 downto 0);

    -- Data memory modules
    dmem0 : dmem4x25 PORT MAP(
        x => x, clk => clk, reset => reset, en => xen,
        a => a, d => x0);

    dmem1 : dmem4x25 PORT MAP(
        x => x0, clk => clk, reset => reset, en => xen,
        a => a, d => x1);

    dmem2 : dmem4x25 PORT MAP(
        x => x1, clk => clk, reset => reset, en => xen,
        a => a, d => x2);

    dmem3 : dmem4x25 PORT MAP(
        x => x2, clk => clk, reset => reset, en => xen,
        a => a, d => x3);

    dmem4 : dmem4x25 PORT MAP( 
        x => x3, clk => clk, reset => reset, en => xen,
        a => a, d => x4);

    dmem5 : dmem4x25_modified PORT MAP( n => n1,
        x => x4, clk => clk, reset => reset, en => xen,
        a1 => a, a2 => nega, d1 => x5, d2 => xc5, odd => odd);

    dmem6 : dmem4x25_modified PORT MAP( n => n1,
        x => x5, clk => clk, reset => reset, en => xen,
        a1 => a, a2 => nega, d1 => x6, d2 => xc6, odd => '0');

    dmem7 : dmem4x25_modified PORT MAP( n => n1,
        x => x6, clk => clk, reset => reset, en => xen,
        a1 => a, a2 => nega, d1 => x7, d2 => xc7, odd => '0');

    dmem8 : dmem4x25_modified PORT MAP( n => n1,
        x => x7, clk => clk, reset => reset, en => xen,
        a1 => a, a2 => nega, d1 => x8, d2 => xc8, odd => '0');

    dmem9 : dmem4x25_modified PORT MAP( n => n1,
        x => x8, clk => clk, reset => reset, en => xen,
        a1 => a, a2 => nega, d1 => x9, d2 => xc9, odd => '0');

    Adder0 : adder GENERIC MAP(res_n => 26, op_n => 25, addi => 1) PORT MAP(dataa => x0, datab => xc9, res => x00);
    Adder1 : adder GENERIC MAP(res_n => 26, op_n => 25, addi => 1) PORT MAP(dataa => x1, datab => xc8, res => x11);
    Adder2 : adder GENERIC MAP(res_n => 26, op_n => 25, addi => 1) PORT MAP(dataa => x2, datab => xc7, res => x22);
    Adder3 : adder GENERIC MAP(res_n => 26, op_n => 25, addi => 1) PORT MAP(dataa => x3, datab => xc6, res => x33);
    Adder4 : adder GENERIC MAP(res_n => 26, op_n => 25, addi => 1) PORT MAP(dataa => x4, datab => xc5, res => x44);
    
    PROCESS (n1, a) IS
    BEGIN
        nega <= n1 - a;
    END PROCESS;

    h0prim <= h0 & "00"; -- 18 bit
    x0prim <= x00(25 DOWNTO 8) WHEN half = '0' ELSE
        x0(24) & x0(24 DOWNTO 8);
    Mult0 : multiplier2 PORT MAP(dataa => x0prim, datab => h0prim, result => res0);

    h1prim <= h1 & "00"; -- 18 bit
    x1prim <= x11(25 DOWNTO 8) WHEN half = '0' ELSE
        x1(24) & x1(24 DOWNTO 8);
    Mult1 : multiplier2 PORT MAP(dataa => x1prim, datab => h1prim, result => res1);

    h2prim <= h2 & "00"; -- 18 bit
    x2prim <= x22(25 DOWNTO 8) WHEN half = '0' ELSE
        x2(24) & x2(24 DOWNTO 8);
    Mult2 : multiplier2 PORT MAP(dataa => x2prim, datab => h2prim, result => res2);

    h3prim <= h3 & "00"; -- 18 bit
    x3prim <= x33(25 DOWNTO 8) WHEN half = '0' ELSE
        x3(24) & x3(24 DOWNTO 8);
    Mult3 : multiplier2 PORT MAP(dataa => x3prim, datab => h3prim, result => res3);

    h4prim <= h4 & "00"; -- 18 bit
    x4prim <= x44(25 DOWNTO 8) WHEN half = '0' ELSE
        x4(24) & x4(24 DOWNTO 8);
    Mult4 : multiplier2 PORT MAP(dataa => x4prim, datab => h4prim, result => res4);

    res0prim <= res0(34 DOWNTO 9);
    res1prim <= res1(34 DOWNTO 9);
    res2prim <= res2(34 DOWNTO 9);
    res3prim <= res3(34 DOWNTO 9);
    res4prim <= res4(34 DOWNTO 9);

    zeroes <= (OTHERS => '0');

    PROCESS (reset, clk) IS
    BEGIN
        IF reset = '0' THEN
            y <= (OTHERS => '0');
            res0sec <= (OTHERS => '0');
            res1sec <= (OTHERS => '0');
            res2sec <= (OTHERS => '0');
            res3sec <= (OTHERS => '0');
            res4sec <= (OTHERS => '0');

            res0ter <= (OTHERS => '0');
            res1ter <= (OTHERS => '0');

            xensec <= '0';
            xenter <= '0';
            xenquad <= '0';

        ELSIF clk'event AND clk = '1' THEN
            IF (en = '1') THEN
                res0sec <= res0prim;
                res1sec <= res1prim;
                res2sec <= res2prim;
                res3sec <= res3prim;
                res4sec <= res4prim;

                res0ter <= res0sec + res1sec;
                res1ter <= res2sec + res3sec + res4sec;

                xensec <= xen;
                xenter <= xensec;
                xenquad <= xenter;

                y <= y1(24 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;

    PROCESS (reset, clk) IS
    BEGIN
        IF reset = '0' THEN
            temp <= (OTHERS => '0');
            y1 <= (OTHERS => '0');
        ELSIF clk'event AND clk = '1' THEN
            IF en = '1' THEN
                IF (xenquad = '1') THEN
                    temp <= res0ter + res1ter;
                    y1 <= temp;
                ELSE
                    temp <= temp + res0ter + res1ter;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    xo <= x9; 

END phequfehf_arch_bj;