CFR Configuration
=================
   
.. tabs::

   .. tab:: LimeSDR-PCIe-5G

        * In order to configure CFR in LMS1 transmit path of board LimeSDR-PCIe-5G 
          open the window *LMS1 CFR controls* through *Modules* |rarr| *LMS1 CFR controls*. 
        * Read the FPGA configuration file (with extension .ini2) which contains the CFR settings and post-CFR FIR filter configuration. 
        * To do this press *Read* button and choose the file.
        * The configuration file which corresponds to 10MHz LTE waveform is ``FPGAsettings/FPGAsettings.ini2``. 

   .. tab:: LimeSDR-QPCIe

        * Open the window *Board related controls* through *Modules* |rarr| *Board Controls*.
        * When window is opened, read the FPGA configuration file (with extension .ini2)
          which contains the CFR settings and post-CFR FIR filter configuration. 
        * To do this press *Read settings* button and choose the file dedicated to 10MHz LTE
          waveform ``FPGAsettings/FPGAsettings_10MHz.ini2``. 


* The CFR data rate as well the post-CFR filter length depends on *Interpolation* option.
  Two options are provided, as explained below. 

* When *Interpolation* = 0, the CFR processing data rate is 30.72MSps. 
  In this case the post-CFR FIR order maximum value is 40. 
  This option is dedicated for 5 MHz and 10 MHz bandwidth waveforms. 

* When *Interpolation* = 1, the signal interpolation is utilized in front of  
  the CFR and post-CFR FIR blocks. 
  In this case, the data rate of signals processed by CFR is 61.44 MSps. 
  This option is used when 15 MHz and 20 MHz bandwidth waveforms are transmitted. 
  In this case the Post-CFR FIR filter order maximum is equal to 20. 
 

.. note::

       Whenever waveform bandwith is changed it is required to change both post-CFR 
       filter coefficients and CFR parameters, including the CFR filter length and
       interpolation that correspond to selected bandwidth.


.. note::

       When interpolation or CFR order values are changed in the control window, new Hann
       windowing coefficients are automatically calculated and are programmed to the
       dedicated CFR registers located in FPGA gateware of the board.       
   
* The CFR treshold determines the target PAPR. 
* It is expressed by real number in the range from 0.0 to 1.0.
* The threshold is normalized to full scale signals. 
* For example, for *Threshold* = 0.707, the PAPR of the output signal is reduced by 3dB.
  

* The CFR filter order depends on waveform bandwidth. The recommended CFR configuration for different LTE bandwidths is given in the
  Table 2.

.. list-table:: Table 2: The recommended CFR configuration for different LTE
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

   If the power of the input signal is additionally backed-off by LTE stack
   settings, the threshold given in the Table 2 should be re-calculated and
   modified. 
