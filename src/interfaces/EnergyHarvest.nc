#include "sagitta_types.h"
#include "power_params.h"

/**
 * EnergyHarvest interface coordinates power harvesting, storage state-of-charge,
 * and adaptive task duty cycling across fluctuating line current conditions.
 */
interface EnergyHarvest {
  /**
   * Initializes power management subsystem.
   * @param config Power system constants and thresholds
   * @return SUCCESS if initialized
   */
  command error_t configure(const power_system_config_t* config);

  /**
   * Updates energy harvesting state with latest line current and solar inputs.
   * @param lineCurrentA Instantaneous transmission line current in Amperes
   * @param solarFluxWm2 Auxiliary solar flux in W/m^2
   * @return Current operational power mode (Hibernate, Eco, Continuous, Burst)
   */
  command power_mode_t updateHarvestState(float lineCurrentA, float solarFluxWm2);

  /**
   * Event signaled when system power mode transitions.
   * @param oldMode Prior power mode
   * @param newMode New power mode
   * @param supercapVoltageVolts Current storage capacitor voltage
   */
  event void powerModeChanged(
    power_mode_t oldMode,
    power_mode_t newMode,
    float supercapVoltageVolts
  );
}
