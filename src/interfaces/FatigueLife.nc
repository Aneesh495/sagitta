#include "sagitta_types.h"
#include "vibration_params.h"

/**
 * FatigueLife interface tracks cumulative strand fatigue damage
 * using rainflow cycle counting and the Palmgren-Miner linear damage rule.
 */
interface FatigueLife {
  /**
   * Records a vibration stress cycle and updates cumulative fatigue damage.
   * @param params Vibration parameters
   * @param microstrain Peak bending microstrain during cycle
   * @param cycleCount Number of cycles accumulated at this strain level
   * @param cumulativeDamageOut Pointer to store updated damage fraction (0.0 to 1.0)
   * @return SUCCESS if recorded
   */
  command error_t accumulateCycleDamage(
    const vibration_parameters_t* params,
    float microstrain,
    uint32_t cycleCount,
    float* cumulativeDamageOut
  );

  /**
   * Queries total cumulative damage accrued since deployment.
   * @return Cumulative Miner sum D (0.0 = virgin, 1.0 = failure)
   */
  command float getCumulativeDamage();

  /**
   * Resets the cumulative fatigue accumulator.
   */
  command void resetDamageAccumulator();
}
