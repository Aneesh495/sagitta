#include "sagitta_types.h"
#include "conductor_params.h"
#include "vibration_params.h"

/**
 * ModalBending interface evaluates dynamic conductor bending amplitude Yb
 * and microstrain at the suspension clamp using Poffenberger-Swart formulation.
 */
interface ModalBending {
  /**
   * Computes dynamic bending strain at the suspension clamp.
   * @param conductor Conductor properties
   * @param params Vibration parameters
   * @param peakAccelerationG Measured peak acceleration in g units
   * @param frequencyHz Dominant vibration frequency in Hertz
   * @param horizontalTensionN Current conductor tension in Newtons
   * @param bendingAmplitudeUmOut Pointer to store peak-to-peak displacement Yb (micrometers)
   * @param microstrainOut Pointer to store peak bending microstrain
   * @return SUCCESS if evaluated, EINVAL if parameters out of bounds
   */
  command error_t computeBendingStrain(
    const conductor_properties_t* conductor,
    const vibration_parameters_t* params,
    float peakAccelerationG,
    float frequencyHz,
    float horizontalTensionN,
    float* bendingAmplitudeUmOut,
    float* microstrainOut
  );
}
