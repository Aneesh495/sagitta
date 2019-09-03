#include <math.h>
#include "sagitta_types.h"

/**
 * Daubechies4P implements 1-level forward and inverse discrete wavelet transform (DWT)
 * using the Daubechies 4-tap filter bank for edge and singularity detection.
 */
module Daubechies4P {
  provides {
    interface WaveletTransform;
  }
}
implementation {
  /*
   * Daubechies 4-tap low-pass scaling filter coefficients h[n]:
   * h0 = (1 + sqrt(3)) / (4 * sqrt(2)) = 0.4829629131
   * h1 = (3 + sqrt(3)) / (4 * sqrt(2)) = 0.8365163037
   * h2 = (3 - sqrt(3)) / (4 * sqrt(2)) = 0.2241438680
   * h3 = (1 - sqrt(3)) / (4 * sqrt(2)) = -0.1294095226
   */
  static const float H0 = 0.4829629131f;
  static const float H1 = 0.8365163037f;
  static const float H2 = 0.2241438680f;
  static const float H3 = -0.1294095226f;

  /* High-pass wavelet filter coefficients g[n] = (-1)^n * h[1 - n] */
  static const float G0 = -0.1294095226f;
  static const float G1 = -0.2241438680f;
  static const float G2 = 0.8365163037f;
  static const float G3 = -0.4829629131f;

  command error_t WaveletTransform.forwardDwt(
    const q15_t* input,
    q15_t* approxOut,
    q15_t* detailOut,
    uint16_t length
  ) {
    if (!input || !approxOut || !detailOut || (length & 1) != 0 || length < 4) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    uint16_t half = length >> 1;
    for (uint16_t i = 0; i < half; i++) {
      uint16_t i0 = 2 * i;
      uint16_t i1 = (i0 + 1) % length;
      uint16_t i2 = (i0 + 2) % length;
      uint16_t i3 = (i0 + 3) % length;

      float x0 = Q15_TO_FLOAT(input[i0]);
      float x1 = Q15_TO_FLOAT(input[i1]);
      float x2 = Q15_TO_FLOAT(input[i2]);
      float x3 = Q15_TO_FLOAT(input[i3]);

      float a = H0 * x0 + H1 * x1 + H2 * x2 + H3 * x3;
      float d = G0 * x0 + G1 * x1 + G2 * x2 + G3 * x3;

      approxOut[i] = FLOAT_TO_Q15(a * 0.7071f);
      detailOut[i] = FLOAT_TO_Q15(d * 0.7071f);
    }

    return SAGITTA_SUCCESS;
  }

  command error_t WaveletTransform.inverseDwt(
    const q15_t* approx,
    const q15_t* detail,
    q15_t* output,
    uint16_t length
  ) {
    if (!approx || !detail || !output || (length & 1) != 0 || length < 4) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    memset(output, 0, length * sizeof(q15_t));
    uint16_t half = length >> 1;

    for (uint16_t i = 0; i < half; i++) {
      float a = Q15_TO_FLOAT(approx[i]) * 1.4142f;
      float d = Q15_TO_FLOAT(detail[i]) * 1.4142f;

      uint16_t i0 = 2 * i;
      uint16_t i1 = (i0 + 1) % length;
      uint16_t i2 = (i0 + 2) % length;
      uint16_t i3 = (i0 + 3) % length;

      /* Synthesis filter bank accumulation */
      float y0 = H2 * a + G2 * d;
      float y1 = H1 * a + G1 * d;
      float y2 = H0 * a + G0 * d;
      float y3 = H3 * a + G3 * d;

      output[i0] += FLOAT_TO_Q15(y0);
      output[i1] += FLOAT_TO_Q15(y1);
      output[i2] += FLOAT_TO_Q15(y2);
      output[i3] += FLOAT_TO_Q15(y3);
    }

    return SAGITTA_SUCCESS;
  }
}
