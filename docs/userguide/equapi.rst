equAPI Application
==================

The application equAPI is a command-line application dedicated to LimeSDR-PCIe-5G board. 

The application performs the I/Q imbalance correction and gain flattening in LMS#2 transmit and receive paths.

Main parts of software application are:

   1. LMS#2 receiver and transmitter calibration routines
   2. Rx and Tx, EQUI and EQUQ, the coefficient's calculation, and, 
   3. Rx and Tx, EQUI and EQUQ, coefficients programming operations.

.. note::
   The LMS#3 is used during LMS#2 calibration routines (in Phases 1, 2 and 3). 
   Clock for the LMS3 analog interfaces should be set to 122.88 MHz. 
   The clock configuration is provided via LimeSuiteGUI CDCM6208 window. 
   
   * Open Modules → CDCM6208
   * Check the Y6 and Y7 CDCM outputs (for LMS#3 ADCs) in the Frequency planning box.
   * Enter frequency of 122.88 in the Frequency requested boxes. Click Calculate.
   * Click Write All to write the new configuration into the CDCM6208 chip.

.. note:: 
   * open Modules → LMS#1 CFR controls window
   * keep checked boxes: ResetN, LMS1 txen, DPD/CFR enable, LMS3 mon.path
   * uncheck DPD cap.en. 

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
    * sudo ./equAPI X [-c]
    * sudo ./equAPI X [-m]
    * sudo ./equAPI X [-c] [-s] <filename>
    * sudo ./equAPI X [-s] <filename>
    * sudo ./equAPI X [-l] <filename>

.. note::
   the X is the index of LMS#2 transceiver channel of LimeSDR-PCIe-5G board, 
   X={0,1}, the <filename> is the filename with extension ".ini2" used to store the 
   Equaliser configuration.

Program options include:

    * "--list"  get the list of all available LimeSDR-PCIe-5G boards
    * "-r, --reset" reset the Equaliser configuration
    * "-c, --calibrate" calibrate Equaliser of target board
    * "-m, --measurement" perform the measurement of target board
    * "-s, --save <filename>" save the Equaliser configuration of target board into the file
    * "-l, --load <filename>" load the configuration from specified file into target board 
    * "-h, --help" show help
