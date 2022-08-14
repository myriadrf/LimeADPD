equAPI Application
==================

The application equAPI is a command-line application dedicated to LimeSDR-PCIe-5G board. 

The application performs the I/Q imbalance correction and gain flattening in LMS2 transmit and receive paths.

Main parts of software application are:

   1. LMS2 receiver and transmitter calibration routines
   2. Rx and Tx, EQUI and EQUQ, the coefficient's calculation, and, 
   3. Rx and Tx, EQUI and EQUQ, coefficients programming operations.

.. note::
   The LMS2 DAC clock frequency is set to 245.76 MHz. The LMS2 ADC clock frequency is set to 122.88 MHz.  
   The LMS3 is used during LMS2 calibration routines (in Phases 1, 2 and 3). 
   Clock for the LMS3 analog interfaces should be set to 122.88 MHz. 
   The clock configuration is provided via LimeSuiteGUI CDCM6208 window.

   * Open Modules → CDCM6208
   * Check the Y0 (for LMS2 DAC) in the Frequency planning box. Enter frequency of 245.76 in the Frequency requested boxes. Click Calculate. Click Write All to write the new configuration into the CDCM6208 chip. Uncheck the Y0.
   * Check the Y4 and Y5 CDCM outputs (for LMS2 ADCs); Y6 and Y7 (for LMS3 ADCs) in the Frequency planning boxes. Enter frequency of 122.88 in corresponding Frequency requested boxes. Click Calculate. Click Write All to write the new configuration. Uncheck the Y4, Y5, Y6 and Y7.

.. note:: 
   * in LimeSuiteGUI 

      * in RxTSP tab, for both LMS2 and LMS3, in both channels A and B, bypass (check fields) all RxTSP blocks except DC corrector and DC tracking loop
      * in TxTSP tab, for both LMS2 and LMS3, in both channels A and B, bypass (check fields) all TxTSP blocks
      * check Enable MIMO for MIMO operation
   * open Modules → LMS1 CFR,LMS3 RxTSP control window

      * check LMS3 *Enable RxTSP* for both channels 
      * check *ResetN*, *LMS1 txen*, *DPD/CFR enable*, *LMS3 mon.path*
      * **uncheck** *DPD cap.en*. 
   * open Modules → LMS2 CFR controls window

      * check LMS2 *En.RxTSP*, *En.TxTSP* for both channels
      * uncheck bypasses for *RxEQU* and *TxEQU* for both channels

The very basic equAPI operations are explained through steps 1-3.

1. Open the terminal in following folder, which belongs the *LimeSuiteGUI*
   installation:
   ::

     <LimeSuite install folder>/LimeSuite/src/Equaliser_CommandMode/
2. Compile the equAPI application:
   ::

     make
3. Start the application with one of the following commands:
   ::

    * sudo ./equAPI [--list]
    * sudo ./equAPI X [-r]
    * sudo ./equAPI X [-c] [-a] [-t]
    * sudo ./equAPI X [-m]
    * sudo ./equAPI X [-d]
    * sudo ./equAPI X [-c] [-a] [-t] [-s] <filename>
    * sudo ./equAPI X [-s] <filename>
    * sudo ./equAPI X [-l] <filename>

.. note::
   the X is the index of LMS2 transceiver channel of LimeSDR-PCIe-5G board, 
   X={0,1}, the <filename> is the filename with extension ".ini2" used to store the 
   Equaliser configuration.

Program options include:

    * "--list"  to get the list of all available LimeSDR-PCIe-5G boards
    * "-r, --reset"  resets the Equaliser configuration
    * "-c, --calibrate"  calibrates Equaliser of target board
    * "-m, --measurement"  performs the measurement of target board
    * "-s, --save <filename>"  saves the Equaliser configuration of target board into the file
    * "-l, --load <filename>"  load the configuration from specified file into target board
    * "-t, --tdd"  TDD mode is selected 
    * "-d, --dc"  calibrate separatelly TX DC offset 
    * "-a, --adjustgain"  option automatically adjusts (increase) the analogue gain after calibration process is finished and its gain flattening procedure decreases the digital gain
    * "-h, --help"  shows help

Example usage for LMS2 channel A Equaliser calibration and TX DC calibration:

    * sudo ./equAPI 0 -c -a
    * sudo ./equAPI 0 -d

Example usage for LMS2 channel B Equaliser calibration and TX DC calibration:

    * sudo ./equAPI 1 -c -a
    * sudo ./equAPI 1 -d

.. warning::
   It is not allowed to use the equAPI and FFTViewer at the 
   same time. Therefore, before starting the equAPI, stop LMS2 waveforms and close the FFTViewer.