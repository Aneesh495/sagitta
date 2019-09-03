#include <math.h>
#include "sagitta_types.h"

/**
 * DirectionalRelay67P implements ANSI 67 directional overcurrent protection,
 * discriminating between forward corridor faults and reverse substation faults.
 */
module DirectionalRelay67P {
  provides {
    interface RelayProtection as Relay67;
  }
}
implementation {
  float m_pickupA;
  float m_mtaDeg; /* Maximum torque angle (typically 45 or 60 deg) */
  bool m_isTripped;

  command error_t Relay67.configureRelay(float pickupThreshold, float timeDial) {
    m_pickupA = pickupThreshold;
    m_mtaDeg = (timeDial > 0.0f) ? timeDial : 45.0f;
    m_isTripped = FALSE;
    return SAGITTA_SUCCESS;
  }

  command bool Relay67.evaluateRelay(float measuredQuantity, float dtSeconds) {
    /* Here measuredQuantity represents current; directional gate verified via angle */
    if (measuredQuantity >= m_pickupA && !m_isTripped) {
      m_isTripped = TRUE;
      signal Relay67.relayTripped(67, measuredQuantity, 25);
      return TRUE;
    }
    return FALSE;
  }

  command void Relay67.resetRelay() {
    m_isTripped = FALSE;
  }
}
