#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * JouleHeatingP evaluates temperature-dependent resistance and AC ohmic loss.
 */
module JouleHeatingP {
  provides {
    interface JouleHeating;
  }
}
implementation {
  command float JouleHeating.computeResistance(
    const conductor_properties_t* conductor,
    float conductorTempC
  ) {
    if (!conductor) {
      return 0.0f;
    }
    float rRef = conductor->resistance_ref_ohm_per_m;
    float alpha = conductor->temp_coeff_resistance;
    /* R(Tc) = R(20 C) * [1 + alpha * (Tc - 20)] */
    float rAdj = rRef * (1.0f + alpha * (conductorTempC - 20.0f));
    return (rAdj > 0.0f) ? rAdj : rRef;
  }

  command float JouleHeating.computeJouleHeat(
    const conductor_properties_t* conductor,
    float currentA,
    float conductorTempC
  ) {
    if (!conductor || currentA <= 0.0f) {
      return 0.0f;
    }
    float r = call JouleHeating.computeResistance(conductor, conductorTempC);
    /* qj = I^2 * R (W/m) */
    return currentA * currentA * r;
  }
}
