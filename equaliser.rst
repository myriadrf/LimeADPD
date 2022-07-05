I/Q Imbalance Correction and Gain Flattening Equaliser
======================================================

Mathematical Background of the Equaliser Design Procedure
---------------------------------------------------------

In order to design FIR filter as an equalizer let us first define its desired frequency response. 
First step is actually to measure gain, IQ gain error and IQ phase error as below

.. math:: g_m(x_i),g_err(x_i), phi_err(x_i), i=1,2,...,N

where N_m is the number of frequency points we have chosen to measure at while x is normalised frequency:

.. math:: x=f/f_clk, 

f_clk being the clock frequency equaliser is going to operate at. 
N_m is minimised in order to speed up the equaliser design procedure and no test equipment is used. 
Instead, measurement is done using LM7#3 on board chip enabling us to tune the equaliser 
at power up.

In this work we define IQ gain and phase errors as below:

.. math:: g_err(x)= \frac{g_Q(x)}{g_I(x)}
.. math:: phi_err(x)= \phi_Q(x)-\phi_I(x)-pi/2, i=1,2,...,N
