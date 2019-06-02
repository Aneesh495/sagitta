#include <math.h>
#include "sagitta_types.h"
#include "catenary_params.h"
#include "conductor_params.h"

/**
 * IceAccretionP quantifies radial ice thickness by comparing observed
 * mechanical tension with expected bare-wire thermal equilibrium tension.
 */
module IceAccretionP {
  provides {
    interface IceAccretion;
  }
  uses {
    interface TensionTracker;
  }
}
implementation {
  command error_t IceAccretion.estimateIceLoad(
    const conductor_properties_t* conductor,
    float observedTensionN,
    float conductorTempC,
    float* iceThicknessMmOut,
    float* iceWeightNpmOut
  ) {
    if (!conductor || !iceThicknessMmOut || !iceWeightNpmOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Standard ice density: 900 kg / m^3; gravity g = 9.80665 m/s^2 */
    float rhoIce = 900.0f;
    float g = 9.80665f;
    float wBare = conductor->linear_weight_n_per_m;

    /* If temperature is above freezing (+3.0 C), ice cannot accumulate */
    if (conductorTempC > 3.0f) {
      *iceThicknessMmOut = 0.0f;
      *iceWeightNpmOut = 0.0f;
      return SAGITTA_SUCCESS;
    }

    /* Expected bare-wire tension based on thermal expansion */
    /* If observed tension is lower than bare-wire tension, sag is larger, implying excess weight */
    float wTotal = wBare;
    if (observedTensionN > 100.0f) {
      /* Inversely, higher sag means lower tension for same span length */
      /* Here we calculate weight increment deltaW */
      float tensionRatio = (observedTensionN < 20000.0f) ? (20000.0f / observedTensionN) : 1.0f;
      if (tensionRatio > 1.05f) {
        wTotal = wBare * tensionRatio;
      }
    }

    float deltaW = wTotal - wBare;
    if (deltaW < 0.0f) {
      deltaW = 0.0f;
    }
    *iceWeightNpmOut = deltaW;

    /* Solve radial ice thickness: deltaW = pi * rho_ice * g * (D * r_ice + r_ice^2) */
    float d = conductor->outer_diameter_m;
    float denom = 3.14159265f * rhoIce * g;
    float c = deltaW / denom;

    /* r_ice^2 + D * r_ice - c = 0 => r_ice = (-D + sqrt(D^2 + 4c)) / 2 */
    float discriminant = d * d + 4.0f * c;
    float rIceM = 0.0f;
    if (discriminant > 0.0f && c > 0.0f) {
      rIceM = (-d + sqrtf(discriminant)) * 0.5f;
    }

    float rIceMm = rIceM * 1000.0f;
    *iceThicknessMmOut = rIceMm;

    /* Signal alarms if ice loading exceeds thresholds */
    if (rIceMm >= 25.0f) {
      signal IceAccretion.iceAlarm(rIceMm, deltaW, ALARM_LEVEL_EMERGENCY);
    } else if (rIceMm >= 12.5f) {
      signal IceAccretion.iceAlarm(rIceMm, deltaW, ALARM_LEVEL_CRITICAL);
    } else if (rIceMm >= 5.0f) {
      signal IceAccretion.iceAlarm(rIceMm, deltaW, ALARM_LEVEL_WARNING);
    }

    return SAGITTA_SUCCESS;
  }
}
