#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * TransientThermal interface models time-dependent heat accumulation,
 * thermal time-constants, and short-term step-change overload trajectories.
 */
interface TransientThermal {
  /**
   * Initializes transient thermal model state.
   * @param conductor Conductor properties
   * @param initialTempC Starting conductor temperature
   * @return SUCCESS if initialized
   */
  command error_t initModel(const conductor_properties_t* conductor, float initialTempC);

  /**
   * Advances the transient conductor thermal state by time step dtSeconds.
   * @param conductor Conductor properties
   * @param currentA Applied phase current in Amperes
   * @param ambientTempC Ambient temperature in deg C
   * @param windSpeedMps Crosswind velocity in m/s
   * @param windYawDeg Wind attack angle in degrees
   * @param solarFluxWm2 Solar radiation flux in W/m^2
   * @param dtSeconds Integration time step in seconds
   * @return Updated conductor core temperature in deg C
   */
  command float stepThermalODE(
    const conductor_properties_t* conductor,
    float currentA,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg,
    float solarFluxWm2,
    float dtSeconds
  );

  /**
   * Computes the thermal time-constant tau for current environmental conditions.
   * @param conductor Conductor properties
   * @param currentTempC Current temperature in deg C
   * @param ambientTempC Ambient temperature in deg C
   * @param windSpeedMps Wind speed in m/s
   * @return Thermal time-constant in seconds
   */
  command float computeThermalTimeConstant(
    const conductor_properties_t* conductor,
    float currentTempC,
    float ambientTempC,
    float windSpeedMps
  );

  /**
   * Predicts allowable time until conductor reaches emergency thermal limit
   * under a sudden step-increase in current to targetCurrentA.
   * @param conductor Conductor properties
   * @param currentTempC Starting temperature in deg C
   * @param targetCurrentA Step-increased current in Amperes
   * @param emergencyLimitTempC Maximum emergency limit in deg C
   * @return Time remaining in seconds before limit exceeded, or UINT32_MAX if safe
   */
  command uint32_t predictTimeToThermalLimit(
    const conductor_properties_t* conductor,
    float currentTempC,
    float targetCurrentA,
    float emergencyLimitTempC
  );
}
