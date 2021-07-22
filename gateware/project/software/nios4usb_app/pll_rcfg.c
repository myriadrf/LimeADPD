/*
 * pll_rcfg.c
 *
 *  Created on: Mar 25, 2016
 *      Author: zydrunas
 */

#include "pll_rcfg.h"
#include "system.h"

// Reads main PLL configuration
void get_pll_config(uint32_t PLL_BASE, tPLL_CFG *pll_cfg)
{
	pll_cfg->M_cnt = IORD_32DIRECT(PLL_BASE, M_COUNTER);

	pll_cfg->MFrac_cnt = IORD_32DIRECT(PLL_BASE, FRAC_COUNTER);

	pll_cfg->N_cnt = IORD_32DIRECT(PLL_BASE, N_COUNTER);

	pll_cfg->DPS_cnt = IORD_32DIRECT(PLL_BASE, DPS_COUNTER);

	pll_cfg->BS_cnt = IORD_32DIRECT(PLL_BASE, BS_COUNTER);

	pll_cfg->CPS_cnt = IORD_32DIRECT(PLL_BASE, CPS_COUNTER);

	pll_cfg->VCO_div = IORD_32DIRECT(PLL_BASE, VCO_DIV);
}

// Writes main PLL configuration
uint8_t set_pll_config(uint32_t PLL_BASE, tPLL_CFG *pll_cfg)
{

	//printf(" \n Full Reconfiguration Selected \n");

	//M
	IOWR_32DIRECT(PLL_BASE, M_COUNTER, pll_cfg->M_cnt);

	//MFrac
	IOWR_32DIRECT(PLL_BASE, FRAC_COUNTER, pll_cfg->MFrac_cnt);

	//N
	IOWR_32DIRECT(PLL_BASE, N_COUNTER, pll_cfg->N_cnt);

	//Bandwidth
	//IOWR_32DIRECT(PLL_BASE, BS_COUNTER, pll_cfg->BS_cnt);

	//Charge Pump Setting
	//IOWR_32DIRECT(PLL_BASE, CPS_COUNTER, pll_cfg->CPS_cnt);

	//
	IOWR_32DIRECT(PLL_BASE, VCO_DIV, pll_cfg->VCO_div);


	return PLLCFG_NOERR; //start_Reconfig(PLL_BASE);

	//printf(" \n Full configuration is completed !! Verify with Scope \n");
}


uint8_t set_CxCnt(uint32_t PLL_BASE, uint32_t CxVal)
{

 	//IOWR_32DIRECT(PLL_BASE, C_COUNTER, val | (Cx << 18));
	IOWR_32DIRECT(PLL_BASE, C_COUNTER, CxVal);

	return PLLCFG_NOERR;
}

uint8_t set_Phase(uint32_t PLL_BASE, uint32_t Cx, uint32_t val, uint32_t dir)
{
	uint32_t dps;

	dps = val;
	dps = dps | ((Cx & 0x1F) << 16);
	dps = dps | ((dir & 0x01) << 21);

 	IOWR_32DIRECT(PLL_BASE, DPS_COUNTER, dps);

	return PLLCFG_NOERR;
}

uint8_t start_Reconfig(uint32_t PLL_BASE)
{
	unsigned int status_reconfig, timeout;

	//Write anything to Start Register to Reconfiguration
	IOWR_32DIRECT(PLL_BASE, START, 0x01);

	timeout = 0;
	do
	{
	  	status_reconfig = IORD_32DIRECT(PLL_BASE, STATUS);
	  	if (timeout++ > PLLCFG_TIMEOUT) return PLLCFG_CX_TIMEOUT;
	}
	while ((!status_reconfig) & 0x01);

	return PLLCFG_NOERR;
}

