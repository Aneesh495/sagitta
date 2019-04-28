#include "sagitta_types.h"

/**
 * FrequencyEstimator interface tracks electrical grid fundamental frequency
 * via phase-locked loop (PLL) and zero-crossing detection.
 */
interface FrequencyEstimator {
  /**
   * Updates frequency tracking with the latest phasor phase angle.
   * @param phaseAngleRad Current unwrapped phase angle in radians
   * @param dtSeconds Elapsed time since prior phase measurement
   * @return Estimated grid frequency in Hertz
   */
  command float updateFrequency(float phaseAngleRad, float dtSeconds);

  /**
   * Returns the current estimated power frequency in milli-Hertz.
   * @return Frequency in mHz (e.g., 60000 for 60.0 Hz)
   */
  command uint32_t getFrequencyMilliHz();
}
