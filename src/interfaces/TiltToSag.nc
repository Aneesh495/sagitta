#include "sagitta_types.h"
#include "catenary_params.h"

/**
 * TiltToSag interface maps real-time accelerometer tilt measurements
 * taken near the suspension clamp to mid-span sagitta and tension.
 */
interface TiltToSag {
  /**
   * Configures mote physical position along the conductor span.
   * @param offsetFromClampM Distance from suspension clamp center in meters
   * @param spanLengthM Total span distance between towers in meters
   * @return SUCCESS if valid
   */
  command error_t configureMotePlacement(float offsetFromClampM, float spanLengthM);

  /**
   * Filters raw triaxial accelerometer readings to isolate static pitch tilt angle.
   * @param accelX Raw X acceleration in milli-g
   * @param accelY Raw Y acceleration in milli-g
   * @param accelZ Raw Z acceleration in milli-g
   * @param pitchAngleDegOut Pointer to store filtered longitudinal tilt angle
   * @param rollAngleDegOut Pointer to store filtered transverse swing angle
   * @return SUCCESS if valid sample processed
   */
  command error_t filterTiltAngles(
    int16_t accelX,
    int16_t accelY,
    int16_t accelZ,
    float* pitchAngleDegOut,
    float* rollAngleDegOut
  );

  /**
   * Converts filtered pitch tilt angle to mid-span sagitta distance.
   * @param pitchAngleDeg Longitudinal tilt angle in degrees
   * @return Mid-span sagitta in meters
   */
  command float convertTiltToSagitta(float pitchAngleDeg);

  /**
   * Converts filtered pitch tilt angle to horizontal mechanical tension.
   * @param pitchAngleDeg Longitudinal tilt angle in degrees
   * @param linearWeightNpm Linear weight density in N/m
   * @return Estimated horizontal tension in Newtons
   */
  command float convertTiltToTension(float pitchAngleDeg, float linearWeightNpm);
}
