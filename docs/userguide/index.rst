LimeDSP User Guides
===================

.. toctree::
   :hidden:

   CFR Configuration <cfr-config>
   DPDViewer Window <dpd-viewer>
   DPDControl Application <dpdcontrol>
   Equaliser Application <equapi>

Before CFR and DPD are started, the LMS7002 transceiver chip should be initialized and modulation waveforms started.

One option is to start the Amarisoft LTE stack, while the other option is to
use LimeSuiteGUI to load LMS7002M configuration files and run test waveforms.

In the first option, during LTE start-up procedure, LMS7002M .ini files are
automatically loaded in transceiver ICs. Additionally, the ``.ini2``  FPGA
configuration file is loaded, containing on-board FPGA gateware configuration,
including information regarding CFRs and post-CFR FIR orders and filter coefficients. 

In the second option, used for development and demonstration, a test waveform is uploaded 
and played from the on-board WFM RAM Blocks. The LimeSuiteGUI application is used in this case.

Before DPD, CFR & Equaliser are run please perform the steps 
that are described in Board Configuration Guide section.