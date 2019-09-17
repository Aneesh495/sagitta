#include "sagitta_types.h"

/**
 * InertialSensor interface abstracts low-noise triaxial MEMS accelerometers.
 */
interface InertialSensor {
  /**
   * Initializes sensor registers, scale range (+/- 2g / 4g / 8g), and output data rate.
   * @param rangeG Dynamic range setting in g
   * @param odrHz Output data rate in Hertz
   * @return SUCCESS if initialized
   */
  command error_t initSensor(uint8_t rangeG, uint16_t odrHz);

  /**
   * Reads current triaxial acceleration vector in milli-g.
   * @param accelXOut Pointer to store X-axis acceleration
   * @param accelYOut Pointer to store Y-axis acceleration
   * @param accelZOut Pointer to store Z-axis acceleration
   * @return SUCCESS if read, EBUSY if conversion in flight
   */
  command error_t readAxes(int16_t* accelXOut, int16_t* accelYOut, int16_t* accelZOut);
}
