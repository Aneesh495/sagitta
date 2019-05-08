#include "sagitta_types.h"

/**
 * SensorAdc interface abstracts multi-channel analog-to-digital conversions.
 */
interface SensorAdc {
  /**
   * Reads an analog channel synchronously or initiates a conversion.
   * @param channel Channel index (0: CT voltage, 1: Temp sensor, 2: Supercap)
   * @param rawValueOut Pointer to store raw 12-bit/16-bit ADC count
   * @return SUCCESS if read, EBUSY if ADC busy
   */
  command error_t readChannel(uint8_t channel, uint16_t* rawValueOut);

  /**
   * Event signaled when asynchronous ADC conversion completes.
   * @param channel Channel index
   * @param value 16-bit conversion result
   */
  async event void dataReady(uint8_t channel, uint16_t value);
}
