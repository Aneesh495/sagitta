#include <math.h>
#include "sagitta_types.h"
#include "phasor_params.h"

/**
 * DftPhasorP implements a recursive single-cycle Discrete Fourier Transform (RDFT)
 * to estimate voltage and current phasor magnitude and phase angle.
 */
module DftPhasorP {
  provides {
    interface DftPhasor;
  }
}
implementation {
  uint16_t m_n;             /* Samples per cycle (e.g., 64) */
  float m_sinTable[128];
  float m_cosTable[128];

  command error_t DftPhasor.initDft(uint16_t windowLength) {
    if (windowLength == 0 || windowLength > 128) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_n = windowLength;
    float step = 2.0f * 3.14159265f / (float)m_n;
    for (uint16_t i = 0; i < m_n; i++) {
      float angle = step * (float)i;
      m_sinTable[i] = sinf(angle);
      m_cosTable[i] = cosf(angle);
    }
    return SAGITTA_SUCCESS;
  }

  command void DftPhasor.updateRecursiveDft(
    int16_t newSample,
    int16_t oldSample,
    int32_t* realOut,
    int32_t* imagOut
  ) {
    if (!realOut || !imagOut) {
      return;
    }
    /* Recursive update: X_new = (X_old + newSample - oldSample) * e^(j*2*pi/N) */
    int32_t diff = (int32_t)newSample - (int32_t)oldSample;
    float r = (float)(*realOut + diff);
    float im = (float)(*imagOut);

    float cosStep = m_cosTable[1];
    float sinStep = m_sinTable[1];

    /* Complex rotation */
    float nextR = r * cosStep - im * sinStep;
    float nextIm = r * sinStep + im * cosStep;

    *realOut = (int32_t)nextR;
    *imagOut = (int32_t)nextIm;
  }

  command void DftPhasor.computeMagnitudeAndPhase(
    int32_t realComponent,
    int32_t imagComponent,
    float* magnitudeRmsOut,
    float* phaseAngleRadOut
  ) {
    if (!magnitudeRmsOut || !phaseAngleRadOut) {
      return;
    }
    float r = (float)realComponent;
    float im = (float)imagComponent;

    /* Peak magnitude = sqrt(2) / N * sqrt(r^2 + im^2) */
    /* RMS magnitude = peak / sqrt(2) = (1 / N) * sqrt(r^2 + im^2) */
    float norm = (m_n > 0) ? (float)m_n : 64.0f;
    *magnitudeRmsOut = sqrtf(r * r + im * im) / norm;
    *phaseAngleRadOut = atan2f(im, r);
  }
}
