#include <math.h>
#include "sagitta_types.h"

/**
 * Pt100DriverP implements 4-wire RTD platinum thermistor bridge driver
 * using the Callendar-Van Dusen equation: R(T) = R0 * (1 + A * T + B * T^2).
 */
module Pt100DriverP {
  provides {
    interface SensorAdc as Pt100Rtd;
  }
}
implementation {
  /* Callendar-Van Dusen coefficients for DIN IEC 751 platinum RTD */
  static const float A = 3.9083e-3f;
  static const float B = -5.7750e-7f;
  static const float R0 = 100.0f; /* 100 Ohms at 0 deg C */

  command error_t Pt100Rtd.readChannel(uint8_t channel, uint16_t* rawValueOut) {
    if (!rawValueOut) return SAGITTA_ERROR_INVALID_ARG;
    /* Simulate 75 C conductor core temperature:
     * R(75) = 100 * (1 + 3.9083e-3 * 75 - 5.775e-7 * 5625) = 128.98 Ohms
     */
    float r = R0 * (1.0f + A * 75.0f + B * 75.0f * 75.0f);
    *rawValueOut = (uint16_t)(r * 10.0f); /* Scaled in 0.1 Ohm units */
    signal Pt100Rtd.dataReady(channel, *rawValueOut);
    return SAGITTA_SUCCESS;
  }

  default async event void Pt100Rtd.dataReady(uint8_t channel, uint16_t value) {
  }
}
