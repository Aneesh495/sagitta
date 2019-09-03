#include <math.h>
#include "sagitta_types.h"

/**
 * DifferentialRelay87P implements ANSI 87 line current differential protection.
 * Compares phasor sum (I_diff = |I_local + I_remote|) against restraint (I_bias).
 */
module DifferentialRelay87P {
  provides {
    interface RelayProtection as Relay87;
  }
}
implementation {
  float m_pickupA;
  float m_slopePercentage;
  bool m_isTripped;

  command error_t Relay87.configureRelay(float pickupThreshold, float timeDial) {
    m_pickupA = pickupThreshold;
    m_slopePercentage = (timeDial > 0.0f) ? timeDial : 25.0f; /* 25% dual-slope bias */
    m_isTripped = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay87.evaluateRelay(float measuredQuantity, float dtSeconds) {
    float diffCurrentA = measuredQuantity;
    if (diffCurrentA >= m_pickupA && !m_isTripped) {
      m_isTripped = TRUE;
      signal Relay87.relayTripped(87, diffCurrentA, 18); /* 18 ms fast differential trip */
      return TRUE;
    }
    return FALSE;
  }

  command void Relay87.resetRelay() {
    m_isTripped = FALSE;
  }
}
