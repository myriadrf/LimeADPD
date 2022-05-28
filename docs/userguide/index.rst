CFR and DPD User Guide
======================

.. toctree::
   :hidden:

   CFR Configuration <cfr-config>
   DPDViewer Window<dpd-viewer>
   DPDControl Application <dpdcontrol>

Before CFR and DPD are started, the LMS7002 transceiver 
chip should be initialized and modulation waveforms started.

One option to do this is to start Amarisoft LTE stack. The other option is,
using LimeSuiteGUI application, to load LMS7002M configuration files and run
test waveforms.

In the first option, during LTE start-up procedure, LMS7002M .ini files are
automatically loaded in transceiver ICs. Also, the ``.ini2``  FPGA
configuration file is loaded, containing on-board FPGA gateware configuration,
including information regarding CFRs and post-CFR FIR orders and filter coefficients. 

In the second option, used for development or demo, test waveform is uploaded
and played from the on-board WFM RAM Blocks. The LimeSuiteGUI application is
used in this case.

Before DPD is run perform the following steps.

The first three steps are the same for the boards.

* Open the terminal in the folder which belongs to LimeSuiteGUI installation: 
   ::

     <LimeSuiteGUI installation folder>/LimeSuite/build/bin
* Start the LimeSuiteGUI application with sudo:
   ::

     sudo ./LimeSuiteGUI 
* Make the connection with the board *Options* |rarr| *Connection settings*. Find and select the board.

The others steps are different for LimeSDR-PCIe-5G and LimeSDR QPCIe boards and are given below:

.. tabs::

   .. tab:: LimeSDR-PCIe-5G

      * Select the right LMS7002M chip (LMS1, LMS2 or LMS3) in LimeSuite GUI and read the corresponding INI configuration files:
        ``LMSsettings/LMS1settings.ini`` ``LMSsettings/LMS2settings.ini`` ``LMSsettings/LMS3settings.ini``
      * In LimeSuiteGUI select the LMS1 chip, open the Calibrations tab, press buttons Calibrate Tx, Calibrate Rx for static I/Q calibration.
      * Open the CLKGEN tab, press buttons Calibrate, Tune.
      * To configure RF switches and amplifiers open the window *Board related controls* 
        using *Modules* |rarr| *Board Controls*. When opened, configure the following items. 
        The *LMS1 TX1_EN* is checked, the *LMS1 RWSW_TX1* selection box is set to option *TX1_2* |rarr| *TX1(J8)*; 
        the *TX1DAC* is set to value od 52000; the *LMS3 RWSW_RX1* selection box is set to option *RX1_H* |larr| *RX_IN(J6)*.
      * Clocks for the LMS2 and LMS3 analog interfaces are provided by the onboard CDCM6208 clock generator.
        Open *Modules* |rarr| *CDCM6208*. When opened, press *Reset* button. Check the Y6 and Y7 CDCM outputs 
        in the *Frequency planning* box. Enter frequenciy of 61.44 in the *Frequency requested* boxes. Click *Calculate*.   
        Click *Write All* to write the new configuration into the CDCM6208 chip.
      * Open the window LMS1 CFR controls window through *Modules* |rarr| *LMS1 CFR controls*. 
        Read the FPGA configuration file (with extension ``.ini2``) which contains the CFRs settings and post-CFR FIR filter configuration. 
        To do this press *Read* button and choose the file dedicated to configuration for 10MHz LTE waveform: ``FPGAsettings/FPGAsettings.ini2``. 
      * Now, select the test waveform by Modules |rarr| FPGA controls, select the LMS1 chip,
        select the 10MHz LTE waveform ``lms7suite_wfm/LTE_DL_TM31_10MHZ.wfm``. Press button *Custom* to start the waveform.
      
      .. note::
              If it is required to additionally modify CFR or post-FIR CFR settings, LimeSuiteGUI is
              used. Again, go to *Modules* |rarr| *LMS1 CFR controls*, open *LMS1 CFR controls*. 
              After the CFR settings are modified, save new configuration into FPGA
              configuration .ini2 file or replace the existing FPGA configuration ``.ini2`` file. 

   .. tab:: LimeSDR-QPCIe

      * Read the LMS7002M configuration file ``LMS1settings/LMS1settings_20_751.ini``.

      * Open the window *Board related controls* through *Modules* |rarr| *Board Controls*.
        When window is opened, read the FPGA configuration file
        which contains the CFRs settings and post-CFR FIR filter configuration. 
        To do this press *Read settings* button and choose the file dedicated to 10MHz LTE
        waveform ``FPGAsettings/FPGAsettings_10MHz.ini2``. When FPGA is initialized, 
        close the *Board related controls window*. 
      * In LimeSuiteGUI open the *Calibrations tab*, press *Calibrate Tx*, then 
        *Calibrate Rx*.
      * Now, select the test waveform by *Modules* |rarr| *FPGA controls*, then select
        the 10MHz LTE waveform ``lms7suite_wfm/LTE_DL_TM31_10MHZ.wfm``.  
        Press button *Custom* to start the waveform.

        .. note::
              If it is required to modify CFR or post-FIR CFR settings, LimeSuiteGUI must be
              used. Again, go to *Modules* |rarr| *Board controls*, open *Board controls*. 
              After the CFR settings are modified, save new configuration into FPGA
              configuration file or replace the existing FPGA configuration file.



