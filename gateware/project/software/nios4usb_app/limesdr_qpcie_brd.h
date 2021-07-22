/**
-- ----------------------------------------------------------------------------	
-- FILE:	stream_brd.h
-- DESCRIPTION:	Stream v2r2
-- DATE:	2015.06.29
-- AUTHOR(s):	Lime Microsystems
-- REVISION: v0r2
-- ----------------------------------------------------------------------------	

*/
#ifndef _STREAM_BRD_H_
#define _STREAM_BRD_H_

#include "LMS64C_protocol.h"

#define FX3_LED0			33
#define FX3_LED1			34
#define FX3_LED2			35

#define FPGA_PS_NCONFIG		43
#define FPGA_PS_NSTATUS		42
#define FPGA_PS_CONFDONE	41
#define FX3_AS_SW			44
#define FX3_SPI_AS_SS		45

#define FX3_FPGA_SS			46

#define FX3_GPIO0			47
#define FX3_GPIO1			48
#define FX3_GPIO2			49
#define FX3_GPIO3			50
#define FX3_GPIO4			51
#define FX3_GPIO5			52

#define FX3_FLASH1_SS		54

//I2C devices
#define SI5351_I2C_ADDR		0x60 //0xC0
#define   LM75_I2C_ADDR		0x48 //0x90
#define MAX7322_I2C_ADDR	0xDA
#define SC18IS602B_I2C_ADDR	0x50
#define EEPROM_I2C_ADDR		0xA0

//get info
#define DEV_TYPE			LMS_DEV_QSPARK
#define HW_VER				0
#define EXP_BOARD			EXP_BOARD_UNSUPPORTED


//FX3 Firmware Flash
#define FX3_SIZE 					(512*1024)
#define FX3_FLASH_PAGE_SIZE 		0x100 //256 bytes, SPI Page size to be used for transfers
#define FX3_FLASH_SECTOR_SIZE 		0x10000 //256 pages * 256 page size = 65536 bytes
#define FX3_FLASH_CMD_SECTOR_ERASE 	0xD8

//FPGA Cyclone IV (EP5CGXFC7D7F31C8N) bitstream (RBF) size in bytes
#define FPGA_SIZE 			7020944

//FLash memory (M25P16, 16M-bit))
#define FLASH_PAGE_SIZE 	0x100 //256 bytes, SPI Page size to be used for transfers
#define FLASH_SECTOR_SIZE 	(0x40000) //256 kB
//#define FLASH_BLOCK_SIZE	(FLASH_SECTOR_SIZE/FLASH_PAGE_SIZE) //in pages

//FLASH memory layout
#define FLASH_LAYOUT_FPGA_METADATA	12//FPGA autoload metadata (start sector)
#define FLASH_LAYOUT_FPGA_BITSTREAM	0//FPGA bitstream (start sector) till end

#define FLASH_CMD_SECTOR_ERASE 0xD8 //depends on flash: 0xD8 or 0x20

#define MAX_ID_LMS7		1

typedef struct{
	uint32_t Bitream_size;
	uint8_t Autoload;
}tBoard_Config_FPGA; //tBoard_Config_FPGA or tBoard_cfg_FPGA


#endif
