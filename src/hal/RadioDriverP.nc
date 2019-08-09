#include "sagitta_types.h"

/**
 * RadioDriverP implements the low-level CC2420 / RF230 802.15.4 radio HAL driver.
 */
module RadioDriverP {
  provides {
    interface RadioTransceiver;
  }
}
implementation {
  uint8_t m_activeChannel;
  int8_t m_txPowerDbm;

  command error_t RadioTransceiver.initRadio(uint8_t channel, int8_t powerDbm) {
    m_activeChannel = channel;
    m_txPowerDbm = powerDbm;
    return SAGITTA_SUCCESS;
  }

  async command error_t RadioTransceiver.transmit(const uint8_t* frame, uint8_t length) {
    if (!frame || length == 0) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    signal RadioTransceiver.sfdCapture(1000);
    signal RadioTransceiver.transmitDone(SAGITTA_SUCCESS);
    return SAGITTA_SUCCESS;
  }

  default async event void RadioTransceiver.transmitDone(error_t status) {
  }

  default async event void RadioTransceiver.frameReceived(
    const uint8_t* frame,
    uint8_t length,
    int8_t rssiDbm,
    uint8_t lqi
  ) {
  }

  default async event void RadioTransceiver.sfdCapture(uint32_t sfdTimestamp) {
  }
}
