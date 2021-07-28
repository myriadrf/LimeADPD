.. _user-guide:

CFR and DPD User Guide
======================

.. note::

   For DPD demonstration two transceiver channels are implemented in LimeSDR
   QPCIe board (named with channels A and B). Also, two power amplifiers are
   requited belonging different transmitting paths. 

Hardware Configuration
----------------------

Follow the steps explained below:

* The LimeSDR QPCIe channel A output, the LimeSDR QPCIe LMS#1 TX1_1 port, is
  connected to channel A PA#1 input. 
* For channel B, port LMS#1 TX2_1 port is used and it is connected to
  corresponding PA#2 input.
* The output of one of the PAs is via RF attenuator connected to spectrum
  analyzer RF input. The other PA output can be terminated with 50 Ohms.
* PA coupling outputs are over 10dB-20dB RF attenuators fed to two LimeSDR QPCIe
  receive inputs. 
* The on-board analogue multiplexer is used for selection of PA coupling output
  signals. The multiplexer input, the U.FL RF1, is dedicated for channel A receive
  input, while the U.FL RF3 is used as channel B input. 
* The analogue multiplexer output U.FL port RFC is connected to the U.FL LMS#1
  RX1_W, which is used as DPD monitoring input. 

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

     sudo ./LimeSuiteGU
#. Make the connection with the LimeSDR QPCIe board Options |rarr| Connection
   settings. Select the LimeSDR QPCIe board.
#. Read the LMS7002M INI configuration file
   ``LMS1settings/LMS1settings_20_751.ini``.
#. In LimeSuiteGUI open the Calibrations tab, press buttons Calibrate Tx, then
   Calibrate Rx for static I/Q calibration.
#. Open the window Board related controls through Modules |rarr| Board Controls.
   When opened, read the FPGA configuration file (with extension .ini2) which
   contains the CFRs settings and post-CFR FIR filter configuration. To do
   this press Read settings button and choose the file dedicated to 10MHz LTE
   waveform: ``FPGAsettings/FPGAsettings_10MHz.ini2``. 
#. Now, select the test waveform by Modules |rarr| FPGA controls, then select the
   10MHz LTE waveform ``lms7suite_wfm/LTE_DL_TM31_10MHZ.wfm``. Check *MIMO* option
   and press button Custom to start the waveforms.

Board Related Controls
----------------------

The Crest factor reduction (CFR) controls have been implemented in the Board
related controls window, which is the part of LimeSuite GUI (Figure 6). The
window provides:

* Selection of the transmit channels A or B.
* Change of PWFIR filter order, in the range from 1 to 40.
* Setting the clipping threshold.
* To change the coefficients of post-CFR FIR filter.
* To turn on/off the LimeNET internal PAs and DCDCs (only if  LimeNET internal
  PAs are used).

.. figure:: images/board-related-controls.png

   Figure 6: The Board related controls dialog.

The radio buttons A_CHANNEL and B_CHANNEL select one of the transmit paths: A or
B (Figure 6). 

Two different CFR blocks and accompanying post-CFR FIR filters in the FPGA
gateware are dedicated to different transmit paths A and B. Therefore, before
any modification of CFR parameters is made, the transmit path must be selected
using the previously specified radio buttons. 

CFR parameters for each of the transmit paths include:

* *Bypass* – when is checked, the CFR is bypassed.
* *Interpolation* has possible values 0 and 1 (Figure 6). The value 1 selects the
  interpolation in front of CFR block. (see Figure 5). In this case the data rate
  of signals entering the CFR is 61.44 MSps. Otherwise, when 0 value is chosen,
  the interpolation is used after CFR and post-CFR FIR blocks. In this case the
  data rate of signals is 30.72MSps. 
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

The recommended CFR configuration for different LTE bandwidths is given in the
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

As previously mentioned, the low-pass post-CFR FIR filter follows the CFR block
(Figure 5). The options for filter coefficients reading end programming are
provided. When *Coeff.* button in the *Board related controls* window is
pressed, the post-CFR FIR filter coefficients are read from FPGA gateware
registers and displayed in the new window. New post-CFR FIR coefficients can be
loaded from .fir file and displayed in the window. For different LTE waveforms
(5MHz, 10MHz, 15MHz and 20MHz) the corresponding .fir files are provided in
folder in folder ``<LimeSuiteGUI install
folder>/LimeSuite/build/bin/FIRcoefficients``. After
pressing OK button, the window is closed and new coefficients are programmed
into the FPGA gateware registers. Since different post-CFR filters exist for
different channels, it is required to select the transmitting channel before
changing filter coefficients. For this purpose the radio buttons
*A_CHANNEL/B_CHANNEL* are used. 

The post-CFR filter length depends on Interpolation. When interpolation is 0,
the data rate of post-CFR FIR signals is 30.72MSps (see Figure 5). In this case
the post-CFR FIR order is 40. Otherwise, when value 1 is chosen, the
interpolation is done before the CFR and post-CFR FIR blocks. In this case, the
data rate of signals is 61.44 MSps and filter order maximum is equal to 20. 

Before waveform bandwidth is changed it is required to change both post-CFR
filter coefficients and CFR parameters, including the CFR filter length and
interpolation.

To save or read gateware configuration the *Board related controls* window
(Figure 6) provides three buttons: 

* *Read settings* which reads the .ini2 file, updates the configuration shown in
  the window and also, automatically programs the FPGA gateware (the CFR blocks
  and post-CFR FIR filters),
* *Refresh* button reads the configuration which is already programmed in the FPGA
  and updates the configuration in the window,
* *Save settings* is used to read the configuration from FPGA and save it into the
  .ini2 file

Beside the CFR and post-CFR FIR configuration, the *Board related controls* window
controls the internal LimeNET Base station PAs and DC/DC convertors. Namely, the
LimeNET Base station PAs and DCDCs can be turned on/off programmatically. 

The check buttons *DC/DC ChA and ChB* (Figure 6) are used to switch on/off the
LimeNET BS DC/DC convertors, which provide power supply to PAs (only if LimeNET
internal PAs are used). Additionally, the LimeNET BS PAs can be turn on/off
using *PA ChA and ChB* check buttons. Note that when the control is checked, the
DCDC or PA is turned on. 

DPDViewer Window
-----------------

.. figure:: images/dpdviewer-before-training.png

   Figure 7: DPDViewer: ADPD signals before training

PC/GUI implements graphical display for demo and debugging purposes. GUI is
capable to show important ADPD signals in FFT (frequency), time and
constellation (I vs Q) domains. The DPD viewer window is displayed through
*Modules |rarr| DPDViewer*.

Figures 7 and 8 show important ADPD signals before and after the algorithm
convergence. Signals are captured by GUI executed by CPU Core.

ADPD parameters given in the QADPD setup part of the window are: 

* *N(mem.)* — the DPD model memory order, maximum value N=4.
* *M (nonl.)* — the nonlinearity order, maximum value M=3,
* *Lambda* — the RLS forgetting factor. It is real value less than 1.0.
* *Train cycles* — number of train cycles before new DPD coefficients are 
  programmed.
* *ND delay* — the DPD delay line length (in range from 74-80).
* *Gain* — floating point number representing the DPD digital gain. When Gain is
  obtained by gain calibration process, the PA output power is maintained at the
  save power level after DPD linearization process is performed compared to
  initial power. When Gain value is chosen to be less than the value derived after
  Gain calibration, the power at PA output is increased, as well the amount of
  distortion. 

.. figure:: images/dpdviewer-after-training.png

   Figure 8: DPDViewer: ADPD signals before training

Before training (Figure 7), predistorter signals *yp* and *xp* are equal (plot
1).  Signal *x* as a measure of PA output is distorted (plot 3). Waveforms *y*
and *u* are very different (plot 2) which results in huge error (plot 4) which
ADPD has to minimize.

After ADPD training (Figure 8), signal *yp* (plot 1) is predistorted in order to
cancel PA distortion components. *x* as a measure of PA output is now linearized
(plot 3). Excellent match between *y* and *u* waveforms in both time and
amplitude scale (plot 2). ADPD error (plot 4) is minimized. Improvement in PA
linearization can be seen by comparing *yp* and *x* spectra of plot 3.

The basic operations describing the DPD operations from LimeSuite GUI are as
follows:

1. Start the waveforms (running the LTE stack, or loading the test waveform)
2. Select the transmitting channel (A or B)
3. Press *Calibrate ND* delay button.

.. note::

   Expected values for delay ND are in the range [74-80]. 

.. note::

   If in consecutive DPD calibration procedures, different, random values for ND
   are obtained, which are out of specified range, there is a RF reflection or
   interference. To solve this, check the RF cables. The cable dedicated for DPD
   monitoring path (from PA’s coupling output to LimeSDR QPCIe board) should have
   strong shield. Else, 10dBm-20dBm RF attenuator should be placed at LimeSDR QPCIe
   board receive input, rather than at PA’s coupling output.

4. Press *Calibrate gain* to determine DPD digital gain.

.. note::

   If LTE stack is running, the DPD calibration procedure requires the data
   payload, generated by connecting mobile phone(s) to BTS and executing Magic
   Iperf application on both sides.

.. note::

   The DPD digital gain should be in range [1.0-3.0], otherwise, LMS7002M
   channel A receiver gain settings must be modified. 

5. In the part of the window *Train DPD*, press the *Start* button, check *Cont.
   train* option and then select *Continuous* option.
6. To stop the DPD training process, first press *One step*, then *End* button,
   above.
7. Repeat steps 2-6 for the other channel .

.. note::

   For DPD coefficient reset use *resetCoeff* button. The result of this operation
   is the same as DPD is bypassed.

.. note::

   For DPD coefficient reset use resetCoeff button. The result of this operation
   is the same as DPD is bypassed.

When LTE stack is running there is a possibility to just monitor the signals
without performing the DPD training. In this case, the sequence of operations is
as follows:

1. Select the channel first (A or B).
2. In the part of the window *Train DPD*, press the *Start* button, uncheck *Cont.
   train* option and select *Continuous* option.
3. To stop monitoring operation, first press *One step*, then *End* button.
4. Repeat steps 1-3 for the other channel .

