-- ----------------------------------------------------------------------------	
-- FILE: 	data_cap_buffer.vhd
-- DESCRIPTION:	captures number of samples 
-- DATE:	Dec 14, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY data_cap_buffer IS
	PORT (
		wclk0 : IN STD_LOGIC;
		wclk1 : IN STD_LOGIC;
		wclk2 : IN STD_LOGIC;
		wclk3 : IN STD_LOGIC;
		wclk4 : IN STD_LOGIC;
		rdclk : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		reset_n : IN STD_LOGIC;
		--capture data
		XP_valid : IN STD_LOGIC;
		XPI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		XPQ : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		YP_valid : IN STD_LOGIC;
		YPI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		YPQ : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		X_valid : IN STD_LOGIC;
		XI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		XQ : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		XP_1_valid : IN STD_LOGIC;
		XPI_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		XPQ_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		YP_1_valid : IN STD_LOGIC;
		YPI_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		YPQ_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		--capture controll signals
		cap_en : IN STD_LOGIC;
		cap_cont_en : IN STD_LOGIC;
		cap_size : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		cap_done : OUT STD_LOGIC;
		--external fifo signals
		fifo_rdreq : IN STD_LOGIC;
		fifo_q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		fifo_rdempty : OUT STD_LOGIC;
		test_data_en : IN STD_LOGIC
	);
END data_cap_buffer;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE arch OF data_cap_buffer IS
	--declare signals,  components here

	--inst0 signals 
	SIGNAL inst0_reset_n : STD_LOGIC;
	SIGNAL inst0_cap_en : STD_LOGIC;
	SIGNAL inst0_cap_cont_en : STD_LOGIC;
	SIGNAL inst0_cap_done : STD_LOGIC;
	SIGNAL inst0_fifo_wrreq : STD_LOGIC;

	--inst1 signals 
	SIGNAL inst1_reset_n : STD_LOGIC;
	SIGNAL inst1_cap_en : STD_LOGIC;
	SIGNAL inst1_cap_cont_en : STD_LOGIC;
	SIGNAL inst1_cap_done : STD_LOGIC;
	SIGNAL inst1_fifo_wrreq : STD_LOGIC;

	--inst2 signals 
	SIGNAL inst2_reset_n : STD_LOGIC;
	SIGNAL inst2_cap_en : STD_LOGIC;
	SIGNAL inst2_cap_cont_en : STD_LOGIC;
	SIGNAL inst2_cap_done : STD_LOGIC;
	SIGNAL inst2_fifo_wrreq : STD_LOGIC;

	--inst3 signals 
	SIGNAL inst3_reset_n : STD_LOGIC;
	SIGNAL inst3_cap_en : STD_LOGIC;
	SIGNAL inst3_cap_cont_en : STD_LOGIC;
	SIGNAL inst3_cap_done : STD_LOGIC;
	SIGNAL inst3_fifo_wrreq : STD_LOGIC;

	--inst4 signals 
	SIGNAL inst4_reset_n : STD_LOGIC;
	SIGNAL inst4_cap_en : STD_LOGIC;
	SIGNAL inst4_cap_cont_en : STD_LOGIC;
	SIGNAL inst4_cap_done : STD_LOGIC;
	SIGNAL inst4_fifo_wrreq : STD_LOGIC;

	--inst5 signals
	SIGNAL inst5_fifo_0_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst5_fifo_0_wrfull : STD_LOGIC;
	SIGNAL inst5_fifo_0_wrempty : STD_LOGIC;
	SIGNAL inst5_fifo_1_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst5_fifo_1_wrfull : STD_LOGIC;
	SIGNAL inst5_fifo_1_wrempty : STD_LOGIC;
	SIGNAL inst5_fifo_2_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst5_fifo_2_wrfull : STD_LOGIC;
	SIGNAL inst5_fifo_2_wrempty : STD_LOGIC;
	SIGNAL inst5_fifo_3_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst5_fifo_3_wrfull : STD_LOGIC;
	SIGNAL inst5_fifo_3_wrempty : STD_LOGIC;
	SIGNAL inst5_fifo_4_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst5_fifo_4_wrfull : STD_LOGIC;
	SIGNAL inst5_fifo_4_wrempty : STD_LOGIC;
	SIGNAL inst5_fifo_rdempty : STD_LOGIC;

	--general signals
	SIGNAL wclk0_reset_n_sync : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL wclk1_reset_n_sync : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL wclk2_reset_n_sync : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL wclk3_reset_n_sync : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL wclk4_reset_n_sync : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL rdclk_reset_n_sync : STD_LOGIC_VECTOR(1 DOWNTO 0);

	TYPE state_type IS (idle, capture, capture_done, wait_cap_en_low);
	SIGNAL current_state, next_state : state_type;

	SIGNAL cap_en_sync_clk : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL cap_cont_en_sync_clk : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL cap_done_int : STD_LOGIC;
	SIGNAL cap_done_int_sync_clk : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL cap_done_all_inst : STD_LOGIC;
	SIGNAL cap_done_all_inst_sync_rdclk : STD_LOGIC_VECTOR(1 DOWNTO 0);

	COMPONENT data_cap IS
		PORT (
			clk : IN STD_LOGIC;
			reset_n : IN STD_LOGIC;
			--capture signalas
			data_valid : IN STD_LOGIC;
			cap_en : IN STD_LOGIC;
			cap_cont_en : IN STD_LOGIC;
			cap_size : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			cap_done : OUT STD_LOGIC;
			--external fifo signalas
			fifo_wrreq : OUT STD_LOGIC;
			fifo_wfull : IN STD_LOGIC;
			fifo_wrempty : IN STD_LOGIC
		);
	END COMPONENT;
	COMPONENT fifo_buff IS
		GENERIC (
			dev_family : STRING := "Cyclone IV E";
			wrwidth : INTEGER := 32;
			wrusedw_witdth : INTEGER := 15; --15=32768 words 
			rdwidth : INTEGER := 32;
			rdusedw_width : INTEGER := 15;
			show_ahead : STRING := "OFF"
		);

		PORT (
			--fifo 0 ports
			fifo_0_reset_n : IN STD_LOGIC;
			fifo_0_wrclk : IN STD_LOGIC;
			fifo_0_wrreq : IN STD_LOGIC;
			fifo_0_data : IN STD_LOGIC_VECTOR(wrwidth - 1 DOWNTO 0);
			fifo_0_wrfull : OUT STD_LOGIC;
			fifo_0_wrempty : OUT STD_LOGIC;
			--fifo 1 ports
			fifo_1_reset_n : IN STD_LOGIC;
			fifo_1_wrclk : IN STD_LOGIC;
			fifo_1_wrreq : IN STD_LOGIC;
			fifo_1_data : IN STD_LOGIC_VECTOR(wrwidth - 1 DOWNTO 0);
			fifo_1_wrfull : OUT STD_LOGIC;
			fifo_1_wrempty : OUT STD_LOGIC;
			--fifo 2 ports
			fifo_2_reset_n : IN STD_LOGIC;
			fifo_2_wrclk : IN STD_LOGIC;
			fifo_2_wrreq : IN STD_LOGIC;
			fifo_2_data : IN STD_LOGIC_VECTOR(wrwidth - 1 DOWNTO 0);
			fifo_2_wrfull : OUT STD_LOGIC;
			fifo_2_wrempty : OUT STD_LOGIC;
			--fifo 3 ports
			fifo_3_reset_n : IN STD_LOGIC;
			fifo_3_wrclk : IN STD_LOGIC;
			fifo_3_wrreq : IN STD_LOGIC;
			fifo_3_data : IN STD_LOGIC_VECTOR(wrwidth - 1 DOWNTO 0);
			fifo_3_wrfull : OUT STD_LOGIC;
			fifo_3_wrempty : OUT STD_LOGIC;
			--fifo 4 ports
			fifo_4_reset_n : IN STD_LOGIC;
			fifo_4_wrclk : IN STD_LOGIC;
			fifo_4_wrreq : IN STD_LOGIC;
			fifo_4_data : IN STD_LOGIC_VECTOR(wrwidth - 1 DOWNTO 0);
			fifo_4_wrfull : OUT STD_LOGIC;
			fifo_4_wrempty : OUT STD_LOGIC;
			--rd port for all fifo
			fifo_rdclk : IN STD_LOGIC;
			fifo_rdclk_reset_n : IN STD_LOGIC;
			fifo_cap_size : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			fifo_rdreq : IN STD_LOGIC;
			fifo_q : OUT STD_LOGIC_VECTOR(rdwidth - 1 DOWNTO 0);
			fifo_rdempty : OUT STD_LOGIC

		);
	END COMPONENT;

BEGIN

	--indicates when all buffers are collected and data all data has been read from buffers
	cap_done_int <= inst0_cap_done AND inst1_cap_done AND inst2_cap_done AND inst3_cap_done AND inst4_cap_done AND
		inst5_fifo_0_wrempty AND inst5_fifo_1_wrempty AND inst5_fifo_2_wrempty AND inst5_fifo_3_wrempty AND inst5_fifo_4_wrempty;

	--indicates when all data_capture instances are finished collecting buffer
	cap_done_all_inst <= inst0_cap_done AND inst1_cap_done AND inst2_cap_done AND inst3_cap_done AND inst4_cap_done;

	cap_done <= cap_done_int;

	-- ----------------------------------------------------------------------------
	-- to synchronize signals to clk domain
	-- ----------------------------------------------------------------------------
	PROCESS (clk, reset_n)BEGIN
		IF (reset_n = '0') THEN
			cap_en_sync_clk <= (OTHERS => '0');
			cap_cont_en_sync_clk <= (OTHERS => '0');
			cap_done_int_sync_clk <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
			cap_en_sync_clk <= cap_en_sync_clk(0) & cap_en;
			cap_cont_en_sync_clk <= cap_cont_en_sync_clk(0) & cap_cont_en;
			cap_done_int_sync_clk <= cap_done_int_sync_clk(0) & cap_done_int;
		END IF;
	END PROCESS;

	-- ----------------------------------------------------------------------------
	-- to synchronize signals to rdclk domain
	-- ----------------------------------------------------------------------------
	PROCESS (rdclk, reset_n)BEGIN
		IF (reset_n = '0') THEN
			cap_done_all_inst_sync_rdclk <= (OTHERS => '0');
		ELSIF (rdclk'event AND rdclk = '1') THEN
			cap_done_all_inst_sync_rdclk <= cap_done_all_inst_sync_rdclk(0) & cap_done_all_inst;
		END IF;
	END PROCESS;
	-- ----------------------------------------------------------------------------
	--state machine for controlling capture signal
	-- ----------------------------------------------------------------------------
	fsm_f : PROCESS (clk, reset_n)BEGIN
		IF (reset_n = '0') THEN
			current_state <= idle;
		ELSIF (clk'event AND clk = '1') THEN
			current_state <= next_state;
		END IF;
	END PROCESS;

	-- ----------------------------------------------------------------------------
	--state machine combo
	-- ----------------------------------------------------------------------------
	fsm : PROCESS (current_state, cap_en_sync_clk(1), cap_done_int_sync_clk(1), cap_cont_en_sync_clk(1)) BEGIN
		next_state <= current_state;
		CASE current_state IS

			WHEN idle => --idle state 
				IF cap_en_sync_clk(1) = '1' AND cap_done_int_sync_clk(1) = '0' THEN
					next_state <= capture;
				ELSE
					next_state <= idle;
				END IF;

			WHEN capture =>
				IF cap_done_int_sync_clk(1) = '1' THEN
					next_state <= capture_done;
				ELSE
					next_state <= capture;
				END IF;

			WHEN capture_done =>
				IF cap_cont_en_sync_clk(1) = '1' THEN
					next_state <= idle;
				ELSE
					next_state <= wait_cap_en_low;
				END IF;

			WHEN wait_cap_en_low =>
				IF cap_en_sync_clk(1) = '0' THEN
					next_state <= idle;
				ELSE
					next_state <= wait_cap_en_low;
				END IF;

			WHEN OTHERS =>
				next_state <= idle;
		END CASE;
	END PROCESS;
	-- ----------------------------------------------------------------------------
	-- Reset synchronizations
	-- ----------------------------------------------------------------------------

	--to wclk0 domain
	PROCESS (wclk0, reset_n)BEGIN
		IF (reset_n = '0') THEN
			wclk0_reset_n_sync <= (OTHERS => '0');
		ELSIF (wclk0'event AND wclk0 = '1') THEN
			wclk0_reset_n_sync <= wclk0_reset_n_sync(0) & reset_n;
		END IF;
	END PROCESS;

	--to wclk1 domain
	PROCESS (wclk1, reset_n)BEGIN
		IF (reset_n = '0') THEN
			wclk1_reset_n_sync <= (OTHERS => '0');
		ELSIF (wclk1'event AND wclk1 = '1') THEN
			wclk1_reset_n_sync <= wclk1_reset_n_sync(0) & reset_n;
		END IF;
	END PROCESS;

	--to wclk2 domain
	PROCESS (wclk2, reset_n)BEGIN
		IF (reset_n = '0') THEN
			wclk2_reset_n_sync <= (OTHERS => '0');
		ELSIF (wclk2'event AND wclk2 = '1') THEN
			wclk2_reset_n_sync <= wclk2_reset_n_sync(0) & reset_n;
		END IF;
	END PROCESS;
	--to wclk3 domain
	PROCESS (wclk3, reset_n)BEGIN
		IF (reset_n = '0') THEN
			wclk3_reset_n_sync <= (OTHERS => '0');
		ELSIF (wclk3'event AND wclk3 = '1') THEN
			wclk3_reset_n_sync <= wclk3_reset_n_sync(0) & reset_n;
		END IF;
	END PROCESS;

	--to wclk4 domain
	PROCESS (wclk4, reset_n)BEGIN
		IF (reset_n = '0') THEN
			wclk4_reset_n_sync <= (OTHERS => '0');
		ELSIF (wclk4'event AND wclk4 = '1') THEN
			wclk4_reset_n_sync <= wclk4_reset_n_sync(0) & reset_n;
		END IF;
	END PROCESS;

	--to rdclk domain
	PROCESS (rdclk, reset_n)BEGIN
		IF (reset_n = '0') THEN
			rdclk_reset_n_sync <= (OTHERS => '0');
		ELSIF (rdclk'event AND rdclk = '1') THEN
			rdclk_reset_n_sync <= rdclk_reset_n_sync(0) & reset_n;
		END IF;
	END PROCESS;

	inst0_cap_cont_en <= '0';

	PROCESS (current_state)BEGIN
		IF (current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done) THEN
			inst0_cap_en <= '1';
		ELSE
			inst0_cap_en <= '0';
		END IF;
	END PROCESS;

	data_cap_inst0 : data_cap
	PORT MAP(
		clk => wclk0,
		reset_n => wclk0_reset_n_sync(1),
		data_valid => XP_valid,
		--capture signalas
		cap_en => inst0_cap_en,
		cap_cont_en => inst0_cap_cont_en,
		cap_size => cap_size,
		cap_done => inst0_cap_done,
		--external fifo signalas
		fifo_wrreq => inst0_fifo_wrreq,
		fifo_wfull => inst5_fifo_0_wrfull,
		fifo_wrempty => inst5_fifo_0_wrempty
	);

	inst1_cap_cont_en <= '0';

	PROCESS (current_state)BEGIN
		IF (current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done) THEN
			inst1_cap_en <= '1';
		ELSE
			inst1_cap_en <= '0';
		END IF;
	END PROCESS;

	data_cap_inst1 : data_cap
	PORT MAP(
		clk => wclk1,
		reset_n => wclk1_reset_n_sync(1),
		data_valid => YP_valid,
		--capture signalas
		cap_en => inst1_cap_en,
		cap_cont_en => inst1_cap_cont_en,
		cap_size => cap_size,
		cap_done => inst1_cap_done,
		--external fifo signalas
		fifo_wrreq => inst1_fifo_wrreq,
		fifo_wfull => inst5_fifo_1_wrfull,
		fifo_wrempty => inst5_fifo_1_wrempty
	);
	inst2_cap_cont_en <= '0';

	PROCESS (current_state)BEGIN
		IF (current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done) THEN
			inst2_cap_en <= '1';
		ELSE
			inst2_cap_en <= '0';
		END IF;
	END PROCESS;

	data_cap_inst2 : data_cap
	PORT MAP(
		clk => wclk2,
		reset_n => wclk2_reset_n_sync(1),
		data_valid => X_valid,
		--capture signalas
		cap_en => inst2_cap_en,
		cap_cont_en => inst2_cap_cont_en,
		cap_size => cap_size,
		cap_done => inst2_cap_done,
		--external fifo signalas
		fifo_wrreq => inst2_fifo_wrreq,
		fifo_wfull => inst5_fifo_2_wrfull,
		fifo_wrempty => inst5_fifo_2_wrempty
	);
	inst3_cap_cont_en <= '0';

	PROCESS (current_state)BEGIN
		IF (current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done) THEN
			inst3_cap_en <= '1';
		ELSE
			inst3_cap_en <= '0';
		END IF;
	END PROCESS;

	data_cap_inst3 : data_cap
	PORT MAP(
		clk => wclk3,
		reset_n => wclk3_reset_n_sync(1),
		data_valid => XP_1_valid,
		--capture signalas
		cap_en => inst3_cap_en,
		cap_cont_en => inst3_cap_cont_en,
		cap_size => cap_size,
		cap_done => inst3_cap_done,
		--external fifo signalas
		fifo_wrreq => inst3_fifo_wrreq,
		fifo_wfull => inst5_fifo_3_wrfull,
		fifo_wrempty => inst5_fifo_3_wrempty
	);

	inst4_cap_cont_en <= '0';

	PROCESS (current_state)BEGIN
		IF (current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done) THEN
			inst4_cap_en <= '1';
		ELSE
			inst4_cap_en <= '0';
		END IF;
	END PROCESS;

	data_cap_inst4 : data_cap
	PORT MAP(
		clk => wclk4,
		reset_n => wclk4_reset_n_sync(1),
		data_valid => YP_1_valid,
		--capture signalas
		cap_en => inst4_cap_en,
		cap_cont_en => inst4_cap_cont_en,
		cap_size => cap_size,
		cap_done => inst4_cap_done,
		--external fifo signalas
		fifo_wrreq => inst4_fifo_wrreq,
		fifo_wfull => inst5_fifo_4_wrfull,
		fifo_wrempty => inst5_fifo_4_wrempty
	);

	--inst5_fifo_0_data <= XPQ & XPI;
	--inst5_fifo_1_data <= YPQ & YPI;
	--inst5_fifo_2_data <= XQ & XI;	

	inst5_fifo_0_data <= (XPQ & XPI) WHEN test_data_en = '0' ELSE
		(x"0302" & x"0100");
	inst5_fifo_1_data <= (YPQ & YPI) WHEN test_data_en = '0' ELSE
		(x"0706" & x"0504");
	inst5_fifo_2_data <= (XQ & XI) WHEN test_data_en = '0' ELSE
		(x"0B0A" & x"0908");
	inst5_fifo_3_data <= (XPQ_1 & XPI_1) WHEN test_data_en = '0' ELSE
		(x"0F0E" & x"0D0C");
	inst5_fifo_4_data <= (YPQ_1 & YPI_1) WHEN test_data_en = '0' ELSE
		(x"1312" & x"1110");

	--inst5_fifo_0_data <= x"0302" & x"0100";
	--inst5_fifo_1_data <= x"0706" & x"0504";
	--inst5_fifo_2_data <= x"0B0A" & x"0908";		

	fifo_buff_inst5 : fifo_buff
	GENERIC MAP(
		dev_family => "Cyclone V GX",
		wrwidth => 32,
		wrusedw_witdth => 15, --15=32768 words 
		rdwidth => 32,
		rdusedw_width => 15,
		show_ahead => "OFF"
	)

	PORT MAP(
		--fifo 0 ports
		fifo_0_reset_n => wclk0_reset_n_sync(1),
		fifo_0_wrclk => wclk0,
		fifo_0_wrreq => inst0_fifo_wrreq,
		fifo_0_data => inst5_fifo_0_data,
		fifo_0_wrfull => inst5_fifo_0_wrfull,
		fifo_0_wrempty => inst5_fifo_0_wrempty,
		--fifo 1 ports
		fifo_1_reset_n => wclk1_reset_n_sync(1),
		fifo_1_wrclk => wclk1,
		fifo_1_wrreq => inst1_fifo_wrreq,
		fifo_1_data => inst5_fifo_1_data,
		fifo_1_wrfull => inst5_fifo_1_wrfull,
		fifo_1_wrempty => inst5_fifo_1_wrempty,
		--fifo 2 ports
		fifo_2_reset_n => wclk2_reset_n_sync(1),
		fifo_2_wrclk => wclk2,
		fifo_2_wrreq => inst2_fifo_wrreq,
		fifo_2_data => inst5_fifo_2_data,
		fifo_2_wrfull => inst5_fifo_2_wrfull,
		fifo_2_wrempty => inst5_fifo_2_wrempty,
		--fifo 3 ports
		fifo_3_reset_n => wclk3_reset_n_sync(1),
		fifo_3_wrclk => wclk3,
		fifo_3_wrreq => inst3_fifo_wrreq,
		fifo_3_data => inst5_fifo_3_data,
		fifo_3_wrfull => inst5_fifo_3_wrfull,
		fifo_3_wrempty => inst5_fifo_3_wrempty,
		--fifo 4 ports
		fifo_4_reset_n => wclk4_reset_n_sync(1),
		fifo_4_wrclk => wclk4,
		fifo_4_wrreq => inst4_fifo_wrreq,
		fifo_4_data => inst5_fifo_4_data,
		fifo_4_wrfull => inst5_fifo_4_wrfull,
		fifo_4_wrempty => inst5_fifo_4_wrempty,
		--rd port for all fifo
		fifo_rdclk => rdclk,
		fifo_rdclk_reset_n => rdclk_reset_n_sync(1),
		fifo_cap_size => cap_size,
		fifo_rdreq => fifo_rdreq,
		fifo_q => fifo_q,
		fifo_rdempty => inst5_fifo_rdempty

	);

	--to show that fifo is not empty only when all data is captured
	fifo_rdempty <= inst5_fifo_rdempty OR (NOT cap_done_all_inst_sync_rdclk(1));

END arch;