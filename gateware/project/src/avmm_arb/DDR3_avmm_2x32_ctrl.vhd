-- ----------------------------------------------------------------------------	
-- FILE: 	DDR3_avmm_2x32_ctrl.vhd
-- DESCRIPTION:	describe
-- DATE:	June 13, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity DDR3_avmm_2x32_ctrl is
		generic(
			dev_family	     	: string  := "Cyclone V GX";
			cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
			cntrl_addr_size	: integer := 14;
			cntrl_ba_size		: integer := 3;
			cntrl_bus_size		: integer := 32;
         --multiport front end parameters
         mpfe_0_addr_size     : integer := 27;
         mpfe_0_bus_size      : integer := 32;
         mpfe_0_burst_length  : integer := 2;         
         mpfe_1_addr_size     : integer := 26;
         mpfe_1_bus_size      : integer := 64;
         mpfe_1_burst_length  : integer := 2;
--			addr_size			: integer := 27;
--			lcl_bus_size		: integer := 32;
--			lcl_burst_length	: integer := 2;
			cmd_fifo_size		: integer := 9;
			outfifo_size_0		: integer := 10;  -- outfifo buffer size
			outfifo_size_1		: integer := 10  -- outfifo buffer size
		);
		port (

      pll_ref_clk       	: in std_logic;
      global_reset_n   		: in std_logic;
		soft_reset_n			: in std_logic;
		--Port 0 
		wcmd_clk_0				: in std_logic;
		wcmd_reset_n_0			: in  std_logic;
		wcmd_rdy_0				: out std_logic;
		wcmd_addr_0				: in std_logic_vector(mpfe_0_addr_size-1 downto 0);
		wcmd_wr_0				: in std_logic;
		wcmd_brst_en_0			: in std_logic; --1- writes in burst, 0- single write
		wcmd_data_0				: in std_logic_vector(mpfe_0_bus_size-1 downto 0);
		rcmd_clk_0				: in std_logic;
		rcmd_reset_n_0			: in  std_logic;
		rcmd_rdy_0				: out std_logic;
		rcmd_addr_0				: in std_logic_vector(mpfe_0_addr_size-1 downto 0);
		rcmd_wr_0				: in std_logic;
		rcmd_brst_en_0			: in std_logic; --1- reads in burst, 0- single read
		outbuf_wrusedw_0		: in std_logic_vector(outfifo_size_0-1 downto 0);
		
		local_ready_0			: out std_logic;
		local_rdata_0			: out std_logic_vector(mpfe_0_bus_size-1 downto 0);
		local_rdata_valid_0	: out std_logic;
		
		--Port 1 
		wcmd_clk_1				: in std_logic;
		wcmd_reset_n_1			: in  std_logic;
		wcmd_rdy_1				: out std_logic;
		wcmd_addr_1				: in std_logic_vector(mpfe_1_addr_size-1 downto 0);
		wcmd_wr_1				: in std_logic;
		wcmd_brst_en_1			: in std_logic; --1- writes in burst, 0- single write
		wcmd_data_1				: in std_logic_vector(mpfe_1_bus_size-1 downto 0);
		rcmd_clk_1				: in std_logic;
		rcmd_reset_n_1			: in  std_logic;
		rcmd_rdy_1				: out std_logic;
		rcmd_addr_1				: in std_logic_vector(mpfe_1_addr_size-1 downto 0);
		rcmd_wr_1				: in std_logic;
		rcmd_brst_en_1			: in std_logic; --1- reads in burst, 0- single read
		outbuf_wrusedw_1		: in std_logic_vector(outfifo_size_0-1 downto 0);

		local_ready_1			: out std_logic;
		local_rdata_1			: out std_logic_vector(mpfe_1_bus_size-1 downto 0);
		local_rdata_valid_1	: out std_logic;
		local_init_done		: out std_logic;

		--External memory signals
		mem_a                : out   std_logic_vector(13 downto 0);                    --             memory.mem_a
		mem_ba               : out   std_logic_vector(2 downto 0);                     --                   .mem_ba
		mem_ck               : out   std_logic_vector(0 downto 0);                     --                   .mem_ck
		mem_ck_n             : out   std_logic_vector(0 downto 0);                     --                   .mem_ck_n
		mem_cke              : out   std_logic_vector(0 downto 0);                     --                   .mem_cke
		mem_cs_n             : out   std_logic_vector(0 downto 0);                     --                   .mem_cs_n
		mem_dm               : out   std_logic_vector(3 downto 0);                     --                   .mem_dm
		mem_ras_n            : out   std_logic_vector(0 downto 0);                     --                   .mem_ras_n
		mem_cas_n            : out   std_logic_vector(0 downto 0);                     --                   .mem_cas_n
		mem_we_n             : out   std_logic_vector(0 downto 0);                     --                   .mem_we_n
		mem_reset_n          : out   std_logic;                                        --                   .mem_reset_n
		mem_dq               : inout std_logic_vector(31 downto 0) := (others => '0'); --                   .mem_dq
		mem_dqs              : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs
		mem_dqs_n            : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs_n
		mem_odt              : out   std_logic_vector(0 downto 0);                
		phy_clk					: out std_logic;
		oct_rzqin            : in    std_logic                     := '0';             --                oct.rzqin
		--aux_full_rate_clk	: out std_logic;
		--aux_half_rate_clk	: out std_logic;
		--reset_request_n		: out std_logic;
		begin_test				: in std_logic;
		insert_error			: in std_logic;
		pnf_per_bit         	: out std_logic_vector(31 downto 0);   
		pnf_per_bit_persist 	: out std_logic_vector(31 downto 0);
		pass                	: out std_logic;
		fail                	: out std_logic; 
		test_complete       	: out std_logic

        
        );
end DDR3_avmm_2x32_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of DDR3_avmm_2x32_ctrl  is
--declare signals,  components here

--inst0 signals 
signal inst0_local_addr			: std_logic_vector(mpfe_0_addr_size-1 downto 0);
signal inst0_local_write_req	: std_logic;
signal inst0_local_read_req	: std_logic;
signal inst0_local_burstbegin	: std_logic;
signal inst0_local_wdata		: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal inst0_local_be			: std_logic_vector(mpfe_0_bus_size/8*cntrl_rate-1 downto 0);
signal inst0_local_size			: std_logic_vector(1 downto 0);

--inst1 signals 
signal inst1_local_addr			: std_logic_vector(mpfe_1_addr_size-1 downto 0);
signal inst1_local_write_req	: std_logic;
signal inst1_local_read_req	: std_logic;
signal inst1_local_burstbegin	: std_logic;
signal inst1_local_wdata		: std_logic_vector(mpfe_1_bus_size-1 downto 0);
signal inst1_local_be			: std_logic_vector(mpfe_1_bus_size/8*cntrl_rate-1 downto 0);
signal inst1_local_size			: std_logic_vector(1 downto 0);

--inst2 signals 
signal inst2_avl_addr					: std_logic_vector(mpfe_0_addr_size-1 downto 0);
signal inst2_avl_write_req				: std_logic;
signal inst2_avl_read_req				: std_logic;
signal inst2_avl_burstbegin			: std_logic;
signal inst2_avl_wdata					: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal inst2_avl_be						: std_logic_vector(mpfe_0_bus_size/8*cntrl_rate-1 downto 0);
signal inst2_avl_size					: std_logic_vector(1 downto 0);
signal begin_test_port0					: std_logic;
signal inst2_pnf_per_bit 				: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal inst2_pnf_per_bit_persist		: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal inst2_pass							: std_logic;
signal inst2_fail							: std_logic;
signal inst2_test_complete				: std_logic;

--inst3 signals 
signal inst3_avl_addr					: std_logic_vector(mpfe_1_addr_size-1 downto 0);
signal inst3_avl_write_req				: std_logic;
signal inst3_avl_read_req				: std_logic;
signal inst3_avl_burstbegin			: std_logic;
signal inst3_avl_wdata					: std_logic_vector(mpfe_1_bus_size-1 downto 0);
signal inst3_avl_be						: std_logic_vector(mpfe_1_bus_size/8*cntrl_rate-1 downto 0);
signal inst3_avl_size					: std_logic_vector(1 downto 0);
signal begin_test_port1					: std_logic;
signal inst3_pnf_per_bit 				: std_logic_vector(mpfe_1_bus_size-1 downto 0);
signal inst3_pnf_per_bit_persist		: std_logic_vector(mpfe_1_bus_size-1 downto 0);
signal inst3_pass							: std_logic;
signal inst3_fail							: std_logic;
signal inst3_test_complete				: std_logic;

--Avalon signal mux port 0
signal mux_avl_addr_0			: std_logic_vector(mpfe_0_addr_size-1 downto 0);
signal mux_avl_write_req_0		: std_logic;
signal mux_avl_read_req_0		: std_logic;
signal mux_avl_burstbegin_0	: std_logic;
signal mux_avl_wdata_0			: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal mux_avl_be_0				: std_logic_vector(mpfe_0_bus_size/8*cntrl_rate-1 downto 0);
signal mux_avl_size_0			: std_logic_vector(1 downto 0);

--Avalon signal mux port 1
signal mux_avl_addr_1			: std_logic_vector(mpfe_1_addr_size-1 downto 0);
signal mux_avl_write_req_1		: std_logic;
signal mux_avl_read_req_1		: std_logic;
signal mux_avl_burstbegin_1	: std_logic;
signal mux_avl_wdata_1			: std_logic_vector(mpfe_1_bus_size-1 downto 0);
signal mux_avl_be_1				: std_logic_vector(mpfe_1_bus_size/8*cntrl_rate-1 downto 0);
signal mux_avl_size_1			: std_logic_vector(1 downto 0);

--DDR3 controller instance inst4 signals
signal inst4_afi_half_clk 				: std_logic;
signal inst4_avl_ready_0 				: std_logic;
signal inst4_avl_rdata_valid_0 		: std_logic;
signal inst4_avl_rdata_0 				: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal inst4_avl_ready_1 				: std_logic;
signal inst4_avl_rdata_valid_1 		: std_logic;
signal inst4_avl_rdata_1				: std_logic_vector(mpfe_1_bus_size-1 downto 0);
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
signal inst4_local_init_done 			: std_logic;
signal inst4_local_cal_success 		: std_logic;
signal inst4_local_cal_fail 			: std_logic;
signal inst4_pll_locked 				: std_logic;
signal inst4_soft_reset_n           : std_logic;

component avmm_arb_top is
	generic(
		dev_family	     	: string  := "Cyclone V GX";
		cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
		cntrl_bus_size		: integer := 16;
		addr_size			: integer := 24;
		lcl_bus_size		: integer := 63;
		lcl_burst_length	: integer := 2;
		cmd_fifo_size		: integer := 9;
		outfifo_size		: integer :=10 -- outfifo buffer size
		);
  port (
      clk       			: in std_logic;
      reset_n   			: in std_logic;
		--Write command ports
		wcmd_clk				: in std_logic;
		wcmd_reset_n		: in  std_logic;
		wcmd_rdy				: out std_logic;
		wcmd_addr			: in std_logic_vector(addr_size-1 downto 0);
		wcmd_wr				: in std_logic;
		wcmd_brst_en		: in std_logic; --1- writes in burst, 0- single write
		wcmd_data			: in std_logic_vector(lcl_bus_size-1 downto 0);
		--rd command ports
		rcmd_clk				: in std_logic;
		rcmd_reset_n		: in  std_logic;
		rcmd_rdy				: out std_logic;
		rcmd_addr			: in std_logic_vector(addr_size-1 downto 0);
		rcmd_wr				: in std_logic;
		rcmd_brst_en		: in std_logic; --1- reads in burst, 0- single read
		
		outbuf_wrusedw		: in std_logic_vector(outfifo_size-1 downto 0);
		
		local_ready			: in std_logic;
		local_addr			: out std_logic_vector(addr_size-1 downto 0);
		local_write_req	: out std_logic;
		local_read_req		: out std_logic;
		local_burstbegin	: out std_logic;
		local_wdata			: out std_logic_vector(lcl_bus_size-1 downto 0);
		local_be				: out std_logic_vector(lcl_bus_size/8*cntrl_rate-1 downto 0);
		local_size			: out std_logic_vector(1 downto 0)	
        );
end component;


component ddr3_av_2x32_tester is
	port (
		avl_ready           : in  std_logic                     := '0';             --       avl.waitrequest_n
		avl_addr            : out std_logic_vector(26 downto 0);                    --          .address
		avl_size            : out std_logic_vector(1 downto 0);                     --          .burstcount
		avl_wdata           : out std_logic_vector(31 downto 0);                    --          .writedata
		avl_rdata           : in  std_logic_vector(31 downto 0) := (others => '0'); --          .readdata
		avl_write_req       : out std_logic;                                        --          .write
		avl_read_req        : out std_logic;                                        --          .read
		avl_rdata_valid     : in  std_logic                     := '0';             --          .readdatavalid
		avl_be              : out std_logic_vector(3 downto 0);                     --          .byteenable
		avl_burstbegin      : out std_logic;                                        --          .beginbursttransfer
		clk                 : in  std_logic                     := '0';             -- avl_clock.clk
		reset_n             : in  std_logic                     := '0';             -- avl_reset.reset_n
		pnf_per_bit         : out std_logic_vector(31 downto 0);                    --       pnf.pnf_per_bit
		pnf_per_bit_persist : out std_logic_vector(31 downto 0);                    --          .pnf_per_bit_persist
		pass                : out std_logic;                                        --    status.pass
		fail                : out std_logic;                                        --          .fail
		test_complete       : out std_logic                                         --          .test_complete
	);
end component;

component ddr3_av_x64_tester is
	port (
		avl_ready           : in  std_logic                     := '0';             --       avl.waitrequest_n
		avl_addr            : out std_logic_vector(25 downto 0);                    --          .address
		avl_size            : out std_logic_vector(1 downto 0);                     --          .burstcount
		avl_wdata           : out std_logic_vector(63 downto 0);                    --          .writedata
		avl_rdata           : in  std_logic_vector(63 downto 0) := (others => '0'); --          .readdata
		avl_write_req       : out std_logic;                                        --          .write
		avl_read_req        : out std_logic;                                        --          .read
		avl_rdata_valid     : in  std_logic                     := '0';             --          .readdatavalid
		avl_be              : out std_logic_vector(7 downto 0);                     --          .byteenable
		avl_burstbegin      : out std_logic;                                        --          .beginbursttransfer
		clk                 : in  std_logic                     := '0';             -- avl_clock.clk
		reset_n             : in  std_logic                     := '0';             -- avl_reset.reset_n
		pnf_per_bit         : out std_logic_vector(63 downto 0);                    --       pnf.pnf_per_bit
		pnf_per_bit_persist : out std_logic_vector(63 downto 0);                    --          .pnf_per_bit_persist
		pass                : out std_logic;                                        --    status.pass
		fail                : out std_logic;                                        --          .fail
		test_complete       : out std_logic                                         --          .test_complete
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
		avl_addr_0                 : in    std_logic_vector(25 downto 0) := (others => '0'); --                   .address
		avl_rdata_valid_0          : out   std_logic;                                        --                   .readdatavalid
		avl_rdata_0                : out   std_logic_vector(63 downto 0);                    --                   .readdata
		avl_wdata_0                : in    std_logic_vector(63 downto 0) := (others => '0'); --                   .writedata
		avl_be_0                   : in    std_logic_vector(7 downto 0)  := (others => '0'); --                   .byteenable
		avl_read_req_0             : in    std_logic                     := '0';             --                   .read
		avl_write_req_0            : in    std_logic                     := '0';             --                   .write
		avl_size_0                 : in    std_logic_vector(1 downto 0)  := (others => '0'); --                   .burstcount
		avl_ready_1                : out   std_logic;                                        --              avl_1.waitrequest_n
		avl_burstbegin_1           : in    std_logic                     := '0';             --                   .beginbursttransfer
		avl_addr_1                 : in    std_logic_vector(25 downto 0) := (others => '0'); --                   .address
		avl_rdata_valid_1          : out   std_logic;                                        --                   .readdatavalid
		avl_rdata_1                : out   std_logic_vector(63 downto 0);                    --                   .readdata
		avl_wdata_1                : in    std_logic_vector(63 downto 0) := (others => '0'); --                   .writedata
		avl_be_1                   : in    std_logic_vector(7 downto 0)  := (others => '0'); --                   .byteenable
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

-- ----------------------------------------------------------------------------
-- Arbiter for memory port 0
-- ----------------------------------------------------------------------------
avmm_arb_top_inst0 : avmm_arb_top
	generic map(
		dev_family	     	=> dev_family,
		cntrl_rate			=> cntrl_rate,
		cntrl_bus_size		=> cntrl_bus_size,
		addr_size			=> mpfe_0_addr_size,
		lcl_bus_size		=> mpfe_0_bus_size,
		lcl_burst_length	=> mpfe_0_burst_length,
		cmd_fifo_size		=> cmd_fifo_size,
		outfifo_size		=> outfifo_size_0
		)
  port map (
      clk       			=> inst4_afi_half_clk,
      reset_n   			=> inst4_local_init_done,
		--Write command ports
		wcmd_clk				=> wcmd_clk_0,
		wcmd_reset_n		=> wcmd_reset_n_0,
		wcmd_rdy				=> wcmd_rdy_0,
		wcmd_addr			=> wcmd_addr_0,
		wcmd_wr				=> wcmd_wr_0,
		wcmd_brst_en		=> wcmd_brst_en_0,
		wcmd_data			=> wcmd_data_0,
		--rd command ports
		rcmd_clk				=> rcmd_clk_0,
		rcmd_reset_n		=> rcmd_reset_n_0,
		rcmd_rdy				=> rcmd_rdy_0,
		rcmd_addr			=> rcmd_addr_0,
		rcmd_wr				=> rcmd_wr_0,
		rcmd_brst_en		=> rcmd_brst_en_0,
		
		outbuf_wrusedw		=> outbuf_wrusedw_0,
		
		local_ready			=> inst4_avl_ready_0,
		local_addr			=> inst0_local_addr,
		local_write_req	=> inst0_local_write_req,
		local_read_req		=> inst0_local_read_req,
		local_burstbegin	=> inst0_local_burstbegin,
		local_wdata			=> inst0_local_wdata,
		local_be				=> inst0_local_be,
		local_size			=> inst0_local_size	
        );
		  
-- ----------------------------------------------------------------------------
-- Arbiter for memory port 1
-- ----------------------------------------------------------------------------
avmm_arb_top_inst1 : avmm_arb_top
	generic map(
		dev_family	     	=> dev_family,
		cntrl_rate			=> cntrl_rate,
		cntrl_bus_size		=> cntrl_bus_size,
		addr_size			=> mpfe_1_addr_size,
		lcl_bus_size		=> mpfe_1_bus_size,
		lcl_burst_length	=> mpfe_1_burst_length,
		cmd_fifo_size		=> cmd_fifo_size,
		outfifo_size		=> outfifo_size_1
		)
  port map (
      clk       			=> inst4_afi_half_clk,
      reset_n   			=> inst4_local_init_done,
		--Write command ports
		wcmd_clk				=> wcmd_clk_1,
		wcmd_reset_n		=> wcmd_reset_n_1,
		wcmd_rdy				=> wcmd_rdy_1,
		wcmd_addr			=> wcmd_addr_1,
		wcmd_wr				=> wcmd_wr_1,
		wcmd_brst_en		=> wcmd_brst_en_1,
		wcmd_data			=> wcmd_data_1,
		--rd command ports
		rcmd_clk				=> rcmd_clk_1,
		rcmd_reset_n		=> rcmd_reset_n_1,
		rcmd_rdy				=> rcmd_rdy_1,
		rcmd_addr			=> rcmd_addr_1,
		rcmd_wr				=> rcmd_wr_1,
		rcmd_brst_en		=> rcmd_brst_en_1,
		
		outbuf_wrusedw		=> outbuf_wrusedw_1,
		
		local_ready			=> inst4_avl_ready_1,
		local_addr			=> inst1_local_addr,
		local_write_req	=> inst1_local_write_req,
		local_read_req		=> inst1_local_read_req,
		local_burstbegin	=> inst1_local_burstbegin,
		local_wdata			=> inst1_local_wdata,
		local_be				=> inst1_local_be,
		local_size			=> inst1_local_size	
        );		  

-- ----------------------------------------------------------------------------
-- Port 0 tester
-- ----------------------------------------------------------------------------
ddr3_av_2x32_tester_inst2 : ddr3_av_x64_tester
	port map (
		avl_ready           => inst4_avl_ready_0,
		avl_addr            => inst2_avl_addr,
		avl_size            => inst2_avl_size,
		avl_wdata           => inst2_avl_wdata,
		avl_rdata           => inst4_avl_rdata_0,
		avl_write_req       => inst2_avl_write_req,
		avl_read_req        => inst2_avl_read_req,
		avl_rdata_valid     => inst4_avl_rdata_valid_0,
		avl_be              => inst2_avl_be,
		avl_burstbegin      => inst2_avl_burstbegin,
		clk                 => inst4_afi_half_clk,
		reset_n             => begin_test_port0,
		pnf_per_bit         => inst2_pnf_per_bit,
		pnf_per_bit_persist => inst2_pnf_per_bit_persist,
		pass                => inst2_pass,
		fail                => inst2_fail,
		test_complete       => inst2_test_complete
	);

begin_test_port0<= inst4_local_init_done and begin_test;

-- ----------------------------------------------------------------------------
-- Port 1 tester
-- ----------------------------------------------------------------------------
ddr3_av_x64_tester_inst3 : ddr3_av_x64_tester
	port map (
		avl_ready           => inst4_avl_ready_1,
		avl_addr            => inst3_avl_addr,
		avl_size            => inst3_avl_size,
		avl_wdata           => inst3_avl_wdata,
		avl_rdata           => inst4_avl_rdata_1,
		avl_write_req       => inst3_avl_write_req,
		avl_read_req        => inst3_avl_read_req,
		avl_rdata_valid     => inst4_avl_rdata_valid_1,
		avl_be              => inst3_avl_be,
		avl_burstbegin      => inst3_avl_burstbegin,
		clk                 => inst4_afi_half_clk,
		reset_n             => begin_test_port1,
		pnf_per_bit         => inst3_pnf_per_bit,
		pnf_per_bit_persist => inst3_pnf_per_bit_persist,
		pass                => inst3_pass,
		fail                => inst3_fail,
		test_complete       => inst3_test_complete
	);

begin_test_port1	<= begin_test_port0 and inst2_test_complete;

mux_avl_addr_0			<= inst0_local_addr			when begin_test='0' else inst2_avl_addr;
mux_avl_write_req_0	<= inst0_local_write_req	when begin_test='0' else inst2_avl_write_req;
mux_avl_read_req_0	<= inst0_local_read_req		when begin_test='0' else inst2_avl_read_req;
mux_avl_burstbegin_0	<= inst0_local_burstbegin	when begin_test='0' else inst2_avl_burstbegin;
mux_avl_wdata_0		<= inst0_local_wdata			when begin_test='0' else inst2_avl_wdata;
mux_avl_be_0			<= inst0_local_be				when begin_test='0' else inst2_avl_be;
mux_avl_size_0			<= inst0_local_size			when begin_test='0' else inst2_avl_size;

mux_avl_addr_1			<= inst1_local_addr			when begin_test='0' else inst3_avl_addr;
mux_avl_write_req_1	<= inst1_local_write_req	when begin_test='0' else inst3_avl_write_req;
mux_avl_read_req_1	<= inst1_local_read_req		when begin_test='0' else inst3_avl_read_req;
mux_avl_burstbegin_1	<= inst1_local_burstbegin	when begin_test='0' else inst3_avl_burstbegin;
mux_avl_wdata_1		<= inst1_local_wdata			when begin_test='0' else inst3_avl_wdata;
mux_avl_be_1			<= inst1_local_be				when begin_test='0' else inst3_avl_be;
mux_avl_size_1			<= inst1_local_size			when begin_test='0' else inst3_avl_size;

inst4_soft_reset_n <= inst4_pll_locked AND soft_reset_n;

	ddr3_av_2x32_inst4: component ddr3_av_2x32
		port map (
			pll_ref_clk                => pll_ref_clk,                --        pll_ref_clk.clk
			global_reset_n             => global_reset_n,             --       global_reset.reset_n
			soft_reset_n               => inst4_soft_reset_n,           --         soft_reset.reset_n
			afi_clk                    => open, -- afi_clk,           --            afi_clk.clk
			afi_half_clk               => inst4_afi_half_clk,         --       afi_half_clk.clk
			afi_reset_n                => open, --afi_reset_n,        --          afi_reset.reset_n
			afi_reset_export_n         => open, --afi_reset_export_n, --   afi_reset_export.reset_n
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
			avl_ready_0                => inst4_avl_ready_0,          --              avl_0.waitrequest_n
			avl_burstbegin_0           => mux_avl_burstbegin_0,       --                   .beginbursttransfer
			avl_addr_0                 => mux_avl_addr_0,             --                   .address
			avl_rdata_valid_0          => inst4_avl_rdata_valid_0,    --                   .readdatavalid
			avl_rdata_0                => inst4_avl_rdata_0,          --                   .readdata
			avl_wdata_0                => mux_avl_wdata_0,            --                   .writedata
			avl_be_0                   => mux_avl_be_0,               --                   .byteenable
			avl_read_req_0             => mux_avl_read_req_0,         --                   .read
			avl_write_req_0            => mux_avl_write_req_0,        --                   .write
			avl_size_0                 => mux_avl_size_0,             --                   .burstcount
			avl_ready_1                => inst4_avl_ready_1,          --              avl_1.waitrequest_n
			avl_burstbegin_1           => mux_avl_burstbegin_1,       --                   .beginbursttransfer
			avl_addr_1                 => mux_avl_addr_1,             --                   .address
			avl_rdata_valid_1          => inst4_avl_rdata_valid_1,    --                   .readdatavalid
			avl_rdata_1                => inst4_avl_rdata_1,          --                   .readdata
			avl_wdata_1                => mux_avl_wdata_1,            --                   .writedata
			avl_be_1                   => mux_avl_be_1,               --                   .byteenable
			avl_read_req_1             => mux_avl_read_req_1,         --                   .read
			avl_write_req_1            => mux_avl_write_req_1,        --                   .write
			avl_size_1                 => mux_avl_size_1,             --                   .burstcount
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
			local_init_done            => inst4_local_init_done,      --             status.local_init_done
			local_cal_success          => inst4_local_cal_success,    --                   .local_cal_success
			local_cal_fail             => inst4_local_cal_fail,       --                   .local_cal_fail
			oct_rzqin                  => oct_rzqin,                  --                oct.rzqin
			pll_mem_clk                => open, --pll_mem_clk,        --        pll_sharing.pll_mem_clk
			pll_write_clk              => open, --pll_write_clk,      --                   .pll_write_clk
			pll_locked                 => inst4_pll_locked,           --                   .pll_locked
			pll_write_clk_pre_phy_clk  => open, --pll_write_clk_pre_phy_clk,  --                   .pll_write_clk_pre_phy_clk
			pll_addr_cmd_clk           => open, --pll_addr_cmd_clk,           --                   .pll_addr_cmd_clk
			pll_avl_clk                => open, --pll_avl_clk,                --                   .pll_avl_clk
			pll_config_clk             => open, --pll_config_clk,             --                   .pll_config_clk
			pll_mem_phy_clk            => open, --pll_mem_phy_clk,            --                   .pll_mem_phy_clk
			afi_phy_clk                => open, --afi_phy_clk,                --                   .afi_phy_clk
			pll_avl_phy_clk            => open --pll_avl_phy_clk              --                   .pll_avl_phy_clk
		);

		
mp_cmd_clk_0_clk 				<= inst4_afi_half_clk;
mp_cmd_reset_n_0_reset_n 	<= inst4_local_cal_success;
mp_cmd_clk_1_clk 				<= inst4_afi_half_clk;
mp_cmd_reset_n_1_reset_n 	<= inst4_local_cal_success;
mp_rfifo_clk_0_clk 			<= inst4_afi_half_clk;
mp_rfifo_reset_n_0_reset_n <= inst4_local_cal_success;
mp_wfifo_clk_0_clk 			<= inst4_afi_half_clk;
mp_wfifo_reset_n_0_reset_n <= inst4_local_cal_success;
mp_rfifo_clk_1_clk 			<= inst4_afi_half_clk;
mp_rfifo_reset_n_1_reset_n <= inst4_local_cal_success;
mp_wfifo_clk_1_clk 			<= inst4_afi_half_clk;
mp_wfifo_reset_n_1_reset_n <= inst4_local_cal_success;


--top level ports
pass 						<= inst2_pass and inst3_pass;
fail 						<= inst2_fail and inst3_fail;
test_complete 			<= inst2_test_complete and inst3_test_complete;
phy_clk					<= inst4_afi_half_clk;
local_init_done		<= inst4_local_init_done;
local_rdata_0			<= inst4_avl_rdata_0;		
local_rdata_valid_0	<= inst4_avl_rdata_valid_0;
local_rdata_1			<= inst4_avl_rdata_1;		
local_rdata_valid_1	<= inst4_avl_rdata_valid_1;

  
end arch;   




