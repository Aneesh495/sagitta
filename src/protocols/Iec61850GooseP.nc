#include <string.h>
#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * Iec61850GooseP formats IEC 61850 GOOSE (Generic Object Oriented Substation Events)
 * fast protection frames (EtherType 0x88B8) for transmission over substation LANs.
 */
module Iec61850GooseP {
  provides {
    interface ProtocolFramer as GooseFramer;
  }
}
implementation {
  uint32_t m_stNum; /* State number */
  uint32_t m_sqNum; /* Sequence number */

  command error_t GooseFramer.encodeFrame(
    const void* inputPayload,
    uint8_t* frameBuffer,
    uint16_t maxLen,
    uint16_t* encodedLengthOut
  ) {
    if (!inputPayload || !frameBuffer || !encodedLengthOut || maxLen < 64) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    uint16_t offset = 0;

    /* Ethernet Header: Multicast 01:0C:CD:01:00:01 */
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = 0x0C;
    frameBuffer[offset++] = 0xCD;
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x01;

    /* Source MAC: 00:50:C2:53:41:47 ('SAG') */
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x50;
    frameBuffer[offset++] = 0xC2;
    frameBuffer[offset++] = 0x53;
    frameBuffer[offset++] = 0x41;
    frameBuffer[offset++] = 0x47;

    /* EtherType 0x88B8 (IEC 61850 GOOSE) */
    frameBuffer[offset++] = 0x88;
    frameBuffer[offset++] = 0xB8;

    /* APPID: 0x0001 */
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x01;

    /* Length placeholder */
    uint16_t lenPos = offset;
    offset += 2;

    /* Reserved 1 & 2 */
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x00;

    /* GOOSE PDU (ASN.1 BER Tag 0x61) */
    frameBuffer[offset++] = 0x61;
    frameBuffer[offset++] = 0x2A; /* PDU length */

    /* gocbRef: "SagittaDLR/LLN0$GO$gcbTrip" */
    frameBuffer[offset++] = 0x80;
    frameBuffer[offset++] = 0x0C;
    memcpy(frameBuffer + offset, "SagittaTrip", 11);
    offset += 11;

    /* stNum */
    frameBuffer[offset++] = 0x85;
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = (uint8_t)(++m_stNum & 0xFF);

    /* sqNum */
    frameBuffer[offset++] = 0x86;
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = (uint8_t)(++m_sqNum & 0xFF);

    /* allData (dataset boolean states) */
    frameBuffer[offset++] = 0xAB;
    frameBuffer[offset++] = 0x03;
    frameBuffer[offset++] = 0x83; /* Boolean */
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = 0x01; /* Tripped = TRUE */

    /* Patch total length */
    frameBuffer[lenPos] = (uint8_t)((offset >> 8) & 0xFF);
    frameBuffer[lenPos + 1] = (uint8_t)(offset & 0xFF);

    *encodedLengthOut = offset;
    return SAGITTA_SUCCESS;
  }

  command error_t GooseFramer.decodeFrame(
    const uint8_t* frameBuffer,
    uint16_t frameLen,
    void* outputPayload
  ) {
    if (!frameBuffer || frameLen < 22) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    /* Verify EtherType 0x88B8 */
    if (frameBuffer[12] != 0x88 || frameBuffer[13] != 0xB8) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    return SAGITTA_SUCCESS;
  }
}
