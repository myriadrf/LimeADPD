-- (C) 2001-2018 Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files from any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License Subscription 
-- Agreement, Intel FPGA IP License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Intel and sold by 
-- Intel or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


library ieee;
    use ieee.std_logic_1164.all;

entity ddr3_av_2x32_p0_altdqdqs is
	generic (
		ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL: integer := 1
	);

        port (
		core_clock_in: in std_logic;
		reset_n_core_clock_in: in std_logic;
		fr_clock_in: in std_logic;
		hr_clock_in: in std_logic;
		write_strobe_clock_in: in std_logic;
		write_strobe: in std_logic_vector (3 downto 0);
		strobe_ena_hr_clock_in: in std_logic;
		read_write_data_io: inout std_logic_vector (8-1 downto 0);
		write_oe_in: in std_logic_vector (2*8-1 downto 0);
		strobe_io: inout std_logic;
		output_strobe_ena: in std_logic_vector (2-1 downto 0);
		strobe_n_io: inout std_logic;
		oct_ena_in: in std_logic_vector (2-1 downto 0);
		read_data_out: out std_logic_vector (2 * 2 * 8-1 downto 0);
		capture_strobe_out: out std_logic;
		write_data_in: in std_logic_vector (2 * 2 * 8-1 downto 0);
		extra_write_data_in: in std_logic_vector (2 * 2 * 1-1 downto 0);
		extra_write_data_out: out std_logic_vector (1-1 downto 0);
		parallelterminationcontrol_in: in std_logic_vector (16-1 downto 0);
		seriesterminationcontrol_in: in std_logic_vector (16-1 downto 0);
		config_data_in: in std_logic;
		config_update: in std_logic;
		config_dqs_ena: in std_logic;
		config_io_ena: in std_logic_vector (8-1 downto 0);
		config_extra_io_ena: in std_logic_vector (1-1 downto 0);
		config_dqs_io_ena: in std_logic;
		config_clock_in: in std_logic;
		lfifo_rdata_en: in std_logic_vector (2-1 downto 0);
		lfifo_rdata_en_full: in std_logic_vector (2-1 downto 0);
		lfifo_rd_latency: in std_logic_vector (4 downto 0);
		lfifo_reset_n: in std_logic; 
		lfifo_rdata_valid: out std_logic;
		vfifo_qvld : in std_logic_vector (2-1 downto 0);
		vfifo_inc_wr_ptr : in std_logic_vector (2-1 downto 0);
		vfifo_reset_n : in std_logic;
		rfifo_reset_n : in std_logic;
		dll_delayctrl_in:  in std_logic_vector (7-1 downto 0)
	);

end entity ddr3_av_2x32_p0_altdqdqs;



architecture RTL of ddr3_av_2x32_p0_altdqdqs is
	component altdq_dqs2_acv_connect_to_hard_phy_cyclonev is
		generic (
                	PIN_WIDTH: integer := 8;
                      	PIN_TYPE: string := "bidir";
                      	USE_INPUT_PHASE_ALIGNMENT: string := "false";
                      	USE_OUTPUT_PHASE_ALIGNMENT: string := "false";
                      	USE_LDC_AS_LOW_SKEW_CLOCK: string := "false";
                      	USE_HALF_RATE_INPUT: string := "false";
                      	USE_HALF_RATE_OUTPUT: string := "true";
                      	DIFFERENTIAL_CAPTURE_STROBE: string := "true";
                      	SEPARATE_CAPTURE_STROBE: string := "false";
                      	INPUT_FREQ:  real := real(333.0);
                      	INPUT_FREQ_PS: string := "3003 ps";
                      	DELAY_CHAIN_BUFFER_MODE: string := "high";
                      	DQS_PHASE_SETTING: integer := 0;
                      	DQS_PHASE_SHIFT: integer := 0;
                      	DQS_ENABLE_PHASE_SETTING: integer := 3;
                      	USE_DYNAMIC_CONFIG: string := "true";
                      	INVERT_CAPTURE_STROBE: string := "true";
                      	SWAP_CAPTURE_STROBE_POLARITY: string := "false";
                      	USE_TERMINATION_CONTROL: string := "true";
                      	USE_DQS_ENABLE: string := "true";
                      	USE_OUTPUT_STROBE: string := "true";
                      	USE_OUTPUT_STROBE_RESET: string := "false";
                      	DIFFERENTIAL_OUTPUT_STROBE: string := "true";
                      	USE_BIDIR_STROBE: string := "true";
                      	REVERSE_READ_WORDS: string := "false";
                      	EXTRA_OUTPUT_WIDTH: integer := 1;
                      	DYNAMIC_MODE: string := "dynamic";
                      	OCT_SERIES_TERM_CONTROL_WIDTH  : integer := 16; 
                      	OCT_PARALLEL_TERM_CONTROL_WIDTH: integer := 16; 
                      	DLL_WIDTH: integer := 7;
                      	DLL_USE_2X_CLK: string := "false";
                      	USE_DATA_OE_FOR_OCT: string := "false";
                      	DQS_ENABLE_WIDTH: integer := 1;
                      	USE_OCT_ENA_IN_FOR_OCT: string := "true";
                      	PREAMBLE_TYPE: string := "high";
                      	EMIF_UNALIGNED_PREAMBLE_SUPPORT: string := "false";
                      	EMIF_BYPASS_OCT_DDIO: string := "false";
                      	USE_OFFSET_CTRL: string := "false";
                      	HR_DDIO_OUT_HAS_THREE_REGS: string := "false";
                      	DQS_ENABLE_PHASECTRL: string := "true";
                      	USE_2X_FF: string := "false";
                      	USE_DQS_TRACKING: string := "false";
                      	USE_HARD_FIFOS: string := "true";
                      	USE_DQSIN_FOR_VFIFO_READ: string := "false";
                      	NATURAL_ALIGNMENT: string := "true";
                      	SEPERATE_LDC_FOR_WRITE_STROBE: string := "false";
                      	CALIBRATION_SUPPORT: string := "false";
                      	HHP_HPS: string := "false"
                );
  		port (
			core_clock_in: in std_logic := '0';
			reset_n_core_clock_in: in std_logic := '0';
			fr_clock_in: in std_logic := '0';
			hr_clock_in: in std_logic := '0';
			dr_clock_in: in std_logic := '0';
			write_strobe_clock_in: in std_logic := '0';
			write_strobe: in std_logic_vector (3 downto 0) := (others => '0');
			strobe_ena_hr_clock_in: in std_logic := '0';
			capture_strobe_ena: in std_logic_vector (1-1 downto 0) := (others => '0');
			read_write_data_io: inout std_logic_vector (8-1 downto 0);
			write_oe_in: in std_logic_vector (2*8-1 downto 0) := (others => '0');
			read_data_in: in std_logic_vector (8-1 downto 0) := (others => '0');
			write_data_out: out std_logic_vector (8-1 downto 0);
			strobe_io: inout std_logic;
			output_strobe_ena: in std_logic_vector (2-1 downto 0) := (others => '0');
			strobe_n_io: inout std_logic;
			output_strobe_out: out std_logic;
			output_strobe_n_out: out std_logic;
			capture_strobe_in: in std_logic := '0';
			capture_strobe_n_in: in std_logic := '0';
			oct_ena_in: in std_logic_vector (1 downto 0) := (others => '0');
			read_data_out: out std_logic_vector (2 * 2 * 8-1 downto 0);
			capture_strobe_out: out std_logic;
			write_data_in: in std_logic_vector (2 * 2 * 8-1 downto 0) := (others => '0');
			extra_write_data_in: in std_logic_vector (abs(2 * 2 * 1-1) downto 0) := (others => '0');
			extra_write_data_out: out std_logic_vector (abs(1-1) downto 0);
			parallelterminationcontrol_in: in std_logic_vector (16-1 downto 0) := (others => '0');
			seriesterminationcontrol_in: in std_logic_vector (16-1 downto 0) := (others => '0');
			config_data_in: in std_logic := '0';
			config_update: in std_logic := '0';
			config_dqs_ena: in std_logic := '0';
			config_io_ena: in std_logic_vector (8-1 downto 0) := (others => '0');
			config_extra_io_ena: in std_logic_vector (abs(1-1) downto 0) := (others => '0');
			config_dqs_io_ena: in std_logic := '0';
			config_clock_in: in std_logic := '0';
			dll_offsetdelay_in: in std_logic_vector (7-1 downto 0) := (others => '0');
			dll_delayctrl_in:  in std_logic_vector (7-1 downto 0) := (others => '0');
			lfifo_rdata_en: in std_logic_vector (2-1 downto 0) := (others => '0');
			lfifo_rdata_en_full: in std_logic_vector (2-1 downto 0) := (others => '0');
			lfifo_rd_latency: in std_logic_vector (4 downto 0) := (others => '0');
			lfifo_reset_n: in std_logic := '0'; 
			lfifo_rdata_valid: out std_logic := '0';
			vfifo_qvld : in std_logic_vector (2-1 downto 0) := (others => '0');
			vfifo_inc_wr_ptr : in std_logic_vector (2-1 downto 0) := (others => '0');
			vfifo_reset_n : in std_logic := '0';
			rfifo_reset_n : in std_logic := '0'
		);
	end component altdq_dqs2_acv_connect_to_hard_phy_cyclonev;

begin


	altdq_dqs2_inst: component altdq_dqs2_acv_connect_to_hard_phy_cyclonev
		generic map (
                	PIN_WIDTH => 8,
                      	PIN_TYPE => "bidir",
                      	USE_INPUT_PHASE_ALIGNMENT => "false",
                      	USE_OUTPUT_PHASE_ALIGNMENT => "false",
                      	USE_LDC_AS_LOW_SKEW_CLOCK => "false",
                      	USE_HALF_RATE_INPUT => "false",
                      	USE_HALF_RATE_OUTPUT => "true",
                      	DIFFERENTIAL_CAPTURE_STROBE => "true",
                      	SEPARATE_CAPTURE_STROBE => "false",
                      	INPUT_FREQ => real(333.0),
                      	INPUT_FREQ_PS => "3003 ps",
                      	DELAY_CHAIN_BUFFER_MODE => "high",
                      	DQS_PHASE_SETTING => 0,
                      	DQS_PHASE_SHIFT => 0,
                      	DQS_ENABLE_PHASE_SETTING => 3,
                      	USE_DYNAMIC_CONFIG => "true",
                      	INVERT_CAPTURE_STROBE => "true",
                      	SWAP_CAPTURE_STROBE_POLARITY => "false",
                      	USE_TERMINATION_CONTROL => "true",
                      	USE_DQS_ENABLE => "true",
                      	USE_OUTPUT_STROBE => "true",
                      	USE_OUTPUT_STROBE_RESET => "false",
                      	DIFFERENTIAL_OUTPUT_STROBE => "true",
                      	USE_BIDIR_STROBE => "true",
                      	REVERSE_READ_WORDS => "false",
                      	EXTRA_OUTPUT_WIDTH => 1,
                      	DYNAMIC_MODE => "dynamic",
                      	OCT_SERIES_TERM_CONTROL_WIDTH   => 16, 
                      	OCT_PARALLEL_TERM_CONTROL_WIDTH => 16, 
                      	DLL_WIDTH => 7,
                      	DLL_USE_2X_CLK => "false",
                      	USE_DATA_OE_FOR_OCT => "false",
                      	DQS_ENABLE_WIDTH => 1,
                      	USE_OCT_ENA_IN_FOR_OCT => "true",
                      	PREAMBLE_TYPE => "high",
                      	EMIF_UNALIGNED_PREAMBLE_SUPPORT => "false",
                      	EMIF_BYPASS_OCT_DDIO => "false",
                      	USE_OFFSET_CTRL => "false",
                      	HR_DDIO_OUT_HAS_THREE_REGS => "false",
                      	DQS_ENABLE_PHASECTRL => "true",
                      	USE_2X_FF => "false",
                      	USE_DQS_TRACKING => "false",
                      	USE_HARD_FIFOS => "true",
                      	USE_DQSIN_FOR_VFIFO_READ => "false",
                      	NATURAL_ALIGNMENT => "true",
                      	SEPERATE_LDC_FOR_WRITE_STROBE => "false",
                      	CALIBRATION_SUPPORT => "false",
                      	HHP_HPS => "false"
                )
  		port map (
			reset_n_core_clock_in => reset_n_core_clock_in,
			core_clock_in => core_clock_in,
			fr_clock_in => fr_clock_in,
			hr_clock_in => hr_clock_in,
			write_strobe_clock_in  =>write_strobe_clock_in,
			write_strobe  => write_strobe,
			strobe_ena_hr_clock_in => strobe_ena_hr_clock_in,
			read_write_data_io => read_write_data_io,
			write_oe_in => write_oe_in,
			strobe_io => strobe_io,
			output_strobe_ena => output_strobe_ena,
			strobe_n_io => strobe_n_io,
			oct_ena_in(2-1 downto 0) => oct_ena_in,
			oct_ena_in(1 downto 2) => (others => '0'),
			read_data_out => read_data_out,
			capture_strobe_out => capture_strobe_out,
			write_data_in => write_data_in,
			extra_write_data_in => extra_write_data_in,
			extra_write_data_out => extra_write_data_out,
			parallelterminationcontrol_in => parallelterminationcontrol_in,
			seriesterminationcontrol_in => seriesterminationcontrol_in,
			config_data_in => config_data_in,
			config_update => config_update,
			config_dqs_ena => config_dqs_ena,
			config_io_ena => config_io_ena,
			config_extra_io_ena => config_extra_io_ena,
			config_dqs_io_ena => config_dqs_io_ena,
			config_clock_in => config_clock_in,
			lfifo_rdata_en => lfifo_rdata_en,
			lfifo_rdata_en_full => lfifo_rdata_en_full,
			lfifo_rd_latency => lfifo_rd_latency,
			lfifo_reset_n => lfifo_reset_n,
			lfifo_rdata_valid => lfifo_rdata_valid,
			vfifo_qvld => vfifo_qvld,
			vfifo_inc_wr_ptr => vfifo_inc_wr_ptr,
			vfifo_reset_n => vfifo_reset_n,
			rfifo_reset_n => rfifo_reset_n,
			dll_delayctrl_in =>dll_delayctrl_in
		);



end architecture RTL;
