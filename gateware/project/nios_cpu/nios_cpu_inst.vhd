	component nios_cpu is
		port (
			avmm_m0_address                        : out   std_logic_vector(7 downto 0);                     -- address
			avmm_m0_read                           : out   std_logic;                                        -- read
			avmm_m0_waitrequest                    : in    std_logic                     := 'X';             -- waitrequest
			avmm_m0_readdata                       : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- readdata
			avmm_m0_write                          : out   std_logic;                                        -- write
			avmm_m0_writedata                      : out   std_logic_vector(7 downto 0);                     -- writedata
			avmm_m0_readdatavalid                  : in    std_logic                     := 'X';             -- readdatavalid
			avmm_m0_clk_clk                        : out   std_logic;                                        -- clk
			avmm_m0_reset_reset                    : out   std_logic;                                        -- reset
			avmm_s0_address                        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- address
			avmm_s0_read                           : in    std_logic                     := 'X';             -- read
			avmm_s0_readdata                       : out   std_logic_vector(31 downto 0);                    -- readdata
			avmm_s0_write                          : in    std_logic                     := 'X';             -- write
			avmm_s0_writedata                      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avmm_s0_waitrequest                    : out   std_logic;                                        -- waitrequest
			avmm_s1_address                        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- address
			avmm_s1_read                           : in    std_logic                     := 'X';             -- read
			avmm_s1_readdata                       : out   std_logic_vector(31 downto 0);                    -- readdata
			avmm_s1_write                          : in    std_logic                     := 'X';             -- write
			avmm_s1_writedata                      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avmm_s1_waitrequest                    : out   std_logic;                                        -- waitrequest
			clk_clk                                : in    std_logic                     := 'X';             -- clk
			dac_spi1_MISO                          : in    std_logic                     := 'X';             -- MISO
			dac_spi1_MOSI                          : out   std_logic;                                        -- MOSI
			dac_spi1_SCLK                          : out   std_logic;                                        -- SCLK
			dac_spi1_SS_n                          : out   std_logic;                                        -- SS_n
			exfifo_if_d_export                     : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			exfifo_if_rd_export                    : out   std_logic;                                        -- export
			exfifo_if_rdempty_export               : in    std_logic                     := 'X';             -- export
			exfifo_of_d_export                     : out   std_logic_vector(31 downto 0);                    -- export
			exfifo_of_wr_export                    : out   std_logic;                                        -- export
			exfifo_of_wrfull_export                : in    std_logic                     := 'X';             -- export
			exfifo_rst_export                      : out   std_logic;                                        -- export
			fpga_spi0_MISO                         : in    std_logic                     := 'X';             -- MISO
			fpga_spi0_MOSI                         : out   std_logic;                                        -- MOSI
			fpga_spi0_SCLK                         : out   std_logic;                                        -- SCLK
			fpga_spi0_SS_n                         : out   std_logic_vector(7 downto 0);                     -- SS_n
			gpi0_export                            : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			gpio0_export                           : out   std_logic_vector(7 downto 0);                     -- export
			pll_recfg_from_pll_0_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_1_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_2_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_3_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_4_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_5_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_to_pll_0_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_1_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_2_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_3_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_4_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_5_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_rst_export                         : out   std_logic_vector(31 downto 0);                    -- export
			pllcfg_cmd_export                      : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			pllcfg_spi_MISO                        : in    std_logic                     := 'X';             -- MISO
			pllcfg_spi_MOSI                        : out   std_logic;                                        -- MOSI
			pllcfg_spi_SCLK                        : out   std_logic;                                        -- SCLK
			pllcfg_spi_SS_n                        : out   std_logic;                                        -- SS_n
			pllcfg_stat_export                     : out   std_logic_vector(9 downto 0);                     -- export
			scl_export                             : inout std_logic                     := 'X';             -- export
			sda_export                             : inout std_logic                     := 'X';             -- export
			vctcxo_tamer_0_ctrl_export             : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			spi_2_MISO                             : in    std_logic                     := 'X';             -- MISO
			spi_2_MOSI                             : out   std_logic;                                        -- MOSI
			spi_2_SCLK                             : out   std_logic;                                        -- SCLK
			spi_2_SS_n                             : out   std_logic                                         -- SS_n
		);
	end component nios_cpu;

	u0 : component nios_cpu
		port map (
			avmm_m0_address                        => CONNECTED_TO_avmm_m0_address,                        --              avmm_m0.address
			avmm_m0_read                           => CONNECTED_TO_avmm_m0_read,                           --                     .read
			avmm_m0_waitrequest                    => CONNECTED_TO_avmm_m0_waitrequest,                    --                     .waitrequest
			avmm_m0_readdata                       => CONNECTED_TO_avmm_m0_readdata,                       --                     .readdata
			avmm_m0_write                          => CONNECTED_TO_avmm_m0_write,                          --                     .write
			avmm_m0_writedata                      => CONNECTED_TO_avmm_m0_writedata,                      --                     .writedata
			avmm_m0_readdatavalid                  => CONNECTED_TO_avmm_m0_readdatavalid,                  --                     .readdatavalid
			avmm_m0_clk_clk                        => CONNECTED_TO_avmm_m0_clk_clk,                        --          avmm_m0_clk.clk
			avmm_m0_reset_reset                    => CONNECTED_TO_avmm_m0_reset_reset,                    --        avmm_m0_reset.reset
			avmm_s0_address                        => CONNECTED_TO_avmm_s0_address,                        --              avmm_s0.address
			avmm_s0_read                           => CONNECTED_TO_avmm_s0_read,                           --                     .read
			avmm_s0_readdata                       => CONNECTED_TO_avmm_s0_readdata,                       --                     .readdata
			avmm_s0_write                          => CONNECTED_TO_avmm_s0_write,                          --                     .write
			avmm_s0_writedata                      => CONNECTED_TO_avmm_s0_writedata,                      --                     .writedata
			avmm_s0_waitrequest                    => CONNECTED_TO_avmm_s0_waitrequest,                    --                     .waitrequest
			avmm_s1_address                        => CONNECTED_TO_avmm_s1_address,                        --              avmm_s1.address
			avmm_s1_read                           => CONNECTED_TO_avmm_s1_read,                           --                     .read
			avmm_s1_readdata                       => CONNECTED_TO_avmm_s1_readdata,                       --                     .readdata
			avmm_s1_write                          => CONNECTED_TO_avmm_s1_write,                          --                     .write
			avmm_s1_writedata                      => CONNECTED_TO_avmm_s1_writedata,                      --                     .writedata
			avmm_s1_waitrequest                    => CONNECTED_TO_avmm_s1_waitrequest,                    --                     .waitrequest
			clk_clk                                => CONNECTED_TO_clk_clk,                                --                  clk.clk
			dac_spi1_MISO                          => CONNECTED_TO_dac_spi1_MISO,                          --             dac_spi1.MISO
			dac_spi1_MOSI                          => CONNECTED_TO_dac_spi1_MOSI,                          --                     .MOSI
			dac_spi1_SCLK                          => CONNECTED_TO_dac_spi1_SCLK,                          --                     .SCLK
			dac_spi1_SS_n                          => CONNECTED_TO_dac_spi1_SS_n,                          --                     .SS_n
			exfifo_if_d_export                     => CONNECTED_TO_exfifo_if_d_export,                     --          exfifo_if_d.export
			exfifo_if_rd_export                    => CONNECTED_TO_exfifo_if_rd_export,                    --         exfifo_if_rd.export
			exfifo_if_rdempty_export               => CONNECTED_TO_exfifo_if_rdempty_export,               --    exfifo_if_rdempty.export
			exfifo_of_d_export                     => CONNECTED_TO_exfifo_of_d_export,                     --          exfifo_of_d.export
			exfifo_of_wr_export                    => CONNECTED_TO_exfifo_of_wr_export,                    --         exfifo_of_wr.export
			exfifo_of_wrfull_export                => CONNECTED_TO_exfifo_of_wrfull_export,                --     exfifo_of_wrfull.export
			exfifo_rst_export                      => CONNECTED_TO_exfifo_rst_export,                      --           exfifo_rst.export
			fpga_spi0_MISO                         => CONNECTED_TO_fpga_spi0_MISO,                         --            fpga_spi0.MISO
			fpga_spi0_MOSI                         => CONNECTED_TO_fpga_spi0_MOSI,                         --                     .MOSI
			fpga_spi0_SCLK                         => CONNECTED_TO_fpga_spi0_SCLK,                         --                     .SCLK
			fpga_spi0_SS_n                         => CONNECTED_TO_fpga_spi0_SS_n,                         --                     .SS_n
			gpi0_export                            => CONNECTED_TO_gpi0_export,                            --                 gpi0.export
			gpio0_export                           => CONNECTED_TO_gpio0_export,                           --                gpio0.export
			pll_recfg_from_pll_0_reconfig_from_pll => CONNECTED_TO_pll_recfg_from_pll_0_reconfig_from_pll, -- pll_recfg_from_pll_0.reconfig_from_pll
			pll_recfg_from_pll_1_reconfig_from_pll => CONNECTED_TO_pll_recfg_from_pll_1_reconfig_from_pll, -- pll_recfg_from_pll_1.reconfig_from_pll
			pll_recfg_from_pll_2_reconfig_from_pll => CONNECTED_TO_pll_recfg_from_pll_2_reconfig_from_pll, -- pll_recfg_from_pll_2.reconfig_from_pll
			pll_recfg_from_pll_3_reconfig_from_pll => CONNECTED_TO_pll_recfg_from_pll_3_reconfig_from_pll, -- pll_recfg_from_pll_3.reconfig_from_pll
			pll_recfg_from_pll_4_reconfig_from_pll => CONNECTED_TO_pll_recfg_from_pll_4_reconfig_from_pll, -- pll_recfg_from_pll_4.reconfig_from_pll
			pll_recfg_from_pll_5_reconfig_from_pll => CONNECTED_TO_pll_recfg_from_pll_5_reconfig_from_pll, -- pll_recfg_from_pll_5.reconfig_from_pll
			pll_recfg_to_pll_0_reconfig_to_pll     => CONNECTED_TO_pll_recfg_to_pll_0_reconfig_to_pll,     --   pll_recfg_to_pll_0.reconfig_to_pll
			pll_recfg_to_pll_1_reconfig_to_pll     => CONNECTED_TO_pll_recfg_to_pll_1_reconfig_to_pll,     --   pll_recfg_to_pll_1.reconfig_to_pll
			pll_recfg_to_pll_2_reconfig_to_pll     => CONNECTED_TO_pll_recfg_to_pll_2_reconfig_to_pll,     --   pll_recfg_to_pll_2.reconfig_to_pll
			pll_recfg_to_pll_3_reconfig_to_pll     => CONNECTED_TO_pll_recfg_to_pll_3_reconfig_to_pll,     --   pll_recfg_to_pll_3.reconfig_to_pll
			pll_recfg_to_pll_4_reconfig_to_pll     => CONNECTED_TO_pll_recfg_to_pll_4_reconfig_to_pll,     --   pll_recfg_to_pll_4.reconfig_to_pll
			pll_recfg_to_pll_5_reconfig_to_pll     => CONNECTED_TO_pll_recfg_to_pll_5_reconfig_to_pll,     --   pll_recfg_to_pll_5.reconfig_to_pll
			pll_rst_export                         => CONNECTED_TO_pll_rst_export,                         --              pll_rst.export
			pllcfg_cmd_export                      => CONNECTED_TO_pllcfg_cmd_export,                      --           pllcfg_cmd.export
			pllcfg_spi_MISO                        => CONNECTED_TO_pllcfg_spi_MISO,                        --           pllcfg_spi.MISO
			pllcfg_spi_MOSI                        => CONNECTED_TO_pllcfg_spi_MOSI,                        --                     .MOSI
			pllcfg_spi_SCLK                        => CONNECTED_TO_pllcfg_spi_SCLK,                        --                     .SCLK
			pllcfg_spi_SS_n                        => CONNECTED_TO_pllcfg_spi_SS_n,                        --                     .SS_n
			pllcfg_stat_export                     => CONNECTED_TO_pllcfg_stat_export,                     --          pllcfg_stat.export
			scl_export                             => CONNECTED_TO_scl_export,                             --                  scl.export
			sda_export                             => CONNECTED_TO_sda_export,                             --                  sda.export
			vctcxo_tamer_0_ctrl_export             => CONNECTED_TO_vctcxo_tamer_0_ctrl_export,             --  vctcxo_tamer_0_ctrl.export
			spi_2_MISO                             => CONNECTED_TO_spi_2_MISO,                             --                spi_2.MISO
			spi_2_MOSI                             => CONNECTED_TO_spi_2_MOSI,                             --                     .MOSI
			spi_2_SCLK                             => CONNECTED_TO_spi_2_SCLK,                             --                     .SCLK
			spi_2_SS_n                             => CONNECTED_TO_spi_2_SS_n                              --                     .SS_n
		);

