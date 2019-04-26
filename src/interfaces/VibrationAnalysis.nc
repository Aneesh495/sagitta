#include "sagitta_types.h"
#include "vibration_params.h"
#include "sagitta_messages.h"

/**
 * VibrationAnalysis interface manages inertial data acquisition,
 * spectral peak extraction, and conductor fatigue assessment.
 */
interface VibrationAnalysis {
  /**
   * Configures vibration analysis parameters.
   * @param params Pointer to vibration settings and S-N constants
   * @return SUCCESS if valid
   */
  command error_t configure(const vibration_parameters_t* params);

  /**
   * Pushes a batch of raw accelerometer samples into the analysis buffer.
   * @param accelSamples Array of 16-bit acceleration samples
   * @param sampleCount Number of samples in batch
   * @return SUCCESS if buffered, EOVERFLOW if buffer overrun
   */
  command error_t pushSamples(const int16_t* accelSamples, uint16_t sampleCount);

  /**
   * Triggers execution of the spectral transformation and modal analysis task.
   * @return SUCCESS if scheduled, EBUSY if already processing
   */
  command error_t processSpectrum();

  /**
   * Event signaled when vibration spectral analysis completes.
   * @param alert Pointer to vibration telemetry alert record
   */
  event void analysisComplete(const msg_vibration_alert_t* alert);
}
