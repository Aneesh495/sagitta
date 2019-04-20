#include "sagitta_types.h"

/**
 * RadiativeCooling interface evaluates heat radiated from the conductor
 * surface to ambient surroundings via Stefan-Boltzmann radiation.
 */
interface RadiativeCooling {
  /**
   * Computes radiated heat loss rate per unit conductor length.
   * @param diameterM Conductor outer diameter in meters
   * @param emissivity Surface radiation emissivity (0.2 to 0.95)
   * @param conductorTempC Conductor temperature in deg C
   * @param ambientTempC Ambient temperature in deg C
   * @return Radiated heat dissipation in Watts per meter (W/m)
   */
  command float computeRadiatedLoss(
    float diameterM,
    float emissivity,
    float conductorTempC,
    float ambientTempC
  );
}
