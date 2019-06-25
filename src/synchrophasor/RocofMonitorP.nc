#include <math.h>
#include "sagitta_types.h"

/**
 * RocofMonitorP monitors Rate of Change of Frequency (ROCOF)
 * across moving finite-difference windows for grid disturbance detection.
 */
module RocofMonitorP {
  provides {
    interface RocofMonitor;
  }
}
implementation {
  float m_lastFreqHz;
  uint32_t m_lastTimestampUs;
  float m_currentRocof;
  bool m_initialized;

  command float RocofMonitor.updateRocof(float currentFrequencyHz, uint32_t timestampUs) {
    if (!m_initialized) {
      m_lastFreqHz = currentFrequencyHz;
      m_lastTimestampUs = timestampUs;
      m_currentRocof = 0.0f;
      m_initialized = TRUE;
      return 0.0f;
    }

    uint32_t dtUs = timestampUs - m_lastTimestampUs;
    if (dtUs == 0) {
      return m_currentRocof;
    }

    float dtSec = (float)dtUs * 1e-6f;
    float instRocof = (currentFrequencyHz - m_lastFreqHz) / dtSec;

    m_lastFreqHz = currentFrequencyHz;
    m_lastTimestampUs = timestampUs;

    /* IIR filter to damp high-frequency noise spikes */
    m_currentRocof = 0.2f * instRocof + 0.8f * m_currentRocof;

    /* Check alarm trigger (|ROCOF| > 0.5 Hz/s is typical trip threshold) */
    if (fabsf(m_currentRocof) >= 1.0f) {
      signal RocofMonitor.rocofThresholdExceeded(m_currentRocof, ALARM_LEVEL_CRITICAL);
    } else if (fabsf(m_currentRocof) >= 0.5f) {
      signal RocofMonitor.rocofThresholdExceeded(m_currentRocof, ALARM_LEVEL_WARNING);
    }

    return m_currentRocof;
  }
}
