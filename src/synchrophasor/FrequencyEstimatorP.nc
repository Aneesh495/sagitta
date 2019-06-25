#include <math.h>
#include "sagitta_types.h"

/**
 * FrequencyEstimatorP tracks power grid frequency from the derivative
 * of unwrapped synchrophasor phase angles: f = f_0 + (1 / 2*pi) * (d_theta / dt).
 */
module FrequencyEstimatorP {
  provides {
    interface FrequencyEstimator;
  }
}
implementation {
  float m_lastPhaseRad;
  float m_estimatedFreqHz;
  bool m_initialized;

  command float FrequencyEstimator.updateFrequency(float phaseAngleRad, float dtSeconds) {
    if (dtSeconds <= 1e-5f) {
      return m_estimatedFreqHz;
    }

    if (!m_initialized) {
      m_lastPhaseRad = phaseAngleRad;
      m_estimatedFreqHz = 60.0f;
      m_initialized = TRUE;
      return m_estimatedFreqHz;
    }

    /* Phase unwrap to handle [-pi, +pi] boundary wraps */
    float deltaPhase = phaseAngleRad - m_lastPhaseRad;
    while (deltaPhase > 3.14159265f) {
      deltaPhase -= 2.0f * 3.14159265f;
    }
    while (deltaPhase < -3.14159265f) {
      deltaPhase += 2.0f * 3.14159265f;
    }
    m_lastPhaseRad = phaseAngleRad;

    /* Frequency deviation: delta_f = (1 / 2*pi) * (d_theta / dt) */
    float deltaFreq = (deltaPhase / (2.0f * 3.14159265f)) / dtSeconds;
    float instFreq = 60.0f + deltaFreq;

    /* IIR smoothing filter (alpha = 0.1) */
    m_estimatedFreqHz = 0.1f * instFreq + 0.9f * m_estimatedFreqHz;
    return m_estimatedFreqHz;
  }

  command uint32_t FrequencyEstimator.getFrequencyMilliHz() {
    return (uint32_t)(m_estimatedFreqHz * 1000.0f);
  }
}
