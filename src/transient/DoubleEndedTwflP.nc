#include <math.h>
#include "sagitta_types.h"

/**
 * DoubleEndedTwflP implements double-ended travelling wave fault location:
 * x_f = [L + v * (t_A - t_B)] / 2.
 */
module DoubleEndedTwflP {
  provides {
    interface DoubleEndedTwfl;
  }
}
implementation {
  command error_t DoubleEndedTwfl.solveFaultLocation(
    uint32_t arrivalTimeLeftS,
    uint32_t arrivalTimeLeftNs,
    uint32_t arrivalTimeRightS,
    uint32_t arrivalTimeRightNs,
    float lineLengthM,
    float velocityMps,
    float* faultDistanceMOut
  ) {
    if (!faultDistanceMOut || lineLengthM <= 0.0f || velocityMps <= 0.0f) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    /* Compute time difference delta_t = t_A - t_B in seconds */
    int64_t secDiff = (int64_t)arrivalTimeLeftS - (int64_t)arrivalTimeRightS;
    int64_t nsDiff = (int64_t)arrivalTimeLeftNs - (int64_t)arrivalTimeRightNs;
    double deltaTSec = (double)secDiff + ((double)nsDiff * 1e-9);

    /* x_f = (L + v * delta_t) / 2 */
    double xf = ((double)lineLengthM + (double)velocityMps * deltaTSec) * 0.5;

    /* Boundary clamp check: 0 <= x_f <= L */
    if (xf < 0.0) {
      xf = 0.0;
    } else if (xf > (double)lineLengthM) {
      xf = (double)lineLengthM;
    }

    *faultDistanceMOut = (float)xf;
    return SAGITTA_SUCCESS;
  }
}
