#include "sagitta_types.h"

/**
 * CurrentTransducer interface abstracts high-bandwidth current sensors:
 * split-core current transformers and flexible Rogowski coils.
 */
interface CurrentTransducer {
  /**
   * Reads instantaneous primary current in Amperes.
   * @param currentAOut Pointer to store measured primary current
   * @param isSaturatedOut Pointer to store saturation flag
   * @return SUCCESS if read
   */
  command error_t readPrimaryCurrent(float* currentAOut, bool* isSaturatedOut);

  /**
   * Reads instantaneous derivative di/dt in Amperes per microsecond.
   * @param didtOut Pointer to store current derivative
   * @return SUCCESS if read
   */
  command error_t readCurrentDerivative(float* didtOut);
}
