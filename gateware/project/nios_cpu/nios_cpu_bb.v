
module nios_cpu (
	avmm_m0_address,
	avmm_m0_read,
	avmm_m0_waitrequest,
	avmm_m0_readdata,
	avmm_m0_write,
	avmm_m0_writedata,
	avmm_m0_readdatavalid,
	avmm_m0_clk_clk,
	avmm_m0_reset_reset,
	avmm_s0_address,
	avmm_s0_read,
	avmm_s0_readdata,
	avmm_s0_write,
	avmm_s0_writedata,
	avmm_s0_waitrequest,
	avmm_s1_address,
	avmm_s1_read,
	avmm_s1_readdata,
	avmm_s1_write,
	avmm_s1_writedata,
	avmm_s1_waitrequest,
	clk_clk,
	dac_spi1_MISO,
	dac_spi1_MOSI,
	dac_spi1_SCLK,
	dac_spi1_SS_n,
	exfifo_if_d_export,
	exfifo_if_rd_export,
	exfifo_if_rdempty_export,
	exfifo_of_d_export,
	exfifo_of_wr_export,
	exfifo_of_wrfull_export,
	exfifo_rst_export,
	fpga_spi0_MISO,
	fpga_spi0_MOSI,
	fpga_spi0_SCLK,
	fpga_spi0_SS_n,
	gpi0_export,
	gpio0_export,
	pll_recfg_from_pll_0_reconfig_from_pll,
	pll_recfg_from_pll_1_reconfig_from_pll,
	pll_recfg_from_pll_2_reconfig_from_pll,
	pll_recfg_from_pll_3_reconfig_from_pll,
	pll_recfg_from_pll_4_reconfig_from_pll,
	pll_recfg_from_pll_5_reconfig_from_pll,
	pll_recfg_to_pll_0_reconfig_to_pll,
	pll_recfg_to_pll_1_reconfig_to_pll,
	pll_recfg_to_pll_2_reconfig_to_pll,
	pll_recfg_to_pll_3_reconfig_to_pll,
	pll_recfg_to_pll_4_reconfig_to_pll,
	pll_recfg_to_pll_5_reconfig_to_pll,
	pll_rst_export,
	pllcfg_cmd_export,
	pllcfg_spi_MISO,
	pllcfg_spi_MOSI,
	pllcfg_spi_SCLK,
	pllcfg_spi_SS_n,
	pllcfg_stat_export,
	scl_export,
	sda_export,
	vctcxo_tamer_0_ctrl_export,
	spi_2_MISO,
	spi_2_MOSI,
	spi_2_SCLK,
	spi_2_SS_n);	

	output	[7:0]	avmm_m0_address;
	output		avmm_m0_read;
	input		avmm_m0_waitrequest;
	input	[7:0]	avmm_m0_readdata;
	output		avmm_m0_write;
	output	[7:0]	avmm_m0_writedata;
	input		avmm_m0_readdatavalid;
	output		avmm_m0_clk_clk;
	output		avmm_m0_reset_reset;
	input	[31:0]	avmm_s0_address;
	input		avmm_s0_read;
	output	[31:0]	avmm_s0_readdata;
	input		avmm_s0_write;
	input	[31:0]	avmm_s0_writedata;
	output		avmm_s0_waitrequest;
	input	[31:0]	avmm_s1_address;
	input		avmm_s1_read;
	output	[31:0]	avmm_s1_readdata;
	input		avmm_s1_write;
	input	[31:0]	avmm_s1_writedata;
	output		avmm_s1_waitrequest;
	input		clk_clk;
	input		dac_spi1_MISO;
	output		dac_spi1_MOSI;
	output		dac_spi1_SCLK;
	output		dac_spi1_SS_n;
	input	[31:0]	exfifo_if_d_export;
	output		exfifo_if_rd_export;
	input		exfifo_if_rdempty_export;
	output	[31:0]	exfifo_of_d_export;
	output		exfifo_of_wr_export;
	input		exfifo_of_wrfull_export;
	output		exfifo_rst_export;
	input		fpga_spi0_MISO;
	output		fpga_spi0_MOSI;
	output		fpga_spi0_SCLK;
	output	[7:0]	fpga_spi0_SS_n;
	input	[7:0]	gpi0_export;
	output	[7:0]	gpio0_export;
	input	[63:0]	pll_recfg_from_pll_0_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_1_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_2_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_3_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_4_reconfig_from_pll;
	input	[63:0]	pll_recfg_from_pll_5_reconfig_from_pll;
	output	[63:0]	pll_recfg_to_pll_0_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_1_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_2_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_3_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_4_reconfig_to_pll;
	output	[63:0]	pll_recfg_to_pll_5_reconfig_to_pll;
	output	[31:0]	pll_rst_export;
	input	[3:0]	pllcfg_cmd_export;
	input		pllcfg_spi_MISO;
	output		pllcfg_spi_MOSI;
	output		pllcfg_spi_SCLK;
	output		pllcfg_spi_SS_n;
	output	[9:0]	pllcfg_stat_export;
	inout		scl_export;
	inout		sda_export;
	input	[3:0]	vctcxo_tamer_0_ctrl_export;
	input		spi_2_MISO;
	output		spi_2_MOSI;
	output		spi_2_SCLK;
	output		spi_2_SS_n;
endmodule
