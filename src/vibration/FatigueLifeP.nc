#include <math.h>
#include "sagitta_types.h"
#include "vibration_params.h"

/**
 * FatigueLifeP tracks strand fatigue damage accumulation using
 * the Palmgren-Miner linear cumulative damage rule and Woehler S-N curves.
 */
module FatigueLifeP {
  provides {
    interface FatigueLife;
  }
}
implementation {
  float m_cumulativeDamage;

  command error_t FatigueLife.accumulateCycleDamage(
    const vibration_parameters_t* params,
    float microstrain,
    uint32_t cycleCount,
    float* cumulativeDamageOut
  ) {
    if (!params || !cumulativeDamageOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Below fatigue endurance limit, damage accumulation is zero */
    if (microstrain < params->fatigue_limit_microstrain || cycleCount == 0) {
      *cumulativeDamageOut = m_cumulativeDamage;
      return SAGITTA_SUCCESS;
    }

    /* Woehler S-N formula: N_allow = C * (microstrain)^(-m) */
    /* Miner damage fraction: deltaD = n / N_allow */
    float c = params->sn_curve_constant_c;
    float m = params->sn_curve_exponent_m;
    if (c <= 0.0f) {
      c = 1e18f;
    }
    if (m <= 0.0f) {
      m = 4.5f;
    }

    float nAllow = c * powf(microstrain, -m);
    if (nAllow <= 1.0f) {
      nAllow = 1.0f;
    }

    float deltaDamage = (float)cycleCount / nAllow;
    m_cumulativeDamage += deltaDamage;
    *cumulativeDamageOut = m_cumulativeDamage;

    return SAGITTA_SUCCESS;
  }

  command float FatigueLife.getCumulativeDamage() {
    return m_cumulativeDamage;
  }

  command void FatigueLife.resetDamageAccumulator() {
    m_cumulativeDamage = 0.0f;
  }
}
