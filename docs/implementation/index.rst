Implementation Platform
=======================

.. toctree::
   :hidden:

   LimeSDR-PCIe-5G <limesdr-pcie-5g>
   LimeSDR-QPCIe <limesdr-qpcie>

The ADPD-I/Q and ADPD algorithms are implemented via the LimeSDR-PCIe-5G and 
LimeSDR-QPCIe boards, respectively. The CFR algorithm, which supports ADPD operation, 
is implemented via LimeSDR-PCIe-5G and LimeSDR-QPCIe also.

.. note::
   The online technical documentation for the board **LimeSDR-PCIe-5G** is available at: https://pcie5g.myriadrf.org/
   
   For the **LimeSDR-QPCIe**, documentation is available at: https://wiki.myriadrf.org/LimeSDR-QPCIe

The boards incorporate LMS7002M transceiver ICs and high-performance FPGA
chips with large resource abilities, which are used for realization of Lime algorithms. In the case of the LimeSDR-PCIe-5G board, the Xilinx XC7A200T-2FBG676C is used. The other board, the LimeSDR-QPCIe utilizes an Altera Cyclone V 5CGXFC7D7F31C8 FPGA chip.

Since the Xilinx XC7A200T-2FBG676C possesses more resources than Altera Cyclone V 5CGXFC7D7F31C8, it is possible to employ computationally more complex LimeADPD I/Q algorithm on the LimeSDR-PCIe-5G board. Due to the more limited resources, LimeADPD is realized in the earlier LimeSDR-QPCIe board.

The FPGA ICs may be used for the implementation of many other digital blocks. For example, for development and demonstration purposes test waveforms are uploaded and played from the WFM RAM Blocks implemented using FPGA resources. 

Regarding ADPD algorithm, the pre-distorter part is embedded in the FPGA. 
Initially, pre-distorter is bypassed i.e. *yp*\ :sub:`I`\ =\ *xp*\ :sub:`I`,
*yp*\ :sub:`Q`\ =\ *xp*\ :sub:`Q`\  (signals shown in the Figure 1 in case of LimeADPD and in the Figure 2 in case of LimeADPD I/Q). The boards have provision for SPI in order to update the DPD coefficients during the training process.  

The FPGA RAM blocks are used for implementation of Data Capture RAM Blocks, 
storing the data streams of signals *xp*, *yp* and *x*. Also, the FPGA implements PCIe and other glue logic required to interconnect on-board components including the LMS7002M ICs to the host CPU. Captured *xp*, *yp* and *x* data is also made available to the host CPU via PCIe interface. The host implements post-distorter block, delay line and the rest of training
algorithm. After each adaptation step, the host CPU updates pre-distorter coefficients via SPI/PCIe interface.

The CFR filter order, filter coefficients and CFR threshold are configured
through the same SPI/PCIe interface. 

The GUI running on host system implements a graphical display for debugging purposes. This GUI is capable of showing important ADPD signals in FFT (frequency), time and constellation (I vs Q) domains. 

In production applications, WFM and *xp* Capture RAM blocks are not required.
The algorithm needs only *yp* and *x* as shown in the Figure 1 (in case of LimeADPD) and in the Figure 2 (in case of LimeADPD I/Q). CPU Core
performs both ADPD adaptation and base-band (BB) digital modem functions.