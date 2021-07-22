/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2_cpu' in SOPC Builder design 'nios_cpu'
 * SOPC Builder design path: ../../nios_cpu.sopcinfo
 *
 * Generated: Thu Sep 13 14:01:24 EEST 2018
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * Av_FIFO_Int_0 configuration
 *
 */

#define ALT_MODULE_CLASS_Av_FIFO_Int_0 Av_FIFO_Int
#define AV_FIFO_INT_0_BASE 0x1800
#define AV_FIFO_INT_0_IRQ -1
#define AV_FIFO_INT_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define AV_FIFO_INT_0_NAME "/dev/Av_FIFO_Int_0"
#define AV_FIFO_INT_0_SPAN 16
#define AV_FIFO_INT_0_TYPE "Av_FIFO_Int"


/*
 * Avalon_MM_external_0 configuration
 *
 */

#define ALT_MODULE_CLASS_Avalon_MM_external_0 Avalon_MM_external
#define AVALON_MM_EXTERNAL_0_BASE 0x600
#define AVALON_MM_EXTERNAL_0_IRQ -1
#define AVALON_MM_EXTERNAL_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define AVALON_MM_EXTERNAL_0_NAME "/dev/Avalon_MM_external_0"
#define AVALON_MM_EXTERNAL_0_SPAN 256
#define AVALON_MM_EXTERNAL_0_TYPE "Avalon_MM_external"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x00001020
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 30720000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x11
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x00010020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 30720000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x11
#define ALT_CPU_NAME "nios2_cpu"
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00010000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x00001020
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 30720000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x11
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x00010020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x11
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00010000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SPI
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_NIOS2_GEN2
#define __ALTERA_PLL_RECONFIG
#define __AVALON_MM_EXTERNAL
#define __AV_FIFO_INT
#define __I2C_OPENCORES


/*
 * PLLCFG_Command configuration
 *
 */

#define ALT_MODULE_CLASS_PLLCFG_Command altera_avalon_pio
#define PLLCFG_COMMAND_BASE 0x7d0
#define PLLCFG_COMMAND_BIT_CLEARING_EDGE_REGISTER 0
#define PLLCFG_COMMAND_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PLLCFG_COMMAND_CAPTURE 0
#define PLLCFG_COMMAND_DATA_WIDTH 4
#define PLLCFG_COMMAND_DO_TEST_BENCH_WIRING 0
#define PLLCFG_COMMAND_DRIVEN_SIM_VALUE 0
#define PLLCFG_COMMAND_EDGE_TYPE "NONE"
#define PLLCFG_COMMAND_FREQ 30720000
#define PLLCFG_COMMAND_HAS_IN 1
#define PLLCFG_COMMAND_HAS_OUT 0
#define PLLCFG_COMMAND_HAS_TRI 0
#define PLLCFG_COMMAND_IRQ -1
#define PLLCFG_COMMAND_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLLCFG_COMMAND_IRQ_TYPE "NONE"
#define PLLCFG_COMMAND_NAME "/dev/PLLCFG_Command"
#define PLLCFG_COMMAND_RESET_VALUE 0
#define PLLCFG_COMMAND_SPAN 16
#define PLLCFG_COMMAND_TYPE "altera_avalon_pio"


/*
 * PLLCFG_SPI configuration
 *
 */

#define ALT_MODULE_CLASS_PLLCFG_SPI altera_avalon_spi
#define PLLCFG_SPI_BASE 0x740
#define PLLCFG_SPI_CLOCKMULT 1
#define PLLCFG_SPI_CLOCKPHASE 0
#define PLLCFG_SPI_CLOCKPOLARITY 0
#define PLLCFG_SPI_CLOCKUNITS "Hz"
#define PLLCFG_SPI_DATABITS 8
#define PLLCFG_SPI_DATAWIDTH 16
#define PLLCFG_SPI_DELAYMULT "1.0E-9"
#define PLLCFG_SPI_DELAYUNITS "ns"
#define PLLCFG_SPI_EXTRADELAY 0
#define PLLCFG_SPI_INSERT_SYNC 0
#define PLLCFG_SPI_IRQ 3
#define PLLCFG_SPI_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PLLCFG_SPI_ISMASTER 1
#define PLLCFG_SPI_LSBFIRST 0
#define PLLCFG_SPI_NAME "/dev/PLLCFG_SPI"
#define PLLCFG_SPI_NUMSLAVES 1
#define PLLCFG_SPI_PREFIX "spi_"
#define PLLCFG_SPI_SPAN 32
#define PLLCFG_SPI_SYNC_REG_DEPTH 2
#define PLLCFG_SPI_TARGETCLOCK 10000000u
#define PLLCFG_SPI_TARGETSSDELAY "0.0"
#define PLLCFG_SPI_TYPE "altera_avalon_spi"


/*
 * PLLCFG_Status configuration
 *
 */

#define ALT_MODULE_CLASS_PLLCFG_Status altera_avalon_pio
#define PLLCFG_STATUS_BASE 0x7c0
#define PLLCFG_STATUS_BIT_CLEARING_EDGE_REGISTER 0
#define PLLCFG_STATUS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PLLCFG_STATUS_CAPTURE 0
#define PLLCFG_STATUS_DATA_WIDTH 10
#define PLLCFG_STATUS_DO_TEST_BENCH_WIRING 0
#define PLLCFG_STATUS_DRIVEN_SIM_VALUE 0
#define PLLCFG_STATUS_EDGE_TYPE "NONE"
#define PLLCFG_STATUS_FREQ 30720000
#define PLLCFG_STATUS_HAS_IN 0
#define PLLCFG_STATUS_HAS_OUT 1
#define PLLCFG_STATUS_HAS_TRI 0
#define PLLCFG_STATUS_IRQ -1
#define PLLCFG_STATUS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLLCFG_STATUS_IRQ_TYPE "NONE"
#define PLLCFG_STATUS_NAME "/dev/PLLCFG_Status"
#define PLLCFG_STATUS_RESET_VALUE 1
#define PLLCFG_STATUS_SPAN 16
#define PLLCFG_STATUS_TYPE "altera_avalon_pio"


/*
 * PLL_RST configuration
 *
 */

#define ALT_MODULE_CLASS_PLL_RST altera_avalon_pio
#define PLL_RST_BASE 0x7b0
#define PLL_RST_BIT_CLEARING_EDGE_REGISTER 0
#define PLL_RST_BIT_MODIFYING_OUTPUT_REGISTER 0
#define PLL_RST_CAPTURE 0
#define PLL_RST_DATA_WIDTH 32
#define PLL_RST_DO_TEST_BENCH_WIRING 0
#define PLL_RST_DRIVEN_SIM_VALUE 0
#define PLL_RST_EDGE_TYPE "NONE"
#define PLL_RST_FREQ 30720000
#define PLL_RST_HAS_IN 0
#define PLL_RST_HAS_OUT 1
#define PLL_RST_HAS_TRI 0
#define PLL_RST_IRQ -1
#define PLL_RST_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_RST_IRQ_TYPE "NONE"
#define PLL_RST_NAME "/dev/PLL_RST"
#define PLL_RST_RESET_VALUE 0
#define PLL_RST_SPAN 16
#define PLL_RST_TYPE "altera_avalon_pio"


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone V"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/null"
#define ALT_STDERR_BASE 0x0
#define ALT_STDERR_DEV null
#define ALT_STDERR_TYPE ""
#define ALT_STDIN "/dev/null"
#define ALT_STDIN_BASE 0x0
#define ALT_STDIN_DEV null
#define ALT_STDIN_TYPE ""
#define ALT_STDOUT "/dev/null"
#define ALT_STDOUT_BASE 0x0
#define ALT_STDOUT_DEV null
#define ALT_STDOUT_TYPE ""
#define ALT_SYSTEM_NAME "nios_cpu"


/*
 * dac_spi1 configuration
 *
 */

#define ALT_MODULE_CLASS_dac_spi1 altera_avalon_spi
#define DAC_SPI1_BASE 0x720
#define DAC_SPI1_CLOCKMULT 1
#define DAC_SPI1_CLOCKPHASE 1
#define DAC_SPI1_CLOCKPOLARITY 0
#define DAC_SPI1_CLOCKUNITS "Hz"
#define DAC_SPI1_DATABITS 8
#define DAC_SPI1_DATAWIDTH 16
#define DAC_SPI1_DELAYMULT "1.0E-9"
#define DAC_SPI1_DELAYUNITS "ns"
#define DAC_SPI1_EXTRADELAY 1
#define DAC_SPI1_INSERT_SYNC 0
#define DAC_SPI1_IRQ 4
#define DAC_SPI1_IRQ_INTERRUPT_CONTROLLER_ID 0
#define DAC_SPI1_ISMASTER 1
#define DAC_SPI1_LSBFIRST 0
#define DAC_SPI1_NAME "/dev/dac_spi1"
#define DAC_SPI1_NUMSLAVES 1
#define DAC_SPI1_PREFIX "spi_"
#define DAC_SPI1_SPAN 32
#define DAC_SPI1_SYNC_REG_DEPTH 2
#define DAC_SPI1_TARGETCLOCK 5000000u
#define DAC_SPI1_TARGETSSDELAY "500.0"
#define DAC_SPI1_TYPE "altera_avalon_spi"


/*
 * fpga_spi0 configuration
 *
 */

#define ALT_MODULE_CLASS_fpga_spi0 altera_avalon_spi
#define FPGA_SPI0_BASE 0x760
#define FPGA_SPI0_CLOCKMULT 1
#define FPGA_SPI0_CLOCKPHASE 0
#define FPGA_SPI0_CLOCKPOLARITY 0
#define FPGA_SPI0_CLOCKUNITS "Hz"
#define FPGA_SPI0_DATABITS 8
#define FPGA_SPI0_DATAWIDTH 16
#define FPGA_SPI0_DELAYMULT "1.0E-9"
#define FPGA_SPI0_DELAYUNITS "ns"
#define FPGA_SPI0_EXTRADELAY 0
#define FPGA_SPI0_INSERT_SYNC 0
#define FPGA_SPI0_IRQ 2
#define FPGA_SPI0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define FPGA_SPI0_ISMASTER 1
#define FPGA_SPI0_LSBFIRST 0
#define FPGA_SPI0_NAME "/dev/fpga_spi0"
#define FPGA_SPI0_NUMSLAVES 8
#define FPGA_SPI0_PREFIX "spi_"
#define FPGA_SPI0_SPAN 32
#define FPGA_SPI0_SYNC_REG_DEPTH 2
#define FPGA_SPI0_TARGETCLOCK 5000000u
#define FPGA_SPI0_TARGETSSDELAY "0.0"
#define FPGA_SPI0_TYPE "altera_avalon_spi"


/*
 * gpi_0 configuration
 *
 */

#define ALT_MODULE_CLASS_gpi_0 altera_avalon_pio
#define GPI_0_BASE 0x7e0
#define GPI_0_BIT_CLEARING_EDGE_REGISTER 0
#define GPI_0_BIT_MODIFYING_OUTPUT_REGISTER 0
#define GPI_0_CAPTURE 0
#define GPI_0_DATA_WIDTH 8
#define GPI_0_DO_TEST_BENCH_WIRING 0
#define GPI_0_DRIVEN_SIM_VALUE 0
#define GPI_0_EDGE_TYPE "NONE"
#define GPI_0_FREQ 30720000
#define GPI_0_HAS_IN 1
#define GPI_0_HAS_OUT 0
#define GPI_0_HAS_TRI 0
#define GPI_0_IRQ -1
#define GPI_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define GPI_0_IRQ_TYPE "NONE"
#define GPI_0_NAME "/dev/gpi_0"
#define GPI_0_RESET_VALUE 0
#define GPI_0_SPAN 16
#define GPI_0_TYPE "altera_avalon_pio"


/*
 * gpio_0 configuration
 *
 */

#define ALT_MODULE_CLASS_gpio_0 altera_avalon_pio
#define GPIO_0_BASE 0x7f0
#define GPIO_0_BIT_CLEARING_EDGE_REGISTER 0
#define GPIO_0_BIT_MODIFYING_OUTPUT_REGISTER 0
#define GPIO_0_CAPTURE 0
#define GPIO_0_DATA_WIDTH 8
#define GPIO_0_DO_TEST_BENCH_WIRING 0
#define GPIO_0_DRIVEN_SIM_VALUE 0
#define GPIO_0_EDGE_TYPE "NONE"
#define GPIO_0_FREQ 30720000
#define GPIO_0_HAS_IN 0
#define GPIO_0_HAS_OUT 1
#define GPIO_0_HAS_TRI 0
#define GPIO_0_IRQ -1
#define GPIO_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define GPIO_0_IRQ_TYPE "NONE"
#define GPIO_0_NAME "/dev/gpio_0"
#define GPIO_0_RESET_VALUE 0
#define GPIO_0_SPAN 16
#define GPIO_0_TYPE "altera_avalon_pio"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * i2c_opencores_0 configuration
 *
 */

#define ALT_MODULE_CLASS_i2c_opencores_0 i2c_opencores
#define I2C_OPENCORES_0_BASE 0x780
#define I2C_OPENCORES_0_IRQ 0
#define I2C_OPENCORES_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define I2C_OPENCORES_0_NAME "/dev/i2c_opencores_0"
#define I2C_OPENCORES_0_SPAN 32
#define I2C_OPENCORES_0_TYPE "i2c_opencores"


/*
 * oc_mem configuration
 *
 */

#define ALT_MODULE_CLASS_oc_mem altera_avalon_onchip_memory2
#define OC_MEM_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define OC_MEM_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define OC_MEM_BASE 0x10000
#define OC_MEM_CONTENTS_INFO ""
#define OC_MEM_DUAL_PORT 0
#define OC_MEM_GUI_RAM_BLOCK_TYPE "AUTO"
#define OC_MEM_INIT_CONTENTS_FILE "nios_cpu_oc_mem"
#define OC_MEM_INIT_MEM_CONTENT 1
#define OC_MEM_INSTANCE_ID "NONE"
#define OC_MEM_IRQ -1
#define OC_MEM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define OC_MEM_NAME "/dev/oc_mem"
#define OC_MEM_NON_DEFAULT_INIT_FILE_ENABLED 0
#define OC_MEM_RAM_BLOCK_TYPE "AUTO"
#define OC_MEM_READ_DURING_WRITE_MODE "DONT_CARE"
#define OC_MEM_SINGLE_CLOCK_OP 0
#define OC_MEM_SIZE_MULTIPLE 1
#define OC_MEM_SIZE_VALUE 32768
#define OC_MEM_SPAN 32768
#define OC_MEM_TYPE "altera_avalon_onchip_memory2"
#define OC_MEM_WRITABLE 1


/*
 * pll_reconfig_0 configuration
 *
 */

#define ALT_MODULE_CLASS_pll_reconfig_0 altera_pll_reconfig
#define PLL_RECONFIG_0_BASE 0x0
#define PLL_RECONFIG_0_IRQ -1
#define PLL_RECONFIG_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_RECONFIG_0_NAME "/dev/pll_reconfig_0"
#define PLL_RECONFIG_0_SPAN 256
#define PLL_RECONFIG_0_TYPE "altera_pll_reconfig"


/*
 * pll_reconfig_1 configuration
 *
 */

#define ALT_MODULE_CLASS_pll_reconfig_1 altera_pll_reconfig
#define PLL_RECONFIG_1_BASE 0x100
#define PLL_RECONFIG_1_IRQ -1
#define PLL_RECONFIG_1_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_RECONFIG_1_NAME "/dev/pll_reconfig_1"
#define PLL_RECONFIG_1_SPAN 256
#define PLL_RECONFIG_1_TYPE "altera_pll_reconfig"


/*
 * pll_reconfig_2 configuration
 *
 */

#define ALT_MODULE_CLASS_pll_reconfig_2 altera_pll_reconfig
#define PLL_RECONFIG_2_BASE 0x200
#define PLL_RECONFIG_2_IRQ -1
#define PLL_RECONFIG_2_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_RECONFIG_2_NAME "/dev/pll_reconfig_2"
#define PLL_RECONFIG_2_SPAN 256
#define PLL_RECONFIG_2_TYPE "altera_pll_reconfig"


/*
 * pll_reconfig_3 configuration
 *
 */

#define ALT_MODULE_CLASS_pll_reconfig_3 altera_pll_reconfig
#define PLL_RECONFIG_3_BASE 0x300
#define PLL_RECONFIG_3_IRQ -1
#define PLL_RECONFIG_3_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_RECONFIG_3_NAME "/dev/pll_reconfig_3"
#define PLL_RECONFIG_3_SPAN 256
#define PLL_RECONFIG_3_TYPE "altera_pll_reconfig"


/*
 * pll_reconfig_4 configuration
 *
 */

#define ALT_MODULE_CLASS_pll_reconfig_4 altera_pll_reconfig
#define PLL_RECONFIG_4_BASE 0x400
#define PLL_RECONFIG_4_IRQ -1
#define PLL_RECONFIG_4_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_RECONFIG_4_NAME "/dev/pll_reconfig_4"
#define PLL_RECONFIG_4_SPAN 256
#define PLL_RECONFIG_4_TYPE "altera_pll_reconfig"


/*
 * pll_reconfig_5 configuration
 *
 */

#define ALT_MODULE_CLASS_pll_reconfig_5 altera_pll_reconfig
#define PLL_RECONFIG_5_BASE 0x500
#define PLL_RECONFIG_5_IRQ -1
#define PLL_RECONFIG_5_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_RECONFIG_5_NAME "/dev/pll_reconfig_5"
#define PLL_RECONFIG_5_SPAN 256
#define PLL_RECONFIG_5_TYPE "altera_pll_reconfig"


/*
 * spi_2 configuration
 *
 */

#define ALT_MODULE_CLASS_spi_2 altera_avalon_spi
#define SPI_2_BASE 0x700
#define SPI_2_CLOCKMULT 1
#define SPI_2_CLOCKPHASE 0
#define SPI_2_CLOCKPOLARITY 1
#define SPI_2_CLOCKUNITS "Hz"
#define SPI_2_DATABITS 8
#define SPI_2_DATAWIDTH 16
#define SPI_2_DELAYMULT "1.0E-9"
#define SPI_2_DELAYUNITS "ns"
#define SPI_2_EXTRADELAY 0
#define SPI_2_INSERT_SYNC 0
#define SPI_2_IRQ 1
#define SPI_2_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SPI_2_ISMASTER 1
#define SPI_2_LSBFIRST 0
#define SPI_2_NAME "/dev/spi_2"
#define SPI_2_NUMSLAVES 1
#define SPI_2_PREFIX "spi_"
#define SPI_2_SPAN 32
#define SPI_2_SYNC_REG_DEPTH 2
#define SPI_2_TARGETCLOCK 5000000u
#define SPI_2_TARGETSSDELAY "0.0"
#define SPI_2_TYPE "altera_avalon_spi"


/*
 * sysid_qsys_0 configuration
 *
 */

#define ALT_MODULE_CLASS_sysid_qsys_0 altera_avalon_sysid_qsys
#define SYSID_QSYS_0_BASE 0x1810
#define SYSID_QSYS_0_ID 10
#define SYSID_QSYS_0_IRQ -1
#define SYSID_QSYS_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_QSYS_0_NAME "/dev/sysid_qsys_0"
#define SYSID_QSYS_0_SPAN 8
#define SYSID_QSYS_0_TIMESTAMP 1536833288
#define SYSID_QSYS_0_TYPE "altera_avalon_sysid_qsys"


/*
 * vctcxo_tamer_0_ctrl configuration
 *
 */

#define ALT_MODULE_CLASS_vctcxo_tamer_0_ctrl altera_avalon_pio
#define VCTCXO_TAMER_0_CTRL_BASE 0x7a0
#define VCTCXO_TAMER_0_CTRL_BIT_CLEARING_EDGE_REGISTER 0
#define VCTCXO_TAMER_0_CTRL_BIT_MODIFYING_OUTPUT_REGISTER 0
#define VCTCXO_TAMER_0_CTRL_CAPTURE 0
#define VCTCXO_TAMER_0_CTRL_DATA_WIDTH 4
#define VCTCXO_TAMER_0_CTRL_DO_TEST_BENCH_WIRING 0
#define VCTCXO_TAMER_0_CTRL_DRIVEN_SIM_VALUE 0
#define VCTCXO_TAMER_0_CTRL_EDGE_TYPE "NONE"
#define VCTCXO_TAMER_0_CTRL_FREQ 30720000
#define VCTCXO_TAMER_0_CTRL_HAS_IN 1
#define VCTCXO_TAMER_0_CTRL_HAS_OUT 0
#define VCTCXO_TAMER_0_CTRL_HAS_TRI 0
#define VCTCXO_TAMER_0_CTRL_IRQ -1
#define VCTCXO_TAMER_0_CTRL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VCTCXO_TAMER_0_CTRL_IRQ_TYPE "NONE"
#define VCTCXO_TAMER_0_CTRL_NAME "/dev/vctcxo_tamer_0_ctrl"
#define VCTCXO_TAMER_0_CTRL_RESET_VALUE 0
#define VCTCXO_TAMER_0_CTRL_SPAN 16
#define VCTCXO_TAMER_0_CTRL_TYPE "altera_avalon_pio"

#endif /* __SYSTEM_H_ */
