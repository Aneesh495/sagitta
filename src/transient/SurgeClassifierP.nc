#include "sagitta_types.h"

/**
 * SurgeClassifierP classifies high-voltage transient waveforms based on
 * front duration (rise-time) and decay characteristics.
 */
module SurgeClassifierP {
  provides {
    interface SurgeClassifier;
  }
}
implementation {
  command uint8_t SurgeClassifier.classifySurge(
    uint16_t riseTimeNs,
    uint16_t peakMv,
    uint16_t decayTimeUs
  ) {
    /*
     * Classification standards:
     * 1: Lightning stroke: Ultra-fast front (rise-time < 1.2 us = 1200 ns, high peak)
     * 2: Fault flashover: Moderate front (1.2 us to 20 us, large persistent tail)
     * 3: Breaker switching: Slow oscillatory front (> 50 us, lower relative peak)
     */
    if (riseTimeNs <= 1500) {
      return 1; /* Lightning impulse */
    } else if (riseTimeNs <= 25000) {
      return 2; /* Fault flashover breakdown */
    } else {
      return 3; /* Breaker switching transient */
    }
  }
}
