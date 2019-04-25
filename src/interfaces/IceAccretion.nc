#include "sagitta_types.h"
#include "catenary_params.h"
#include "conductor_params.h"

/**
 * IceAccretion interface detects and quantifies atmospheric glaze/rime ice
 * accumulation on overhead lines by tracking mechanical weight increments.
 */
interface IceAccretion {
  /**
   * Evaluates ice accumulation by comparing observed tension against bare-conductor baseline.
   * @param conductor Conductor properties
   * @param observedTensionN Current mechanical tension estimated from tilt
   * @param conductorTempC Current conductor temperature in deg C
   * @param iceThicknessMmOut Pointer to store computed radial ice thickness (mm)
   * @param iceWeightNpmOut Pointer to store extra ice weight per meter (N/m)
   * @return SUCCESS if evaluated, EBUSY if baseline unresolved
   */
  command error_t estimateIceLoad(
    const conductor_properties_t* conductor,
    float observedTensionN,
    float conductorTempC,
    float* iceThicknessMmOut,
    float* iceWeightNpmOut
  );

  /**
   * Event signaled when ice accretion exceeds safe mechanical load threshold.
   * @param iceThicknessMm Radial ice thickness in millimeters
   * @param extraWeightNpm Additional ice weight per meter in N/m
   * @param severity Alarm severity level
   */
  event void iceAlarm(float iceThicknessMm, float extraWeightNpm, alarm_level_t severity);
}
