#include "sagitta_types.h"

/**
 * ProtocolFramer interface serializes and deserializes structured telemetry
 * into standard industrial substation and telemetry protocols.
 */
interface ProtocolFramer {
  /**
   * Encodes state payload into protocol frame.
   * @param inputPayload Pointer to source telemetry struct
   * @param frameBuffer Output byte buffer for framed packet
   * @param maxLen Maximum buffer length
   * @param encodedLengthOut Pointer to store resulting byte length
   * @return SUCCESS if encoded, EOVERFLOW if buffer too small
   */
  command error_t encodeFrame(
    const void* inputPayload,
    uint8_t* frameBuffer,
    uint16_t maxLen,
    uint16_t* encodedLengthOut
  );

  /**
   * Decodes protocol frame into structured payload.
   * @param frameBuffer Input byte buffer containing protocol packet
   * @param frameLen Packet byte length
   * @param outputPayload Pointer to destination struct
   * @return SUCCESS if valid, EINVAL if packet corrupt or bad checksum
   */
  command error_t decodeFrame(
    const uint8_t* frameBuffer,
    uint16_t frameLen,
    void* outputPayload
  );
}
