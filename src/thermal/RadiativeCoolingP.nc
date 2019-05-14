#include <math.h>
#include "sagitta_types.h"
#include "sagitta_config.h"

/**
 * RadiativeCoolingP implements Stefan-Boltzmann radiation cooling
 * from the conductor surface to surroundings.
 */
module RadiativeCoolingP {
  provides {
    interface RadiativeCooling;
  }
}
implementation {
  command float RadiativeCooling.computeRadiatedLoss(
    float diameterM,
    float emissivity,
    float conductorTempC,
    float ambientTempC
  ) {
    if (conductorTempC <= ambientTempC) {
      return 0.0f;
    }

    float tConductorK = conductorTempC + 273.15f;
    float tAmbientK = ambientTempC + 273.15f;

    /* Scaled fourth-power expansion to prevent floating point overflow */
    float tcRatio = tConductorK / 100.0f;
    float taRatio = tAmbientK / 100.0f;

    float tcPow4 = tcRatio * tcRatio * tcRatio * tcRatio;
    float taPow4 = taRatio * taRatio * taRatio * taRatio;

    /* IEEE 738 radiative dissipation constant: 17.8 * D * eps * ((Tc/100)^4 - (Ta/100)^4) */
    float qr = 17.8f * diameterM * emissivity * (tcPow4 - taPow4);
    return (qr > 0.0f) ? qr : 0.0f;
  }
}
