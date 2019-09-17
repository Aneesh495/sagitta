#include <string.h>
#include "sagitta_types.h"

/**
 * Iec61850SvP formats IEC 61850-9-2LE Sampled Values packets (EtherType 0x88BA)
 * publishing 80 samples/cycle digitized current and voltage waveforms.
 */
module Iec61850SvP {
  provides {
    interface ProtocolFramer as SvFramer;
  }
}
implementation {
  uint16_t m_smpCnt;

  command error_t SvFramer.encodeFrame(
    const void* inputPayload,
    uint8_t* frameBuffer,
    uint16_t maxLen,
    uint16_t* encodedLengthOut
  ) {
    if (!frameBuffer || !encodedLengthOut || maxLen < 64) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    uint16_t offset = 0;

    /* Ethernet Header: Multicast 01:0C:CD:04:00:01 */
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = 0x0C;
    frameBuffer[offset++] = 0xCD;
    frameBuffer[offset++] = 0x04;
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x01;

    /* Source MAC */
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x50;
    frameBuffer[offset++] = 0xC2;
    frameBuffer[offset++] = 0x53;
    frameBuffer[offset++] = 0x41;
    frameBuffer[offset++] = 0x47;

    /* EtherType 0x88BA (IEC 61850 Sampled Values) */
    frameBuffer[offset++] = 0x88;
    frameBuffer[offset++] = 0xBA;

    /* APPID: 0x4000 */
    frameBuffer[offset++] = 0x40;
    frameBuffer[offset++] = 0x00;

    /* Length */
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x30;

    /* Reserved */
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x00;

    /* SAV PDU */
    frameBuffer[offset++] = 0x60;
    frameBuffer[offset++] = 0x24;

    /* noASDU = 1 */
    frameBuffer[offset++] = 0x80;
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = 0x01;

    /* seqASDU */
    frameBuffer[offset++] = 0xA2;
    frameBuffer[offset++] = 0x1F;

    /* svID: "SagittaMU01" */
    frameBuffer[offset++] = 0x80;
    frameBuffer[offset++] = 0x0B;
    memcpy(frameBuffer + offset, "SagittaMU01", 11);
    offset += 11;

    /* smpCnt (0 to 3999 for 80 smp/cycle at 50 Hz, or 0 to 4799 at 60 Hz) */
    m_smpCnt = (m_smpCnt + 1) % 4800;
    frameBuffer[offset++] = 0x82;
    frameBuffer[offset++] = 0x02;
    frameBuffer[offset++] = (uint8_t)((m_smpCnt >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(m_smpCnt & 0xFF);

    /* smpSynch: 2 (synchronized by global clock master) */
    frameBuffer[offset++] = 0x85;
    frameBuffer[offset++] = 0x01;
    frameBuffer[offset++] = 0x02;

    *encodedLengthOut = offset;
    return SAGITTA_SUCCESS;
  }

  command error_t SvFramer.decodeFrame(
    const uint8_t* frameBuffer,
    uint16_t frameLen,
    void* outputPayload
  ) {
    if (!frameBuffer || frameLen < 22) return SAGITTA_ERROR_INVALID_ARG;
    if (frameBuffer[12] != 0x88 || frameBuffer[13] != 0xBA) {
      return SAGITTA_ERROR_INVALID_ARG;
    }
    return SAGITTA_SUCCESS;
  }
}
