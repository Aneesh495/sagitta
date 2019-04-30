#include "sagitta_types.h"

/**
 * PowerBudget interface calculates duty cycle schedules and enables/disables
 * peripheral subsystems to match active energy harvesting rates.
 */
interface PowerBudget {
  /**
   * Adjusts subsystem duty-cycle intervals to match available energy budget.
   * @param currentMode Current power operational mode
   * @param dlrIntervalMsOut Pointer to store DLR sampling interval in ms
   * @param vibrationIntervalMsOut Pointer to store vibration FFT interval in ms
   * @param radioTxPowerDbmOut Pointer to store RF transmit power level in dBm
   */
  command void calculateTaskSchedule(
    power_mode_t currentMode,
    uint32_t* dlrIntervalMsOut,
    uint32_t* vibrationIntervalMsOut,
    int8_t* radioTxPowerDbmOut
  );
}
