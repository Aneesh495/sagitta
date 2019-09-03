#include "sagitta_types.h"

/**
 * ChebyshevFilterP implements a 2nd-order Chebyshev Type I band-pass filter
 * centered on aeolian vibration frequencies (15 Hz to 45 Hz) in Q15 format.
 */
module ChebyshevFilterP {
  provides {
    interface DigitalFilter as Chebyshev;
  }
}
implementation {
  static const int16_t B0 = 1250;
  static const int16_t B1 = 0;
  static const int16_t B2 = -1250;
  static const int16_t A1 = -48120;
  static const int16_t A2 = 28100;

  int32_t m_d1;
  int32_t m_d2;

  command void Chebyshev.resetFilter() {
    m_d1 = 0;
    m_d2 = 0;
  }

  command q15_t Chebyshev.filterSample(q15_t inputSample) {
    int32_t x = (int32_t)inputSample;
    int32_t y = ((int32_t)B0 * x + m_d1) >> 15;

    m_d1 = (int32_t)B1 * x - ((int32_t)A1 * y) + m_d2;
    m_d2 = (int32_t)B2 * x - ((int32_t)A2 * y);

    if (y > 32767) y = 32767;
    if (y < -32768) y = -32768;
    return (q15_t)y;
  }

  command void Chebyshev.filterBlock(q15_t* buffer, uint16_t count) {
    if (!buffer) return;
    for (uint16_t i = 0; i < count; i++) {
      buffer[i] = call Chebyshev.filterSample(buffer[i]);
    }
  }
}
