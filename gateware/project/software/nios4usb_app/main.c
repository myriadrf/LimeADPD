/*
 * main.c
 *
 *  Created on: Mar 23, 2016
 *      Author: zydrunas
 */

#include "io.h"
#include <system.h>
#include <stdbool.h>
#include "alt_types.h"
#include <stdint.h>
#include <string.h>

#include "pll_rcfg.h"

#include <altera_avalon_spi.h>

#include "LMS64C_protocol.h"
#include "limesdr_qpcie_brd.h"
#include "i2c_opencores.h"
#include "vctcxo_tamer.h"
#include "math.h"

#define sbi(p,n) ((p) |= (1UL << (n)))
#define cbi(p,n) ((p) &= ~(1 << (n)))

//#define FW_VER			1 //Initial version
#define FW_VER				2 //NIOS memory increased up to 32kB
							  //I2C module added
							  //POT, ADF4002, TCXO DAC, LM75, Si5351C control implemented

#define SPI_NR_LMS7002M_0   0
#define SPI_NR_LMS7002M_1   1
#define SPI_NR_TCXO_ADF4002 2
#define SPI_NR_TCXO_DAC     0
#define SPI_NR_POT          4
#define SPI_NR_EXTADC       5
#define SPI_NR_FPGA         6
#define SPI_2_NR_EXTADC    	0



#define BRD_SPI_REG_LMS1_LMS2_CTRL  0x13
#define LMS1_SS			0
#define LMS1_RESET		1
#define LMS2_SS			8
#define LMS2_RESET		9

uint16_t dac_val = 30714;		//TCXO DAC value
signed short int converted_val = 300;	//Temperature


uint8_t test, block, cmd_errors, glEp0Buffer_Rx[64], glEp0Buffer_Tx[64];
tLMS_Ctrl_Packet *LMS_Ctrl_Packet_Tx = (tLMS_Ctrl_Packet*)glEp0Buffer_Tx;
tLMS_Ctrl_Packet *LMS_Ctrl_Packet_Rx = (tLMS_Ctrl_Packet*)glEp0Buffer_Rx;


/**	This function checks if all blocks could fit in data field.
*	If blocks will not fit, function returns TRUE. */
unsigned char Check_many_blocks (unsigned char block_size)
{
	if (LMS_Ctrl_Packet_Rx->Header.Data_blocks > (sizeof(LMS_Ctrl_Packet_Tx->Data_field)/block_size))
	{
		LMS_Ctrl_Packet_Tx->Header.Status = STATUS_BLOCKS_ERROR_CMD;
		return 1;
	}
	else return 0;
	return 1;
}

/** Cchecks if peripheral ID is valid.
 Returns 1 if valid, else 0. */
unsigned char Check_Periph_ID (unsigned char max_periph_id, unsigned char Periph_ID)
{
		if (LMS_Ctrl_Packet_Rx->Header.Periph_ID > max_periph_id)
		{
		LMS_Ctrl_Packet_Tx->Header.Status = STATUS_INVALID_PERIPH_ID_CMD;
		return 0;
		}
	else return 1;
}

/**
 * Gets 64 bytes packet from FIFO.
 */
void getFifoData(uint8_t *buf, uint8_t k)
{
	uint8_t cnt = 0;
	uint32_t* dest = (uint32_t*)buf;
	for(cnt=0; cnt<k/sizeof(uint32_t); ++cnt)
	{
		dest[cnt] = IORD(AV_FIFO_INT_0_BASE, 1);	// Read Data from FIFO
	};
}

/**
 * Configures LM75
 */

void Configure_LM75(void)
{
	int spirez;

	// OS polarity configuration
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x01, 0);				// Pointer = configuration register
	//spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x04, 1);				//Configuration value: OS polarity = 1, Comparator/int = 0, Shutdown = 0

	// THYST configuration
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x02, 0);				// Pointer = THYST register
	//spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 45, 0);				// Set THYST H
	spirez = I2C_write(I2C_OPENCORES_0_BASE,  0, 1);				// Set THYST L

	// TOS configuration
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x03, 0);				// Pointer = TOS register
	//spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 55, 0);				// Set TOS H
	spirez = I2C_write(I2C_OPENCORES_0_BASE,  0, 1);				// Set TOS L
}

void init_ADC()
{
	uint8_t wr_buf[2];
	uint8_t rd_buf[2];
	int spirez;

	// Reset ADC
    //ui32_tmp = IORD(GPIO_0_BASE, 0x00);
    //IOWR(GPIO_0_BASE, 0x00, ui32_tmp | 0x00000001);	//Set to 1
    //asm("nop"); asm("nop"); asm("nop");
    //IOWR(GPIO_0_BASE, 0x00, ui32_tmp & 0xFFFFFFFE);	//Set to 0

	//IOWR_8DIRECT(GPIO_0_BASE, 0x00, 0x01);	//Set to 1
    //asm("nop"); asm("nop"); asm("nop");
	IOWR_8DIRECT(GPIO_0_BASE, 0x00, 0x00);	//Set to 0

	// Disable ADC readout and reset
	wr_buf[0] = 0x00;	//Address
	wr_buf[1] = 0x02;	//Data
	//wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x01
	wr_buf[0] = 0x01;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x03
	wr_buf[0] = 0x03;	//Address
	//wr_buf[1] = 0x53;	//Data
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x25
	wr_buf[0] = 0x25;	//Address
	wr_buf[1] = 0x04;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x29
	wr_buf[0] = 0x29;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x2B
	wr_buf[0] = 0x2B;	//Address
	wr_buf[1] = 0x04;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x3D
	wr_buf[0] = 0x3D;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x3F
	wr_buf[0] = 0x3F;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x40
	wr_buf[0] = 0x40;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x41
	wr_buf[0] = 0x41;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x42
	wr_buf[0] = 0x42;	//Address
	//wr_buf[1] = 0x08;	//Data
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x45
	wr_buf[0] = 0x45;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x4A
	wr_buf[0] = 0x4A;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0x58
	wr_buf[0] = 0x58;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0xBF
	wr_buf[0] = 0xBF;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0xC1
	wr_buf[0] = 0xC1;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0xCF
	wr_buf[0] = 0xCF;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0xDB
	wr_buf[0] = 0xDB;	//Address
	wr_buf[1] = 0x01;	//Data (0x01 - Low Speed MODE CH B enabled, 0x00 - Low Speed MODE CH B disabled)
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0xEF
	wr_buf[0] = 0xEF;	//Address
	wr_buf[1] = 0x10;	//Data (0x10 - Low Speed MODE enabled, 0x00 - Low Speed MODE disabled)
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0xF1
	wr_buf[0] = 0xF1;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// 0xF2
	wr_buf[0] = 0xF2;	//Address
	wr_buf[1] = 0x08;	//Data (0x08 - Low Speed MODE CH A enabled, 0x00 - Low Speed MODE CH A disabled)
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	// ---------------Testing
	// Enable ADC readout


	wr_buf[0] = 0x00;	//Address
	wr_buf[1] = 0x01;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	wr_buf[0] = 0x3F;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0x40;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0x41;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0x42;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0x45;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0x4A;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0x58;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0xBF;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0xC1;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0xCF;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0xDB;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0xEF;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0xF1;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	wr_buf[0] = 0xF2;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

	// Disable ADC readout
	wr_buf[0] = 0x00;	//Address
	wr_buf[1] = 0x00;	//Data
	spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);









}

/**
 *	@brief Function to control DAC for TCXO frequency control
 *	@param oe output enable control: 0 - output disabled, 1 - output enabled
 *	@param data pointer to DAC value (1 byte)
 */
void Control_TCXO_DAC (unsigned char oe, uint16_t *data) //controls DAC (AD5601)
{
	volatile int spirez;
	unsigned char DAC_data[3];

	if (oe == 0) //set DAC out to three-state
	{
		DAC_data[0] = 0x03; //POWER-DOWN MODE = THREE-STATE (PD[1:0]([17:16]) = 11)
		DAC_data[1] = 0x00;
		DAC_data[2] = 0x00; //LSB data

		spirez = alt_avalon_spi_command(DAC_SPI1_BASE, SPI_NR_TCXO_DAC, 3, DAC_data, 0, NULL, 0);
	}
	else //enable DAC output, set new val
	{
		DAC_data[0] = 0; //POWER-DOWN MODE = NORMAL OPERATION PD[1:0]([17:16]) = 00)
		DAC_data[1] = ((*data) >>8) & 0xFF;
		DAC_data[2] = ((*data) >>0) & 0xFF;

	    /* Update cached value of trim DAC setting */
	    vctcxo_trim_dac_value = (uint16_t) *data;
		spirez = alt_avalon_spi_command(DAC_SPI1_BASE, SPI_NR_TCXO_DAC, 3, DAC_data, 0, NULL, 0);
	}
}

/**
 *	@brief Function to control ADF for TCXO frequency control
 *	@param oe output enable control: 0 - output disabled, 1 - output enabled
 *	@param data pointer to ADF data block (3 bytes)
 */
void Control_TCXO_ADF (unsigned char oe, unsigned char *data) //controls ADF4002
{
	volatile int spirez;
	unsigned char ADF_data[12], ADF_block;

	if (oe == 0) //set ADF4002 CP to three-state and MUX_OUT to DGND
	{
		ADF_data[0] = 0x1f;
		ADF_data[1] = 0x81;
		ADF_data[2] = 0xf3;
		ADF_data[3] = 0x1f;
		ADF_data[4] = 0x81;
		ADF_data[5] = 0xf2;
		ADF_data[6] = 0x00;
		ADF_data[7] = 0x01;
		ADF_data[8] = 0xf4;
		ADF_data[9] = 0x01;
		ADF_data[10] = 0x80;
		ADF_data[11] = 0x01;

		//Reconfigure_SPI_for_LMS();

		//write data to ADF
		for(ADF_block = 0; ADF_block < 4; ADF_block++)
		{
			spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_TCXO_ADF4002, 3, &ADF_data[ADF_block*3], 0, NULL, 0);
		}
	}
	else //set PLL parameters, 4 blocks must be written
	{
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_TCXO_ADF4002, 3, data, 0, NULL, 0);
	}
}

void change_ADC_tpat(uint8_t mode)
{
	uint8_t wr_buf[2];
	uint8_t rd_buf[2];
	int spirez;

	if(mode)
	{
		// Upload Test pattern 1
		// 0x03
		//wr_buf[0] = 0x03;	//Address
		//wr_buf[1] = 0x53;	//Data
		//spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		//Was before
		/*
		// 0x25
		wr_buf[0] = 0x25;	//Address
		wr_buf[1] = 0x05;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x2B
		wr_buf[0] = 0x2B;	//Address
		wr_buf[1] = 0x05;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x3F
		wr_buf[0] = 0x3F;	//Address
		wr_buf[1] = 0x55;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x40
		wr_buf[0] = 0x40;	//Address
		wr_buf[1] = 0x55;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);
		*/

		// Disable ADC readout
		wr_buf[0] = 0x00;	//Address
		wr_buf[1] = 0x00;	//Data
		spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x25
		wr_buf[0] = 0x25;	//Address
		wr_buf[1] = 0x03;	//Data
		spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x2B
		wr_buf[0] = 0x2B;	//Address
		wr_buf[1] = 0x03;	//Data
		spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x3F
		wr_buf[0] = 0x3F;	//Address
		wr_buf[1] = 0x1F;	//Data
		spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x40
		wr_buf[0] = 0x40;	//Address
		wr_buf[1] = 0xFF;	//Data
		spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);


		// 0x42 Enable Digital functions
		wr_buf[0] = 0x42;	//Address
		wr_buf[1] = 0x08;	//Data
		spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		//testing
			wr_buf[0] = 0x00;	//Address
			wr_buf[1] = 0x01;	//Data
			spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

			wr_buf[0] = 0x3F;	//Address
			wr_buf[1] = 0x00;	//Data
			spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

			wr_buf[0] = 0x42;	//Address
			wr_buf[1] = 0x00;	//Data
			spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 1, wr_buf, 1, rd_buf, 0);

			// Disable ADC readout
			wr_buf[0] = 0x00;	//Address
			wr_buf[1] = 0x00;	//Data
			spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);



	}
	else
	{
		// Upload Test pattern 0
		// 0x03
		//wr_buf[0] = 0x03;	//Address
		//wr_buf[1] = 0x03;	//Data
		//spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		//was before
		/*
		// 0x25
		wr_buf[0] = 0x25;	//Address
		wr_buf[1] = 0x04;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x2B
		wr_buf[0] = 0x2B;	//Address
		wr_buf[1] = 0x04;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x3F
		wr_buf[0] = 0x3F;	//Address
		wr_buf[1] = 0x00;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		// 0x40
		wr_buf[0] = 0x40;	//Address
		wr_buf[1] = 0x00;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

		*/
		// 0x42 Disable Digital functions
		wr_buf[0] = 0x42;	//Address
		wr_buf[1] = 0x00;	//Data
		spirez = alt_avalon_spi_command(SPI_2_BASE, SPI_2_NR_EXTADC, 2, wr_buf, 0, NULL, 0);

	};
}

// Return PLL base address acoording to the PLL index
uint32_t GetPLLCFG_Base(uint8_t ind)
{
	uint32_t PLL_BASE;

	switch ( ind )
	{
		case 1:
			PLL_BASE = PLL_RECONFIG_1_BASE;
	    break;

		case 2:
			PLL_BASE = PLL_RECONFIG_2_BASE;
		break;

		case 3:
			PLL_BASE = PLL_RECONFIG_3_BASE;
		break;

		case 4:
			PLL_BASE = PLL_RECONFIG_4_BASE;
	    break;

		default:
			PLL_BASE = PLL_RECONFIG_0_BASE;
	}

	return PLL_BASE;
}
void ResetPLL(void)
{
	uint8_t wr_buf[2];
	uint8_t rd_buf[2];
	int pll_ind, spirez;

	// Read
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x23;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);

	// Get PLL index
	pll_ind = PLL_IND(rd_buf[1]); //(rd_buf[0] >> 3) & 0x3F;

	// Toggle reset line of appropriate PLL
    IOWR(PLL_RST_BASE, 0x00, 0x01 << pll_ind);	//Set to 1
    asm("nop"); asm("nop");
    IOWR(PLL_RST_BASE, 0x00, 0x00);	//Set to 0
}

// Updates PLL configuration
uint8_t UpdatePLLCFG(void)
{
	int spirez, i;
	tPLL_CFG pll_cfg = {0};
	uint8_t wr_buf[2];
	uint8_t rd_buf[2];
	uint32_t PLL_BASE;
	uint16_t div_byp;
	uint8_t pllcfgrez;

	// Read
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x23;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);

	// Get PLL base address
	PLL_BASE = GetPLLCFG_Base( PLL_IND(rd_buf[1]) );

	//Write in Mode Register "0" for wait request mode, "1" for polling mode
	IOWR_32DIRECT(PLL_BASE, MODE, 0x01);


	// Set M_ODDDIV, M_BYP, N_ODDDIV, N_BYP
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x26;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	pll_cfg.N_cnt = N_CNT_DIVBYP(rd_buf[1]); //(rd_buf[0] & 0x03) << 16;
	pll_cfg.M_cnt = M_CNT_DIVBYP(rd_buf[1]); //(rd_buf[0] & 0x0C) << 14;

	// Set N_HCNT[15:8], N_LCNT[7:0]
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x2A;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	pll_cfg.N_cnt = pll_cfg.N_cnt | N_CNT(rd_buf[0], rd_buf[1]); //pll_cfg.N_cnt | (rd_buf[1] << 8) | rd_buf[0];

	// Set M_HCNT[15:8], M_LCNT[7:0]
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x2B;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	pll_cfg.M_cnt = pll_cfg.M_cnt | M_CNT(rd_buf[0], rd_buf[1]); //pll_cfg.M_cnt | (rd_buf[1] << 8) | rd_buf[0];

	// Set M_FRAC[15:0]
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x2C;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	pll_cfg.MFrac_cnt = MFRAC_CNT_LSB(rd_buf[0], rd_buf[1]); //(rd_buf[1] << 8) | rd_buf[0];

	// Set M_FRAC[31:16]
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x2D;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	pll_cfg.MFrac_cnt = pll_cfg.MFrac_cnt | MFRAC_CNT_MSB(rd_buf[0], rd_buf[1]); //pll_cfg.MFrac_cnt | ( ((rd_buf[1] << 8) | rd_buf[0]) << 16 );

	// Set PLLCFG_BS[3:0] (for Cyclone V), CHP_CURR[2:0], PLLCFG_VCODIV
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x25;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	pll_cfg.BS_cnt = BS_CNT(rd_buf[0]); //(rd_buf[1] >> 3) & 0x0F;
	pll_cfg.CPS_cnt = CPS_CNT(rd_buf[0]); //rd_buf[1] & 0x07;
	pll_cfg.VCO_div = VCO_DIVSEL(rd_buf[1]); //(rd_buf[0] >> 7) & 0x01;


	// Update PLL configuration;
	pllcfgrez = set_pll_config(PLL_BASE, &pll_cfg);
	if(pllcfgrez) return pllcfgrez;



	//// Set Cx counters (first eight for now)

	// Read ODDDIV and BYP values for first 8 counters
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x27;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	div_byp = CX_DIVBYP(rd_buf[0], rd_buf[1]); //(rd_buf[1] << 8) | rd_buf[0];


	for(i=0; i<8; i++)
	{
		// Read Cx value
		wr_buf[0] = 0x00;	// Command and Address
		wr_buf[1] = 0x2E + i;	// Command and Address
		spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
		pll_cfg.C_cnt = (i << 18) | ( ((div_byp >> 2*i) & 0x03) << 16 ) | C_CNT(rd_buf[0], rd_buf[1]); //(rd_buf[1] << 8) | rd_buf[0];

		// Set Cx register
		pllcfgrez = set_CxCnt(PLL_BASE, pll_cfg.C_cnt);
		if(pllcfgrez) return pllcfgrez;

		// Set phase counter to zero
		//set_Phase(PLL_BASE, i, 0, 1);
		//if(pllcfgrez) return pllcfgrez;
	}

	// Apply PLL configuration
	pllcfgrez = start_Reconfig(PLL_BASE);

	ResetPLL();

	return pllcfgrez;

}

// Change PLL phase
uint8_t UpdatePHCFG(void)
{
	uint32_t PLL_BASE;
	uint32_t Val, Cx, Dir;
	uint8_t wr_buf[2];
	uint8_t rd_buf[2];
	int spirez;
	uint8_t pllcfgrez;

	// Read
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x23;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);

	// Get PLL base address
	PLL_BASE = GetPLLCFG_Base( PLL_IND(rd_buf[1]) );

	//Write in Mode Register "0" for waitrequest mode, "1" for polling mode
	IOWR_32DIRECT(PLL_BASE, MODE, 0x01);

	// Set Up/Down
	Dir = PH_DIR(rd_buf[0]); //(rd_buf[1] >> 5) & 0x01;

	// Set Cx
	Cx = CX_IND(rd_buf[0]) - 2; //(rd_buf[1] & 0x1F);

	// Set Phase Cnt
	wr_buf[0] = 0x00;	// Command and Address
	wr_buf[1] = 0x24;	// Command and Address
	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	Val = CX_PHASE(rd_buf[0], rd_buf[1]); //(rd_buf[1] << 8) | rd_buf[0];

	// Set Phase shift register
	set_Phase(PLL_BASE, Cx, Val, Dir);
	// Apply PLL configuration
	pllcfgrez = start_Reconfig(PLL_BASE);
	return pllcfgrez;
}

//

/**
 *	@brief Function to modify BRD (FPGA) spi register bits
 *	@param SPI_reg_addr register address
 *	@param MSB_bit MSB bit of range that will be modified
 *	@param LSB_bit LSB bit of range that will be modified
 */
void Modify_BRDSPI16_Reg_bits (unsigned short int SPI_reg_addr, unsigned char MSB_bit, unsigned char LSB_bit, unsigned short int new_bits_data)
{
	unsigned short int mask, SPI_reg_data;
	unsigned char bits_number;
	//uint8_t MSB_byte, LSB_byte;
	unsigned char WrBuff[4];
	unsigned char RdBuff[2];
	int spirez;

	//**Reconfigure_SPI_for_LMS();

	bits_number = MSB_bit - LSB_bit + 1;

	mask = 0xFFFF;

	//removing unnecessary bits from mask
	mask = mask << (16 - bits_number);
	mask = mask >> (16 - bits_number);

	new_bits_data &= mask; //mask new data

	new_bits_data = new_bits_data << LSB_bit; //shift new data

	mask = mask << LSB_bit; //shift mask
	mask =~ mask;//invert mask

	// Read original data
	WrBuff[0] = (SPI_reg_addr >> 8 ) & 0xFF; //MSB_byte
	WrBuff[1] = SPI_reg_addr & 0xFF; //LSB_byte
	cbi(WrBuff[0], 7);  //clear write bit
	spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_FPGA, 2, WrBuff, 2, RdBuff, 0);

	SPI_reg_data = (RdBuff[0] << 8) + RdBuff[1]; //read current SPI reg data

	//modify reg data
	SPI_reg_data &= mask;//clear bits
	SPI_reg_data |= new_bits_data; //set bits with new data

	//write reg addr
	WrBuff[0] = (SPI_reg_addr >> 8 ) & 0xFF; //MSB_byte
	WrBuff[1] = SPI_reg_addr & 0xFF; //LSB_byte
	//modified data to be written to SPI reg
	WrBuff[2] = (SPI_reg_data >> 8 ) & 0xFF;
	WrBuff[3] = SPI_reg_data & 0xFF;
	sbi(WrBuff[0], 7); //set write bit
	spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_FPGA, 4, WrBuff, 0, NULL, 0);
}


int main(void)
{
	uint8_t sw2_old, sw2;
	uint8_t phcfg_start_old, phcfg_start;
	uint8_t pllcfg_start_old, pllcfg_start;
	uint8_t pllrst_start_old, pllrst_start;
	uint8_t phcfg_mode;
	//tPLL_CFG pll_config;
	uint8_t pllcfgrez;

	int spirez;
	uint32_t* dest = (uint32_t*)glEp0Buffer_Tx;

	//MCP4261 wiper control
	unsigned char MCP_data[2];
	uint16_t wiper_pos[2];

    uint8_t vctcxo_tamer_irq = 0;
    uint8_t vctcxo_tamer_en=0,	vctcxo_tamer_en_old = 0;

    // Trim DAC constants
    const uint16_t trimdac_min       = 0x1938;  // Decimal value  = 6456
    const uint16_t trimdac_max       = 0xE2F3;	// Decimal value  = 58099

    // Trim DAC calibration line
    line_t trimdac_cal_line;

    // VCTCXO Tune State machine
    state_t tune_state = COARSE_TUNE_MIN;

    // Set the known/default values of the trim DAC cal line
    trimdac_cal_line.point[0].x  = 0;
    trimdac_cal_line.point[0].y  = trimdac_min;
    trimdac_cal_line.point[1].x  = 0;
    trimdac_cal_line.point[1].y  = trimdac_max;
    trimdac_cal_line.slope       = 0;
    trimdac_cal_line.y_intercept = 0;
    struct vctcxo_tamer_pkt_buf vctcxo_tamer_pkt;
	vctcxo_tamer_pkt.ready = false;

    // I2C initialiazation
    I2C_init(I2C_OPENCORES_0_BASE, ALT_CPU_FREQ, 100000);

    // Configure LM75
    Configure_LM75();


	// Initialize variables to detect PLL phase change and PLL config update request
	phcfg_start_old = 0; phcfg_start = 0;
	pllcfg_start_old = 0; pllcfg_start = 0;
	pllrst_start_old = 0; pllrst_start = 0;

	// Initialize PLL configuration status
	IOWR(PLLCFG_STATUS_BASE, 0x00, PLLCFG_DONE);

	// Initialize ADC
	init_ADC();

	//write default TCXO DAC value
	Control_TCXO_ADF (0, NULL); //set ADF4002 CP to three-state
	dac_val = 30714;
	Control_TCXO_DAC (1, &dac_val); //enable DAC output, set new val

	//default dig pot wiper values
	wiper_pos[0] = wiper_pos[1] = 0x80;

	// Initialize switch for ADC test pattern change detection
	sw2 = IORD(GPI_0_BASE, 0x00) & 0x01;
	sw2_old = 0x00;

	//get_pll_config(PLL_RECONFIG_0_BASE, &pll_config);

    IOWR(AV_FIFO_INT_0_BASE, 3, 1);		// Toggle FIFO reset
    IOWR(AV_FIFO_INT_0_BASE, 3, 0); // Toggle FIFO reset


	while(1)	// infinite loop
	{
/*
		// Set to power down mode
		//wr_buf[0] = 0x45;	//Address
		//wr_buf[1] = 0x04;	//Data
		//spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, 0, 2, wr_buf, 0, NULL, 0);


		// Enable ADC readout
		wr_buf[0] = 0x00;	//Address
		wr_buf[1] = 0x01;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, 0, 2, wr_buf, 0, NULL, 0);

		wr_buf[0] = 0x45;	//Address
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, 0, 1, wr_buf, 1, rd_buf, 0);

		wr_buf[0] = 0x00;	//Address
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, 0, 1, wr_buf, 1, rd_buf, 0);

		// Disable ADC readout
		wr_buf[0] = 0x00;	//Address
		wr_buf[1] = 0x00;	//Data
		spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, 0, 2, wr_buf, 0, NULL, 0);
*/

/*

		i = IORD(PLL_RECONFIG_0_BASE, 0x00);
		i = IORD(PLL_RECONFIG_0_BASE, 0x01);
		i = IORD(PLL_RECONFIG_0_BASE, 0x03);
		i = IORD(PLL_RECONFIG_0_BASE, 0x04);
		i = IORD(PLL_RECONFIG_0_BASE, 0x05);
		i = IORD(PLL_RECONFIG_0_BASE, 0x08);
		i = IORD(PLL_RECONFIG_0_BASE, 0x09);
		i = IORD(PLL_RECONFIG_0_BASE, 0x1C);

		i = IORD(PLL_RECONFIG_0_BASE, 0x0A);
		i = IORD(PLL_RECONFIG_0_BASE, 0x0B);
*/

		// Toggle PIO port, bit 7
/*
	    ui32_tmp = IORD(GPIO_0_BASE, 0x00);
	    IOWR(GPIO_0_BASE, 0x00, ui32_tmp | 0x00000080);	//Set to 1
	    asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop");
	    asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop");
	    IOWR(GPIO_0_BASE, 0x00, ui32_tmp & 0xFFFFFF7F);	//Set to 0
	    asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop");
	    asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop");
*/
	    // Check if ADC test pattern must be changed
	    if(sw2_old != sw2)
	    {
	    	change_ADC_tpat(sw2);
	    }

	    // Update switch status for ADC test pattern change detection
	    sw2_old = sw2;
	    sw2 = IORD(GPI_0_BASE, 0x00) & 0x01;


	    // Check if there is a request for PLL phase update
	    if((phcfg_start_old == 0) && (phcfg_start != 0))
	    {
	    	IOWR(PLLCFG_STATUS_BASE, 0x00, PLLCFG_BUSY);
	    	phcfg_mode = (IORD(PLLCFG_COMMAND_BASE, 0x00) & 0x08) >> 3;
	    	if (phcfg_mode){

	    	}
	    	else{
	    		//pllcfgrez = UpdatePHCFG();

	    	};

	    	IOWR(PLLCFG_STATUS_BASE, 0x00, (pllcfgrez << 2) | PLLCFG_DONE);
	    }

	    // Check if there is a request for PLL configuration update
	    if((pllcfg_start_old == 0) && (pllcfg_start != 0))
	    {
	    	IOWR(PLLCFG_STATUS_BASE, 0x00, PLLCFG_BUSY);
	    	pllcfgrez = UpdatePLLCFG();
	    	IOWR(PLLCFG_STATUS_BASE, 0x00, (pllcfgrez << 2) | PLLCFG_DONE);
	    }

	    // Check if there is a request for PLL configuration update
	    if((pllrst_start_old == 0) && (pllrst_start != 0))
	    {
	    	IOWR(PLLCFG_STATUS_BASE, 0x00, PLLCFG_BUSY);
	    	ResetPLL();
	    	IOWR(PLLCFG_STATUS_BASE, 0x00, PLLCFG_DONE);
	    }

	    // Update PLL configuration command status
	    pllrst_start_old = pllrst_start;
	    pllrst_start = (IORD(PLLCFG_COMMAND_BASE, 0x00) & 0x04) >> 2;
	    phcfg_start_old = phcfg_start;
	    phcfg_start = (IORD(PLLCFG_COMMAND_BASE, 0x00) & 0x02) >> 1;
	    pllcfg_start_old = pllcfg_start;
	    pllcfg_start = IORD(PLLCFG_COMMAND_BASE, 0x00) & 0x01;


    	vctcxo_tamer_irq = (IORD_8DIRECT(VCTCXO_TAMER_0_CTRL_BASE, 0x00) & 0x02);
	    // Clear VCTCXO tamer interrupt
	    if(vctcxo_tamer_irq != 0)
	    {	vctcxo_tamer_isr(&vctcxo_tamer_pkt);
	    	//IOWR_8DIRECT(VCTCXO_TAMER_0_BASE, 0, 0x70);
	    }

    	//Get vctcxo tamer enable bit status
    	vctcxo_tamer_en_old = vctcxo_tamer_en;
    	vctcxo_tamer_en = (IORD_8DIRECT(VCTCXO_TAMER_0_CTRL_BASE, 0x00) & 0x01);

    	if (vctcxo_tamer_en_old != vctcxo_tamer_en){
    		if (vctcxo_tamer_en == 0x01){
    			vctcxo_tamer_init();
    			vctcxo_tamer_pkt.ready = true;
    		}
    		else {
    			vctcxo_tamer_dis();
    			tune_state = COARSE_TUNE_MIN;
    			vctcxo_tamer_pkt.ready = false;
    		}
    	}

        /* Temporarily putting the VCTCXO Calibration stuff here. */
        if( vctcxo_tamer_pkt.ready ) {

            vctcxo_tamer_pkt.ready = false;

            switch(tune_state) {

            case COARSE_TUNE_MIN:

                /* Tune to the minimum DAC value */
                vctcxo_trim_dac_write( 0x08, trimdac_min );
                dac_val = (uint16_t) trimdac_min;
            	Control_TCXO_DAC (1, &dac_val); //enable DAC output, set new val

                /* State to enter upon the next interrupt */
                tune_state = COARSE_TUNE_MAX;

                break;

            case COARSE_TUNE_MAX:

                /* We have the error from the minimum DAC setting, store it
                 * as the 'x' coordinate for the first point */
                trimdac_cal_line.point[0].x = vctcxo_tamer_pkt.pps_1s_error;

                /* Tune to the maximum DAC value */
                vctcxo_trim_dac_write( 0x08, trimdac_max );
                dac_val = (uint16_t) trimdac_max;
            	Control_TCXO_DAC (1, &dac_val); //enable DAC output, set new val

                /* State to enter upon the next interrupt */
                tune_state = COARSE_TUNE_DONE;

                break;

            case COARSE_TUNE_DONE:
            	/* Write status to to state register*/
            	vctcxo_tamer_write(VT_STATE_ADDR, 0x01);

                /* We have the error from the maximum DAC setting, store it
                 * as the 'x' coordinate for the second point */
                trimdac_cal_line.point[1].x = vctcxo_tamer_pkt.pps_1s_error;

                /* We now have two points, so we can calculate the equation
                 * for a line plotted with DAC counts on the Y axis and
                 * error on the X axis. We want a PPM of zero, which ideally
                 * corresponds to the y-intercept of the line. */
                trimdac_cal_line.slope = ( (float) (trimdac_cal_line.point[1].y - trimdac_cal_line.point[0].y) / (float)
                                           (trimdac_cal_line.point[1].x - trimdac_cal_line.point[0].x) );

                trimdac_cal_line.y_intercept = ( trimdac_cal_line.point[0].y -
                                                 (uint16_t)(round(trimdac_cal_line.slope * (float) trimdac_cal_line.point[0].x)));

                /* Set the trim DAC count to the y-intercept */
                vctcxo_trim_dac_write( 0x08, trimdac_cal_line.y_intercept );
                dac_val = (uint16_t) trimdac_cal_line.y_intercept;
            	Control_TCXO_DAC (1, &dac_val); //enable DAC output, set new val


                /* State to enter upon the next interrupt */
                tune_state = FINE_TUNE;

                break;

            case FINE_TUNE:

                /* We should be extremely close to a perfectly tuned
                 * VCTCXO, but some minor adjustments need to be made */

                /* Check the magnitude of the errors starting with the
                 * one second count. If an error is greater than the maxium
                 * tolerated error, adjust the trim DAC by the error (Hz)
                 * multiplied by the slope (in counts/Hz) and scale the
                 * result by the precision interval (e.g. 1s, 10s, 100s). */
                if( vctcxo_tamer_pkt.pps_1s_error_flag ) {
                	vctcxo_trim_dac_value = (vctcxo_trim_dac_value -
                	                    		(uint16_t) (round((float)vctcxo_tamer_pkt.pps_1s_error * trimdac_cal_line.slope)/1));
                	// Write tuned val to VCTCXO_tamer MM registers
                    vctcxo_trim_dac_write( 0x08, vctcxo_trim_dac_value);
                    // Change DAC value
                    dac_val = (uint16_t) vctcxo_trim_dac_value;
                	Control_TCXO_DAC (1, &dac_val); //enable DAC output, set new val

                } else if( vctcxo_tamer_pkt.pps_10s_error_flag ) {
                	vctcxo_trim_dac_value = (vctcxo_trim_dac_value -
                    							(uint16_t)(round((float)vctcxo_tamer_pkt.pps_10s_error * trimdac_cal_line.slope)/10));
                	// Write tuned val to VCTCXO_tamer MM registers
                    vctcxo_trim_dac_write( 0x08, vctcxo_trim_dac_value);
                    // Change DAC value
                    dac_val = (uint16_t) vctcxo_trim_dac_value;
                	Control_TCXO_DAC (1, &dac_val); //enable DAC output, set new val

                } else if( vctcxo_tamer_pkt.pps_100s_error_flag ) {
                	vctcxo_trim_dac_value = (vctcxo_trim_dac_value -
                    							(uint16_t)(round((float)vctcxo_tamer_pkt.pps_100s_error * trimdac_cal_line.slope)/100));
                	// Write tuned val to VCTCXO_tamer MM registers
                    vctcxo_trim_dac_write( 0x08, vctcxo_trim_dac_value);
                    // Change DAC value
                    dac_val = (uint16_t) vctcxo_trim_dac_value;
                	Control_TCXO_DAC (1, &dac_val); //enable DAC output, set new val
                }

                break;

            default:
                break;

            } /* switch */

            /* Take PPS counters out of reset */
            vctcxo_tamer_reset_counters( false );

            /* Enable interrupts */
            vctcxo_tamer_enable_isr( true );

        } /* VCTCXO Tamer interrupt */

        spirez = IORD(AV_FIFO_INT_0_BASE, 2);	// Read FIFO Status
        if(!(spirez & 0x01))
        {
            IOWR(AV_FIFO_INT_0_BASE, 3, 1);		// Toggle FIFO reset
            IOWR(AV_FIFO_INT_0_BASE, 3, 0); // Toggle FIFO reset

        	getFifoData(glEp0Buffer_Rx, 64);

         	memset (glEp0Buffer_Tx, 0, sizeof(glEp0Buffer_Tx)); //fill whole tx buffer with zeros
         	cmd_errors = 0;

     		LMS_Ctrl_Packet_Tx->Header.Command = LMS_Ctrl_Packet_Rx->Header.Command;
     		LMS_Ctrl_Packet_Tx->Header.Data_blocks = LMS_Ctrl_Packet_Rx->Header.Data_blocks;
     		LMS_Ctrl_Packet_Tx->Header.Periph_ID = LMS_Ctrl_Packet_Rx->Header.Periph_ID;
     		LMS_Ctrl_Packet_Tx->Header.Status = STATUS_BUSY_CMD;


     		switch(LMS_Ctrl_Packet_Rx->Header.Command)
     		{
 				case CMD_GET_INFO:

 					LMS_Ctrl_Packet_Tx->Data_field[0] = FW_VER;
 					LMS_Ctrl_Packet_Tx->Data_field[1] = DEV_TYPE;
 					LMS_Ctrl_Packet_Tx->Data_field[2] = LMS_PROTOCOL_VER;
 					LMS_Ctrl_Packet_Tx->Data_field[3] = HW_VER;
 					LMS_Ctrl_Packet_Tx->Data_field[4] = EXP_BOARD;

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;
				

 				case CMD_LMS_RST:

 					if(!Check_Periph_ID(MAX_ID_LMS7, LMS_Ctrl_Packet_Rx->Header.Periph_ID)) break;

 					switch (LMS_Ctrl_Packet_Rx->Data_field[0])
 					{
 						case LMS_RST_DEACTIVATE:

 		 					switch(LMS_Ctrl_Packet_Rx->Header.Periph_ID)
 		 					{
 		 						default:
 		 						case 0:
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS1_RESET, LMS1_RESET, 1); //high level
 		 						break;
 		 						case 1:
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS2_RESET, LMS2_RESET, 1); //high level
 		 						break;
 		 					}

 						break;

 						case LMS_RST_ACTIVATE:

 		 					switch(LMS_Ctrl_Packet_Rx->Header.Periph_ID)
 		 					{
 		 						default:
 		 						case 0:
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS1_RESET, LMS1_RESET, 0); //low level
 		 						break;
 		 						case 1:
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS2_RESET, LMS2_RESET, 0); //low level
 		 						break;
 		 					}

 						break;

 						case LMS_RST_PULSE:
 		 					switch(LMS_Ctrl_Packet_Rx->Header.Periph_ID)
 		 					{
 		 						default:
 		 						case 0:
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS1_RESET, LMS1_RESET, 0); //low level
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS1_RESET, LMS1_RESET, 1); //high level
 		 						break;
 		 						case 1:
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS2_RESET, LMS2_RESET, 0); //low level
 		 							Modify_BRDSPI16_Reg_bits (BRD_SPI_REG_LMS1_LMS2_CTRL, LMS2_RESET, LMS2_RESET, 1); //high level
 		 						break;
 		 					}

 						break;

 						default:
 							cmd_errors++;
 						break;
 					}

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;


 				case CMD_LMS7002_WR:
 					if(!Check_Periph_ID(MAX_ID_LMS7, LMS_Ctrl_Packet_Rx->Header.Periph_ID)) break;
 					if(Check_many_blocks (4)) break;

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{
 						//Write LMS7 register
 						sbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 7); //set write bit
 						spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, LMS_Ctrl_Packet_Rx->Header.Periph_ID == 1 ? SPI_NR_LMS7002M_1 : SPI_NR_LMS7002M_0,
 								4, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 0, NULL, 0);
 					}

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;


 				case CMD_LMS7002_RD:
 					if(Check_many_blocks (4)) break;

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{
 						//Read LMS7 register
 						cbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 7);  //clear write bit
 						spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, LMS_Ctrl_Packet_Rx->Header.Periph_ID == 1 ? SPI_NR_LMS7002M_1 : SPI_NR_LMS7002M_0,
 								2, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 2, &LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)], 0);
 					}

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;


 	 			case CMD_BRDSPI16_WR:
 	 				if(Check_many_blocks (4)) break;

 	 				for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 	 				{
 	 					//write reg addr
 	 					sbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 7); //set write bit

 	 					spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_FPGA, 4, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 0, NULL, 0);
 	 				}

 	 				LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 	 			break;


 				case CMD_BRDSPI16_RD:
 					if(Check_many_blocks (4)) break;

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{

 						//write reg addr
 						cbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 7);  //clear write bit

 						spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_FPGA, 2, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 2, &LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)], 0);
 					}

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;


 				case CMD_ADF4002_WR:
 					if(Check_many_blocks (3)) break;

 					Control_TCXO_DAC (0, NULL); //set DAC out to three-state

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{
 						Control_TCXO_ADF (1, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block*3)]); //write data to ADF
 					}

 					if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_INVALID_PERIPH_ID_CMD;
 					else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;


				case CMD_ANALOG_VAL_RD:

					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
					{
						switch (LMS_Ctrl_Packet_Rx->Data_field[0 + (block)])//ch
						{
							case 0://dac val

								LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[block]; //ch
								LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = 0x00; //RAW //unit, power

								//LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)] = 0; //signed val, MSB byte
								//LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)] = dac_val; //signed val, LSB byte
								LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)] = (dac_val >> 8) & 0xFF; //unsigned val, MSB byte
								LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)] = dac_val & 0xFF; //unsigned val, LSB byte

							break;

							case 1: //temperature

								spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
								spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x00, 1);				// Pointer = temperature register
								spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);

								// Read temperature and recalculate
								converted_val = (signed short int)I2C_read(I2C_OPENCORES_0_BASE, 0);
								converted_val = converted_val << 8;
								converted_val = 10 * (converted_val >> 8);
								spirez = I2C_read(I2C_OPENCORES_0_BASE, 1);
								if(spirez & 0x80) converted_val = converted_val + 5;

								LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[block]; //ch
								LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = 0x50; //mC //unit, power

								LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)] = (converted_val >> 8); //signed val, MSB byte
								LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)] = converted_val; //signed val, LSB byte

							break;

							case 2://wiper 0 position
								LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[block]; //ch
								LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = 0x00; //RAW //unit, power

								LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)] = (wiper_pos[0] >> 8) & 0xFF; //signed val, MSB byte
								LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)] = wiper_pos[0] & 0xFF; //signed val, LSB byte
							break;

							case 3://wiper 1 position
								LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[block]; //ch
								LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = 0x00; //RAW //unit, power

								LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)] = (wiper_pos[1] >> 8) & 0xFF; //signed val, MSB byte
								LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)] = wiper_pos[1] & 0xFF; //signed val, LSB byte
							break;

							default:
								cmd_errors++;
							break;
						}
					}

					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

				break;


				case CMD_ANALOG_VAL_WR:
					if(Check_many_blocks (4)) break;

					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
					{
						switch (LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)]) //do something according to channel
						{
							case 0: //TCXO DAC
								if (LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 4)] == 0) //RAW units?
								{
									Control_TCXO_ADF(0, NULL); //set ADF4002 CP to three-state

									//write data to DAC
									//dac_val = LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)];
									dac_val = (LMS_Ctrl_Packet_Rx->Data_field[2 + (block * 4)] << 8 ) + LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)];
									Control_TCXO_DAC(1, &dac_val); //enable DAC output, set new val
								}
								else cmd_errors++;

							break;

							case 2: //MCP4261 wiper 0 control

								if (LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 4)] == 0) //RAW units?
								{
									wiper_pos[0] = (LMS_Ctrl_Packet_Rx->Data_field[2 + (block * 4)] << 8) + LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)];
									if(wiper_pos[0] <= 256)
									{
										MCP_data[0] = MCP_data[1] = 0;

										MCP_data[0] |= (0x00 << 4); //Memory addr [16:13] = Volatile Wiper 0 (0x00)
										MCP_data[0] |= (0x00 << 2); //Command bits [11:10] = CMD  Write data (0x00)

										if (wiper_pos[0] > 255)	MCP_data[0] |= (0x01); //Full Scale (W = A)

										MCP_data[1] = LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)];

										spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_POT, 2, MCP_data, 0, NULL, 0);
									}
									else cmd_errors++;
								}
								else cmd_errors++;
							break;

							case 3: //MCP4261 wiper 1 control

								if (LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 4)] == 0) //RAW units?
								{
									wiper_pos[1] = (LMS_Ctrl_Packet_Rx->Data_field[2 + (block * 4)] << 8) + LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)];
									if(wiper_pos[1] <= 256)
									{
										MCP_data[0] = MCP_data[1] = 0;

										MCP_data[0] |= (0x01 << 4); //Memory addr [16:13] = Volatile Wiper 1 (0x01)
										MCP_data[0] |= (0x00 << 2); //Command bits [11:10] = CMD  Write data (0x00)

										if (wiper_pos[1] > 255)	MCP_data[0] |= (0x01); //Full Scale (W = A)

										MCP_data[1] = LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)];

										spirez = alt_avalon_spi_command(FPGA_SPI0_BASE, SPI_NR_POT, 2, MCP_data, 0, NULL, 0);
									}
									else cmd_errors++;
								}
								else cmd_errors++;
							break;

							default:
								cmd_errors++;
							break;
						}
					}

					if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
					else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

				break;


	 			case CMD_SI5351_WR:
	 				if(Check_many_blocks(2)) break;

	 				for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
	 				{
	 					cmd_errors += I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 0);
	 					cmd_errors += I2C_write(I2C_OPENCORES_0_BASE, LMS_Ctrl_Packet_Rx->Data_field[block * 2    ], 0);
	 					cmd_errors += I2C_write(I2C_OPENCORES_0_BASE, LMS_Ctrl_Packet_Rx->Data_field[block * 2 + 1], 1);
	 				}

	 				if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
	 				else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

	 			break;


 				case CMD_SI5351_RD:
 					if(Check_many_blocks (2)) break;

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{
 						cmd_errors += I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 0);
 						cmd_errors += I2C_write(I2C_OPENCORES_0_BASE, LMS_Ctrl_Packet_Rx->Data_field[block], 1);
 						cmd_errors += I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 1);

 						LMS_Ctrl_Packet_Tx->Data_field[block * 2    ] = LMS_Ctrl_Packet_Rx->Data_field[block];
 						LMS_Ctrl_Packet_Tx->Data_field[block * 2 + 1] = I2C_read(I2C_OPENCORES_0_BASE, 1);
 					}

 					if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
 					else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

 				break;


 				default:
 					/* This is unknown request. */
 					//isHandled = CyFalse;
 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_UNKNOWN_CMD;
 				break;

			};



     		//Send response to the command
        	for(int i=0; i<64/sizeof(uint32_t); ++i)
        	{
        		IOWR(AV_FIFO_INT_0_BASE, 0, dest[i]);
			};

        };




/*
	    for(i=0; i<24; i++)
	    {
	    	wr_buf[0] = 0x00;	// Command and Address
	    	wr_buf[1] = 0x20 + i;	// Command and Address
	    	spirez = alt_avalon_spi_command(PLLCFG_SPI_BASE, 0, 2, wr_buf, 2, rd_buf, 0);
	    }
*/


	}

	return 0;
}
