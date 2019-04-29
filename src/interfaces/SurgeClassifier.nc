#include "sagitta_types.h"

/**
 * SurgeClassifier interface classifies high-voltage transient events
 * based on rise-time, tail-time, and oscillation characteristics.
 */
interface SurgeClassifier {
  /**
   * Classifies a captured transient surge waveform.
   * @param riseTimeNs 10-to-90 percent front duration in nanoseconds
   * @param peakMv Maximum peak surge voltage in millivolts
   * @param decayTimeUs Time to 50 percent decay in microseconds
   * @return Classification code: 1: Lightning, 2: Fault flashover, 3: Breaker switching
   */
  command uint8_t classifySurge(
    uint16_t riseTimeNs,
    uint16_t peakMv,
    uint16_t decayTimeUs
  );
}
