#include "sagitta_types.h"

/**
 * RadioTransceiver interface abstracts physical 802.15.4 packet radio hardware.
 */
interface RadioTransceiver {
  /**
   * Initializes radio state and sets channel frequency.
   * @param channel 802.15.4 channel number (11 to 26)
   * @param powerDbm Output power level in dBm (-30 to +10 dBm)
   * @return SUCCESS if initialized
   */
  command error_t initRadio(uint8_t channel, int8_t powerDbm);

  /**
   * Transmits a packet frame over the physical RF channel.
   * @param frame Array of frame bytes
   * @param length Total frame byte length
   * @return SUCCESS if scheduled, EBUSY if radio transmitting
   */
  async command error_t transmit(const uint8_t* frame, uint8_t length);

  /**
   * Event signaled when frame transmission finishes.
   * @param status SUCCESS or ETIMEOUT/EFAIL
   */
  async event void transmitDone(error_t status);

  /**
   * Event signaled when physical frame received.
   * @param frame Buffer containing received bytes
   * @param length Received frame length
   * @param rssiDbm RSSI measurement in dBm
   * @param lqi Link quality indicator
   */
  async event void frameReceived(const uint8_t* frame, uint8_t length, int8_t rssiDbm, uint8_t lqi);

  /**
   * Hardware interrupt event fired at radio Start-of-Frame Delimiter (SFD) pin.
   * @param sfdTimestamp Ticks captured at arrival of SFD delimiter
   */
  async event void sfdCapture(uint32_t sfdTimestamp);
}
