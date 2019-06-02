#include <math.h>
#include "sagitta_types.h"
#include "catenary_params.h"
#include "conductor_params.h"

/**
 * TensionTrackerP solves the classic cubic state change equation for
 * transmission conductor mechanical tension across temperature and load changes.
 */
module TensionTrackerP {
  provides {
    interface TensionTracker;
  }
}
implementation {
  command float TensionTracker.solveStateChangeTension(
    const conductor_properties_t* conductor,
    const span_geometry_t* geometry,
    float referenceTempC,
    float referenceTensionN,
    float targetTempC,
    float currentWeightNpm
  ) {
    if (!conductor || !geometry || referenceTensionN <= 10.0f) {
      return 20000.0f;
    }

    float l = geometry->span_length_m;
    float ea = conductor->elastic_modulus_pa * conductor->cross_section_area_m2;
    float alpha = conductor->thermal_expansion_coeff;
    float deltaT = targetTempC - referenceTempC;
    float w1 = conductor->linear_weight_n_per_m;
    float w2 = currentWeightNpm;
    float h1 = referenceTensionN;

    /* Cubic equation: H2^2 * [H2 + K] = M */
    /* K = EA * [ (w1^2 * L^2) / (24 * H1^2) + alpha * deltaT - H1 / EA ] */
    /* M = (EA * w2^2 * L^2) / 24 */
    float termSag1 = (w1 * w1 * l * l) / (24.0f * h1 * h1);
    float termElastic1 = h1 / ea;
    float k = ea * (termSag1 + alpha * deltaT - termElastic1);
    float m = (ea * w2 * w2 * l * l) / 24.0f;

    /* Solve H2^3 + K * H2^2 - M = 0 using Newton-Raphson */
    float h2 = h1;
    for (int iter = 0; iter < 25; iter++) {
      float f = h2 * h2 * h2 + k * h2 * h2 - m;
      float fPrime = 3.0f * h2 * h2 + 2.0f * k * h2;
      if (fabsf(fPrime) < 1.0f) {
        break;
      }
      float step = f / fPrime;
      h2 -= step;
      if (fabsf(step) < 0.5f) {
        break;
      }
    }

    return (h2 > 1000.0f) ? h2 : 1000.0f;
  }
}
