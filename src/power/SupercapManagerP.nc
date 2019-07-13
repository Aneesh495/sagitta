#include "sagitta_types.h"
#include "power_params.h"

/**
 * SupercapManagerP tracks supercapacitor buffer voltage, calculates
 * state-of-charge, and estimates available energy in Joules.
 */
module SupercapManagerP {
  provides {
    interface SupercapManager;
  }
}
implementation {
  float m_currentVoltageV;

  command float SupercapManager.updateVoltage(
    uint16_t rawAdcTerminalMv,
    float currentDrawMa,
    uint8_t* chargePercentageOut
  ) {
    /* Voltage in Volts */
    m_currentVoltageV = (float)rawAdcTerminalMv * 0.001f;

    /* State of charge percentage: V_min = 2.2 V, V_max = 5.0 V */
    float vMin = 2.2f;
    float vMax = 5.0f;
    float soc = (m_currentVoltageV - vMin) / (vMax - vMin);

    if (soc < 0.0f) {
      soc = 0.0f;
    } else if (soc > 1.0f) {
      soc = 1.0f;
    }

    if (chargePercentageOut) {
      *chargePercentageOut = (uint8_t)(soc * 100.0f);
    }

    return m_currentVoltageV;
  }

  command float SupercapManager.getVoltage() {
    return m_currentVoltageV;
  }
}
