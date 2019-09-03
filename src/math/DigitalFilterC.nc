#include "sagitta_types.h"

/**
 * DigitalFilterC wires the suite of mathematical filters including
 * Butterworth, Chebyshev, Moving Average, Median, Kalman, and Wavelets.
 */
configuration DigitalFilterC {
  provides {
    interface DigitalFilter as Butterworth;
    interface DigitalFilter as Chebyshev;
    interface DigitalFilter as MovingAverage;
    interface DigitalFilter as Median;
    interface KalmanState;
    interface WaveletTransform;
    interface CordicTrig;
  }
}
implementation {
  components ButterworthFilterP;
  components ChebyshevFilterP;
  components MovingAverageFilterP;
  components MedianFilterP;
  components KalmanFilter3DP;
  components Daubechies4P;
  components CordicEngineP;

  Butterworth = ButterworthFilterP.Butterworth;
  Chebyshev = ChebyshevFilterP.Chebyshev;
  MovingAverage = MovingAverageFilterP.MovingAverage;
  Median = MedianFilterP.Median;
  KalmanState = KalmanFilter3DP.KalmanState;
  WaveletTransform = Daubechies4P.WaveletTransform;
  CordicTrig = CordicEngineP.CordicTrig;
}
