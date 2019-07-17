#include "sagitta_types.h"
#include "power_params.h"

/**
 * EnergyHarvestP manages power state transitions, solar/CT inputs,
 * and signals operational mode transitions.
 */
module EnergyHarvestP {
  provides {
    interface EnergyHarvest;
  }
  uses {
    interface InductionHarvest;
    interface SupercapManager;
    interface PowerBudget;
  }
}
implementation {
  power_system_config_t m_config;
  power_mode_t m_currentMode;

  command error_t EnergyHarvest.configure(const power_system_config_t* config) {
    if (!config) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    memcpy(&m_config, config, sizeof(power_system_config_t));
    m_currentMode = POWER_MODE_CONTINUOUS;
    return SAGITTA_SUCCESS;
  }

  command power_mode_t EnergyHarvest.updateHarvestState(float lineCurrentA, float solarFluxWm2) {
    float ctPowerMw = 0.0f;
    bool isSaturated = FALSE;
    call InductionHarvest.computeHarvestedPower(&m_config, lineCurrentA, &ctPowerMw, &isSaturated);

    float vCap = call SupercapManager.getVoltage();
    power_mode_t newMode = m_currentMode;

    /* Power mode state machine based on supercapacitor reserve */
    if (vCap < m_config.v_shutdown_volts) {
      newMode = POWER_MODE_HIBERNATE;
    } else if (vCap < m_config.v_eco_volts) {
      newMode = POWER_MODE_ECO;
    } else if (vCap >= m_config.v_nominal_volts && lineCurrentA > 200.0f) {
      newMode = POWER_MODE_BURST;
    } else {
      newMode = POWER_MODE_CONTINUOUS;
    }

    if (newMode != m_currentMode) {
      power_mode_t oldMode = m_currentMode;
      m_currentMode = newMode;
      signal EnergyHarvest.powerModeChanged(oldMode, newMode, vCap);
    }

    return m_currentMode;
  }
}
