#include "sagitta_types.h"

/**
 * InstantaneousOvercurrent50P implements ANSI 50 instantaneous overcurrent protection.
 * Trips unconditionally without intentional time delay when RMS current exceeds pickup.
 */
module InstantaneousOvercurrent50P {
  provides {
    interface RelayProtection as Relay50;
  }
}
implementation {
  float m_pickupA;
  bool m_isTripped;

  command error_t Relay50.configureRelay(float pickupThreshold, float timeDial) {
    if (pickupThreshold <= 0.0f) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_pickupA = pickupThreshold;
    m_isTripped = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay50.evaluateRelay(float measuredQuantity, float dtSeconds) {
    if (measuredQuantity >= m_pickupA && !m_isTripped) {
      m_isTripped = TRUE;
      /* Sub-cycle trip: ~16 ms at 60 Hz */
      signal Relay50.relayTripped(50, measuredQuantity, 16);
      return TRUE;
    }
    return FALSE;
  }

  command void Relay50.resetRelay() {
    m_isTripped = FALSE;
  }
}
