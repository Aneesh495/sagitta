#include <string.h>
#include "sagitta_types.h"
#include "sagitta_messages.h"

/**
 * C37118FramerP formats IEEE C37.118-2011 binary synchrophasor data frames.
 * Frame structure: SYNC (0xAA01), FRAMESIZE, IDCODE, SOC, FRACSEC, STAT, PHASORS, FREQ, DFREQ, CHK.
 */
module C37118FramerP {
  provides {
    interface ProtocolFramer as C37118Framer;
  }
}
implementation {
  /* CRC-CCITT (polynomial 0x1021) lookup */
  static uint16_t computeCrcCcitt(const uint8_t* data, uint16_t length) {
    uint16_t crc = 0xFFFF;
    for (uint16_t i = 0; i < length; i++) {
      crc ^= (uint16_t)data[i] << 8;
      for (uint8_t j = 0; j < 8; j++) {
        if (crc & 0x8000) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc <<= 1;
        }
      }
    }
    return crc;
  }

  command error_t C37118Framer.encodeFrame(
    const void* inputPayload,
    uint8_t* frameBuffer,
    uint16_t maxLen,
    uint16_t* encodedLengthOut
  ) {
    if (!inputPayload || !frameBuffer || !encodedLengthOut || maxLen < 32) {
      return SAGITTA_ERROR_INVALID_ARG;
    }

    const msg_synchrophasor_t* pmu = (const msg_synchrophasor_t*)inputPayload;
    uint16_t offset = 0;

    /* SYNC byte 0: 0xAA (fixed), byte 1: Frame type (0x01 = Data Frame 1) */
    frameBuffer[offset++] = 0xAA;
    frameBuffer[offset++] = 0x01;

    /* FRAMESIZE (total frame length in bytes) */
    uint16_t frameSize = 30; /* Header + Time + Phasors + Freq + CRC */
    frameBuffer[offset++] = (uint8_t)((frameSize >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(frameSize & 0xFF);

    /* IDCODE (Stream ID: 101) */
    frameBuffer[offset++] = 0x00;
    frameBuffer[offset++] = 0x65;

    /* SOC: Second of Century (Unix epoch) */
    uint32_t soc = pmu->header.timestamp_s;
    frameBuffer[offset++] = (uint8_t)((soc >> 24) & 0xFF);
    frameBuffer[offset++] = (uint8_t)((soc >> 16) & 0xFF);
    frameBuffer[offset++] = (uint8_t)((soc >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(soc & 0xFF);

    /* FRACSEC: Fraction of second */
    uint32_t fracSec = pmu->header.timestamp_us;
    frameBuffer[offset++] = (uint8_t)((fracSec >> 24) & 0xFF);
    frameBuffer[offset++] = (uint8_t)((fracSec >> 16) & 0xFF);
    frameBuffer[offset++] = (uint8_t)((fracSec >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(fracSec & 0xFF);

    /* STAT: Status flags (0x0000 = valid synchronization) */
    frameBuffer[offset++] = (uint8_t)((pmu->status_flags >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(pmu->status_flags & 0xFF);

    /* PHASOR 1: Voltage (Magnitude 16-bit, Angle 16-bit) */
    uint16_t vMag = (uint16_t)(pmu->v_mag_rms_mv / 100);
    int16_t vAng = (int16_t)pmu->v_phase_rad_q15;
    frameBuffer[offset++] = (uint8_t)((vMag >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(vMag & 0xFF);
    frameBuffer[offset++] = (uint8_t)((vAng >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(vAng & 0xFF);

    /* PHASOR 2: Current (Magnitude 16-bit, Angle 16-bit) */
    uint16_t iMag = (uint16_t)(pmu->i_mag_rms_ma / 100);
    int16_t iAng = (int16_t)pmu->i_phase_rad_q15;
    frameBuffer[offset++] = (uint8_t)((iMag >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(iMag & 0xFF);
    frameBuffer[offset++] = (uint8_t)((iAng >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(iAng & 0xFF);

    /* FREQ: Frequency deviation from nominal (mHz in 16-bit) */
    int16_t fDev = (int16_t)(pmu->frequency_mhz - 60000);
    frameBuffer[offset++] = (uint8_t)((fDev >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(fDev & 0xFF);

    /* DFREQ: ROCOF (mHz/s) */
    frameBuffer[offset++] = (uint8_t)((pmu->rocof_mhz_per_s >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(pmu->rocof_mhz_per_s & 0xFF);

    /* CHK: CRC-CCITT across whole frame */
    uint16_t crc = computeCrcCcitt(frameBuffer, offset);
    frameBuffer[offset++] = (uint8_t)((crc >> 8) & 0xFF);
    frameBuffer[offset++] = (uint8_t)(crc & 0xFF);

    *encodedLengthOut = offset;
    return SAGITTA_SUCCESS;
  }

  command error_t C37118Framer.decodeFrame(
    const uint8_t* frameBuffer,
    uint16_t frameLen,
    void* outputPayload
  ) {
    if (!frameBuffer || frameLen < 16) return SAGITTA_ERROR_INVALID_ARG;
    if (frameBuffer[0] != 0xAA) return SAGITTA_ERROR_INVALID_ARG;
    return SAGITTA_SUCCESS;
  }
}
