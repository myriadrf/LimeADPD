/*
 * vctcxo_tamer.h
 *
 *  Created on: Feb 19, 2018
 *      Author: Vytautas
 */

#ifndef VCTCXO_TAMER_H_
#define VCTCXO_TAMER_H_

/* VCTCXO tamer register offsets */
#   define VT_CTRL_ADDR      		(0x00)
#   define VT_STAT_ADDR      		(0x01)
#   define VT_ERR_1S_ADDR    		(0x04)
#   define VT_ERR_10S_ADDR   		(0x0C)
#   define VT_ERR_100S_ADDR  		(0x14)
# 	define VT_STATE_ADDR     		(0x1C)
# 	define VT_DAC_TUNNED_VAL_ADDR0 	(0x20)
# 	define VT_DAC_TUNNED_VAL_ADDR1 	(0x21)

/* VCTCXO tamer control/status bits */
#   define VT_CTRL_RESET     		(0x01)
#   define VT_CTRL_IRQ_EN    		(1<<4)
#   define VT_CTRL_IRQ_CLR   		(1<<5)
#   define VT_CTRL_TUNE_MODE 		(0xC0)

#   define VT_STAT_ERR_1S    		(0x01)
#   define VT_STAT_ERR_10S   		(1<<1)
#   define VT_STAT_ERR_100S  		(1<<2)


/* Define a cached version of the VCTCXO tamer control register */
extern uint8_t vctcxo_tamer_ctrl_reg;

/* Define a global variable containing the current VCTCXO DAC setting.
 * This is a 'cached' value of what is written to the DAC and is used
 * by the VCTCXO calibration algorithm to avoid constant read requests
 * going out to the DAC. Initial power-up state of the DAC is mid-scale.
 */
extern uint16_t vctcxo_trim_dac_value;

/* A structure that represents a point on a line. Used for calibrating
 * the VCTCXO */
typedef struct point {
    int32_t  x; // Error counts
    uint16_t y; // DAC count
} point_t;

typedef struct line {
    point_t  point[2];
    float  slope;
    uint16_t y_intercept; // in DAC counts
} line_t;

/* State machine for VCTCXO tuning */
typedef enum state {
    COARSE_TUNE_MIN,
    COARSE_TUNE_MAX,
    COARSE_TUNE_DONE,
    FINE_TUNE,
    DO_NOTHING
} state_t;

typedef enum {
    /** Denotes an invalid selection or state */
    VCTCXO_TAMER_INVALID = -1,

    /** Do not attempt to tame the VCTCXO with an input source. */
    VCTCXO_TAMER_DISABLED = 0,

    /** Use a 1 pps input source to tame the VCTCXO. */
    VCTCXO_TAMER_1_PPS = 1,

    /** Use a 10 MHz input source to tame the VCTCXO. */
    VCTCXO_TAMER_10_MHZ = 2
} vctcxo_tamer_mode;

struct vctcxo_tamer_pkt_buf {
    volatile bool    ready;
    volatile int32_t pps_1s_error;
    volatile bool    pps_1s_error_flag;
    volatile int32_t pps_10s_error;
    volatile bool    pps_10s_error_flag;
    volatile int32_t pps_100s_error;
    volatile bool    pps_100s_error_flag;
};


void vctcxo_tamer_write(uint8_t addr, uint8_t data) ;

void vctcxo_tamer_reset_counters(bool reset) ;

void vctcxo_tamer_enable_isr(bool enable) ;

void vctcxo_tamer_clear_isr() ;

void vctcxo_tamer_set_tune_mode(vctcxo_tamer_mode mode) ;

int32_t vctcxo_tamer_read_count(uint8_t addr) ;

void vctcxo_trim_dac_write(uint8_t cmd, uint16_t val);

void vctcxo_tamer_isr(void *context) ;

void vctcxo_tamer_init();

void vctcxo_tamer_dis();

#endif /* VCTCXO_TAMER_H_ */
