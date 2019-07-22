#include "sagitta_types.h"
#include "sagitta_config.h"
#include "sagitta_messages.h"

#define TX_QUEUE_CAPACITY 8

/**
 * MacTschP implements linear corridor Time-Slotted Channel Hopping (TSCH),
 * tracking the 64-bit Absolute Slot Number (ASN) and priority transmission queues.
 */
module MacTschP {
  provides {
    interface MacTsch;
  }
  uses {
    interface RadioTransceiver;
  }
}
implementation {
  uint16_t m_slotframeLength;
  uint64_t m_asn;
  bool m_isRunning;

  /* Priority and standard queues */
  uint8_t m_txQueue[TX_QUEUE_CAPACITY][128];
  uint8_t m_txLen[TX_QUEUE_CAPACITY];
  bool m_txPriority[TX_QUEUE_CAPACITY];
  uint8_t m_queueHead;
  uint8_t m_queueTail;
  uint8_t m_queueCount;

  command error_t MacTsch.initTsch(uint16_t slotframeLength) {
    m_slotframeLength = (slotframeLength > 0) ? slotframeLength : TSCH_SLOTFRAME_LENGTH;
    m_asn = 0;
    m_isRunning = TRUE;
    m_queueHead = 0;
    m_queueTail = 0;
    m_queueCount = 0;
    return SAGITTA_SUCCESS;
  }

  async command uint64_t MacTsch.getAbsoluteSlotNumber() {
    uint64_t currentAsn;
    atomic {
      currentAsn = m_asn;
    }
    return currentAsn;
  }

  command error_t MacTsch.sendPacket(const uint8_t* packet, uint8_t length, bool isHighPriority) {
    if (!packet || length == 0 || length > 128) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    atomic {
      if (m_queueCount >= TX_QUEUE_CAPACITY) {
        return SAGITTA_ERROR_OVERFLOW;
      }
      memcpy(m_txQueue[m_queueTail], packet, length);
      m_txLen[m_queueTail] = length;
      m_txPriority[m_queueTail] = isHighPriority;
      m_queueTail = (m_queueTail + 1) % TX_QUEUE_CAPACITY;
      m_queueCount++;
    }

    return SAGITTA_SUCCESS;
  }

  /* Slot tick interrupt handling */
  async event void RadioTransceiver.sfdCapture(uint32_t sfdTimestamp) {
    atomic {
      m_asn++;
    }
  }

  async event void RadioTransceiver.transmitDone(error_t status) {
    const uint8_t* sentPacket = NULL;
    atomic {
      if (m_queueCount > 0) {
        sentPacket = m_txQueue[m_queueHead];
        m_queueHead = (m_queueHead + 1) % TX_QUEUE_CAPACITY;
        m_queueCount--;
      }
    }
    if (sentPacket) {
      signal MacTsch.sendDone(sentPacket, status);
    }
  }

  async event void RadioTransceiver.frameReceived(
    const uint8_t* frame,
    uint8_t length,
    int8_t rssiDbm,
    uint8_t lqi
  ) {
    signal MacTsch.packetReceived(frame, length, rssiDbm, lqi);
  }
}
