#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * HeatBalanceC wires the IEEE 738 heat balance solver to convective,
 * radiative, solar, and Joule heating modules.
 */
configuration HeatBalanceC {
  provides {
    interface HeatBalance;
  }
}
implementation {
  components HeatBalanceP;
  components ConvectiveCoolingP;
  components RadiativeCoolingP;
  components SolarAbsorptionP;
  components JouleHeatingP;

  HeatBalance = HeatBalanceP.HeatBalance;

  HeatBalanceP.ConvectiveCooling -> ConvectiveCoolingP.ConvectiveCooling;
  HeatBalanceP.RadiativeCooling -> RadiativeCoolingP.RadiativeCooling;
  HeatBalanceP.SolarAbsorption -> SolarAbsorptionP.SolarAbsorption;
  HeatBalanceP.JouleHeating -> JouleHeatingP.JouleHeating;
}
