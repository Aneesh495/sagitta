#include <math.h>
#include "sagitta_types.h"

/**
 * SolarAbsorptionP evaluates solar radiation absorbed by the conductor.
 */
module SolarAbsorptionP {
  provides {
    interface SolarAbsorption;
  }
}
implementation {
  command float SolarAbsorption.computeSolarGain(
    float diameterM,
    float absorptivity,
    float solarFluxWm2,
    float effectiveIncidenceAngleDeg
  ) {
    if (solarFluxWm2 <= 0.0f) {
      return 0.0f;
    }

    float rad = effectiveIncidenceAngleDeg * (3.14159265f / 180.0f);
    float sinTheta = sinf(rad);
    if (sinTheta < 0.0f) {
      sinTheta = 0.0f;
    }

    /* Projected surface area per unit length equals outer diameter D */
    float projectedArea = diameterM;
    return absorptivity * solarFluxWm2 * sinTheta * projectedArea;
  }
}
