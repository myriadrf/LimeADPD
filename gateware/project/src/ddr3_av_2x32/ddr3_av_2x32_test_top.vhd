-- ----------------------------------------------------------------------------	
-- FILE: 	file_name.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ddr3_av_2x32_test_top is
	port (
		pll_ref_clk                : in    std_logic                     := '0';             --        pll_ref_clk.clk
		global_reset_n             : in    std_logic                     := '0';             --       global_reset.reset_n
		port_sel							: in 		std_logic;
		mem_a                      : out   std_logic_vector(13 downto 0);                    --             memory.mem_a
		mem_ba                     : out   std_logic_vector(2 downto 0);                     --                   .mem_ba
		mem_ck                     : out   std_logic_vector(0 downto 0);                     --                   .mem_ck
		mem_ck_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_ck_n
		mem_cke                    : out   std_logic_vector(0 downto 0);                     --                   .mem_cke
		mem_cs_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_cs_n
		mem_dm                     : out   std_logic_vector(3 downto 0);                     --                   .mem_dm
		mem_ras_n                  : out   std_logic_vector(0 downto 0);                     --                   .mem_ras_n
		mem_cas_n                  : out   std_logic_vector(0 downto 0);                     --                   .mem_cas_n
		mem_we_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_we_n
		mem_reset_n                : out   std_logic;                                        --                   .mem_reset_n
		mem_dq                     : inout std_logic_vector(31 downto 0) := (others => '0'); --                   .mem_dq
		mem_dqs                    : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs
		mem_dqs_n                  : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs_n
		mem_odt                    : out   std_logic_vector(0 downto 0);                     --                   .mem_odt
		local_init_done            : out   std_logic;                                        --             status.local_init_done
		local_cal_success          : out   std_logic;                                        --                   .local_cal_success
		local_cal_fail             : out   std_logic;                                        --                   .local_cal_fail
		oct_rzqin                  : in    std_logic                     := '0';             --                oct.rzqin
		port0_pnf 						: out std_logic;
		port0_pnf_per_bit				: out std_logic_vector(31 downto 0);
		port0_pnf_per_bit_persist	: out std_logic_vector(31 downto 0);
		port0_pass            		: out std_logic;                                        --    status.pass
		port0_fail            		: out std_logic;                                        --          .fail
		port0_test_complete   		: out std_logic;  
		port1_pnf						: out std_logic;
		port1_pnf_per_bit				: out std_logic_vector(31 downto 0);
		port1_pnf_per_bit_persist	: out std_logic_vector(31 downto 0);
		port1_pass            		: out std_logic;                                        --    status.pass
		port1_fail            		: out std_logic;                                        --          .fail
		port1_test_complete   		: out std_logic  
	);
end entity ddr3_av_2x32_test_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ddr3_av_2x32_test_top is
--declare signals,  components here

--First tester instance inst0 signals
signal reset_port0_tester		 	: std_logic;
signal inst0_avl_addr_0        	: std_logic_vector(26 downto 0); 
signal inst0_avl_size_0        	: std_logic_vector(1 downto 0); 
signal inst0_avl_wdata_0       	: std_logic_vector(31 downto 0); 
signal inst0_avl_write_req_0   	: std_logic;
signal inst0_avl_read_req_0    	: std_logic;
signal inst0_avl_be_0          	: std_logic_vector(3 downto 0); 
signal inst0_avl_burstbegin_0  	: std_logic;
signal inst0_pnf_per_bit		 	: std_logic_vector(31 downto 0);
signal inst0_pnf_per_bit_persist : std_logic_vector(31 downto 0);

--Second tester instance inst1 signals
signal reset_port1_tester			: std_logic;
signal inst1_avl_addr_1        	: std_logic_vector(26 downto 0); 
signal inst1_avl_size_1        	: std_logic_vector(1 downto 0); 
signal inst1_avl_wdata_1       	: std_logic_vector(31 downto 0); 
signal inst1_avl_write_req_1   	: std_logic;
signal inst1_avl_read_req_1    	: std_logic;
signal inst1_avl_be_1          	: std_logic_vector(3 downto 0); 
signal inst1_avl_burstbegin_1  	: std_logic;
signal inst1_pnf_per_bit		 	: std_logic_vector(31 downto 0);
signal inst1_pnf_per_bit_persist : std_logic_vector(31 downto 0);

--DDR3 controller instance inst3 signals

signal inst3_afi_half_clk 				: std_logic;
signal inst3_avl_ready_0 				: std_logic;
signal inst3_avl_rdata_valid_0 		: std_logic;
signal inst3_avl_rdata_0 				: std_logic_vector(31 downto 0);
signal inst3_avl_ready_1 				: std_logic;
signal inst3_avl_rdata_valid_1 		: std_logic;
signal inst3_avl_rdata_1				: std_logic_vector(31 downto 0);
signal mp_cmd_clk_0_clk 				: std_logic;
signal mp_cmd_reset_n_0_reset_n 		: std_logic;
signal mp_cmd_clk_1_clk 				: std_logic;
signal mp_cmd_reset_n_1_reset_n 		: std_logic;
signal mp_rfifo_clk_0_clk 				: std_logic;
signal mp_rfifo_reset_n_0_reset_n 	: std_logic;
signal mp_wfifo_clk_0_clk 				: std_logic;
signal mp_wfifo_reset_n_0_reset_n 	: std_logic;
signal mp_rfifo_clk_1_clk 				: std_logic;
signal mp_rfifo_reset_n_1_reset_n 	: std_logic;
signal mp_wfifo_clk_1_clk 				: std_logic;
signal mp_wfifo_reset_n_1_reset_n 	: std_logic;
signal inst3_local_init_done 			: std_logic;
signal inst3_local_cal_success 		: std_logic;
signal inst3_local_cal_fail 			: std_logic;
signal inst3_pll_locked 				: std_logic;

component ddr3_av_2x32_tester is
	port (
		avl_ready       		: in  std_logic                     := '0';             --       avl.waitrequest_n
		avl_addr        		: out std_logic_vector(26 downto 0);                    --          .address
		avl_size        		: out std_logic_vector(1 downto 0);                     --          .burstcount
		avl_wdata       		: out std_logic_vector(31 downto 0);                    --          .writedata
		avl_rdata       		: in  std_logic_vector(31 downto 0) := (others => '0'); --          .readdata
		avl_write_req   		: out std_logic;                                        --          .write
		avl_read_req    		: out std_logic;                                        --          .read
		avl_rdata_valid 		: in  std_logic                     := '0';             --          .readdatavalid
		avl_be          		: out std_logic_vector(3 downto 0);                     --          .byteenable
		avl_burstbegin  		: out std_logic;                                        --          .beginbursttransfer
		clk             		: in  std_logic                     := '0';             -- avl_clock.clk
		reset_n         		: in  std_logic                     := '0';             -- avl_reset.reset_n
		pnf_per_bit         	: out std_logic_vector(31 downto 0);                    --       pnf.pnf_per_bit
		pnf_per_bit_persist 	: out std_logic_vector(31 downto 0); 
		pass            		: out std_logic;                                        --    status.pass
		fail           	 	: out std_logic;                                        --          .fail
		test_complete   		: out std_logic                                         --          .test_complete
	);
end component;


component ddr3_av_2x32 is
	port (
		pll_ref_clk                : in    std_logic                     := '0';             --        pll_ref_clk.clk
		global_reset_n             : in    std_logic                     := '0';             --       global_reset.reset_n
		soft_reset_n               : in    std_logic                     := '0';             --         soft_reset.reset_n
		afi_clk                    : out   std_logic;                                        --            afi_clk.clk
		afi_half_clk               : out   std_logic;                                        --       afi_half_clk.clk
		afi_reset_n                : out   std_logic;                                        --          afi_reset.reset_n
		afi_reset_export_n         : out   std_logic;                                        --   afi_reset_export.reset_n
		mem_a                      : out   std_logic_vector(13 downto 0);                    --             memory.mem_a
		mem_ba                     : out   std_logic_vector(2 downto 0);                     --                   .mem_ba
		mem_ck                     : out   std_logic_vector(0 downto 0);                     --                   .mem_ck
		mem_ck_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_ck_n
		mem_cke                    : out   std_logic_vector(0 downto 0);                     --                   .mem_cke
		mem_cs_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_cs_n
		mem_dm                     : out   std_logic_vector(3 downto 0);                     --                   .mem_dm
		mem_ras_n                  : out   std_logic_vector(0 downto 0);                     --                   .mem_ras_n
		mem_cas_n                  : out   std_logic_vector(0 downto 0);                     --                   .mem_cas_n
		mem_we_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_we_n
		mem_reset_n                : out   std_logic;                                        --                   .mem_reset_n
		mem_dq                     : inout std_logic_vector(31 downto 0) := (others => '0'); --                   .mem_dq
		mem_dqs                    : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs
		mem_dqs_n                  : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs_n
		mem_odt                    : out   std_logic_vector(0 downto 0);                     --                   .mem_odt
		avl_ready_0                : out   std_logic;                                        --              avl_0.waitrequest_n
		avl_burstbegin_0           : in    std_logic                     := '0';             --                   .beginbursttransfer
		avl_addr_0                 : in    std_logic_vector(26 downto 0) := (others => '0'); --                   .address
		avl_rdata_valid_0          : out   std_logic;                                        --                   .readdatavalid
		avl_rdata_0                : out   std_logic_vector(31 downto 0);                    --                   .readdata
		avl_wdata_0                : in    std_logic_vector(31 downto 0) := (others => '0'); --                   .writedata
		avl_be_0                   : in    std_logic_vector(3 downto 0)  := (others => '0'); --                   .byteenable
		avl_read_req_0             : in    std_logic                     := '0';             --                   .read
		avl_write_req_0            : in    std_logic                     := '0';             --                   .write
		avl_size_0                 : in    std_logic_vector(1 downto 0)  := (others => '0'); --                   .burstcount
		avl_ready_1                : out   std_logic;                                        --              avl_1.waitrequest_n
		avl_burstbegin_1           : in    std_logic                     := '0';             --                   .beginbursttransfer
		avl_addr_1                 : in    std_logic_vector(26 downto 0) := (others => '0'); --                   .address
		avl_rdata_valid_1          : out   std_logic;                                        --                   .readdatavalid
		avl_rdata_1                : out   std_logic_vector(31 downto 0);                    --                   .readdata
		avl_wdata_1                : in    std_logic_vector(31 downto 0) := (others => '0'); --                   .writedata
		avl_be_1                   : in    std_logic_vector(3 downto 0)  := (others => '0'); --                   .byteenable
		avl_read_req_1             : in    std_logic                     := '0';             --                   .read
		avl_write_req_1            : in    std_logic                     := '0';             --                   .write
		avl_size_1                 : in    std_logic_vector(1 downto 0)  := (others => '0'); --                   .burstcount
		mp_cmd_clk_0_clk           : in    std_logic                     := '0';             --       mp_cmd_clk_0.clk
		mp_cmd_reset_n_0_reset_n   : in    std_logic                     := '0';             --   mp_cmd_reset_n_0.reset_n
		mp_cmd_clk_1_clk           : in    std_logic                     := '0';             --       mp_cmd_clk_1.clk
		mp_cmd_reset_n_1_reset_n   : in    std_logic                     := '0';             --   mp_cmd_reset_n_1.reset_n
		mp_rfifo_clk_0_clk         : in    std_logic                     := '0';             --     mp_rfifo_clk_0.clk
		mp_rfifo_reset_n_0_reset_n : in    std_logic                     := '0';             -- mp_rfifo_reset_n_0.reset_n
		mp_wfifo_clk_0_clk         : in    std_logic                     := '0';             --     mp_wfifo_clk_0.clk
		mp_wfifo_reset_n_0_reset_n : in    std_logic                     := '0';             -- mp_wfifo_reset_n_0.reset_n
		mp_rfifo_clk_1_clk         : in    std_logic                     := '0';             --     mp_rfifo_clk_1.clk
		mp_rfifo_reset_n_1_reset_n : in    std_logic                     := '0';             -- mp_rfifo_reset_n_1.reset_n
		mp_wfifo_clk_1_clk         : in    std_logic                     := '0';             --     mp_wfifo_clk_1.clk
		mp_wfifo_reset_n_1_reset_n : in    std_logic                     := '0';             -- mp_wfifo_reset_n_1.reset_n
		local_init_done            : out   std_logic;                                        --             status.local_init_done
		local_cal_success          : out   std_logic;                                        --                   .local_cal_success
		local_cal_fail             : out   std_logic;                                        --                   .local_cal_fail
		oct_rzqin                  : in    std_logic                     := '0';             --                oct.rzqin
		pll_mem_clk                : out   std_logic;                                        --        pll_sharing.pll_mem_clk
		pll_write_clk              : out   std_logic;                                        --                   .pll_write_clk
		pll_locked                 : out   std_logic;                                        --                   .pll_locked
		pll_write_clk_pre_phy_clk  : out   std_logic;                                        --                   .pll_write_clk_pre_phy_clk
		pll_addr_cmd_clk           : out   std_logic;                                        --                   .pll_addr_cmd_clk
		pll_avl_clk                : out   std_logic;                                        --                   .pll_avl_clk
		pll_config_clk             : out   std_logic;                                        --                   .pll_config_clk
		pll_mem_phy_clk            : out   std_logic;                                        --                   .pll_mem_phy_clk
		afi_phy_clk                : out   std_logic;                                        --                   .afi_phy_clk
		pll_avl_phy_clk            : out   std_logic                                         --                   .pll_avl_phy_clk
	);
end component;

  
begin

reset_port0_tester<= port_sel and inst3_local_init_done;

	ddr3_av_2x32_tester_inst0 : component ddr3_av_2x32_tester
		port map (
			avl_ready       		=> inst3_avl_ready_0,       --       avl.waitrequest_n
			avl_addr        		=> inst0_avl_addr_0,        --          .address
			avl_size        		=> inst0_avl_size_0,        --          .burstcount
			avl_wdata      	 	=> inst0_avl_wdata_0,       --          .writedata
			avl_rdata       		=> inst3_avl_rdata_0,       --          .readdata
			avl_write_req   		=> inst0_avl_write_req_0,   --          .write
			avl_read_req    		=> inst0_avl_read_req_0,    --          .read
			avl_rdata_valid 		=> inst3_avl_rdata_valid_0, --          .readdatavalid
			avl_be          		=> inst0_avl_be_0,          --          .byteenable
			avl_burstbegin  		=> inst0_avl_burstbegin_0,  --          .beginbursttransfer
			clk             		=> inst3_afi_half_clk,    		-- avl_clock.clk
			reset_n         		=> reset_port0_tester,  		-- avl_reset.reset_n
			pnf_per_bit         	=> inst0_pnf_per_bit,
			pnf_per_bit_persist 	=> inst0_pnf_per_bit_persist,
			pass            		=> port0_pass,            --    status.pass
			fail            		=> port0_fail,            --          .fail
			test_complete   		=> port0_test_complete    --          .test_complete
		);
		
reset_port1_tester<= (not port_sel) and inst3_local_init_done;		
		
	ddr3_av_2x32_tester_inst1 : component ddr3_av_2x32_tester
		port map (
			avl_ready       		=> inst3_avl_ready_1,       --       avl.waitrequest_n
			avl_addr        		=> inst1_avl_addr_1,        --          .address
			avl_size        		=> inst1_avl_size_1,        --          .burstcount
			avl_wdata       		=> inst1_avl_wdata_1,       --          .writedata
			avl_rdata       		=> inst3_avl_rdata_1,       --          .readdata
			avl_write_req   		=> inst1_avl_write_req_1,   --          .write
			avl_read_req    		=> inst1_avl_read_req_1,    --          .read
			avl_rdata_valid 		=> inst3_avl_rdata_valid_1, --          .readdatavalid
			avl_be          		=> inst1_avl_be_1,          --          .byteenable
			avl_burstbegin  		=> inst1_avl_burstbegin_1,  --          .beginbursttransfer
			clk             		=> inst3_afi_half_clk,    -- avl_clock.clk
			reset_n         		=> reset_port1_tester,  -- avl_reset.reset_n
			pnf_per_bit         	=> inst1_pnf_per_bit,
			pnf_per_bit_persist 	=> inst1_pnf_per_bit_persist,
			pass            		=> port1_pass,            --    status.pass
			fail            		=> port1_fail,            --          .fail
			test_complete   		=> port1_test_complete    --          .test_complete
		);		

	ddr3_av_2x32_inst3: component ddr3_av_2x32
		port map (
			pll_ref_clk                => pll_ref_clk,                --        pll_ref_clk.clk
			global_reset_n             => global_reset_n,             --       global_reset.reset_n
			soft_reset_n               => inst3_pll_locked,               --         soft_reset.reset_n
			afi_clk                    => open, -- afi_clk,            --            afi_clk.clk
			afi_half_clk               => inst3_afi_half_clk,         --       afi_half_clk.clk
			afi_reset_n                => open, --afi_reset_n,                --          afi_reset.reset_n
			afi_reset_export_n         => open, --afi_reset_export_n,         --   afi_reset_export.reset_n
			mem_a                      => mem_a,                      --             memory.mem_a
			mem_ba                     => mem_ba,                     --                   .mem_ba
			mem_ck                     => mem_ck,                     --                   .mem_ck
			mem_ck_n                   => mem_ck_n,                   --                   .mem_ck_n
			mem_cke                    => mem_cke,                    --                   .mem_cke
			mem_cs_n                   => mem_cs_n,                   --                   .mem_cs_n
			mem_dm                     => mem_dm,                     --                   .mem_dm
			mem_ras_n                  => mem_ras_n,                  --                   .mem_ras_n
			mem_cas_n                  => mem_cas_n,                  --                   .mem_cas_n
			mem_we_n                   => mem_we_n,                   --                   .mem_we_n
			mem_reset_n                => mem_reset_n,                --                   .mem_reset_n
			mem_dq                     => mem_dq,                     --                   .mem_dq
			mem_dqs                    => mem_dqs,                    --                   .mem_dqs
			mem_dqs_n                  => mem_dqs_n,                  --                   .mem_dqs_n
			mem_odt                    => mem_odt,                    --                   .mem_odt
			avl_ready_0                => inst3_avl_ready_0,                --              avl_0.waitrequest_n
			avl_burstbegin_0           => inst0_avl_burstbegin_0,           --                   .beginbursttransfer
			avl_addr_0                 => inst0_avl_addr_0,                 --                   .address
			avl_rdata_valid_0          => inst3_avl_rdata_valid_0,          --                   .readdatavalid
			avl_rdata_0                => inst3_avl_rdata_0,                --                   .readdata
			avl_wdata_0                => inst0_avl_wdata_0,                --                   .writedata
			avl_be_0                   => inst0_avl_be_0,                   --                   .byteenable
			avl_read_req_0             => inst0_avl_read_req_0,             --                   .read
			avl_write_req_0            => inst0_avl_write_req_0,            --                   .write
			avl_size_0                 => inst0_avl_size_0,                 --                   .burstcount
			avl_ready_1                => inst3_avl_ready_1,                --              avl_1.waitrequest_n
			avl_burstbegin_1           => inst1_avl_burstbegin_1,           --                   .beginbursttransfer
			avl_addr_1                 => inst1_avl_addr_1,                 --                   .address
			avl_rdata_valid_1          => inst3_avl_rdata_valid_1,          --                   .readdatavalid
			avl_rdata_1                => inst3_avl_rdata_1,                --                   .readdata
			avl_wdata_1                => inst1_avl_wdata_1,                --                   .writedata
			avl_be_1                   => inst1_avl_be_1,                   --                   .byteenable
			avl_read_req_1             => inst1_avl_read_req_1,             --                   .read
			avl_write_req_1            => inst1_avl_write_req_1,            --                   .write
			avl_size_1                 => inst1_avl_size_1,                 --                   .burstcount
			mp_cmd_clk_0_clk           => mp_cmd_clk_0_clk,           --       mp_cmd_clk_0.clk
			mp_cmd_reset_n_0_reset_n   => mp_cmd_reset_n_0_reset_n,   --   mp_cmd_reset_n_0.reset_n
			mp_cmd_clk_1_clk           => mp_cmd_clk_1_clk,           --       mp_cmd_clk_1.clk
			mp_cmd_reset_n_1_reset_n   => mp_cmd_reset_n_1_reset_n,   --   mp_cmd_reset_n_1.reset_n
			mp_rfifo_clk_0_clk         => mp_rfifo_clk_0_clk,         --     mp_rfifo_clk_0.clk
			mp_rfifo_reset_n_0_reset_n => mp_rfifo_reset_n_0_reset_n, -- mp_rfifo_reset_n_0.reset_n
			mp_wfifo_clk_0_clk         => mp_wfifo_clk_0_clk,         --     mp_wfifo_clk_0.clk
			mp_wfifo_reset_n_0_reset_n => mp_wfifo_reset_n_0_reset_n, -- mp_wfifo_reset_n_0.reset_n
			mp_rfifo_clk_1_clk         => mp_rfifo_clk_1_clk,         --     mp_rfifo_clk_1.clk
			mp_rfifo_reset_n_1_reset_n => mp_rfifo_reset_n_1_reset_n, -- mp_rfifo_reset_n_1.reset_n
			mp_wfifo_clk_1_clk         => mp_wfifo_clk_1_clk,         --     mp_wfifo_clk_1.clk
			mp_wfifo_reset_n_1_reset_n => mp_wfifo_reset_n_1_reset_n, -- mp_wfifo_reset_n_1.reset_n
			local_init_done            => inst3_local_init_done,            --             status.local_init_done
			local_cal_success          => inst3_local_cal_success,          --                   .local_cal_success
			local_cal_fail             => inst3_local_cal_fail,             --                   .local_cal_fail
			oct_rzqin                  => oct_rzqin,                  --                oct.rzqin
			pll_mem_clk                => open, --pll_mem_clk,                --        pll_sharing.pll_mem_clk
			pll_write_clk              => open, --pll_write_clk,              --                   .pll_write_clk
			pll_locked                 => inst3_pll_locked,                 --                   .pll_locked
			pll_write_clk_pre_phy_clk  => open, --pll_write_clk_pre_phy_clk,  --                   .pll_write_clk_pre_phy_clk
			pll_addr_cmd_clk           => open, --pll_addr_cmd_clk,           --                   .pll_addr_cmd_clk
			pll_avl_clk                => open, --pll_avl_clk,                --                   .pll_avl_clk
			pll_config_clk             => open, --pll_config_clk,             --                   .pll_config_clk
			pll_mem_phy_clk            => open, --pll_mem_phy_clk,            --                   .pll_mem_phy_clk
			afi_phy_clk                => open, --afi_phy_clk,                --                   .afi_phy_clk
			pll_avl_phy_clk            => open --pll_avl_phy_clk             --                   .pll_avl_phy_clk
		);
		
mp_cmd_clk_0_clk 				<= inst3_afi_half_clk;
mp_cmd_reset_n_0_reset_n 	<= inst3_local_cal_success;
mp_cmd_clk_1_clk 				<= inst3_afi_half_clk;
mp_cmd_reset_n_1_reset_n 	<= inst3_local_cal_success;
mp_rfifo_clk_0_clk 			<= inst3_afi_half_clk;
mp_rfifo_reset_n_0_reset_n <= inst3_local_cal_success;
mp_wfifo_clk_0_clk 			<= inst3_afi_half_clk;
mp_wfifo_reset_n_0_reset_n <= inst3_local_cal_success;
mp_rfifo_clk_1_clk 			<= inst3_afi_half_clk;
mp_rfifo_reset_n_1_reset_n <= inst3_local_cal_success;
mp_wfifo_clk_1_clk 			<= inst3_afi_half_clk;
mp_wfifo_reset_n_1_reset_n <= inst3_local_cal_success;


--To top level ports
local_init_done            <= inst3_local_init_done;
local_cal_success          <= inst3_local_cal_success;
local_cal_fail             <= inst3_local_cal_fail; 

port0_pnf_per_bit				<= inst0_pnf_per_bit;
port0_pnf_per_bit_persist	<= inst0_pnf_per_bit_persist;
port1_pnf_per_bit				<= inst1_pnf_per_bit;
port1_pnf_per_bit_persist	<= inst1_pnf_per_bit_persist;

port0_pnf	<= '1' when (inst0_pnf_per_bit_persist=x"FFFFFFFF" and inst0_pnf_per_bit=x"FFFFFFFF") else '0';		
port1_pnf	<= '1' when (inst1_pnf_per_bit_persist=x"FFFFFFFF" and inst1_pnf_per_bit=x"FFFFFFFF") else '0';		
  
end arch;





