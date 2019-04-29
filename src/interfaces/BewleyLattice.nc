#include "sagitta_types.h"

/**
 * BewleyLattice interface reconstructs multiple successive wave reflections
 * from impedance discontinuities to verify fault origin and line boundaries.
 */
interface BewleyLattice {
  /**
   * Evaluates succession of reflected wave pulses.
   * @param pulseArrivalTimesNs Array of arrival time offsets in nanoseconds
   * @param pulseAmplitudesMv Array of pulse peak voltages in mV
   * @param pulseCount Number of detected reflections
   * @param estimatedFaultDistanceMOut Pointer to store single-ended fault distance
   * @return SUCCESS if lattice resolved
   */
  command error_t analyzeReflections(
    const uint32_t* pulseArrivalTimesNs,
    const int16_t* pulseAmplitudesMv,
    uint8_t pulseCount,
    float* estimatedFaultDistanceMOut
  );
}
