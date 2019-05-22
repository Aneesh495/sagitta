#include <math.h>
#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * HeatBalanceP coordinates steady-state heat equation terms and solves
 * for conductor equilibrium temperature using Newton-Raphson iteration.
 */
module HeatBalanceP {
  provides {
    interface HeatBalance;
  }
  uses {
    interface ConvectiveCooling;
    interface RadiativeCooling;
    interface SolarAbsorption;
    interface JouleHeating;
  }
}
implementation {
  command error_t HeatBalance.calculateTerms(
    const conductor_properties_t* conductor,
    float conductorTempC,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg,
    float solarFluxWm2,
    float currentA,
    float* qcOut,
    float* qrOut,
    float* qsOut,
    float* qjOut
  ) {
    if (!conductor || !qcOut || !qrOut || !qsOut || !qjOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    *qcOut = call ConvectiveCooling.computeConvectiveLoss(
      conductor->outer_diameter_m, conductorTempC, ambientTempC, windSpeedMps, windYawDeg);
    *qrOut = call RadiativeCooling.computeRadiatedLoss(
      conductor->outer_diameter_m, conductor->emissivity, conductorTempC, ambientTempC);
    *qsOut = call SolarAbsorption.computeSolarGain(
      conductor->outer_diameter_m, conductor->absorptivity, solarFluxWm2, 90.0f);
    *qjOut = call JouleHeating.computeJouleHeat(conductor, currentA, conductorTempC);

    return SAGITTA_SUCCESS;
  }

  command error_t HeatBalance.solveEquilibriumTemp(
    const conductor_properties_t* conductor,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg,
    float solarFluxWm2,
    float currentA,
    float* equilibriumTempOut
  ) {
    if (!conductor || !equilibriumTempOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Newton-Raphson root solver: f(Tc) = qc(Tc) + qr(Tc) - qs - qj(Tc) = 0 */
    float tempEstimate = ambientTempC + 10.0f;
    float tolerance = 0.05f; /* 0.05 deg C convergence tolerance */

    for (int iter = 0; iter < 30; iter++) {
      float qc, qr, qs, qj;
      call HeatBalance.calculateTerms(
        conductor, tempEstimate, ambientTempC, windSpeedMps, windYawDeg, solarFluxWm2, currentA,
        &qc, &qr, &qs, &qj);

      float f = qc + qr - qs - qj;
      if (fabsf(f) < tolerance) {
        *equilibriumTempOut = tempEstimate;
        return SAGITTA_SUCCESS;
      }

      /* Numerical derivative df/dTc with step deltaT = 0.1 C */
      float deltaT = 0.1f;
      float qc2, qr2, qs2, qj2;
      call HeatBalance.calculateTerms(
        conductor, tempEstimate + deltaT, ambientTempC, windSpeedMps, windYawDeg, solarFluxWm2, currentA,
        &qc2, &qr2, &qs2, &qj2);

      float fPrime = ((qc2 + qr2 - qs2 - qj2) - f) / deltaT;
      if (fabsf(fPrime) < 1e-4f) {
        break;
      }

      tempEstimate = tempEstimate - (f / fPrime);
      if (tempEstimate < ambientTempC - 10.0f) {
        tempEstimate = ambientTempC - 10.0f;
      } else if (tempEstimate > 300.0f) {
        tempEstimate = 300.0f;
      }
    }

    *equilibriumTempOut = tempEstimate;
    return SAGITTA_SUCCESS;
  }
}
