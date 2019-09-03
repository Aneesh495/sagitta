#include "sagitta_types.h"

/**
 * OverVoltage59P implements ANSI 59 overvoltage protection.
 */
module OverVoltage59P {
  provides {
    interface RelayProtection as Relay59;
  }
}
implementation {
  float m_pickupVolts;
  float m_timeDelaySec;
  float m_timerSec;
  bool m_isTripped;

  command error_t Relay59.configureRelay(float pickupThreshold, float timeDial) {
    m_pickupVolts = pickupThreshold;
    m_timeDelaySec = (timeDial > 0.0f) ? timeDial : 0.5f;
    m_timerSec = 0.0f;
    m_isTripped = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay59.evaluateRelay(float measuredQuantity, float dtSeconds) {
    if (m_isTripped) return TRUE;

    if (measuredQuantity >= m_pickupVolts) {
      m_timerSec += dtSeconds;
      if (m_timerSec >= m_timeDelaySec) {
        m_isTripped = TRUE;
        uint32_t opTimeMs = (uint32_t)(m_timeDelaySec * 1000.0f);
        signal Relay59.relayTripped(59, measuredQuantity, opTimeMs);
        return TRUE;
      }
      return TRUE;
    }

    m_timerSec = 0.0f;
    return FALSE;
  }

  command void Relay59.resetRelay() {
    m_timerSec = 0.0f;
    m_isTripped = FALSE;
  }
}
