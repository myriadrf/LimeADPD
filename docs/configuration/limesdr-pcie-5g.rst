LimeSDR-PCIe-5G Board Configuration
===================================

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


LMS1 DPD Hardware Configuration
-------------------------------

The LMS1 is used an LTE transceiver.
For DPD demonstration the LMS1 and LMS3 are used. Two transmitter channels (named with channels A and B) are implemented by LMS1. 
The DPD monitoring paths are realized by two LMS3 receiver paths. The pre-driver TQM8M9079 PAs 
are embedded on the board, located in LMS1 transmit paths.

In DPD demonstration the TQM8M9079 PAs is being linearized.

Please, follow the steps explained below:

* The LMS1 A channel connections:
   * For LMS1 channel A TX output, use the U.FL connector TX1(J8) - the LMS1 TX1_1.
   * For channel A DPD monitoring input, the U.FL connector J4 is used. It is connected to LMS3 RX1_W input. 
   * The channel A RX input is made via U.FL connector RX1(J1), connected to LMS1 RX1_H input port.

* The LMS1 B channel connections: 
   * For LMS1 TX channel B output, the U.FL connector TX2(J9) located at the LMS1 TX2 port (the LMS1 TX2_1).
   * The U.FL connector J5 is used as channel B DPD monitoring input. It is connected to LMS3 RX2_W input.
   * The channel B RX input is U.FL connector RX2(J2), connected to LMS1 RX2_H input port.

* For DPD demonstration, for selected channel, 
   * TX output (LMS1 TX 1) is connected to RF coupler input.
   * RF coupler output is connected to Spectrum Analyser RF input.
   * RF coupler coupling output is fed to DPD monitoring input (connected to LMS3 RX W input).
   * At DPD monitoring input, at board LimeSDR-PCIe-5G side, the 10 dB RF attenuator is placed for attenuation of RF coupler coupling output. 
   * The other channel TX output can be terminated with 50 Ohms.

LMS1 DPD Software Configuration
-------------------------------

The CFR and DPD control is implemented in LimeSuiteGUI application. Follow the
steps 1 to 12: 

#. Copy the :download:`QADPDconfig.ini </doc/QADPDconfig.ini>` into the folder 
   that belongs to LimeSuiteGUI installation: ``<LimeSuite install folder>/LimeSuite/build/bin``.
#. Open a terminal in this folder.
#. Start the LimeSuiteGUI application with sudo:
   ::

     sudo ./LimeSuiteGUI
#. Make the connection with the LimeSDR-PCIe-5G board *Options* |rarr| *Connection
   settings*. Select the LimeSDR-PCIe-5G board.

#. Clocks for the LMS3 analog interfaces are provided by the onboard 
   CDCM6208 clock generator. 
   
   * Open *Modules* |rarr| *CDCM6208*. 
   * Check the LMS2 Y0 CDCM output in the *Frequency planning* box. 
     Enter frequency of 122.88 in the *Frequency requested* boxes. Click *Calculate*.
     Click *Write All* to write the new configuration into the CDCM6208 chip. Uncheck the Y0.
   * Check the LMS3 Y6 and Y7 CDCM outputs in the *Frequency planning* box. 
     Enter frequency of 61.44 in the *Frequency requested* boxes. Click *Calculate*.
     Click *Write All* to write the new configuration into the CDCM6208 chip. Uncheck the Y6 and Y7.

#. To configure RF switches and amplifiers open the window *Board related controls* 
   using *Modules* |rarr| *Board Controls*. When opened, please configure the following:

   * The LMS1 A channel settings:
      * the *LMS1 TX1_EN* is checked, the *LMS1 RWSW_TX1* selection box is set to *TX1_1* |rarr| *TX1(J8)*, *TX1DAC* should is set to value od 52000,
      * the *LMS1 RWSW_RX1* selection box should be set to option *RX1_H* |larr| *RX1(J1)*,
   
   * The LMS1 B channel:
      * the *LMS1 TX2_EN* is checked, the *LMS1 RWSW_TX2* selection box is *TX2_1* |rarr| *TX2(J9)*, *TX2DAC* should is set to value od 52000,  
      * the *LMS1 RWSW_RX2* selection box should be set to *RX2_H* |larr| *RX2(J2)*,


#. Select the LMS1 chip in the LimeSuite GUI and 
   read corresponding INI configuration file:
   
   * :download:`LMS1settings_dpd.ini </doc/LMS1settings_dpd.ini>`
#. In LimeSuiteGUI select the LMS1 chip, open the *Calibrations* tab, press buttons *Calibrate All*.

#. Select the LMS2 and LMS3 LMS7002M chips in the LimeSuiteGUI and 
   read corresponding INI configuration files:
   
   * :download:`LMS2settings_equ.ini </doc/LMS2settings_equ.ini>`
   * :download:`LMS3settings_dpd.ini </doc/LMS3settings_dpd.ini>`
  
#. Open the window *LMS1 CFR controls* through *Modules* |rarr| *LMS1 CFR, LMS3 RxTSP*.
   
   * Read the FPGA configuration file (the file with extension ``.ini2``) which contains the CFR and post-CFR FIR configuration. 
   * To do this press *Read* button and choose the file dedicated to 10MHz LTE waveform: 
   * :download:`FPGAsettings_LMS1_10MHz_LMS2_100MHz.ini2 </doc/FPGAsettings_LMS1_10MHz_LMS2_100MHz.ini2>` 
   * **check** *DPD cap.en.* 
 
#. Now, select the test waveform by *Modules* |rarr| *FPGA controls*, 
   
   * Select the LMS1 option, and, read the 10MHz LTE waveform 
   * :download:`LTE_DL_TM31_10MHZ.wfm </doc/LTE_DL_TM31_10MHZ.wfm>`
   * Press button *Custom* to start the waveform.
   * When MIMO operation is required, before pressing *Custom* button check MIMO option.

.. note:: 
   * open *Modules* |rarr| *LMS1 CFR, LMS3 RxTSP* control window

      * check LMS3 *Enable RxTSP* for both channels 
      * check *ResetN*, *LMS1 txen*, *DPD/CFR enable*, *LMS3 mon.path*
      * **check** *DPD cap.en.* 

.. note::
   In LimeSuiteGUI, for selected LMS3 chip, it is required:
   
   * SXR tab |rarr| *Enable SXR/SXT module* is checked
   * SXT tab |rarr| *Enable SXR/SXT module* is **unchecked**
   * the previous two requirements are written in ``LMS3settings_dpd.ini``

.. note::
   When it is required to modify CFR or post-FIR CFR settings, LimeSuiteGUI must be used. 
   Again, go to *Modules* |rarr| *LMS1 CFR, LMS3 RxTSP*, open *LMS1 CFR, LMS3 RxTSP*. 
   After the CFR settings are modified, save new configuration into FPGA configuration file or replace the existing file.

LMS2 Equaliser Hardware Configuration
-------------------------------------

The LMS2 is used for 5G signal transmission and implements two transceiver chains. 
The TX chain includes the CFR block, specifically optimized for 100 MHz bandwidth waveforms,
post-CFR FIR, static I/Q and DC offset correctors and Equaliser circuits. 

Please, follow the steps explained below:

* The LMS2 A channel connections:
   * For LMS2 channel A TX output, use the U.FL connector TRX1(J10) connected to LMS2 TX1_1 output.
   * The channel A RX input is the U.FL connector RX1(J11), connected to LMS2 RX1_H input port.
  
* The LMS2 B channel connections:
   * For LMS2 channel B TX output, the U.FL connector TRX2(J12), connected to the LMS2 TX2_1 port.
   * The channel B RX input is U.FL connector RX2(J13), connected to LMS2 RX2_H input port.

LMS2 Equaliser Software Configuration
-------------------------------------

Follow the steps: 

#. Open a terminal in the folder ``<LimeSuite install folder>/LimeSuite/build/bin``.
#. Start the LimeSuiteGUI application with sudo:
   ::

     sudo ./LimeSuiteGUI
#. Make the connection with the LimeSDR-PCIe-5G board *Options* |rarr| *Connection
   settings*. Select the LimeSDR-PCIe-5G board.
#. Select the right LMS7002M chip (LMS1, LMS2 or LMS3) in the LimeSuiteGUI and 
   read corresponding INI configuration files:
   
   * :download:`LMS1settings_dpd.ini </doc/LMS1settings_dpd.ini>`
   * :download:`LMS2settings_equ.ini </doc/LMS2settings_equ.ini>` 
   * :download:`LMS3settings_equ.ini </doc/LMS3settings_equ.ini>` 
   
   Three INI files are provided with this document, one for each LMS7002M IC.
#. To configure RF switches and amplifiers open the window *Board related controls* 
   using *Modules* |rarr| *Board Controls*. When opened, configure the following items:

   * The LMS2 A channel configuration:
      * the *LMS2 TX1_EN* is checked; the *LMS2 RWSW_TRX1T* selection box is *TX1_1* |rarr| *RFSW_TRX1*; the *LMS2 RWSW_TRX1* is *RFSW_TRX1T* |rarr| *TRX1(J10)*, 
      * the *LMS2 RX1_LNA* is checked; the *LMS2 RWSW_RX1C* is set to option *RX1_H* |larr| *RFSW_RX1IN(LNA)*; the *LMS2 RWSW_RX1IN* selection box is *RFSW_RX1C* |larr| *RX1(J11)*,
      * the *LMS3 RWSW1_RX1* is *RX1_H* |larr| *RX1_IN(J6)*,
   
   * The LMS2 B channel:
      * the *LMS2 TX2_EN* is checked; the *LMS2 RWSW_TRX2T* selection box is *TX2_1* |rarr| *RFSW_TRX2*; the *LMS2 RWSW_TRX2* is set to *RFSW_TRX2T* |rarr| *TRX2(J12)*, 
      * the *LMS2 RX2_LNA* is checked; the *LMS2 RWSW_RX2C* selection box is set to *RX2_H* |larr| *RFSW_RX2IN(LNA)*; the *LMS2 RWSW_RX2IN* is *RFSW_RX2C* |larr| *RX2(J13)*,
      * the *LMS3 RWSW1_RX2* box is set to *RX2_H* |larr| *RX2_IN(J7)*, 

#. Clocks for the LMS2 and LMS3 analog interfaces are provided by the onboard 
   CDCM6208 clock generator. Open *Modules* |rarr| *CDCM6208*. 
   
   * Check the Y0 CDCM outputs in the *Frequency planning* box.
     Enter frequency of 245.76 in the *Frequency requested* boxes. Click *Calculate*,
     click *Write All* to write the new configuration into the CDCM6208 chip. Uncheck the Y0.
   * Check the Y4, Y5, Y6 and Y7 CDCM outputs in the *Frequency planning* box. 
     Enter frequency of 122.88 in the *Frequency requested* boxes. Click *Calculate*.
     Click *Write All* to write the new configuration into the CDCM6208 chip. Uncheck the Y4, Y5, Y6 and Y7.
  
#. Open the window *LMS1 CFR controls* through *Modules* |rarr| *LMS1 CFR, LMS3 RxTSP*.
   Read the FPGA configuration file which contains the CFRs settings and post-CFR FIR filter configuration. To do this press 
   *Read* button and choose the file: 
   
   * :download:`FPGAsettings_LMS1_10MHz_LMS2_100MHz.ini2 </doc/FPGAsettings_LMS1_10MHz_LMS2_100MHz.ini2>` 
    
#. Open the window *LMS2 CFR controls* through *Modules* |rarr| *LMS2 CFR controls*.
   Read the same FPGA configuration file. Press *Read* button and choose the file: ``FPGAsettings_LMS1_10MHz_LMS2_100MHz.ini2``.
#. Execute the *equAPI* application to calibrate the Equaliser. Please follow the steps which can be found in the description of *equAPI* in 
   *UserGuide/Equaliser* section. 
#. When Equaliser is calibrated, go to *Modules* |rarr| *FFTviewer*, then, select the *Data reading* |rarr| *LMS2SISO, 16-bit format*. 
   Press button *Start* to start receiving data on LMS2 channel A.
#. Go to *Modules* |rarr| *FPGA controls*, then select the LMS2 option. 
   Select the waveform. Press button *Custom* to start the LMS2 channel A waveform.
   When MIMO operation is required, before pressing *Custom* button check MIMO option.

.. note:: 
   * in LimeSuiteGUI 

      * in RxTSP tab, for both LMS2 and LMS3, in both channels A and B, bypass (check the fields) all RxTSP blocks except DC corrector and DC tracking loop
      * in TxTSP tab, for both LMS2 and LMS3, in both channels A and B, bypass (check the fields) all TxTSP blocks
      * check Enable MIMO for MIMO operation
   * open Modules |rarr| *LMS1 CFR, LMS3 RxTSP* control window

      * check LMS3 *Enable RxTSP* for both channels 
      * check *ResetN*, *LMS1 txen*, *DPD/CFR enable*, *LMS3 mon.path*
      * **uncheck**  *DPD cap.en.* 
   * open Modules |rarr| LMS2 CFR controls window

      * check LMS2 *En.RxTSP*, *En.TxTSP* for both channels
      * uncheck bypasses for *RxEQU* and *TxEQU* for both channels

.. warning::
   It is not allowed to run Equaliser calibration software and FFTViewer at the 
   same time. Therefore, before starting the Equaliser calibration software, 
   please stop LMS2 waveforms and close the FFTViewer.