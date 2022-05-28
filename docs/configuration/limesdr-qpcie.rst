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

Board Related Controls window
-----------------------------

The Crest factor reduction (CFR) controls have been implemented in the *Board
related controls window*, which is the part of LimeSuiteGUI (Figure 13). The
window provides:

* Selection of the transmitter channels A or B.
* Change of PWFIR filter order, in the range from 1 to 40.
* Setting the clipping threshold.
* To change the coefficients of post-CFR FIR filter.
* To turn on/off the LimeNET internal PAs and DCDCs (only if  LimeNET internal
  PAs are used).

.. figure:: ../images/board-related-controls.png

   Figure 13: The Board related controls' dialog.

The radio buttons A_CHANNEL and B_CHANNEL select one of the TX paths: A or
B (Figure 13). 

Two different CFR blocks and accompanying post-CFR FIR filters in the FPGA
gateware are dedicated to different transmit paths A and B. Therefore, before
any modification of CFR parameters is made, the TX path must be selected
using the previously specified radio buttons. 

CFR parameters for each of the TX paths include:

* *Bypass* – when is checked, the CFR is bypassed.
* *Interpolation* has possible values 0 and 1 (Figure 13). The value 1 selects the
  interpolation in front of CFR block. (see Figure 8). In this case the data rate
  of signals entering the CFR is 61.44 MS/s. Otherwise, when 0 value is chosen,
  the interpolation is used after CFR and post-CFR FIR blocks. In this case the
  data rate of signals is 30.72 MS/s. 
* *CFR order* is the integer value representing the CFR PWFIR order. When
  Interpolation=0 the CFR order maximum is 40, otherwise, when control signal
  interpolation = 1, maximum PWFIR order is 20.
* *Threshold* is the floating point number in the range from 0.0 to 1.0,
  determining the clipping threshold. The value is normalized to input signal
  amplitude maximum. The parameter Threshold determines the amount of PAPR
  reduction. For example, the value of 0.7 reduces the input signal PAPR by 3dB.
  When value of 1.0 is chosen, the clipping operation is bypassed. 
* *Gain* is the digital gain following CFR block. The default value is set to 1.0.

When interpolation or CFR order values are changed in the window, the new Hann
windowing coefficients are automatically calculated and are programmed to the
dedicated CFR registers located in FPGA gateware. 

The low-pass post-CFR FIR filter follows the CFR block
(Figure 8). The options for filter coefficients reading end programming are
provided. When *Coeff.* button in the *Board related controls* window is
pressed, the post-CFR FIR filter coefficients are read from FPGA
registers and displayed in the new window. New post-CFR FIR coefficients can be
loaded from ``.fir`` file and displayed in the same window. After
pressing OK button, the window is closed and new coefficients are programmed
into the FPGA registers. 

.. note::

  For different LTE waveforms
  (5MHz, 10MHz, 15MHz and 20MHz) the corresponding files are provided in
  folder ``<LimeSuiteGUI install
  folder>/LimeSuite/build/bin/FIRcoefficients``. 

  Since different post-CFR filters exist for
  different channels, it is required to select the transmitting channel before
  changing filter coefficients. For this purpose the radio buttons
  *A_CHANNEL/B_CHANNEL* are used. 

The post-CFR filter length depends on Interpolation. When interpolation is 0,
the data rate of post-CFR FIR signals is 30.72 MS/s (see Figure 5). In this case
the post-CFR FIR order is 40. Otherwise, when value 1 is chosen, the
interpolation is done before the CFR and post-CFR FIR blocks. In this case, the
data rate of signals is 61.44 MS/s and filter order maximum is equal to 20. 

To save or read gateware configuration the *Board related controls* window
(Figure 13) provides three buttons: 

* *Read settings* which reads the ``.ini2`` file, updates the configuration shown in
  the window and also, automatically programs the FPGA gateware (the CFR blocks
  and post-CFR FIR filters),
* *Refresh* button reads the configuration which is already programmed in the FPGA
  and updates the configuration in the window,
* *Save settings* is used to read the configuration from FPGA and save it into the
  ``.ini2`` file.

Beside the CFR and post-CFR FIR configuration, the *Board related controls* window
controls the internal LimeNET Base station PAs and DC/DC convertors. Namely, the
LimeNET Base station PAs and DC/DCs can be turned on/off programmatically. 

The check buttons *DC/DC ChA and ChB* (Figure 13) are used to switch on/off the
LimeNET BS DC/DC convertors, which provide power supply to PAs (only if LimeNET
internal PAs are used). Additionally, the LimeNET BS PAs can be turn on/off
using *PA ChA and ChB* check buttons. Note that when the control is checked, the
DCDC or PA is turned on. 
