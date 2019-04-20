#include "sagitta_types.h"
#include "sagitta_messages.h"
#include "conductor_params.h"

/**
 * DynamicLineRating interface manages top-level thermal rating evaluation,
 * dynamic ampacity computation, and thermal overload alerts.
 */
interface DynamicLineRating {
  /**
   * Initializes the DLR evaluation engine with specific conductor properties.
   * @param conductor Pointer to conductor physical parameters
   * @return SUCCESS if initialized, EINVAL if parameters invalid
   */
  command error_t configure(const conductor_properties_t* conductor);

  /**
   * Triggers a synchronous or split-phase recalculation of dynamic ampacity
   * based on the latest acquired environmental and electrical measurements.
   * @param currentA Measured RMS phase current in Amperes
   * @param ambientTempC Ambient air temperature in deg C (Q8.8)
   * @param windSpeedMps Perpendicular wind velocity in m/s (Q8.8)
   * @param windYawDeg Wind attack yaw angle relative to conductor axis
   * @param solarFluxWm2 Solar irradiance in W/m^2 (Q8.8)
   * @return SUCCESS if calculation initiated, EBUSY if prior task running
   */
  command error_t evaluateRating(
    uint16_t currentA,
    int16_t ambientTempC,
    uint16_t windSpeedMps,
    uint16_t windYawDeg,
    uint16_t solarFluxWm2
  );

  /**
   * Queries the latest computed steady-state allowable ampacity.
   * @return Continuous ampacity in Amperes for maximum design operating temp
   */
  command uint16_t getContinuousAmpacity();

  /**
   * Queries the short-term contingency emergency ampacity rating.
   * @param durationMinutes Emergency duration (e.g., 5, 15, or 30 minutes)
   * @return Allowable contingency current in Amperes
   */
  command uint16_t getEmergencyAmpacity(uint8_t durationMinutes);

  /**
   * Event signaled when DLR evaluation completes.
   * @param state Pointer to full DLR telemetry state
   */
  event void ratingUpdated(const msg_dlr_state_t* state);

  /**
   * Event signaled when conductor core temperature exceeds warning thresholds.
   * @param currentTempC Instantaneous conductor core temperature in deg C
   * @param maxAllowedTempC Conductor design limit in deg C
   * @param severity Alarm severity level
   */
  event void thermalAlarm(int16_t currentTempC, int16_t maxAllowedTempC, alarm_level_t severity);
}
