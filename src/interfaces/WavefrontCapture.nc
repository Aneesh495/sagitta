#include "sagitta_types.h"
#include "wavefront_params.h"

/**
 * WavefrontCapture interface interacts with hardware comparators,
 * high-speed ADC, and circular DMA ring buffers.
 */
interface WavefrontCapture {
  /**
   * Initializes high-speed circular sample ring buffer.
   * @param buffer Array to store transient ADC samples
   * @param bufferSize Number of sample entries
   * @return SUCCESS if initialized
   */
  command error_t initBuffer(uint16_t* buffer, uint16_t bufferSize);

  /**
   * Hardware trigger callback triggered at sub-microsecond comparator trip.
   * @param triggerTimestamp Epoch timestamp of arrival latch
   */
  async command void triggerLatch(const sagitta_timestamp_t* triggerTimestamp);

  /**
   * Queries peak wavefront amplitude in millivolts.
   * @return Peak surge voltage amplitude
   */
  command uint16_t getPeakSurgeMilliVolts();

  /**
   * Queries 10-to-90 percent rise-time in nanoseconds.
   * @return Rise-time in nanoseconds
   */
  command uint16_t getRiseTimeNanoseconds();
}
