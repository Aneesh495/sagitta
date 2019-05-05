#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * MacTsch interface manages Time-Slotted Channel Hopping (TSCH),
 * Absolute Slot Numbers (ASN), and linear corridor transmission schedules.
 */
interface MacTsch {
  /**
   * Initializes the TSCH engine with slotframe size and hopping sequence.
   * @param slotframeLength Number of slots per frame (e.g., 101)
   * @return SUCCESS if initialized
   */
  command error_t initTsch(uint16_t slotframeLength);

  /**
   * Enqueues an outgoing packet into the appropriate TSCH priority queue.
   * @param packet Pointer to packet buffer
   * @param length Packet byte length
   * @param isHighPriority True for travelling wave / emergency alarms
   * @return SUCCESS if enqueued, EOVERFLOW if queue full
   */
  command error_t sendPacket(const uint8_t* packet, uint8_t length, bool isHighPriority);

  /**
   * Event signaled when a packet has been transmitted over the air.
   * @param packet Pointer to packet buffer
   * @param status Transmission result status code
   */
  event void sendDone(const uint8_t* packet, error_t status);

  /**
   * Event signaled when a packet is received during an active slot.
   * @param packet Pointer to received packet buffer
   * @param length Packet byte length
   * @param rssiDbm Received signal strength in dBm
   * @param lqi Link quality indicator
   */
  event void packetReceived(const uint8_t* packet, uint8_t length, int8_t rssiDbm, uint8_t lqi);

  /**
   * Queries the current Absolute Slot Number.
   * @return 64-bit ASN counter
   */
  async command uint64_t getAbsoluteSlotNumber();
}
