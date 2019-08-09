#include "sagitta_types.h"

/**
 * AdcDriverP implements the multi-channel ADC HAL driver for thermistors,
 * CT secondary voltage, and supercapacitor terminal sensing.
 */
module AdcDriverP {
  provides {
    interface SensorAdc;
  }
}
implementation {
  uint16_t m_mockChannelValues[8] = {1200, 2450, 3600, 1850, 0, 0, 0, 0};

  command error_t SensorAdc.readChannel(uint8_t channel, uint16_t* rawValueOut) {
    if (channel >= 8 || !rawValueOut) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    *rawValueOut = m_mockChannelValues[channel];
    signal SensorAdc.dataReady(channel, *rawValueOut);
    return SAGITTA_SUCCESS;
  }

  default async event void SensorAdc.dataReady(uint8_t channel, uint16_t value) {
  }
}
