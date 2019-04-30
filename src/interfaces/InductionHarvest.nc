#include "sagitta_types.h"
#include "power_params.h"

/**
 * InductionHarvest interface models split-core current transformer
 * magnetic induction harvesting, saturation limiting, and rectified power.
 */
interface InductionHarvest {
  /**
   * Computes available harvestable power from CT secondary winding.
   * @param config Power system configuration
   * @param lineCurrentA Transmission line conductor current in Amperes
   * @param harvestedPowerMwOut Pointer to store harvested electrical power in mW
   * @param isSaturatedOut Pointer to store saturation clamp indicator
   * @return SUCCESS if evaluated
   */
  command error_t computeHarvestedPower(
    const power_system_config_t* config,
    float lineCurrentA,
    float* harvestedPowerMwOut,
    bool* isSaturatedOut
  );
}
