#include "sagitta_types.h"
#include "power_params.h"

/**
 * SupercapManager interface monitors storage supercapacitor voltage,
 * performs Coulomb counting, and tracks state-of-charge (SoC).
 */
interface SupercapManager {
  /**
   * Updates capacitor bank state with latest ADC terminal voltage reading.
   * @param rawAdcTerminalMv Measured supercapacitor terminal voltage in mV
   * @param currentDrawMa Current system load consumption in mA
   * @param chargePercentageOut Pointer to store state-of-charge percentage (0 to 100)
   * @return Current terminal voltage in Volts
   */
  command float updateVoltage(
    uint16_t rawAdcTerminalMv,
    float currentDrawMa,
    uint8_t* chargePercentageOut
  );

  /**
   * Queries instantaneous terminal voltage in Volts.
   * @return Storage capacitor voltage
   */
  command float getVoltage();
}
