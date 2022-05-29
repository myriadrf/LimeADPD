LimeSDR-PCIe-5G Board Configuration
===================================

.. note::

   The board LimeSDR-PCIe-5G incorporates three LMS7002M ICs, named with LMS1, LMS2, LMS3.
   
   For DPD demonstration the LMS1 and LMS3 are used. Two transmitter channels (named with channels A and B) are implemented by LMS1. 
   The DPD monitoring paths are realized by two LMS3 receiver paths. The pre-driver TQM8M9079 PAs 
   are embedded on the board, located in LMS1 transmit paths.

   The LMS2 is used for 5G signal transmission and implements two transceiver chains. 
   The TX chain includes the CFR block, specifically optimized for 100 MHz bandwidth waveforms. 

Hardware Configuration
----------------------

Please, follow the steps explained below:

* For LMS1 TX channel A output, use the U.FL connector J8 - the LMS1 TX1. 
* For LMS1 channel B TX output, the U.FL connector J9, LMS1 TX2 port, is used.
* For DPD demonstration, one of the TX outputs is connected to PA input and after the PA to RF coupler. 
  The other TX output can be terminated with 50 Ohms.
  RF coupling outputs are over 10-20 dB RF attenuators fed to two LMS3 receive inputs,
  which are used as DPD monitoring path inputs.  
* For LMS3 channel A RX input, the U.FL connector J6 is used. It is connected to LMS3 RX1_H input.
* The U.FL connector J5 is used as channel B LMS3 input. It is connected to LMS3 RX2_H input.
* For transmission of 5G signals, the ports LMS2 TRX1 and TRX2 are used, located at J10 and J12 connectors. 


Connecting to the board
-----------------------
Install the Litepcie kernel ``https://gitlab.com/myriadrf/pcie_kernel_sw/-/tree/diff_dev_names`` 
by running setup.sh with super user privileges:
   
   ::

     sudo ./setup.sh

After installing the kernel, LimeSDR-PCIe-5G board appears in the ``/dev/`` hfolder. 
You can check this by typing:
   
   ::

     ls /dev | grep Lime5G 

LimeSuiteGUI settings
---------------------

The CFR and DPD control is implemented in LimeSuiteGUI application. Follow the
steps 1 to 12: 

#. Copy the content of folder *DPD/sw* (the subfolders and *QADPDconfig.ini*) into
   folder that belongs to LimeSuiteGUI installation: ``<LimeSuite install
   folder>/LimeSuite/build/bin``.
#. Open a terminal in this folder.
#. Start the LimeSuiteGUI application with sudo:
   ::

     sudo ./LimeSuiteGUI
#. Make the connection with the LimeSDR-PCIe-5G board *Options* |rarr| *Connection
   settings*. Select the LimeSDR-PCIe-5G board.
#. Select the right LMS7002M chip (LMS1, LMS2 or LMS3) in the LimeSuite GUI and 
   read corresponding INI configuration files:
   ``LMSsettings/LMS1settings.ini``
   ``LMSsettings/LMS2settings.ini``
   ``LMSsettings/LMS3settings.ini``
   Three INI files are provided with this document, one for each LMS7002M IC.
#. In LimeSuiteGUI select the LMS1 chip, open the *Calibrations* tab, press buttons *Calibrate Tx*, then
   *Calibrate Rx* for static LMS1 TX I/Q calibration. 
#. In LimeSuiteGUI open the *CLKGEN* tab, press buttons *Calibrate*, *Tune*.
#. To configure RF switches and amplifiers open the window *Board related controls* 
   using *Modules* |rarr| *Board Controls*. When opened, configure the following items:

   * the *LMS1 TX1_EN* is checked, the *LMS1 RWSW_TX1* selection box is set to option 
     *TX1_2* |rarr| *TX1(J8)*, *TX1DAC* should is set to value od 52000, 
   * the *LMS3 RWSW_RX1* selection box should be set to option *RX1_H* |larr| *RX_IN(J6)*,
   * the *LMS2 TX1_EN* is checked, the *LMS2 RWSW_TX1T* selection box is set to option *TX1_1* |rarr| *RFSW_TRX1*, 
     the *LMS2 RWSW_TRX1* selection box is set to option *RFSW_TRX1* |rarr| *TRX1(J10)*.

#. Clocks for the LMS2 and LMS3 analog interfaces are provided by the onboard 
   CDCM6208 clock generator. Open *Modules* |rarr| *CDCM6208*. 
   
   * First press *Reset* button. 
   * Check the Y0 CDCM outputs in the *Frequency planning* box.
     Enter frequency of 245.76 in the *Frequency requested* boxes. Click *Calculate*,
     click *Write All* to write the new configuration into the CDCM6208 chip. Uncheck the Y0.
   * Check the Y4 and Y5 CDCM outputs in the *Frequency planning* box. 
     Enter frequency of 122.88 in the *Frequency requested* boxes. Click *Calculate*.
     Click *Write All* to write the new configuration into the CDCM6208 chip. Uncheck the Y4 and Y5.
   * Check the Y6 and Y7 CDCM outputs in the *Frequency planning* box. 
     Enter frequency of 61.44 in the *Frequency requested* boxes. Click *Calculate*.
     Click *Write All* to write the new configuration into the CDCM6208 chip. Uncheck the Y6 and Y7.
  
#. Open the window *LMS1 CFR controls* through *Modules* |rarr| *LMS#1 CFR controls*.
   When window is opened, read the FPGA configuration file (the file with extension ``.ini2``) which
   contains the CFRs settings and post-CFR FIR filter configuration. To do this press 
   *Read* button and choose the file dedicated to 10MHz LTE waveform: 
   ``FPGAsettings/FPGAsettings.ini2``. 
#. Open the window *LMS2 CFR controls* through *Modules* |rarr| *LMS#2 CFR controls*.
   Read the FPGA configuration file (the file with extension ``.ini2``) which
   contains the 5G CFRs settings and FIR configuration. Press 
   *Read* button and choose the file: 
   ``FPGAsettings/FPGAsettings.ini2``.    
#. Now, select the test waveform by *Modules* |rarr| *FPGA controls*, then select the
   LMS1 option, and, select the 10MHz LTE waveform ``lms7suite_wfm/LTE_DL_TM31_10MHZ.wfm``.
   Press button *Custom* to start the waveform.

   .. figure:: ../images/board-related-controls-5G.png

   Figure 9: The Board related controls' dialog.

   .. figure:: ../images/CDCM6208.png

   Figure 10: CDCM6208 dialog.
  
LMS#1 CFR controls window
-------------------------

 The Crest factor reduction (CFR) controls have been implemented in the LMS#1 CFR controls
 window, which is the part of LimeSuite GUI (Figure 11). 
 
 The window *LMS1 CFR controls* is opened by *Modules* |rarr| *LMS#1 CFR controls*.

 The window provides:

* Selection of the TX channels A or B.
* Change of PWFIR filter order, in the range from 1 to 40.
* Setting the clipping threshold.
* To change the coefficients of post-CFR FIR filter.

 .. figure:: ../images/lms1-cfr-controls-5G.png

   Figure 11: LMS1 CFR controls dialog

The radio buttons A_CHANNEL and B_CHANNEL select one of the TX paths: A or
B (Figure 11). 

Two CFR blocks and accompanying post-CFR FIR filters are implemented in transmit 
paths A and B. Therefore, before any modification of CFR parameters is made, the 
TX path must be selected using the previously specified radio buttons. 

CFR parameters for each of the TX paths include:

* *Bypass CFR* – when is checked, the CFR is bypassed.
* *Interpolation* has possible values 0 and 1 (Figure 11). The value 1 selects the
  interpolation in front of CFR block. (see Figure 6). In this case the data rate
  of signals entering the CFR is 61.44 MS/s. Otherwise, when 0 value is chosen,
  the interpolation is used after CFR and post-CFR FIR blocks. In this case the
  data rate of signals is 30.72 MS/s. 
* *CFR order* is the integer value representing the CFR PWFIR order. When
  *Interpolation* = 0 the CFR order maximum is 40; When control signal
  *Interpolation* = 1, maximum PWFIR order is 20.
* *Threshold* is the floating point number in the range from 0.0 to 1.0,
  determining the clipping threshold. The value is normalized to input signal
  amplitude maximum. The parameter *Threshold* determines the amount of PAPR
  reduction. For example, the value of 0.707 reduces the input signal PAPR by 3dB.
  When value of 1.0 is chosen, the clipping operation is bypassed. 
* *Gain* is the digital gain following CFR block. The default value is set to 1.0.

The low-pass post-CFR FIR filter follows the CFR block (Figure 6). The options for 
FIR filter coefficients reading end programming are provided. 
When *Coefficients* button is pressed, the post-CFR FIR filter coefficients 
are read from FPGA  registers and displayed in the new window.
New FIR coefficients can be loaded from ``.fir`` file and displayed in the window.
After pressing OK button, the window is closed and new coefficients are programmed
into the FPGA registers.

.. note::

   Since different post-CFR filters exist for
   different channels, it is required to select the transmitting channel before
   changing filter coefficients. 
   For this purpose the radio buttons *A_CHANNEL/B_CHANNEL* are used. 

.. note::

   For different LTE waveforms (5MHz, 10MHz, 15MHz and 20MHz) the corresponding ``.fir`` files are provided in
   folder ``<LimeSuiteGUI install folder>/LimeSuite/build/bin/FIRcoefficients``. 
   The coefficient values, stored in the ``.fir`` file, are derived as normalized FIR filter 
   coefficient values multiplied with constant integer number of 2\ :sup:`15`\ -1.

To save or read FPGA configuration the window (Figure 11) provides three buttons: 

* *Refresh all* button reads the configuration which has been already programmed 
  in the FPGA and updates the configuration in the window.
* *Read* button which reads the ``.ini2`` file, updates the configuration shown in
  the window and also, automatically programs the FPGA registers (the CFR blocks
  and post-CFR FIR filters).
* *Save* button is used to read the configuration from FPGA and save it into the ``.ini2`` file.

Additional controls:

* *ResetN* - used for debugging purposes
* *LMS1 txen* - used for debugging purposes
* *DPD cap.en.* - when checked, the captured signals are sent to DPDViewer instead of FFTViewer
* *LMS3 mon.path* - selects the DPD monitoring path, when checked, the LMS3 receiver 
  is used, otherwise it is the LMS1 receiver 
* *DPD/CFR enable* - should be checked in order to use the CFR and DPD modules


LMS#2 CFR controls window
-------------------------

The window *LMS#2 CFR controls* is opened by *Modules* |rarr| *LMS#2 CFR controls*.

 .. figure:: ../images/lms2-cfr-controls-5G.png

   Figure 12: LMS2 CFR controls dialog

The radio buttons A_CHANNEL and B_CHANNEL select one of the LMS2 TX paths: A or
B (Figure 12). 

CFR parameters for each of the TX paths include:

* *Bypass HB1*, when checked, the interpolation is bypassed (Figure 7). In this 
  case, the data rate of signals is 122.88 MS/s. When unchecked, the data rate of 
  the signals processed by CFR is 245.76 MS/s.
* *Bypass CFR* – when is checked, the CFR is bypassed.   
* *CFR order* is the integer value representing the CFR PWFIR order. 
  The CFR order maximum is 32;
* *Threshold* is the floating point number in the range from 0.0 to 1.0,
  determining the clipping threshold value, normalized to signal
  full-scale. For example, the value of 0.707 reduces the input signal PAPR by 3dB.
  When value of 1.0 is chosen, the clipping operation is bypassed. 
* *Gain* is the digital gain following CFR block. The default value is set to 1.0.

The low-pass post-CFR FIR filter follows the CFR block. By pressing the *Coefficients* 
button, the filter coefficients are read from FPGA registers and displayed 
in the new window. Also, new coefficients can be loaded from ``.fir`` file and displayed.
After pressing OK button and new coefficients are programmed into the FPGA. 
Option *Bypass FIR* bypasses the post-CFR FIR operation.

Option *TX input source* selects the NCO signal or regularly transmitted waveform.

At right side of the window, the window provides bypass check boxes and value editing fields for 
various RX and TX static corrector modules:

* Phase I/Q correction (*PHCORR*)
* Gain I/Q correction (*GCORR*)
* I and Q components DC offset correction (*DCCORRI* and *DCCORRQ*)

.. note::

   For 100 MHz bandwidth waveform the corresponding ``.fir`` files is provided in
   folder ``<LimeSuiteGUI install folder>/LimeSuite/build/bin/FIRcoefficients``. 
   The coefficient values are derived as normalized filter 
   coefficient values multiplied with constant integer number of 2\ :sup:`15`\ -1.

To save or read FPGA configuration: 

* Button *Read* reads the ``.ini2`` file, updates the configuration shown in
  the window and also, automatically programs the FPGA (the CFR blocks
  and post-CFR FIR filters).
* *Save* button is used to read the configuration from FPGA and save it into the ``.ini2`` file.
