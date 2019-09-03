#include "sagitta_types.h"

/**
 * UnderVoltage27P implements ANSI 27 undervoltage protection with definite time delay.
 */
module UnderVoltage27P {
  provides {
    interface RelayProtection as Relay27;
  }
}
implementation {
  float m_pickupVolts;
  float m_timeDelaySec;
  float m_timerSec;
  bool m_isTripped;

  command error_t Relay27.configureRelay(float pickupThreshold, float timeDial) {
    m_pickupVolts = pickupThreshold;
    m_timeDelaySec = (timeDial > 0.0f) ? timeDial : 1.0f;
    m_timerSec = 0.0f;
    m_isTripped = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay27.evaluateRelay(float measuredQuantity, float dtSeconds) {
    if (m_isTripped) return TRUE;

    if (measuredQuantity < m_pickupVolts && measuredQuantity > 10.0f) {
      m_timerSec += dtSeconds;
      if (m_timerSec >= m_timeDelaySec) {
        m_isTripped = TRUE;
        uint32_t opTimeMs = (uint32_t)(m_timeDelaySec * 1000.0f);
        signal Relay27.relayTripped(27, measuredQuantity, opTimeMs);
        return TRUE;
      }
      return TRUE;
    }

    m_timerSec = 0.0f;
    return FALSE;
  }

  command void Relay27.resetRelay() {
    m_timerSec = 0.0f;
    m_isTripped = FALSE;
  }
}
