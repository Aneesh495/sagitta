#include "sagitta_types.h"

/**
 * ButterworthFilterP implements a 2nd-order Direct Form II Transposed IIR
 * Butterworth low-pass filter (cutoff fc = 10 Hz at Fs = 256 Hz) in Q15 format.
 */
module ButterworthFilterP {
  provides {
    interface DigitalFilter as Butterworth;
  }
}
implementation {
  /*
   * Normalized coefficients for 2nd order Butterworth LPF (fc = 10 Hz, Fs = 256 Hz)
   * Scaled to Q15 (multiplied by 32768)
   */
  static const int16_t B0 = 432;
  static const int16_t B1 = 864;
  static const int16_t B2 = 432;
  static const int16_t A1 = -56248; /* Scaled -1.7165 */
  static const int16_t A2 = 24712;  /* Scaled +0.7541 */

  int32_t m_d1;
  int32_t m_d2;

  command void Butterworth.resetFilter() {
    m_d1 = 0;
    m_d2 = 0;
  }

  command q15_t Butterworth.filterSample(q15_t inputSample) {
    int32_t x = (int32_t)inputSample;

    /* Direct Form II Transposed:
     * y[n] = b0 * x[n] + d1[n-1]
     * d1[n] = b1 * x[n] - a1 * y[n] + d2[n-1]
     * d2[n] = b2 * x[n] - a2 * y[n]
     */
    int32_t y = ((int32_t)B0 * x + m_d1) >> 15;

    m_d1 = (int32_t)B1 * x - ((int32_t)A1 * y) + m_d2;
    m_d2 = (int32_t)B2 * x - ((int32_t)A2 * y);

    if (y > 32767) y = 32767;
    if (y < -32768) y = -32768;
    return (q15_t)y;
  }

  command void Butterworth.filterBlock(q15_t* buffer, uint16_t count) {
    if (!buffer) return;
    for (uint16_t i = 0; i < count; i++) {
      buffer[i] = call Butterworth.filterSample(buffer[i]);
    }
  }
}
