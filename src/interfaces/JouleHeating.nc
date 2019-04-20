#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * JouleHeating interface calculates resistive heat generation in conductors
 * considering temperature-dependent resistance and AC skin effect.
 */
interface JouleHeating {
  /**
   * Computes temperature-adjusted AC resistance per unit length.
   * @param conductor Conductor properties reference
   * @param conductorTempC Operating conductor temperature in deg C
   * @return AC resistance in Ohms per meter
   */
  command float computeResistance(
    const conductor_properties_t* conductor,
    float conductorTempC
  );

  /**
   * Computes Joule ohmic heating rate per unit length.
   * @param conductor Conductor properties reference
   * @param currentA RMS electrical current in Amperes
   * @param conductorTempC Operating conductor temperature in deg C
   * @return Ohmic heat generation in Watts per meter (W/m)
   */
  command float computeJouleHeat(
    const conductor_properties_t* conductor,
    float currentA,
    float conductorTempC
  );
}
