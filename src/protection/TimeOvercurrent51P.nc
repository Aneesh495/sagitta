#include <math.h>
#include "sagitta_types.h"

/**
 * TimeOvercurrent51P implements ANSI 51 inverse-time overcurrent protection
 * using IEEE standard moderately inverse, very inverse, and extremely inverse curves.
 */
module TimeOvercurrent51P {
  provides {
    interface RelayProtection as Relay51;
  }
}
implementation {
  float m_pickupA;
  float m_timeDial;
  float m_tripAccumulator;
  bool m_isTripped;

  /* IEEE Standard Very Inverse Curve Constants: t = [A / ((I/Is)^p - 1) + B] * TD */
  static const float CURVE_A = 19.61f;
  static const float CURVE_B = 0.491f;
  static const float CURVE_P = 2.0f;

  command error_t Relay51.configureRelay(float pickupThreshold, float timeDial) {
    if (pickupThreshold <= 0.0f || timeDial <= 0.0f) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_pickupA = pickupThreshold;
    m_timeDial = timeDial;
    m_tripAccumulator = 0.0f;
    m_isTripped = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay51.evaluateRelay(float measuredQuantity, float dtSeconds) {
    if (m_isTripped) return TRUE;

    if (measuredQuantity <= m_pickupA) {
      /* Reset integration when current drops below pickup */
      if (m_tripAccumulator > 0.0f) {
        m_tripAccumulator -= dtSeconds * 2.0f;
        if (m_tripAccumulator < 0.0f) m_tripAccumulator = 0.0f;
      }
      return FALSE;
    }

    /* M = I / I_pickup */
    float m = measuredQuantity / m_pickupA;
    float denom = powf(m, CURVE_P) - 1.0f;
    if (denom <= 0.001f) denom = 0.001f;

    /* Operating trip time in seconds */
    float tTripSec = (CURVE_A / denom + CURVE_B) * m_timeDial;
    if (tTripSec < 0.02f) tTripSec = 0.02f;

    /* Integrate: deltaAccum = dt / tTrip */
    m_tripAccumulator += dtSeconds / tTripSec;

    if (m_tripAccumulator >= 1.0f) {
      m_isTripped = TRUE;
      uint32_t opTimeMs = (uint32_t)(tTripSec * 1000.0f);
      signal Relay51.relayTripped(51, measuredQuantity, opTimeMs);
      return TRUE;
    }

    return TRUE; /* Picked up, integrating toward trip */
  }

  command void Relay51.resetRelay() {
    m_tripAccumulator = 0.0f;
    m_isTripped = FALSE;
  }
}
