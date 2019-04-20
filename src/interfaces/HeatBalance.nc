#include "sagitta_types.h"
#include "conductor_params.h"

/**
 * HeatBalance interface computes the individual components of the
 * IEEE 738 steady-state and transient conductor thermal model.
 */
interface HeatBalance {
  /**
   * Evaluates complete steady-state thermal heat terms for given conditions.
   * @param conductor Conductor physical properties
   * @param conductorTempC Current conductor surface temperature in deg C
   * @param ambientTempC Ambient air temperature in deg C
   * @param windSpeedMps Crosswind velocity in m/s
   * @param windYawDeg Wind direction angle relative to line axis
   * @param solarFluxWm2 Solar radiation flux in W/m^2
   * @param currentA Electrical current in Amperes
   * @param qcOut Pointer to store computed convective cooling (W/m)
   * @param qrOut Pointer to store computed radiative cooling (W/m)
   * @param qsOut Pointer to store computed solar heat gain (W/m)
   * @param qjOut Pointer to store computed Joule ohmic heating (W/m)
   * @return SUCCESS if valid, EINVAL if parameters out of physical range
   */
  command error_t calculateTerms(
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
  );

  /**
   * Solves for the conductor steady-state equilibrium temperature
   * where heat gain exactly balances heat dissipation: qc + qr = qs + qj.
   * @param conductor Conductor physical properties
   * @param ambientTempC Ambient air temperature in deg C
   * @param windSpeedMps Crosswind velocity in m/s
   * @param windYawDeg Wind attack angle
   * @param solarFluxWm2 Solar radiation flux in W/m^2
   * @param currentA Electrical current in Amperes
   * @param equilibriumTempOut Pointer to store equilibrium temperature in deg C
   * @return SUCCESS if converged, FAIL if failed to converge
   */
  command error_t solveEquilibriumTemp(
    const conductor_properties_t* conductor,
    float ambientTempC,
    float windSpeedMps,
    float windYawDeg,
    float solarFluxWm2,
    float currentA,
    float* equilibriumTempOut
  );
}
