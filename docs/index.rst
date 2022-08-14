.. toctree::
   :maxdepth: 2
   :hidden:

   Introduction <self>
   dsp/index
   implementation/index
   programming/index
   limesuite/index
   configuration/index
   userguide/index
   results/index
   conclusion

LimeDSP Algorithms
==================

.. figure:: images/spectrum.png

Power amplifiers (PA) are nonlinear devices and their linearization is highly
desired for a number of reasons. In case of RF PAs, linearization improves power
efficiency and subsequently reduces running cost of the wireless infrastructure.

Considering the PA performance for a given air interface, ACPR and  EVM are the
key considerations to provide support for sophisticated modulation schemes,
multicarrier signals and high modulation bandwidths.

Here, we present Lime Microsystems solution for PA linearization based on
adaptive digital predistortion (ADPD) and crest factor reduction (CFR).

In case of 5G NR where modulation bandwidth is +/-50MHz in baseband, 100MHz in RF, 
neither static (Frequency Independent) nor dynamic (Frequency Dependent) IQ imbalance can be ignored.
Moreover, the I/Q imbalance and gain error problems arise as target Local Oscillator (LO) frequency increases.

The Lime Equaliser compensates the receiver and transmitter static
as well as dynamic in-phase/quadrature (I/Q) imbalance. 
Besides, it addresses the frequency dependence of receiver and transmitter gain, 
which is not a constant value at different baseband frequencies. 

