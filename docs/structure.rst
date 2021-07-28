.. _structure:

LimeADPD Structure
==================

Indirect Learning Architecture
------------------------------

The simplified block diagram of an indirect learning architecture is given in
Figure 1. Please note that RF part in both TX (up to PA input) neither in RX
(back to base band frequency) paths is shown for simplicity.

Delay line compensates ADPD loop *(yp(n)* to *x(n))* delay. Postdistorter is
trained to be inverse of power amplifier. Predistorter is simple copy of
postdistorter. When converged:

(n)=0, *yp(n)=y(n) => x(n)=xp(n)*,

hence, PA is linearized.

.. figure:: images/indirect-learning-architecture.png

Complex Valued Memory Polynomial
--------------------------------

LimeADPD algorithm is based on modelling nonlinear system (PA and its inverse in
this case) by complex valued memory polynomials which are in fact cut version of
Volterra series which is well known as general nonlinear system modelling and
identification approach. In this particular case “cut version ” means the system
can efficiently be implemented in real life applications.

For a given complex input:


complex valued memory polynomial produces complex output:


where:


are the polynomial coefficients while e(n) is the envelop of the input. For the
envelop calculation, two options are considered, the usual one:


and the squared one:


Usually, squared one is used in ADPD applications since it is simpler to
calculate and in most cases provides even better results.

In the above equations, *N* is memory length while *M* represents nonlinearity
order. Hence, complex valued memory polynomial can be taken into account both
system memory effects as well as the system nonlinearity.

LimeADPD Equations
------------------

Based on discussions given in previous sections and using signal notations of
Figure 1, ADPD predistorter implements the following equations:


while postdistorter does similar:


Note that predistorter and postdistorter share the same set of complex
coefficients **w**\ ij. Delay line is simple and its output is given by:


Training Algorithm
------------------

ADPD training algorithm alters complex valued memory polynomial coefficients
**w**\ ij in order to minimise the difference between PA input **yp**\ *(n)* and
**y**\ *((n)*, ignoring the delay and gain difference between the two signals.
Instantaneous error shown in Figure 1 is calculated as:


Training is based on minimising Recursive Least Square (RLS) E(n) error:


by solving linear system of equations:


Any linear equation system solving algorithm can be used. Lime ADPD involves LU
decomposition. However, iterative techniques such as Gauss – Seidel and Gradient
Descent have been evaluated as well. LU decomposition is adopted in order to get
faster adaptation and tracking of the ADPD loop.

