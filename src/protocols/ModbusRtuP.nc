#include <string.h>
#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * ModbusRtuP implements Modbus RTU serial frame encoding and CRC-16 generation
 * for legacy RTU / SCADA RTU integration.
 */
module ModbusRtuP {
  provides {
    interface ProtocolFramer as ModbusFramer;
  }
}
implementation {
  static uint16_t computeModbusCrc(const uint8_t* buffer, uint16_t length) {
    uint16_t crc = 0xFFFF;
    for (uint16_t pos = 0; pos < length; pos++) {
      crc ^= (uint16_t)buffer[pos];
      for (int i = 8; i != 0; i--) {
        if ((crc & 0x0001) != 0) {
          crc >>= 1;
          crc ^= 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc;
  }

  command error_t ModbusFramer.encodeFrame(
    const void* inputPayload,
    uint8_t* frameBuffer,
    uint16_t maxLen,
    uint16_t* encodedLengthOut
  ) {
    if (!inputPayload || !frameBuffer || !encodedLengthOut || maxLen < 16) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    const msg_dlr_state_t* dlr = (const msg_dlr_state_t*)inputPayload;
    uint16_t offset = 0;

    /* Slave Address */
    frameBuffer[offset++] = 0x01;

    /* Function Code: 0x03 (Read Holding Registers response) */
    frameBuffer[offset++] = 0x03;

    /* Byte Count: 6 bytes (3 registers: Temp, Sagitta, Ampacity) */
    frameBuffer[offset++] = 0x06;

    /* Register 1: Conductor Temp (Q8.8) */
    frameBuffer[offset++] = (uint8_t)((dlr->conductor_temp_c_q8 >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(dlr->conductor_temp_c_q8 & 0xFF);

    /* Register 2: Measured Current (Amperes) */
    frameBuffer[offset++] = (uint8_t)((dlr->measured_current_a >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(dlr->measured_current_a & 0xFF);

    /* Register 3: Dynamic Ampacity (Amperes) */
    frameBuffer[offset++] = (uint8_t)((dlr->current_ampacity_a >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(dlr->current_ampacity_a & 0xFF);

    /* CRC-16 (Low byte first, then high byte) */
    uint16_t crc = computeModbusCrc(frameBuffer, offset);
    frameBuffer[offset++] = (uint8_t)(crc & 0xFF);
    frameBuffer[offset++] = (uint8_t)((crc >> 8) & 0xFF);

    *encodedLengthOut = offset;
    return SAGITTA_SUCCESS;
  }

  command error_t ModbusFramer.decodeFrame(
    const uint8_t* frameBuffer,
    uint16_t frameLen,
    void* outputPayload
  ) {
    if (!frameBuffer || frameLen < 5) return SAGITTA_ERROR_INVALID_ARG;
    uint16_t expectedCrc = computeModbusCrc(frameBuffer, frameLen - 2);
    uint16_t actualCrc = (uint16_t)frameBuffer[frameLen - 2] | ((uint16_t)frameBuffer[frameLen - 1] << 8);
    if (expectedCrc != actualCrc) return SAGITTA_ERROR_GENERIC;
    return SAGITTA_SUCCESS;
  }
}
