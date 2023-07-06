.. Lime Equaliser - The I/Q Imbalance Correction and Gain Flattening
.. =====================================================================

Lime Equaliser 
==============

Mathematical Background of the Equaliser Design Procedure
---------------------------------------------------------

In order to design FIR filter as an equalizer let us first define its desired frequency response. 
First step is actually to measure gain, IQ gain error and IQ phase error as below

.. math:: g_m(x_i),g_{err}(x_i), \phi_{err}(x_i), i=1,2,...,N_m

where N\ :sub:`m`\  is the number of frequency points we have chosen to measure at, while x is normalised frequency:

.. math:: x=\frac{f}{f_{clk}}

f\ :sub:`clk`\  being the clock frequency the equaliser is going to operate at. 
N\ :sub:`m`\  is minimised in order to speed up the equaliser design procedure. 

We define the IQ gain and phase errors as below:

.. math:: g_{err}(x)= \frac{g_Q(x)}{g_I(x)}
.. math:: \phi_{err}(x)= \phi_Q(x)-\phi_I(x)-\pi/2, i=1,2,...,N

If g\ :sub:`err`\(x)=1 and :math:`{\phi}`\ :sub:`err`\(x)=0, at least in the pass-band of interest, 
then there is no issue with IQ imbalance. This is never the case. However, 
for narrow-band modulations, the IQ imbalance could be tolerated or at least considered as frequency independent. 

In case of 5G NR, where modulation bandwidth is +/-50MHz in baseband, 100MHz in RF, 
neither static nor dynamic IQ imbalance can be ignored. 
Hence, there is the need for the equaliser which should take care of both IQ imbalance components.

Based on measured data, next step forward is to build mathematical models of the gain g\ :sub:`a`\(x), the
IQ gain error g\ :sub:`erra`\(x) and IQ phase error :math:`{\phi}`\ :sub:`erra`\(x). 

..  We use the following polynomial approximations:

.. .. math:: g_a(x)=a_g[0] + a_g[1]x^2 + a_g[2]x^4

.. .. math:: g_{erra}(x)=a_{errg}[0] + a_{errg}[1]x^2 + a_{errg}[2]x^4

.. .. math:: \phi_{erra}(x)=a_{errp}[0] + a_{errp}[1]x + a_{errp}[2]x^3

..  Polynomial coefficients in the above equations are determined by minimising 
.. mean square error (MSE) between measured data and the approximating polynomial at measured frequency points. 
.. As it can be seen from equations above, each polynomial has three unknown coefficients. 
.. Hence, minimum measured points is N\ :sub:`m`\=3. We used N\ :sub:`m`\=6. 
.. In other words, looking at baseband frequencies, +/-f\ :sub:`0`\, +/-f\ :sub:`mid`\, +/-f\ :sub:`p`\  are chosen, 
.. where f\ :sub:`0`\  is close to DC, f\ :sub:`p`\  is the equaliser passband equal to 50 MHz while f\ :sub:`mid`\  is in the middle.
.. In RF f\ :sub:`0`\, f\ :sub:`mid`\, f\ :sub:`p`\  are in fact test tone offsets from LO frequency.

.. Any circuit with real valued components has positive symmetrical amplitude 
.. and negative symmetrical phase response around DC. That is the reason why g\ :sub:`a`\(x) and g\ :sub:`erra`\(x) 
.. use even orders while :math:`{\phi}`\ :sub:`erra`\(x) uses odd orders only polynomials 
.. which inherently provide above-mentioned property. 
.. This symmetry however is not guaranteed in RF due to the need to measure both sides around DC 
.. (around LO in RF) in order to equalise both sides to the same extent. 

Transmit chain equalisation is performed using two FIR filters,
placed inside I and Q branches, respectively. 

.. Using polynomial approximation their desired gain,
.. i.e. amplitude response, are given as:

.. .. math:: g_{dI}(x)= \frac{1}{g_a(x)}
.. .. math:: g_{dQ}(x)= \frac{g_{erra}(x)}{g_a(x)}

Both gain functions contain inverse of g\ :sub:`a`\(x) to equalise (flatten) the channel 
gain, while EQUQ also corrects the IQ gain error. 
On the other hand, phase error is corrected by EQUI. 
Hence, desired phase responses are defined as:   

.. .. math:: \phi_{dI}(x)= a_{errp}[1]x + a_{errp}[2]x^3
.. .. math:: \phi_{dQ}(x)= 0

a\ :sub:`errg`\[0] and a\ :sub:`errp`\[0] are in fact the static IQ gain and phase errors.
While static gain error is taken into account, static phase error is implemented by 
static phase correction block.

Equations for desired gain and phase responses show that IQ imbalance correction is split 
into two available filters. Gain error is corrected by EQUQ while phase error is corrected by EQUI. 
This is done on purpose to relax the specification of the filters and consequently to
reduce required number of filtering taps.

Having in mind equations for desired phase response, 
desired normalised group delays of the equaliser filters can be calculated as:

.. .. math:: \tau_{dI}(x)= - \frac{1}{T_{clk}} \frac{d \phi_{dI}(x)}{dx} \frac{dx}{d \omega}

.. In order to design equaliser FIR filters, the same numerical optimization procedure is executed
.. twice. Once with desired amplitude and group delay for EQUI:

 .. .. math:: A_d(x)=g_{dI}(x)
 .. .. math:: \tau_{d}(x)= \tau_{dI}(x)

.. and once more for EQUQ:

 .. .. math:: A_d(x)=g_{dQ}(x)
 .. .. math:: \tau_{d}(x)= \tau_{dQ}(x)


.. The advantage of using polynomial approximation rather than measured results is obvious. 
.. We can improve the process of equaliser coefficients calculation by calculating 
.. more points of the desired amplitude and group delay responses without actually measuring them. 
.. This saves a lot of time.

.. The Amplitude Response, Phase Response and Group Delay of FIR Filter
.. -------------------------------------------------------------------- 

.. Let us assume that the equaliser is implemented as N tap FIR filter. 
.. If its transfer function is given by:

.. .. math:: H(z)=\sum_{k=0}^{N-1} h(k) z^{-k}

.. then, the frequency response of the filter has the form:

.. .. math:: H(e^{j2\pi x})= Re(x)-jIm(x)

.. where real and imaginary parts of previous equation are calculated as:

.. .. math:: Re(x)=\sum_{k=0}^{N-1} h(k) cos(2\pi kx)
.. .. math:: Im(x)=\sum_{k=0}^{N-1} h(k) sin(2\pi kx)

.. The amplitude and phase of the complex function are then:

.. .. math:: A(x)=|H(e^{j2\pi x})|= \sqrt{Re(x)^2+Im(x)^2}
.. .. math:: \phi (x)=arg  H(e^{j2\pi x})= -arctan \frac{Im(x)}{Re(x)}

.. Therefore, from last equations, the group delay can be calculated as below:

.. .. math:: \tau'(x)= - \frac{d \phi(x)}{dx} \frac{dx}{d \omega}
.. .. math:: \tau'(x)= \frac{1}{f_{clk}} \frac{Re(x)Re_k(x)+Im(x)Im_k(x)}{A(x)^2}


.. .. math:: Re_k(x)=\sum_{k=0}^{N-1} k h(k) cos(2\pi kx)
.. .. math:: Im_k(x)=\sum_{k=0}^{N-1} k h(k) sin(2\pi kx)

.. Finally, the normalised group delay is given as:

.. .. math:: \tau(x)= \frac{ \tau'(x)}{T_{clk}} = \frac{Re(x)Re_k(x)+Im(x)Im_k(x)}{A(x)^2}

..  EQUI and EQUQ equalising FIR filter coefficients are designed complying two constraints:
.. 
..   * FIR amplitude response A(x) should approximate desired functions g\ :sub:`dI`\(x) for EQUI or g\ :sub:`dQ`\(x) for EQUQ,
..   * the FIR group delay :math:`{\tau}`\(x) should be as close as possible to desired functions given in
..     the equations for :math:`{\tau}`\ :sub:`dI`\(x) for EQUI or :math:`{\tau}`\ :sub:`dQ`\(x) or EQUQ.