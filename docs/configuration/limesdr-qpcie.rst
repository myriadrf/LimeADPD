LimeSDR-QPCIe Board Configuration
=================================

.. note::

   For DPD demonstration two transceiver channels are implemented in LimeSDR
   QPCIe board (named with channels A and B). Also, two power amplifiers are
   required that are connected to the two different transmit paths. 

Hardware Configuration
----------------------

Follow the steps explained below:

* The LimeSDR QPCIe channel A output, the LimeSDR QPCIe LMS#1 TX1_1 port is connected to channel A PA#1 input. 
* For channel B, port LMS#1 TX2_1 port is used, and, it is connected to corresponding PA#2 input.
* The output of one of the PAs is via RF attenuator connected to spectrum analyzer RF input. The other PA output can be terminated with 50 Ohms.
* PA coupling outputs are over 10dB-20dB RF attenuators fed to two LimeSDR QPCIe receive inputs. 
* The on-board analogue multiplexer is used for selection of PA coupling output signals. The multiplexer input, the U.FL RF1, is dedicated for channel A receive input, while the U.FL RF3 is used as channel B input. 
* The analogue multiplexer output U.FL port RFC is connected to the U.FL LMS#1 RX1_W, which is used as DPD monitoring input. 

LimeSuiteGUI settings
---------------------

The CFR and DPD control is implemented in LimeSuiteGUI application. Follow the
steps 1 to 8: 

#. Copy the content of folder *DPD/sw* (the subfolders and *QADPDconfig.ini*) into
   folder that belongs to LimeSuiteGUI installation: ``<LimeSuite install
   folder>/LimeSuite/build/bin``.
#. Open a terminal in this folder.
#. Start the LimeSuiteGUI application with sudo:
   ::

     sudo ./LimeSuiteGUI
#. Make the connection with the LimeSDR QPCIe board Options |rarr| Connection
   settings. Select the LimeSDR QPCIe board.
#. Read the LMS7002M INI configuration file
   ``LMS1settings/LMS1settings_20_751.ini``.
#. In LimeSuiteGUI open the Calibrations tab, press buttons Calibrate Tx, then
   Calibrate Rx for static I/Q calibration.
#. Open the window Board related controls through Modules |rarr| Board Controls.
   When opened, read the FPGA configuration file (with extension ``.ini2``) which
   contains the CFRs settings and post-CFR FIR filter configuration. To do
   this press Read settings button and choose the file dedicated to 10MHz LTE
   waveform: ``FPGAsettings/FPGAsettings_10MHz.ini2``. 
#. Now, select the test waveform by Modules |rarr| FPGA controls, then select the
   10MHz LTE waveform ``lms7suite_wfm/LTE_DL_TM31_10MHZ.wfm``. Check *MIMO* option
   and press button Custom to start the waveforms.
