#include "sagitta_types.h"

/**
 * WeatherStation interface abstracts ambient meteorological sensors:
 * ambient temperature, barometric pressure, relative humidity, and air density.
 */
interface WeatherStation {
  /**
   * Reads barometric pressure in Pascals, relative humidity in percent, and air density in kg/m^3.
   * @param pressurePaOut Pointer to store atmospheric pressure
   * @param humidityPctOut Pointer to store relative humidity
   * @param airDensityOut Pointer to store calculated air density
   * @return SUCCESS if read
   */
  command error_t readAtmosphere(
    float* pressurePaOut,
    float* humidityPctOut,
    float* airDensityOut
  );
}
