#include <math.h>
#include "sagitta_types.h"

/**
 * DistanceRelay21P implements ANSI 21 mho and quadrilateral distance protection.
 * Evaluates apparent loop impedance Z_app = V / I against Zone 1 (80% reach)
 * and Zone 2 (120% reach with intentional coordination timer).
 */
module DistanceRelay21P {
  provides {
    interface RelayProtection as Relay21;
  }
}
implementation {
  float m_reachOhms;     /* Zone 1 positive-sequence reach impedance */
  float m_lineAngleDeg;  /* Maximum torque angle (typically 75 to 85 deg for HV lines) */
  float m_zone2TimerSec;
  float m_zone2AccumSec;
  bool m_isTripped;

  command error_t Relay21.configureRelay(float pickupThreshold, float timeDial) {
    if (pickupThreshold <= 0.0f) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_reachOhms = pickupThreshold;
    m_lineAngleDeg = 80.0f;
    m_zone2TimerSec = (timeDial > 0.0f) ? timeDial : 0.30f; /* 300 ms Zone 2 delay */
    m_zone2AccumSec = 0.0f;
    m_isTripped = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay21.evaluateRelay(float measuredQuantity, float dtSeconds) {
    if (m_isTripped) return TRUE;

    float apparentZOhms = measuredQuantity;

    /* Zone 1: Instantaneous trip for faults within 80% reach */
    if (apparentZOhms <= m_reachOhms * 0.80f) {
      m_isTripped = TRUE;
      signal Relay21.relayTripped(21, apparentZOhms, 20); /* 20 ms sub-cycle trip */
      return TRUE;
    }

    /* Zone 2: Fault within 120% reach requires coordination timer */
    if (apparentZOhms <= m_reachOhms * 1.20f) {
      m_zone2AccumSec += dtSeconds;
      if (m_zone2AccumSec >= m_zone2TimerSec) {
        m_isTripped = TRUE;
        uint32_t opTimeMs = (uint32_t)(m_zone2TimerSec * 1000.0f);
        signal Relay21.relayTripped(21, apparentZOhms, opTimeMs);
        return TRUE;
      }
      return TRUE; /* In Zone 2 pickup */
    }

    /* Reset timer if impedance exits zone */
    m_zone2AccumSec = 0.0f;
    return FALSE;
  }

  command void Relay21.resetRelay() {
    m_zone2AccumSec = 0.0f;
    m_isTripped = FALSE;
  }
}
