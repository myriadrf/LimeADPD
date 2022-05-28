Implementation Platform
=======================

.. toctree::
   :hidden:

   LimeSDR-PCIe-5G <limesdr-pcie-5g>
   LimeSDR-QPCIe <limesdr-qpcie>

The Lime's ADPD-I/Q and ADPD algorithms were implemented in LimeSDR-PCIe-5G and 
LimeSDR-QPCIe boards, respectively. The CFR algorithm, which supports the LimeADPD operation, 
is implemented on the boards, also.

The boards incorporate LMS7002M transceiver ICs and 
high-performance FPGA chips with large resource abilities, which are used 
for realization of Lime algorithms. In case of LimeSDR-PCIe-5G board, 
the Xilinx XC7A200T-2FBG676C is used. The other board, 
the LimeSDR-QPCIe utilizes an Altera Cyclone V 5CGXFC7D7F31C8 FPGA chip.

Since the Xilinx XC7A200T-2FBG676C possesses more resources than Altera Cyclone V 5CGXFC7D7F31C8,
and, it was possible to employ computationally more complex LimeADPD I/Q algorithm on 
the LimeSDR-PCIe-5G board. Because of limited resources, the LimeADPD is realized in
LimeSDR-QPCIe board.

The FPGA ICs are used for realization many other 
digital blocks. For example, for the development or demonstration purposes, 
test waveforms are uploaded and played from the WFM RAM Blocks implemented 
using FPGA resources. 

Regarding ADPD algorithm, the pre-distorter part is embedded in the FPGA. 
Initially, pre-distorter is bypassed i.e. *yp*\ :sub:`I`\ =\ *xp*\ :sub:`I`,
*yp*\ :sub:`Q`\ =\ *xp*\ :sub:`Q`. The boards have provision for SPI in order to update the
DPD coefficients during the training process.  

The FPGA RAM blocks are used for implementation of Data Capture RAM Blocks, 
storing the data streams of signals *xp*, *yp* and *x*.
Also, the FPGA implements PCIe and other glue logic required to interconnect
on-board components including the LMS7002M ICs to the CPU Core. 
later, captured *xp*, *yp* and *x* data is made available to CPU (Intel Motherboard) Core via PCIe
interface. The CPU implements post-distorter block, delay line and the rest of training
algorithm. After each adaptation step, CPU updates pre-distorter coefficients via
SPI/PCIe interface.

The CFR filter order, filter coefficients and CFR threshold are configured
through the same SPI/PCIe interface. 

PC/GUI running on CPU core implements graphical display for debugging purposes. GUI is
capable of showing important ADPD signals in FFT (frequency), time and
constellation (I vs Q) domains. 

In the real applications, WFM and *xp* Capture RAM blocks are not required.
The algorithm needs only *yp* and *x* as shown in the Figure x. CPU Core
performs both ADPD adaptation and base-band (BB) digital modem functions.
