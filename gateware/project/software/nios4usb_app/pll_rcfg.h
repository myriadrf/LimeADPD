/*
 * pll_rcfg.h
 *
 *  Created on: Mar 25, 2016
 *      Author: zydrunas
 */

#ifndef PLL_RCFG_H_
#define PLL_RCFG_H_

#include "alt_types.h"
#include "io.h"
#include <stdint.h>
#include <string.h>

/* Multiply Reconfig Register with 4 when you use IOWR_32DIRECT*/
#define MODE      		0x00//
#define STATUS    		0x04
#define START     		0x08
#define N_COUNTER 		0x0C//
#define M_COUNTER 		0x10//
#define C_COUNTER 		0x14//
#define DPS_COUNTER		0x18
#define FRAC_COUNTER 	0x1C//
#define BS_COUNTER		0x20//
#define CPS_COUNTER		0x24//
#define VCO_DIV			0x70//
#define C0_COUNTER 		0x28
#define C1_COUNTER 		0x2C
#define C2_COUNTER 		0x30
#define C3_COUNTER 		0x34
#define C4_COUNTER 		0x38
#define C5_COUNTER 		0x3C

// PLL configuration status defines
#define PLLCFG_DONE 1
#define PLLCFG_BUSY 2

// PLL configuration error codes
#define PLLCFG_NOERR 0x00
#define PLLCFG_TIMEOUT 100000
#define PLLCFG_PLL_TIMEOUT 0x09
#define PLLCFG_CX_TIMEOUT 0x0A
#define PLLCFG_PH_TIMEOUT 0x0B

// Get values according to the PLL SPI memory map
#define PLL_IND(lsb) ((lsb >> 3) & 0x1F)
#define PH_DIR(msb) ((msb >> 5) & 0x01)
#define CX_IND(msb) (msb & 0x1F)
#define CX_PHASE(msb, lsb) ((msb << 8) | lsb)
#define N_CNT_DIVBYP(lsb) ((lsb & 0x03) << 16)
#define M_CNT_DIVBYP(lsb) ((lsb & 0x0C) << 14)
#define N_CNT(msb, lsb) ((msb << 8) | lsb)
#define M_CNT(msb, lsb) ((msb << 8) | lsb)
#define MFRAC_CNT_LSB(msb, lsb) ((msb << 8) | lsb)
#define MFRAC_CNT_MSB(msb, lsb) (((msb << 8) | lsb) << 16)
#define BS_CNT(msb) ((msb >> 3) & 0x0F)
#define CPS_CNT(msb) (msb & 0x07)
#define VCO_DIVSEL(lsb) ((lsb >> 7) & 0x01)
#define CX_DIVBYP(msb, lsb) ((msb << 8) | lsb)
#define C_CNT(msb, lsb) ((msb << 8) | lsb)

	typedef struct
	{
		uint32_t M_cnt;
		uint32_t MFrac_cnt;
		uint32_t N_cnt;
		uint32_t C_cnt;
		uint32_t DPS_cnt;
		uint32_t BS_cnt;
		uint32_t CPS_cnt;
		uint32_t VCO_div;
	} tPLL_CFG;


	// Functions
	void get_pll_config(uint32_t PLL_BASE, tPLL_CFG *pll_cfg);
	uint8_t set_pll_config(uint32_t PLL_BASE, tPLL_CFG *pll_cfg);

	//void set_CxCnt(uint32_t PLL_BASE, uint32_t Cx, uint32_t val);
	uint8_t set_CxCnt(uint32_t PLL_BASE, uint32_t CxVal);

	uint8_t set_Phase(uint32_t PLL_BASE, uint32_t Cx, uint32_t val, uint32_t dir);

	uint8_t start_Reconfig(uint32_t PLL_BASE);

#endif /* PLL_RCFG_H_ */
