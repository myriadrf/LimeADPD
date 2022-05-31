Conclusion
==========

LimeADPD
--------

The LimeADPD algorithm has been implemented, verified by measured results and is capable of cancelling any distortion above system noise floor, 
DACs |rarr| TX |rarr| PA |rarr| Coupler |rarr| RX |rarr| ADCs. 

Improvements in ACPR and EVM have been achieved in all cases as shown in Table
11.

.. table:: Table 11: DPD results summary.

   +-------------+----------+------+-----+------------------+------------------+
   |Configuration|Modulation|Psat  |Fc   |ACPR (dBc)        | EVM (%)          |
   |             |          |      |     +--------+---------+--------+---------+
   |             |          |(dbM) |(GHz)|No ADPD |With ADPD|No ADPD |With ADPD|
   +=============+==========+======+=====+========+=========+========+=========+
   | **Case 1**  |10MHz LTE | 19   |0.751| -40.2  | -51.8   | 3.2    | 2.2     |
   +-------------+----------+------+-----+--------+---------+--------+---------+
   | **Case 2**  |20MHz LTE | 19   |0.751| -40.3  | -49.6   | 3.6    | 2.2     |
   +-------------+----------+------+-----+--------+---------+--------+---------+
   | **Case 3**  |10MHz LTE | 39   |0.75 | -37.5* | -50.5*  | 3.3    | 2.4     |
   +-------------+----------+------+-----+--------+---------+--------+---------+
      
Compared to the original Peak Windowing (PW) algorithm, time-multiplexing is implemented, reducing the number of utilized multipliers. The CFR block operates
at 122.88 MHz, while data sample rate is 30.72 MS/s. 

The architecture of CFR FIR filter is further optimized, having in mind that
PWFIR coefficients are symmetrical. This reduces the number of multiplication
operations, and consequentially, the number of used FPGA DSP blocks. FPGA
resources are saved in this way leaving the room for some other DSP blocks to be
added, DPD for example.

The novelty not seen in the published literature so far is Peak search block
which is introduced in CFR preprocessing stage to find local minimum values of
the signal *c(n)*. Compared to the original PW, the difference between local
minimum values of the gain correction *b(n)* and the clipping signal *c(n)* is
minimized. With this circuit, the peaks of the output signal envelope are more
accurately constrained to the threshold *Th*, resulting in lower EVM degradation.

Another important novelty here is utilization of the interpolation and
decimation blocks. These are placed in front of and after the CFR block
respectively. Interpolation and decimation helps in getting better EVM results
for the wider modulation formats (15MHz and 20MHz LTE, for example). In other
words, this approach helps the cases when the modulation edge approaches the
Nyquist frequency. With this option enabled the clipping operation becomes more
precise, since peaks are better seen. Adding interpolation/decimation required
some modifications in FIR filter architecture and also in the method of
coefficients programming.

PAPR increased as the modulation bandwidth becomes wider. A real LTE stack
signal has a higher PAPR than the test model one. Both facts are well known and
expected. Due to higher PAPR, the digital gain of LTE stack is backed off by 3 dB so as to avoid digital overload. Consequently, CFR threshold *Th* is changed from 0.75 to 0.66.

Interpolation/decimation makes CFR algorithm almost insensitive to the
modulation bandwidth. 

If we take 20 MHz real life LTE stack test as the target and the most
challenging case, we can say that the CFR block reduced PAPR from 11.2 dB down to 8.42 dB, while degrading EVM from 0.6% to 2.3%. In other words, PAPR is reduced by 2.78 dB while EVM is degraded by only 1.7%.

ACPR is not affected at all, neither by BB modem nor CFR algorithm, thanks to
digital filtering implemented by FIR blocks.

PA linearization results achieved by LimeADPD I/Q are comparable with the LimeADPD method. It is worth mentioning that beside pre-distorter, the other digital blocks are also required in transmitter paths, such as CFR and post-CFR FIR filters.

The real benefit of using LimeADPD I/Q is that the method, besides efficient PA linearization, provides RF transmitter I/Q imbalance mitigation. The nonlinearities of the PA and I/Q modulator are minimized by non-conjugate DPD block. The FIR filter, implementing linear I/Q corrector, compensates the I/Q imbalance specifically. Another advantage of using LimeADPD I/Q is that the transceiver's static I/Q calibration procedure is not required. 

LimeADPD I/Q
------------

The LimeADPD I/Q algorithm provides low complexity in terms of reduced number of complex-valued coefficients. This is achieved by several solutions and firstly, by choosing the even order terms form for envelope function. 
The architecture is further simplified by selecting the FIR length *N*\ :sub:`2`\  equal to the memory length *N*\ :sub:`1`\. The utilization of FIR block for I/Q corrector realization additionally reduces the number of coefficients. 

The total number of complex-valued coefficients of pre-distorter implemented in LimeSDR-PCIe-5G is (*N*\ :sub:`1`\+1)×(*M*\ :sub:`1`\ +2) = (4+1)×(3+2) = 25. 
Decreased number of coefficients provides more savings of FPGA resources. 

Measurement results demonstrate LimeADPD I/Q capabilities:

* The I/Q related imbalance images are suppressed almost down to the noise floor without sacrificing the PA output power. 
* Although the provided results consider the test cases where the I/Q imbalance effects are present at negative image frequencies, LimeADPD I/Q also provides satisfactory results if I/Q imbalance images are present at positive frequencies. 
  
The performance was analyzed using multi-tone signals and LTE type of waveforms.