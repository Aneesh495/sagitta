#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * DynamicLineRatingC wires the DLR orchestrator to the heat balance engine,
 * transient thermal models, and cooling calculators.
 */
configuration DynamicLineRatingC {
  provides {
    interface DynamicLineRating;
  }
}
implementation {
  components DynamicLineRatingP;
  components HeatBalanceC;
  components JouleHeatingP;
  components ConvectiveCoolingP;
  components RadiativeCoolingP;
  components SolarAbsorptionP;
  components TransientThermalP;

  DynamicLineRating = DynamicLineRatingP.DynamicLineRating;

  DynamicLineRatingP.HeatBalance -> HeatBalanceC.HeatBalance;
  DynamicLineRatingP.JouleHeating -> JouleHeatingP.JouleHeating;
  DynamicLineRatingP.ConvectiveCooling -> ConvectiveCoolingP.ConvectiveCooling;
  DynamicLineRatingP.RadiativeCooling -> RadiativeCoolingP.RadiativeCooling;
  DynamicLineRatingP.SolarAbsorption -> SolarAbsorptionP.SolarAbsorption;
  DynamicLineRatingP.TransientThermal -> TransientThermalP.TransientThermal;

  TransientThermalP.ConvectiveCooling -> ConvectiveCoolingP.ConvectiveCooling;
  TransientThermalP.RadiativeCooling -> RadiativeCoolingP.RadiativeCooling;
  TransientThermalP.SolarAbsorption -> SolarAbsorptionP.SolarAbsorption;
  TransientThermalP.JouleHeating -> JouleHeatingP.JouleHeating;
}
