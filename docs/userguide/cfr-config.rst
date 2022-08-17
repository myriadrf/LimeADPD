CFR Configuration
=================

.. tabs::

   .. tab:: LimeSDR-PCIe-5G

        * The LMS1 CFR processes the LTE waveforms. The data processing rate is 30.72 MS/s or 61.44MS/s depending on LTE signal bandwidth. 
        * For 5 MHz and 10 MHz bandwidth waveforms the rate is 30.72 MS/s. For 15 MHz and 20 MHz bandwidth waveforms the rate is 61.44 MS/s. 
        * In order to configure CFR in LMS1 transmit path open the window *LMS1 CFR controls* via *Modules* |rarr| *LMS1 CFR, LMS3 RxTSP controls*. 
        * Read the FPGA configuration file ``FPGAsettings/FPGAsettings_LMS1_10MHz_LMS2_100MHz.ini2`` which contains the LMS1 CFR settings and post-CFR FIR filter configuration. 
        * To do this press *Read* button and choose the file.

         
        * The LMS2 CFR runs the 5G 100MHz bandwidth waveforms. The CFR data processing rate is 245.76 MS/s. 
        * In order to configure LMS2 CFR, open the window *LMS2 CFR controls* via *Modules* |rarr| *LMS2 CFR controls*. 
        * Read the FPGA configuration file ``FPGAsettings/FPGAsettings_LMS1_10MHz_LMS2_100MHz.ini2`` which contains the LMS2 CFR and post-CFR FIR filter configuration. 
        * To do this press *Read* button and choose the file.

   .. tab:: LimeSDR-QPCIe

        * The CFR processes the LTE waveforms. The data processing rate is 30.72 MS/s or 61.44MS/s depending on LTE signal bandwidth. 
        * Open the window *Board related controls* through *Modules* |rarr| *Board Controls*.
        * Read the FPGA configuration file (with extension .ini2) which contains the CFR settings and post-CFR FIR filter configuration. 
        * To do this press *Read settings* button and choose the file dedicated to 10MHz LTE waveform, ``FPGAsettings/FPGAsettings_10MHz.ini2``. 

In case of LMS1 transmit paths of LimeSDR-PCIe-5G board different LTE signal bandwidths are considered.
The CFR data rate, as well the post-CFR filter length, depends on the *Interpolation* option:

* When *Interpolation* = 0, the CFR processing data rate is 30.72MS/s. In this case the post-CFR FIR order maximum is 40. This Interpolation option is dedicated for 5 MHz and 10 MHz bandwidth waveforms. 
* When *Interpolation* = 1, the signal interpolation is utilized in front of the CFR and post-CFR FIR blocks. In this case, the data rate of signals processed by CFR is 61.44 MS/s. This option is used for 15 MHz and 20 MHz bandwidth waveforms. In this case the Post-CFR FIR filter order maximum is equal to 20. 
 
The CFR threshold determines the target PAPR and is expressed by real number in the range from 0.0 to 1.0. The threshold is normalized to full scale signals.
For example, for *Threshold* = 0.707, the PAPR of the output signal is reduced by 3dB.
  
The LMS1 CFR filter order depends upon the waveform bandwidth. The recommended CFR configuration for different LTE bandwidths is given in Table 3.

.. list-table:: Table 3: The recommended CFR configuration for different LTE
                bandwidths. 
   :header-rows: 1

   * - LTE bandwidth [MHz]
     - CFR order
     - Interpolation
     - Threshold

   * - **05**
     - 21
     - 0
     - 0.75*

   * - **10**
     - 17 
     - 0
     - 0.75*

   * - **15**
     - 17 
     - 1 
     - 0.75*

   * - **20**
     - 13
     - 1
     - 0.75*

.. note::
  
  * Whenever the waveform bandwidth is changed it is required to change the post-CFR filter coefficients and CFR parameters, including the CFR filter length and interpolation that correspond to selected bandwidth.
  * When interpolation or CFR order values are changed, new Hann windowing coefficients are automatically calculated and are programmed into the dedicated CFR registers.
     
.. note::

   If the power of the input signal is additionally backed-off by LTE stack
   settings, the threshold given in the Table 3 should be re-calculated and
   modified. 

.. note::

   For the CFR block, located in LimeSDR-PCIe-5G LMS2 path, which processes the 5G 100MHz bandwidth at the rate 245.76 MS/s, the configuration includes:

   * CFR is enabled (the option *Bypass CFR* is left unchecked), 
   * the interpolation is enabled (the option *Bypass HB1* is **unchecked**, the *HB1 Delay* is **checked**), 
   * the recommended CFR order is equal to 13,
   * the post-CFR FIR operation is enabled (the option *Bypass FIR* is unchecked).
   
   