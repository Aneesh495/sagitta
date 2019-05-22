#include <math.h>
#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * TransientThermalP integrates the first-order conductor thermal differential equation
 * using 4th-order Runge-Kutta / adaptive Euler stepping.
 */
module TransientThermalP {
  provides {
    interface TransientThermal;
  }
  uses {
    interface ConvectiveCooling;
    interface RadiativeCooling;
    interface SolarAbsorption;
    interface JouleHeating;
  }
}
implementation {
  float m_currentTempC;

  command error_t TransientThermal.initModel(const conductor_properties_t* conductor, float initialTempC) {
    if (!conductor) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    m_currentTempC = initialTempC;
    return SAGITTA_SUCCESS;
  }

  /* Computes net rate of temperature change: dTc/dt = (qj + qs - qc - qr) / (m * Cp) */
  static float computeDerivative(
    const conductor_properties_t* conductor,
    float tempC,
    float currentA,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg,
    float solarFluxWm2
  ) {
    float qc = call ConvectiveCooling.computeConvectiveLoss(
      conductor->outer_diameter_m, tempC, ambientTempC, windSpeedMps, windYawDeg);
    float qr = call RadiativeCooling.computeRadiatedLoss(
      conductor->outer_diameter_m, conductor->emissivity, tempC, ambientTempC);
    float qs = call SolarAbsorption.computeSolarGain(
      conductor->outer_diameter_m, conductor->absorptivity, solarFluxWm2, 90.0f);
    float qj = call JouleHeating.computeJouleHeat(conductor, currentA, tempC);

    float heatCapacity = conductor->mass_kg_per_m * conductor->specific_heat_j_kg_k;
    if (heatCapacity <= 0.0f) {
      heatCapacity = 1000.0f;
    }

    return (qj + qs - qc - qr) / heatCapacity;
  }

  command float TransientThermal.stepThermalODE(
    const conductor_properties_t* conductor,
    float currentA,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg,
    float solarFluxWm2,
    float dtSeconds
  ) {
    if (!conductor || dtSeconds <= 0.0f) {
      return m_currentTempC;
    }

    /* 4th-order Runge-Kutta integration step */
    float k1 = computeDerivative(conductor, m_currentTempC, currentA, ambientTempC, windSpeedMps, windYawDeg, solarFluxWm2);
    float k2 = computeDerivative(conductor, m_currentTempC + 0.5f * dtSeconds * k1, currentA, ambientTempC, windSpeedMps, windYawDeg, solarFluxWm2);
    float k3 = computeDerivative(conductor, m_currentTempC + 0.5f * dtSeconds * k2, currentA, ambientTempC, windSpeedMps, windYawDeg, solarFluxWm2);
    float k4 = computeDerivative(conductor, m_currentTempC + dtSeconds * k3, currentA, ambientTempC, windSpeedMps, windYawDeg, solarFluxWm2);

    m_currentTempC += (dtSeconds / 6.0f) * (k1 + 2.0f * k2 + 2.0f * k3 + k4);
    return m_currentTempC;
  }

  command float TransientThermal.computeThermalTimeConstant(
    const conductor_properties_t* conductor,
    float currentTempC,
    float ambientTempC,
    float windSpeedMps
  ) {
    if (!conductor) {
      return 600.0f; /* Default 10 minutes */
    }
    float heatCapacity = conductor->mass_kg_per_m * conductor->specific_heat_j_kg_k;
    float deltaT = (currentTempC > ambientTempC) ? (currentTempC - ambientTempC) : 10.0f;
    float qc = call ConvectiveCooling.computeConvectiveLoss(
      conductor->outer_diameter_m, currentTempC, ambientTempC, windSpeedMps, 90.0f);
    float qr = call RadiativeCooling.computeRadiatedLoss(
      conductor->outer_diameter_m, conductor->emissivity, currentTempC, ambientTempC);

    float heatDissipationRate = (qc + qr) / deltaT;
    if (heatDissipationRate <= 0.01f) {
      return 1200.0f;
    }
    return heatCapacity / heatDissipationRate;
  }

  command uint32_t TransientThermal.predictTimeToThermalLimit(
    const conductor_properties_t* conductor,
    float currentTempC,
    float targetCurrentA,
    float emergencyLimitTempC
  ) {
    if (currentTempC >= emergencyLimitTempC) {
      return 0;
    }
    float simTemp = currentTempC;
    float dt = 5.0f; /* 5 second simulation steps */
    uint32_t elapsedSeconds = 0;

    while (elapsedSeconds < 7200) { /* Limit lookahead to 2 hours */
      float deriv = computeDerivative(conductor, simTemp, targetCurrentA, 25.0f, 1.0f, 90.0f, 800.0f);
      if (deriv <= 0.0f) {
        return UINT32_MAX; /* Thermal equilibrium reached below emergency limit */
      }
      simTemp += deriv * dt;
      elapsedSeconds += (uint32_t)dt;
      if (simTemp >= emergencyLimitTempC) {
        return elapsedSeconds;
      }
    }
    return UINT32_MAX;
  }
}
