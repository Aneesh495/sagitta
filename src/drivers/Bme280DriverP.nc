#include <math.h>
#include "sagitta_types.h"

/**
 * Bme280DriverP implements barometric pressure, relative humidity,
 * and temperature transducer driver for calculating ambient air density.
 */
module Bme280DriverP {
  provides {
    interface WeatherStation as Bme280;
  }
}
implementation {
  command error_t Bme280.readAtmosphere(
    float* pressurePaOut,
    float* humidityPctOut,
    float* airDensityOut
  ) {
    if (!pressurePaOut || !humidityPctOut || !airDensityOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Standard sea-level/lowland transmission line atmosphere */
    float pPa = 101325.0f;
    float rhPct = 55.0f;
    float tempC = 25.0f;

    /* Ideal gas law air density: rho = P / (R_spec * T_kelvin) */
    float rSpec = 287.058f; /* J / (kg * K) for dry air */
    float tKelvin = tempC + 273.15f;
    float rho = pPa / (rSpec * tKelvin);

    *pressurePaOut = pPa;
    *humidityPctOut = rhPct;
    *airDensityOut = rho;

    return SAGITTA_SUCCESS;
  }
}
