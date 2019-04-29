#include "sagitta_types.h"

/**
 * DoubleEndedTwfl interface computes exact fault location distance
 * from arrival time difference of wavefronts at corridor boundary motes.
 */
interface DoubleEndedTwfl {
  /**
   * Solves double-ended travelling wave fault location equation.
   * @param arrivalTimeLeftS Arrival time at Mote A (seconds)
   * @param arrivalTimeLeftNs Arrival time at Mote A (nanoseconds)
   * @param arrivalTimeRightS Arrival time at Mote B (seconds)
   * @param arrivalTimeRightNs Arrival time at Mote B (nanoseconds)
   * @param lineLengthM Total distance between Mote A and Mote B (meters)
   * @param velocityMps Wave propagation velocity (m/s)
   * @param faultDistanceMOut Pointer to store computed fault distance from Mote A
   * @return SUCCESS if valid, EINVAL if times or distance inconsistent
   */
  command error_t solveFaultLocation(
    uint32_t arrivalTimeLeftS,
    uint32_t arrivalTimeLeftNs,
    uint32_t arrivalTimeRightS,
    uint32_t arrivalTimeRightNs,
    float lineLengthM,
    float velocityMps,
    float* faultDistanceMOut
  );
}
