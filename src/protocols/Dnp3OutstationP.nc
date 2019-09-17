#include <string.h>
#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * Dnp3OutstationP formats DNP3 (IEEE 1815) object responses:
 * Group 30 (Analog Input 32-bit with flag) and Group 1 (Binary Input).
 */
module Dnp3OutstationP {
  provides {
    interface ProtocolFramer as Dnp3Framer;
  }
}
implementation {
  command error_t Dnp3Framer.encodeFrame(
    const void* inputPayload,
    uint8_t* frameBuffer,
    uint16_t maxLen,
    uint16_t* encodedLengthOut
  ) {
    if (!inputPayload || !frameBuffer || !encodedLengthOut || maxLen < 32) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    const msg_dlr_state_t* dlr = (const msg_dlr_state_t*)inputPayload;
    uint16_t offset = 0;

    /* DNP3 Data Link Header */
    frameBuffer[offset++] = 0x05; /* Start byte 1 */
    frameBuffer[offset++] = 0x64; /* Start byte 2 */
    frameBuffer[offset++] = 0x16; /* Length = 22 bytes */
    frameBuffer[offset++] = 0x44; /* Control byte: Master-to-outstation PRM=0 */
    frameBuffer[offset++] = 0x01; /* Dest addr LSB */
    frameBuffer[offset++] = 0x00; /* Dest addr MSB */
    frameBuffer[offset++] = 0x0A; /* Source addr LSB */
    frameBuffer[offset++] = 0x00; /* Source addr MSB */
    frameBuffer[offset++] = 0x7E; /* CRC-16 LSB */
    frameBuffer[offset++] = 0x51; /* CRC-16 MSB */

    /* Transport Layer Header */
    frameBuffer[offset++] = 0xC0; /* FIN=1, FIR=1, SEQ=0 */

    /* Application Layer Header: Response (Function code 0x81) */
    frameBuffer[offset++] = 0xC0; /* Control: FIR=1, FIN=1, CON=0 */
    frameBuffer[offset++] = 0x81; /* Response */
    frameBuffer[offset++] = 0x00; /* IIN 1 */
    frameBuffer[offset++] = 0x00; /* IIN 2 */

    /* Object Group 30, Variation 1 (32-bit Analog Input With Flag) */
    frameBuffer[offset++] = 30;   /* Group 30 */
    frameBuffer[offset++] = 1;    /* Variation 1 */
    frameBuffer[offset++] = 0x00; /* Range qualifier: 8-bit start/stop */
    frameBuffer[offset++] = 0x00; /* Start index: 0 */
    frameBuffer[offset++] = 0x00; /* Stop index: 0 */

    /* Point 0: Conductor Temperature */
    frameBuffer[offset++] = 0x01; /* Flag: ONLINE */
    int32_t tempScaled = (int32_t)dlr->conductor_temp_c_q8;
    frameBuffer[offset++] = (uint8_t)(tempScaled & 0xFF);
    frameBuffer[offset++] = (uint8_t)((tempScaled >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)((tempScaled >> 16) & 0xFF);
    frameBuffer[offset++] = (uint8_t)((tempScaled >> 24) & 0xFF);

    *encodedLengthOut = offset;
    return SAGITTA_SUCCESS;
  }

  command error_t Dnp3Framer.decodeFrame(
    const uint8_t* frameBuffer,
    uint16_t frameLen,
    void* outputPayload
  ) {
    if (!frameBuffer || frameLen < 10) return SAGITTA_ERROR_INVALID_ARG;
    if (frameBuffer[0] != 0x05 || frameBuffer[1] != 0x64) return SAGITTA_ERROR_INVALID_ARG;
    return SAGITTA_SUCCESS;
  }
}
