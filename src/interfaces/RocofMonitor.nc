#include "sagitta_types.h"

/**
 * RocofMonitor interface computes Rate of Change of Frequency (ROCOF)
 * across a moving finite-difference window for loss-of-mains detection.
 */
interface RocofMonitor {
  /**
   * Pushes latest frequency reading and evaluates ROCOF.
   * @param currentFrequencyHz Current grid frequency in Hertz
   * @param timestampUs Microsecond timestamp
   * @return Rate of change of frequency in Hertz per second (Hz/s)
   */
  command float updateRocof(float currentFrequencyHz, uint32_t timestampUs);

  /**
   * Event signaled when ROCOF exceeds protection threshold.
   * @param rocofHzPerS Measured frequency derivative in Hz/s
   * @param severity Alarm severity level
   */
  event void rocofThresholdExceeded(float rocofHzPerS, alarm_level_t severity);
}
