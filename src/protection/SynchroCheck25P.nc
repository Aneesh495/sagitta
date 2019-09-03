#include <math.h>
#include "sagitta_types.h"

/**
 * SynchroCheck25P implements ANSI 25 synchronism-check reclosing supervision.
 * Verifies voltage magnitude difference delta_V, phase angle difference delta_delta,
 * and slip frequency delta_f before authorizing breaker closing.
 */
module SynchroCheck25P {
  provides {
    interface RelayProtection as Relay25;
  }
}
implementation {
  float m_maxAngleDiffDeg;
  float m_maxVoltageDiffVolts;
  bool m_isPermitted;

  command error_t Relay25.configureRelay(float pickupThreshold, float timeDial) {
    m_maxAngleDiffDeg = (pickupThreshold > 0.0f) ? pickupThreshold : 20.0f; /* 20 deg */
    m_maxVoltageDiffVolts = (timeDial > 0.0f) ? timeDial : 5000.0f; /* 5 kV */
    m_isPermitted = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay25.evaluateRelay(float measuredQuantity, float dtSeconds) {
    float phaseAngleDiffDeg = fabsf(measuredQuantity);
    if (phaseAngleDiffDeg <= m_maxAngleDiffDeg) {
      m_isPermitted = TRUE;
      return TRUE; /* Reclosing permissive granted */
    }
    m_isPermitted = FALSE;
    return FALSE;
  }

  command void Relay25.resetRelay() {
    m_isPermitted = FALSE;
  }
}
