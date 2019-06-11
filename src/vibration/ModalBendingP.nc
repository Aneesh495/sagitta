#include <math.h>
#include "sagitta_types.h"
#include "conductor_params.h"
#include "vibration_params.h"

/**
 * ModalBendingP computes dynamic conductor bending amplitude Yb and microstrain
 * at the suspension clamp using the IEEE / Poffenberger-Swart model.
 */
module ModalBendingP {
  provides {
    interface ModalBending;
  }
}
implementation {
  command error_t ModalBending.computeBendingStrain(
    const conductor_properties_t* conductor,
    const vibration_parameters_t* params,
    float peakAccelerationG,
    float frequencyHz,
    float horizontalTensionN,
    float* bendingAmplitudeUmOut,
    float* microstrainOut
  ) {
    if (!conductor || !params || !bendingAmplitudeUmOut || !microstrainOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    if (frequencyHz <= 0.5f || horizontalTensionN <= 10.0f) {
      *bendingAmplitudeUmOut = 0.0f;
      *microstrainOut = 0.0f;
      return SAGITTA_SUCCESS;
    }

    /* Peak acceleration in m/s^2: a_peak = peakAccelG * 9.80665 */
    float aPeak = peakAccelerationG * 9.80665f;
    float omega = 2.0f * 3.14159265f * frequencyHz;

    /* Peak displacement: Y = a_peak / omega^2 */
    float yPeakM = aPeak / (omega * omega);
    float yPeakUm = yPeakM * 1e6f;
    *bendingAmplitudeUmOut = yPeakUm;

    /* Poffenberger-Swart parameter: p = sqrt(H / EI) */
    float ei = params->flexural_rigidity_ei;
    if (ei <= 0.0f) {
      ei = 500.0f; /* N * m^2 nominal for 795 kcmil ACSR */
    }
    float p = sqrtf(horizontalTensionN / ei);

    /* Clamp distance: xb = 0.089 m (89 mm = 3.5 in) */
    float xb = params->clamp_distance_xb_m;
    float pXb = p * xb;

    /* Denominator: e^(-p*xb) - 1 + p*xb */
    float denom = expf(-pXb) - 1.0f + pXb;
    if (fabsf(denom) < 1e-5f) {
      denom = 1e-5f;
    }

    /* Peak bending strain at outer strand: epsilon = (D * p^2 * Yb) / (4 * denom) */
    float d = conductor->outer_diameter_m;
    float strain = (d * p * p * yPeakM) / (4.0f * denom);

    /* Convert strain to microstrain (x 10^6) */
    *microstrainOut = strain * 1e6f;
    return SAGITTA_SUCCESS;
  }
}
