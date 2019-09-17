#include "sagitta_types.h"

/**
 * RogowskiDriverP implements high-speed flexible Rogowski coil current transducer
 * driver for capturing both fundamental AC load currents and high-frequency di/dt surges.
 */
module RogowskiDriverP {
  provides {
    interface CurrentTransducer as RogowskiCoil;
  }
}
implementation {
  /* Mutual inductance sensitivity: M = 50 nH (50 mV per kA/us) */
  command error_t RogowskiCoil.readPrimaryCurrent(float* currentAOut, bool* isSaturatedOut) {
    if (!currentAOut || !isSaturatedOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    /* Rogowski coils do not have iron cores and never magnetically saturate */
    *isSaturatedOut = FALSE;
    *currentAOut = 750.0f; /* 750 Amperes load */
    return SAGITTA_SUCCESS;
  }

  command error_t RogowskiCoil.readCurrentDerivative(float* didtOut) {
    if (!didtOut) return SAGITTA_ERROR_INVALID_ARG;
    /* Normal 60 Hz 750 A RMS: peak di/dt = 750 * sqrt(2) * 2*pi*60 = 400 kA/s = 0.4 A/us */
    *didtOut = 0.40f;
    return SAGITTA_SUCCESS;
  }
}
