#include "sagitta_types.h"
#include "vibration_params.h"

/**
 * GallopingDetector interface detects severe low-frequency, high-amplitude
 * subconductor galloping oscillations typically caused by ice accretion and crosswind.
 */
interface GallopingDetector {
  /**
   * Evaluates inertial time series for low-frequency galloping signatures.
   * @param params Vibration parameters
   * @param dominantFreqHz Dominant modal frequency in Hz
   * @param peakToPeakDisplacementM Estimated peak-to-peak motion in meters
   * @param isGallopingOut Pointer to store boolean detection result
   * @return SUCCESS if evaluated
   */
  command error_t checkGallopingCondition(
    const vibration_parameters_t* params,
    float dominantFreqHz,
    float peakToPeakDisplacementM,
    bool* isGallopingOut
  );

  /**
   * Event signaled when hazardous line galloping is detected.
   * @param oscillationFreqHz Galloping frequency (typically 0.1 to 1.5 Hz)
   * @param peakDisplacementM Peak displacement in meters
   * @param severity Alarm severity level
   */
  event void gallopingDetected(
    float oscillationFreqHz,
    float peakDisplacementM,
    alarm_level_t severity
  );
}
