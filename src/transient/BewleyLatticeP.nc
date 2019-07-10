#include <math.h>
#include "sagitta_types.h"

/**
 * BewleyLatticeP reconstructs successive wave reflection intervals
 * to perform single-ended fault distance estimation.
 */
module BewleyLatticeP {
  provides {
    interface BewleyLattice;
  }
}
implementation {
  command error_t BewleyLattice.analyzeReflections(
    const uint32_t* pulseArrivalTimesNs,
    const int16_t* pulseAmplitudesMv,
    uint8_t pulseCount,
    float* estimatedFaultDistanceMOut
  ) {
    if (!pulseArrivalTimesNs || !pulseAmplitudesMv || !estimatedFaultDistanceMOut || pulseCount < 2) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Round-trip time delta_t = t2 - t1 */
    uint32_t dtNs = pulseArrivalTimesNs[1] - pulseArrivalTimesNs[0];
    float dtSec = (float)dtNs * 1e-9f;

    /* Velocity: 294,000,000 m/s in overhead aerial conductor */
    float v = 2.94e8f;

    /* Round-trip distance 2 * x_f = v * delta_t => x_f = (v * delta_t) / 2 */
    float xf = (v * dtSec) * 0.5f;
    *estimatedFaultDistanceMOut = xf;

    return SAGITTA_SUCCESS;
  }
}
