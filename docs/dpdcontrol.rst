DPDControl Application
======================

The application is dedicated to LimeSDR QPCIe board. Before starting the
command-line application, named DPDcontrol, the LMS7002 transceiver chip should
be initialized and modulation waveforms started.

One option to do this is to start Amarisoft LTE stack. The other option is,
using LimeSuiteGUI application, to load LMS7002M configuration files and run
test waveforms.

In the first option, during LTE start-up procedure, two LMS7002M .ini files are
automatically loaded into two transceiver ICs. Also, the .ini2 FPGA
configuration file is loaded, containing on-board FPGA gateware configuration,
including information regarding CFRs and post-CFR FIR filter coefficients. 

In the second option, used for development or demo, test waveform is uploaded
and played from the on-board WFM RAM Blocks. The LimeSuiteGUI application is
used in this case.

#. Open the terminal in the folder which belongs to LimeSuiteGUI installation: 
   ::

     <LimeSuiteGUI installation folder>/LimeSuite/build/bin
#. Start the LimeSuiteGUI application with sudo:
   ::

     sudo ./LimeSuiteGUI
#. Make the connection with the board Options->Connection settings. Find and
   select LimeSDR QPCIe board.
#. Read the LMS7002M .ini configuration file
   ``LMS1settings/LMS1settings_20_751.ini``.
#. Open the window Board related controls through *Modules* |rarr| *Board Controls*.
   When window is opened, read the FPGA configuration file (with extension .ini2)
   which contains the CFRs settings and post-CFR FIR filter configuration. To do
   this press *Read settings* button and choose the file dedicated to 10MHz LTE
   waveform ``FPGAsettings/FPGAsettings_10MHz.ini2``. When FPGA is initialized, 
   close the *Board related controls window*. 
#. In LimeSuiteGUI open the *Calibrations tab*, press *Calibrate Tx*, then 
   *Calibrate Rx*.
#. Now, select the test waveform by *Modules* |rarr| *FPGA controls*, then select
   the 10MHz LTE waveform ``lms7suite_wfm/LTE_DL_TM31_10MHZ.wfm``. Check *MIMO*
   option and press button *Custom* to start the waveform.

.. note::
   If it is required to modify CFR or post-FIR CFR settings, LimeSuiteGUI must be
   used. Again, go to *Modules* |rarr| *Board Controls*, open *Board related 
   controls*. After the CFR settings are modified, save new configuration into FPGA
   configuration .ini2 file or replace the existing FPGA configuration .ini2 file. 

Once the test waveforms are played, the ``DPDcontrol`` application can be started.

.. warning::
   It is not allowed to use the DPDcontrol application and LimeSuiteGUI at the 
   same time. Therefore, before starting the DPDcontrol, close the LimeSuiteGUI.

It is still possible to linearize PAs using DPDcontrol, and then, after closing
the DPDcontrol, open LimeSuiteGUI, its DPDViewer window, and check the spectrum
of the PA output signals. The relevant signal is signal x which is a measure of
PA output.

The very basic DPDcontrol operations are explained through steps 1-7.

1. Open the terminal in following folder, which belongs the *LimeSuiteGUI*
   installation:
   ::

     <LimeSuite install folder>/LimeSuite/src/commandmode/
2. Compile the DPDcontrol application:
   ::

     make
3. Start the application with sudo:
   ::

     sudo ./DPDcontrol

.. note::
   If the application *DPDcontrol* is started without any argument, the DPD
   nonlinearity order QADPD_M is defined by the value which is last stored in
   DPDcontrol configuration file. Please, find the description of 
   ``storeConfigDPD`` command below.

.. note::
   If the application is started with an argument, the argument represents the
   DPD nonlinearity order - QADPD_M, which is an integer value in the range from
   1 to 3. This parameter should be stored into DPDcontrol configuration file.
   Use ``storeConfigDPD`` command after DPD is being calibrated. 

4. To calibrate DPD parameters (calculate DPD digital gain and ND delay):
   ::

     calibrateDPD {1, 2, all}

.. note::
   The argument **all** refers to both transmitting channels; available arguments
   are 1, 2 or all, particularly for first channel A, second channel named B, or
   both channels.

.. note::
   Expected values for delay ND are in the range [74 – 80]. 

If in consecutive DPD calibration procedures, different, random values for ND
are obtained, which are out of specified range, there is a RF reflection or
interference. To solve this, check the RF cables. The cable dedicated for DPD
monitoring path (from PA’s coupling output to board) must have strong shield.
Else, place 10dBm-20dBm RF attenuator at LimeSDR QPCIe board receive port,
dedicated to DPD monitoring input, rather than at PA’s coupling output.

.. note::
   The DPD digital gain should be in range [1.0-3.0], otherwise change the
   LMS7002M receiver gain settings. Open *LimeSuiteGUI*, in tab RFE modify LNA;
   in tab RBB modify PGA gain settings.

.. note:: 
   When running the LTE stack, the DPD calibration procedure requires that the
   data payload is generated by connecting mobile phones to BTS and executing
   MagicIperf application on both phones.

5. When DPD is calibrated, the DPD training operation is started by:
   ::

     startDPD {1, 2, all}

.. note::
   Again, like in previous commands, the argument **all** refers to both
   transmitting channels; available arguments are 1, 2 or all, particularly for
   first channel A, second channel B or both channels.

.. note::
   DPD training operation is performed periodically for both transmitting
   channels, the calculation period is equal to four seconds, just in a few
   iterations PAs get linearized.

.. note::
   The information about DPD calculation errors obtained by DPD training process
   can be useful. The information is displayed or disabled by successive entering
   the character “**l**” in command line.

6. To stop DPD training operation use:
   ::

     stopDPD {1, 2, all}

7. To stop the application:
   ::

     quit

The application *DPDcontrol* has some additional useful commands which are
explained below:

1. The entire command set provided by:
   ::

     help

2. To turn on the DCDCs and PAs (only if  LimeNET internal PAs are used):
   ::

     startDCDC {1, 2, all}
     startPA {1, 2, all}

3. To turn off the DCDCs and PAs (if LimeNET internal PAs are used):
   ::

     stopPA {1, 2, all}
     stopDCDC {1, 2, all}

4. To store the DPD parameters into DPDcontrol configuration file (DPD digital
   gain and ND delay, which are determined by calibrateDPD; and DPD nonlinearity
   order – QADPD_M, defined by *DPDcontrol* application argument), use:
   ::

     storeConfigDPD {1, 2, all}

5. The DPD parameters (*DPD digital gain*, *ND delay* and *QADPD_M*) are loaded
   from configuration file using: 
   ::

     loadConfigDPD {1, 2, all}

.. note::
   When the application *DPDcontrol* is started, the parameters DPD digital gain
   and ND delay are automatically loaded from *DPDcontrol* configuration file.
   Also, when application is started without arguments, the DPD nonlinearity
   order *QADPD_M* is read from configuration file. When it is started with
   argument, it represents value of *QADPD_M*.

6. There is an option to store all calculated DPD coefficients (after training
   process is stopped with *stopDPD* command) into application’s configuration
   file. 
   ::

     storeCoeffDPD {1, 2, all}

7. To read the DPD coefficients from configuration file: 
   ::

     loadCoeffDPD {1, 2, all}

8. To read current status of DPD parameters (*DPD digital gain*, *ND delay* and
   *QADPD_M*), or status of the PAs and DCDCs for both transmitting channels, use
   the following command: 
   ::

     readConfigDPD {1, 2, all}

9. To reset all DPD coefficients:
   ::

     resetDPD {1, 2, all}

.. note::
   The result of this command is the same as DPD is bypassed. 
