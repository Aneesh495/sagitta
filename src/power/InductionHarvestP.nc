#include <math.h>
#include "sagitta_types.h"
#include "power_params.h"

/**
 * InductionHarvestP models inductive energy harvesting from current transformers
 * clamped around transmission conductors, accounting for magnetic core saturation.
 */
module InductionHarvestP {
  provides {
    interface InductionHarvest;
  }
}
implementation {
  command error_t InductionHarvest.computeHarvestedPower(
    const power_system_config_t* config,
    float lineCurrentA,
    float* harvestedPowerMwOut,
    bool* isSaturatedOut
  ) {
    if (!config || !harvestedPowerMwOut || !isSaturatedOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    if (lineCurrentA < config->min_harvest_current_a) {
      *harvestedPowerMwOut = 0.0f;
      *isSaturatedOut = FALSE;
      return SAGITTA_SUCCESS;
    }

    /* Core saturation clamp */
    float effectiveCurrentA = lineCurrentA;
    if (lineCurrentA >= config->saturation_current_a) {
      effectiveCurrentA = config->saturation_current_a;
      *isSaturatedOut = TRUE;
    } else {
      *isSaturatedOut = FALSE;
    }

    /* Secondary current: I_sec = I_line / turns_ratio */
    float turns = (config->ct_turns_ratio > 0.0f) ? config->ct_turns_ratio : 500.0f;
    float iSecA = effectiveCurrentA / turns;

    /* Rectified power: P = I_sec^2 * R_burden (Watts) */
    float rBurden = (config->ct_burden_resistor_ohms > 0.0f) ? config->ct_burden_resistor_ohms : 50.0f;
    float powerWatts = iSecA * iSecA * rBurden;

    /* Power in milliwatts */
    *harvestedPowerMwOut = powerWatts * 1000.0f;
    return SAGITTA_SUCCESS;
  }
}
