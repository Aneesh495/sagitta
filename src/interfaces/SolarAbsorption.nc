#include "sagitta_types.h"

/**
 * SolarAbsorption interface computes solar radiation heat absorption
 * based on solar position, atmospheric clarity, and line azimuth.
 */
interface SolarAbsorption {
  /**
   * Computes solar heat gain per unit conductor length.
   * @param diameterM Conductor outer diameter in meters
   * @param absorptivity Conductor solar absorptivity coefficient (0.2 to 0.95)
   * @param solarFluxWm2 Total solar and sky radiation flux in W/m^2
   * @param effectiveIncidenceAngleDeg Effective solar ray angle of incidence
   * @return Solar heat gain in Watts per meter (W/m)
   */
  command float computeSolarGain(
    float diameterM,
    float absorptivity,
    float solarFluxWm2,
    float effectiveIncidenceAngleDeg
  );
}
